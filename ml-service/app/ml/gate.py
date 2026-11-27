"""Penyaring daun tomat (model v9.1): menolak foto yang bukan daun tomat SEBELUM diagnosis.

Model diagnosis (10 kelas) selalu menjawab salah satu penyakit tomat, bahkan untuk daun cabai
atau foto tembok (mis. daun cabai pernah didiagnosis "Sehat 99%"). Penyaring ini adalah model
MobileNetV2 biner terpisah yang mengeluarkan peluang "daun tomat" (p_tomat, 0-1). Foto dengan
p_tomat di bawah ambang ditolak (400) dan tidak disimpan.

Multi-crop (OPSIONAL, bawaan mati): foto utuh + 6 potongan persegi (app/ml/crops.py) dinilai
semua; foto diterima bila potongan TERBAIK >= ambang multi-crop, dan diagnosis memakai
potongan-potongan yang lolos. Pada data uji v9.1 cara ini tidak lebih baik dari foto utuh
(potongan foto cabai ikut lolos), jadi bawaannya mati; foto ramai ditangani lewat langkah
potong foto oleh pengguna di web/app. Angka lengkap ada di models/gate_config.json.

Env: GATE_THRESHOLD menimpa ambang; GATE_MULTICROP=1 menyalakan multi-crop.
"""

import json
import os
from dataclasses import dataclass, field
from functools import lru_cache
from pathlib import Path

import numpy as np
from PIL import Image

from app.config import settings
from app.ml.crops import make_crops
from app.ml.model_loader import model_registry


@lru_cache
def gate_config() -> dict:
    path = Path(settings.model_dir) / "gate_config.json"
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def multicrop_enabled() -> bool:
    """Bawaan MATI (gate_config.json "multicrop_default": false): pada data uji v9.1, multi-crop
    tidak lebih baik dari foto utuh (potongan foto cabai ikut lolos). Pemotongan oleh pengguna di
    web/app sudah membuat "foto utuh" yang dinilai berupa bagian daun yang dipilih."""
    cfg = gate_config()
    if "threshold_multicrop" not in cfg:
        return False
    env = os.getenv("GATE_MULTICROP", "").strip().lower()
    if env:
        return env in ("1", "true", "yes", "ya")
    return bool(cfg.get("multicrop_default", False))


def gate_threshold() -> float:
    override = os.getenv("GATE_THRESHOLD")
    if override:
        return float(override)
    cfg = gate_config()
    return float(cfg["threshold_multicrop"] if multicrop_enabled() else cfg["threshold"])


@dataclass(frozen=True, eq=False)
class GateResult:
    p_tomat: float  # peluang tertinggi di antara foto utuh/potongan yang dinilai
    threshold: float
    accepted_crops: tuple = field(default=())  # foto/potongan (RGB uint8) dengan p_tomat >= ambang
    multicrop: bool = False

    @property
    def is_tomato(self) -> bool:
        return self.p_tomat >= self.threshold

    def reject_detail(self) -> str:
        return (
            "Foto ini tidak dikenali sebagai daun tomat "
            f"(kemiripan dengan daun tomat {self.p_tomat * 100:.0f}%). AgriVision hanya dapat "
            "mendiagnosis daun tomat. Pastikan yang difoto daun tomat, ambil dari dekat, lalu coba lagi."
        )


def _p_tomat(image_rgb_uint8: np.ndarray) -> float:
    width, height = gate_config()["img_size"]
    resized = Image.fromarray(np.ascontiguousarray(image_rgb_uint8)).resize((width, height), Image.BILINEAR)
    # Input mentah 0-255 float32: preprocessing MobileNetV2 sudah ada di dalam graf model
    # (sama dengan model diagnosis) -- JANGAN dibagi 255.
    batched = np.expand_dims(np.asarray(resized, dtype=np.float32), axis=0)
    return float(np.ravel(model_registry.predict("gate", batched))[0])


def check_tomato(image_rgb_uint8: np.ndarray) -> GateResult:
    """Jalankan penyaring pada foto (RGB uint8, ukuran bebas)."""
    threshold = gate_threshold()
    multicrop = multicrop_enabled()
    candidates = make_crops(image_rgb_uint8) if multicrop else [image_rgb_uint8]
    scores = [_p_tomat(c) for c in candidates]
    accepted = tuple(c for c, p in zip(candidates, scores) if p >= threshold)
    # p_tomat TIDAK dibulatkan: keputusan is_tomato harus konsisten dengan accepted_crops.
    return GateResult(p_tomat=max(scores), threshold=threshold, accepted_crops=accepted, multicrop=multicrop)
