from fastapi import APIRouter

from app.ml.labels import get_model_version
from app.ml.model_loader import model_registry
from app.schemas import HealthResponse

router = APIRouter(prefix="/api", tags=["health"])


@router.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    return HealthResponse(
        status="ok",
        model_loaded=model_registry.is_loaded,
        model_version=get_model_version("tomat") if model_registry.is_loaded else "unknown",
    )
