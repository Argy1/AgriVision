from typing import Literal, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class DiagnoseRequest(BaseModel):
    upload_id: UUID
    image_path: str
    crop_type: Literal["tomat", "cabai"]


class DiagnosisResult(BaseModel):
    id: UUID
    disease_label: str
    disease_name: str
    confidence: float
    severity: Literal["ringan", "sedang", "parah"]
    affected_area_pct: float


class VegetationIndexResult(BaseModel):
    exg_score: float
    vari_score: float
    health_score: float


class RecommendationResult(BaseModel):
    recommendation_text: str
    dosage: Optional[str] = None
    application_schedule: Optional[str] = None
    warning_note: Optional[str] = None


class DiagnoseResponse(BaseModel):
    diagnosis: DiagnosisResult
    vegetation_index: VegetationIndexResult
    recommendation: RecommendationResult


class HealthResponse(BaseModel):
    model_config = ConfigDict(protected_namespaces=())

    status: str
    model_loaded: bool
    model_version: str
