import cv2
import numpy as np


_MIN_EXG_FOR_VEGETATION = 0.02  # ExG absolut minimum agar piksel dianggap vegetasi


def compute_exg(image_rgb_float01: np.ndarray) -> np.ndarray:
    """ExG = 2G - R - B, dengan R/G/B dinormalisasi ke 0-1 (Woebbecke et al. 1995)."""
    r, g, b = image_rgb_float01[..., 0], image_rgb_float01[..., 1], image_rgb_float01[..., 2]
    return 2 * g - r - b


def segment_vegetation(image_rgb_float01: np.ndarray) -> np.ndarray:
    """Pisahkan piksel tanaman dari background pakai ExG + threshold Otsu.

    ExG sendiri sudah efektif memisahkan vegetasi dari background (Woebbecke et al. 1995).
    Otsu dipakai supaya ambang batas adaptif terhadap pencahayaan tiap foto, bukan angka
    tetap yang mudah meleset pada kondisi lapangan yang bervariasi.
    """
    exg = compute_exg(image_rgb_float01)
    # ExG teoretis berkisar [-2, 2] -> normalisasi ke 0-255 supaya bisa dipakai cv2.threshold.
    exg_uint8 = np.clip((exg + 2) / 4 * 255, 0, 255).astype(np.uint8)
    _, mask = cv2.threshold(exg_uint8, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    # Otsu pada gambar yang hampir seragam (dinding polos, foto gelap/terang) menghasilkan
    # ambang ~0 sehingga SEMUA piksel jadi "tanaman". Syarat ExG minimum mencegahnya.
    return mask.astype(bool) & (exg > _MIN_EXG_FOR_VEGETATION)
