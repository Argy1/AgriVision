"""Pra-pemrosesan citra (enhancement) sebelum klasifikasi — satu implementasi untuk training dan serving.

Modul ini dipakai OLEH notebook training (agar eksperimen ablasi) DAN oleh API (kalau varian
terbaik dipasang di produksi), sehingga paritas training/serving terjamin. Semua fungsi
menerima/mengembalikan array RGB uint8 (H, W, 3); deterministik (tanpa acak).

Urutan di serving: decode -> resize ke ukuran model (PIL bilinear) -> enhance -> model.
Pada training, urutan yang sama dipakai saat membuat dataset varian (lihat notebook v3).

Varian (nama -> urutan langkah):
- none          : tanpa enhancement (baseline)
- clahe         : CLAHE pada kanal L (LAB) — menonjolkan bercak, meredam efek pencahayaan buruk
- sog           : normalisasi warna Shades-of-Gray (p=6) — mengoreksi warna cahaya
- unsharp       : unsharp mask — mempertajam tepi/bercak
- bg            : penekanan latar — piksel di luar "wilayah daun" diganti abu-abu netral
- sog_clahe     : sog lalu clahe
- bg_sog_clahe  : bg, sog, lalu clahe
"""

import cv2
import numpy as np

CLAHE_CLIP = 2.0
CLAHE_TILE = 8
SOG_POWER = 6
UNSHARP_SIGMA = 1.5
UNSHARP_AMOUNT = 0.8
BG_NEUTRAL = 128
BG_DILATE_FRACTION = 0.025

# Penekanan latar dibatalkan bila segmentasi jelas gagal (hampir tak ada / hampir semua piksel "daun").
BG_MIN_REGION = 0.05
BG_MAX_REGION = 0.97

VARIANTS = {
    "none": [],
    "clahe": ["clahe"],
    "sog": ["sog"],
    "unsharp": ["unsharp"],
    "bg": ["bg"],
    "sog_clahe": ["sog", "clahe"],
    "bg_sog_clahe": ["bg", "sog", "clahe"],
}


def clahe(image: np.ndarray) -> np.ndarray:
    lab = cv2.cvtColor(image, cv2.COLOR_RGB2LAB)
    engine = cv2.createCLAHE(clipLimit=CLAHE_CLIP, tileGridSize=(CLAHE_TILE, CLAHE_TILE))
    lab[..., 0] = engine.apply(lab[..., 0])
    return cv2.cvtColor(lab, cv2.COLOR_LAB2RGB)


def shades_of_gray(image: np.ndarray) -> np.ndarray:
    pixels = image.astype(np.float64) / 255.0
    illuminant = np.power(np.mean(np.power(pixels, SOG_POWER), axis=(0, 1)), 1.0 / SOG_POWER)
    illuminant = np.maximum(illuminant, 1e-6)
    scale = illuminant.mean() / illuminant
    return np.clip(pixels * scale * 255.0, 0, 255).astype(np.uint8)


def unsharp(image: np.ndarray) -> np.ndarray:
    blurred = cv2.GaussianBlur(image, (0, 0), UNSHARP_SIGMA)
    sharpened = cv2.addWeighted(image, 1.0 + UNSHARP_AMOUNT, blurred, -UNSHARP_AMOUNT, 0)
    return sharpened


def suppress_background(image: np.ndarray) -> np.ndarray:
    # Import di dalam fungsi: modul cv hanya butuh numpy/cv2, tapi tidak perlu dimuat bila varian tak dipakai.
    from app.cv.affected_area import detect_lesion_mask
    from app.cv.leaf_region import split_lesion_and_nonleaf
    from app.cv.segmentation import segment_vegetation

    green = segment_vegetation(image.astype(np.float32) / 255.0)
    _lesion, _nonleaf, region = split_lesion_and_nonleaf(image, detect_lesion_mask(image), green)
    fraction = float(region.mean())
    if fraction < BG_MIN_REGION or fraction > BG_MAX_REGION:
        return image
    # Lebarkan supaya bercak di tepi daun (dekat hijau) tidak ikut terhapus.
    radius = max(2, int(round(BG_DILATE_FRACTION * min(image.shape[:2]))))
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (2 * radius + 1, 2 * radius + 1))
    region = cv2.dilate(region.astype(np.uint8), kernel) > 0
    output = image.copy()
    output[~region] = BG_NEUTRAL
    return output


_STEPS = {
    "clahe": clahe,
    "sog": shades_of_gray,
    "unsharp": unsharp,
    "bg": suppress_background,
}


def apply_variant(image: np.ndarray, name: str) -> np.ndarray:
    """Terapkan varian enhancement `name` (kunci VARIANTS) pada gambar RGB uint8."""
    if name not in VARIANTS:
        raise ValueError(f"varian enhancement tidak dikenal: {name!r}")
    if image.dtype != np.uint8 or image.ndim != 3 or image.shape[2] != 3:
        raise ValueError("gambar harus RGB uint8 (H, W, 3)")
    output = image
    for step in VARIANTS[name]:
        output = _STEPS[step](output)
    return output
