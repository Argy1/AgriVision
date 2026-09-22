import json
from functools import lru_cache
from pathlib import Path
from typing import Literal

from app.config import settings

CropKey = Literal["tomato", "chili"]

# Jembatan antara nilai crop_type di API contract (Indonesia, sesuai enum Postgres)
# dengan key bahasa Inggris yang dipakai di label_map.json / nama file model.
CROP_TYPE_TO_KEY: dict[str, CropKey] = {"tomat": "tomato", "cabai": "chili"}


@lru_cache
def _load_label_map() -> dict:
    path = Path(settings.model_dir) / "label_map.json"
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def get_crop_key(crop_type: str) -> CropKey:
    try:
        return CROP_TYPE_TO_KEY[crop_type]
    except KeyError as exc:
        raise ValueError(f"crop_type tidak valid: {crop_type!r}") from exc


def get_img_size(crop_type: str) -> tuple[int, int]:
    key = get_crop_key(crop_type)
    width, height = _load_label_map()[key]["img_size"]
    return width, height


def get_class_by_index(crop_type: str, index: int) -> dict:
    key = get_crop_key(crop_type)
    return _load_label_map()[key]["classes"][index]


def get_model_version(crop_type: str) -> str:
    key = get_crop_key(crop_type)
    return _load_label_map()[key]["model_version"]
