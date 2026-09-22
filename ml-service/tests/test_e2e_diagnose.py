"""Test integrasi end-to-end untuk POST /api/diagnose melawan project Supabase asli
(AgriVision, org "Kuliah"). Butuh ml-service/.env terisi (SUPABASE_SERVICE_ROLE_KEY asli)
-- ini BUKAN unit test yang jalan tanpa jaringan, sengaja dipisah dari suite unit test biasa.

Alur: buat user + zona + foto + baris upload sungguhan lewat client "sebagai user" (supaya
RLS insert beneran teruji), panggil /api/diagnose dengan access_token asli user tsb, lalu
verifikasi hasilnya benar-benar tersimpan di database. Semua data uji dibersihkan di akhir
(hapus user -> cascade menghapus profile/zona/upload/diagnosis/dst sesuai FK di schema.sql).

Jalankan dari folder ml-service/:
    .venv/Scripts/python.exe -m pytest tests/test_e2e_diagnose.py -v -s
"""

import io
import os
import secrets

from dotenv import load_dotenv
from fastapi.testclient import TestClient
from PIL import Image, ImageDraw
from supabase import create_client

from app.config import settings
from app.supabase_client import get_client

# pydantic-settings (app.config) memuat .env ke dalam objek Settings-nya sendiri, bukan ke
# os.environ global -- load_dotenv() di sini supaya SUPABASE_ANON_KEY juga bisa dibaca lewat
# os.environ tanpa perlu hardcode nilainya (bukan secret, tapi tetap bukan untuk di-commit
# sebagai literal JWT di kode).
load_dotenv()
_ANON_KEY = os.environ["SUPABASE_ANON_KEY"]


def _make_test_jpeg() -> bytes:
    image = Image.new("RGB", (300, 300), (40, 30, 20))
    draw = ImageDraw.Draw(image)
    draw.ellipse((50, 50, 250, 250), fill=(40, 160, 40))  # 'daun' hijau di tengah
    buf = io.BytesIO()
    image.save(buf, format="JPEG")
    return buf.getvalue()


def test_diagnose_end_to_end():
    admin = get_client()  # service role, dari app.supabase_client (settings dari .env)
    anon = create_client(settings.supabase_url, _ANON_KEY)

    email = f"e2e-test-{secrets.token_hex(6)}@agrivision-test.local"
    password = secrets.token_urlsafe(16)

    user_id = None
    image_path = None
    try:
        # 1. Buat test user (email fiktif, langsung confirmed lewat admin API)
        created = admin.auth.admin.create_user(
            {
                "email": email,
                "password": password,
                "email_confirm": True,
                "user_metadata": {"full_name": "E2E Test User"},
            }
        )
        user_id = created.user.id

        # 2. Sign-in sebagai user itu -> access_token asli, persis seperti dari frontend
        session = anon.auth.sign_in_with_password({"email": email, "password": password})
        access_token = session.session.access_token
        anon.auth.set_session(access_token, session.session.refresh_token)

        # 3. Buat zona milik user ini lewat client user (exercise RLS zones_insert_own)
        zone = (
            anon.table("zones")
            .insert({"name": "Zona Uji E2E", "crop_type": "tomat", "owner_id": user_id})
            .execute()
            .data[0]
        )

        # 4. Upload foto uji lewat client user (exercise storage RLS plant_photos_insert_own)
        image_path = f"{user_id}/{zone['id']}/e2e_test.jpg"
        anon.storage.from_(settings.storage_bucket).upload(
            image_path, _make_test_jpeg(), {"content-type": "image/jpeg"}
        )

        # 5. Buat baris uploads lewat client user (exercise RLS uploads_insert)
        upload = (
            anon.table("uploads")
            .insert({"zone_id": zone["id"], "uploaded_by": user_id, "image_path": image_path})
            .execute()
            .data[0]
        )

        # 6. Panggil /api/diagnose sungguhan (model asli, Storage asli, DB asli)
        import app.main as main_module

        with TestClient(main_module.app) as client:
            response = client.post(
                "/api/diagnose",
                headers={"Authorization": f"Bearer {access_token}"},
                json={"upload_id": upload["id"], "image_path": image_path, "crop_type": "tomat"},
            )

        assert response.status_code == 200, response.text
        body = response.json()
        assert body["diagnosis"]["disease_label"].startswith("tomato_")
        assert 0 <= body["diagnosis"]["confidence"] <= 1
        assert body["diagnosis"]["severity"] in ("ringan", "sedang", "parah")
        assert body["recommendation"]["recommendation_text"]
        assert 0 <= body["vegetation_index"]["health_score"] <= 100

        # 7. Verifikasi hasil benar-benar tersimpan di database (bukan cuma di response)
        saved = (
            admin.table("diagnoses")
            .select("*")
            .eq("upload_id", upload["id"])
            .single()
            .execute()
            .data
        )
        assert saved["disease_label"] == body["diagnosis"]["disease_label"]

        print("\nDiagnosis:", body["diagnosis"])
        print("Vegetation index:", body["vegetation_index"])
    finally:
        if image_path:
            try:
                admin.storage.from_(settings.storage_bucket).remove([image_path])
            except Exception:
                pass
        if user_id:
            admin.auth.admin.delete_user(user_id)  # cascade: profile/zone/upload/diagnosis/dst
