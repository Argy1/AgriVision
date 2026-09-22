import numpy as np

from app.cv.segmentation import compute_exg

# Kalibrasi awal rentang ExG mentah -> health_score 0-100.
# PLACEHOLDER: sesuai 05-ml-pipeline.md, ini wajib divalidasi manual terhadap foto sehat
# vs sakit (roadmap minggu 5, 06-roadmap.md) dan disesuaikan berdasarkan distribusi nilai
# ExG riil dari data training/lapangan sebelum dipakai untuk laporan akhir.
_EXG_MIN = -0.2
_EXG_MAX = 0.6


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
    ExG ke health_score 0-100.
    """
    if not leaf_mask.any():
        # Tidak ada piksel tanaman terdeteksi (foto gagal/background dominan) -> fallback netral.
        return {"exg_score": 0.0, "vari_score": 0.0, "health_score": 0.0}

    exg = compute_exg(image_rgb_float01)
    vari = _compute_vari(image_rgb_float01)

    mean_exg = float(exg[leaf_mask].mean())
    mean_vari = float(vari[leaf_mask].mean())

    normalized = (mean_exg - _EXG_MIN) / (_EXG_MAX - _EXG_MIN) * 100
    health_score = float(np.clip(normalized, 0, 100))

    return {
        "exg_score": round(mean_exg, 3),
        "vari_score": round(mean_vari, 3),
        "health_score": round(health_score, 2),
    }
