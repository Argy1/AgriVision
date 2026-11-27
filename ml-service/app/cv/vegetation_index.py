import numpy as np

from app.cv.segmentation import compute_exg

# health_score 0-100 = VARI rata-rata piksel daun, dipetakan linear dari _VARI_MIN (0) ke
# _VARI_MAX (100). Dikalibrasi 2026-11-28 dengan foto kebun berlabel Tomato-Village
# (scripts/kalibrasi_cv.py; batas dari train+val, dicek di test):
#   _VARI_MIN = persentil 5 VARI daun sakit, _VARI_MAX = persentil 90 VARI daun sehat.
# VARI dipilih karena memisahkan sehat vs sakit jauh lebih baik daripada ExG (AUC 0,947 vs 0,799).
# Hasil di data uji (median): sehat 88, early blight 72, late blight 29 (dulu dengan ExG
# -0,2..0,6: 64 / 63 / 46). Data kalibrasi hanya 3 kelas dari satu sumber (India) -> perlu
# dicek ulang dengan foto kebun sendiri. exg_score tetap dihitung dan dikirim seperti biasa.
_VARI_MIN = -0.13
_VARI_MAX = 0.22


def _compute_vari(image_rgb_float01: np.ndarray) -> np.ndarray:
    """VARI = (G - R) / (G + R - B) (Gitelson et al. 2002).

    Penyebut (G+R-B) bisa mendekati nol per piksel (mis. highlight terlalu terang atau
    bayangan gelap), yang membuat VARI meledak jadi nilai ekstrem pada piksel itu saja dan
    merusak rata-rata keseluruhan meski cuma satu piksel outlier. Piksel dengan penyebut
    mendekati nol di-treat sebagai 0 (bukan sekadar dijaga dari exact-zero), dan hasilnya
    di-clip ke rentang VARI yang bermakna secara fisik untuk vegetasi.
    """
    r, g, b = image_rgb_float01[..., 0], image_rgb_float01[..., 1], image_rgb_float01[..., 2]
    denom = g + r - b
    safe = np.abs(denom) > 1e-3
    with np.errstate(divide="ignore", invalid="ignore"):
        vari = np.where(safe, (g - r) / np.where(safe, denom, 1.0), 0.0)
    return np.clip(vari, -1.0, 1.0)


def compute_vegetation_index(image_rgb_float01: np.ndarray, leaf_mask: np.ndarray) -> dict:
    """Hitung ExG/VARI rata-rata hanya pada piksel tanaman (leaf_mask), lalu normalisasi
    VARI ke health_score 0-100 (lihat kalibrasi di atas).
    """
    if not leaf_mask.any():
        # Tidak ada piksel tanaman terdeteksi (foto gagal/background dominan) -> fallback netral.
        return {"exg_score": 0.0, "vari_score": 0.0, "health_score": 0.0}

    exg = compute_exg(image_rgb_float01)
    vari = _compute_vari(image_rgb_float01)

    mean_exg = float(exg[leaf_mask].mean())
    mean_vari = float(vari[leaf_mask].mean())

    normalized = (mean_vari - _VARI_MIN) / (_VARI_MAX - _VARI_MIN) * 100
    health_score = float(np.clip(normalized, 0, 100))

    return {
        "exg_score": round(mean_exg, 3),
        "vari_score": round(mean_vari, 3),
        "health_score": round(health_score, 2),
    }
