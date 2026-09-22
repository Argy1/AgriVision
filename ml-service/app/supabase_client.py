from functools import lru_cache
from typing import Optional

from supabase import Client, create_client

from app.config import settings


@lru_cache
def get_client() -> Client:
    # Service role key — bypass RLS by design (lihat 03-database-schema.md).
    # Dipakai hanya di sini, di server, tidak pernah dikirim ke frontend.
    return create_client(settings.supabase_url, settings.supabase_service_role_key)


def download_image(image_path: str) -> bytes:
    return get_client().storage.from_(settings.storage_bucket).download(image_path)


def get_upload_with_zone(upload_id: str) -> Optional[dict]:
    result = (
        get_client()
        .table("uploads")
        .select("id, zone_id, uploaded_by, zones(id, owner_id, crop_type)")
        .eq("id", upload_id)
        .maybe_single()
        .execute()
    )
    return result.data if result else None


def get_profile_role(user_id: str) -> Optional[str]:
    result = (
        get_client()
        .table("profiles")
        .select("role")
        .eq("id", user_id)
        .maybe_single()
        .execute()
    )
    return result.data["role"] if result and result.data else None


def get_disease_reference(disease_label: str) -> Optional[dict]:
    result = (
        get_client()
        .table("disease_reference")
        .select("*")
        .eq("disease_label", disease_label)
        .maybe_single()
        .execute()
    )
    return result.data if result else None


def insert_diagnosis(payload: dict) -> dict:
    result = get_client().table("diagnoses").insert(payload).execute()
    return result.data[0]


def insert_vegetation_index(payload: dict) -> dict:
    result = get_client().table("vegetation_index_readings").insert(payload).execute()
    return result.data[0]


def insert_recommendation(payload: dict) -> dict:
    result = get_client().table("recommendations").insert(payload).execute()
    return result.data[0]


def get_user_from_token(access_token: str):
    """Validasi access token ke Supabase Auth (GoTrue). Melempar exception kalau invalid."""
    response = get_client().auth.get_user(access_token)
    return response.user if response else None
