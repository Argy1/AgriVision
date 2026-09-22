import logging

from fastapi import Header, HTTPException, status

from app.supabase_client import get_user_from_token

logger = logging.getLogger(__name__)


def get_current_user_id(authorization: str = Header(...)) -> str:
    """Dependency FastAPI: validasi header 'Authorization: Bearer <supabase_access_token>'
    ke Supabase Auth (04-api-contract.md) dan kembalikan user id.
    """
    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Header Authorization harus berupa 'Bearer <token>'",
        )
    token = authorization.removeprefix("Bearer ").strip()

    try:
        user = get_user_from_token(token)
    except Exception:
        logger.exception("Gagal validasi token ke Supabase Auth")
        user = None

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token tidak valid atau kedaluwarsa",
        )
    return user.id
