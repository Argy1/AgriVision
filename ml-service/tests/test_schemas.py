"""Tes offline (tanpa jaringan/.env) untuk kontrak request /api/diagnose."""

import pytest
from pydantic import ValidationError

from app.schemas import DiagnoseRequest

_VALID = {
    "upload_id": "00000000-0000-0000-0000-000000000001",
    "image_path": "user/zone/foto.jpg",
}


def test_crop_type_tomat_diterima():
    assert DiagnoseRequest(**_VALID, crop_type="tomat").crop_type == "tomat"


@pytest.mark.parametrize("crop", ["cabai", "chili", "padi", ""])
def test_crop_type_selain_tomat_ditolak(crop):
    # Proyek fokus ke tomat saja; FastAPI memetakan ValidationError ini ke HTTP 422.
    with pytest.raises(ValidationError):
        DiagnoseRequest(**_VALID, crop_type=crop)
