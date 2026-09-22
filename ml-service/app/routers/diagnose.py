import logging

from fastapi import APIRouter, Depends, HTTPException, status

from app import supabase_client as db
from app.auth import get_current_user_id
from app.cv.analyzer import analyze_image
from app.imaging import decode_image
from app.ml.inference import classify
from app.ml.labels import get_crop_key
from app.schemas import (
    DiagnoseRequest,
    DiagnoseResponse,
    DiagnosisResult,
    RecommendationResult,
    VegetationIndexResult,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api", tags=["diagnose"])


@router.post("/diagnose", response_model=DiagnoseResponse)
def diagnose(
    payload: DiagnoseRequest, user_id: str = Depends(get_current_user_id)
) -> DiagnoseResponse:
    # --- Validasi crop_type (400) ---
    try:
        get_crop_key(payload.crop_type)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="crop_type tidak valid (harus 'tomat' atau 'cabai')",
        )

    # --- Otorisasi: pemilik zona terkait, atau admin_ppl (403) ---
    upload = db.get_upload_with_zone(str(payload.upload_id))
    if upload is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="upload_id tidak ditemukan"
        )

    zone = upload.get("zones")
    role = db.get_profile_role(user_id)
    is_owner = bool(zone) and zone.get("owner_id") == user_id
    is_admin = role == "admin_ppl"
    if not (is_owner or is_admin):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Anda bukan pemilik zona ini dan bukan admin_ppl",
        )

    # --- 1. Ambil foto dari Supabase Storage (400 kalau tidak ditemukan) ---
    try:
        image_bytes = db.download_image(payload.image_path)
    except Exception:
        logger.exception("Gagal mengambil foto dari Storage: %s", payload.image_path)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="image_path tidak ditemukan di Storage",
        )

    try:
        image_rgb = decode_image(image_bytes)
    except Exception:
        logger.exception("Gagal decode gambar: %s", payload.image_path)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="File di image_path bukan gambar valid"
        )

    # --- 2-3. Preprocess + jalankan model CNN -> disease_label, confidence ---
    try:
        classification = classify(payload.crop_type, image_rgb)
    except Exception:
        logger.exception("Inference model gagal untuk crop_type=%s", payload.crop_type)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Gagal menjalankan model inference"
        )

    # --- 4-6. affected_area_pct, severity, ExG/VARI (classical CV) ---
    try:
        cv_result = analyze_image(image_rgb)
    except Exception:
        logger.exception("Analisis classical CV gagal")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Gagal menghitung vegetation index / affected area",
        )

    # --- 7. Lookup disease_reference ---
    reference = db.get_disease_reference(classification["disease_label"])
    if reference is None:
        logger.error("disease_label '%s' tidak ditemukan di disease_reference", classification["disease_label"])
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Referensi penyakit tidak ditemukan untuk hasil diagnosis ini",
        )

    # --- 8. Simpan hasil (service role key, bypass RLS) ---
    try:
        diagnosis_row = db.insert_diagnosis(
            {
                "upload_id": str(payload.upload_id),
                "disease_label": classification["disease_label"],
                "disease_name": reference["disease_name"],
                "confidence": classification["confidence"],
                "severity": cv_result["severity"],
                "affected_area_pct": cv_result["affected_area_pct"],
                "model_version": classification["model_version"],
            }
        )
        db.insert_vegetation_index(
            {
                "upload_id": str(payload.upload_id),
                **cv_result["vegetation_index"],
            }
        )
        db.insert_recommendation(
            {
                "diagnosis_id": diagnosis_row["id"],
                "recommendation_text": reference["recommendation_text"],
                "dosage": reference.get("dosage"),
                "application_schedule": reference.get("application_schedule"),
                "warning_note": reference.get("warning_note"),
            }
        )
    except Exception:
        logger.exception("Gagal menyimpan hasil diagnosis ke database")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Gagal menyimpan hasil diagnosis"
        )

    # --- 9. Response gabungan ---
    return DiagnoseResponse(
        diagnosis=DiagnosisResult(
            id=diagnosis_row["id"],
            disease_label=classification["disease_label"],
            disease_name=reference["disease_name"],
            confidence=classification["confidence"],
            severity=cv_result["severity"],
            affected_area_pct=cv_result["affected_area_pct"],
        ),
        vegetation_index=VegetationIndexResult(**cv_result["vegetation_index"]),
        recommendation=RecommendationResult(
            recommendation_text=reference["recommendation_text"],
            dosage=reference.get("dosage"),
            application_schedule=reference.get("application_schedule"),
            warning_note=reference.get("warning_note"),
        ),
    )
