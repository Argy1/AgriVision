import cv2
import numpy as np

# Rentang hue kecoklatan/kekuningan (bercak/lesi umum pada daun tomat & cabai) di ruang
# HSV OpenCV (H: 0-179). Saturasi/value minimum dinaikkan (bukan cuma di atas nol) supaya
# tidak ikut menangkap background gelap/kusam bernuansa coklat (tanah, meja kayu) sebagai
# lesi — warna lesi asli biasanya lebih terang & jenuh karena permukaan daun yang mengkilap.
# PLACEHOLDER: seperti kalibrasi vegetation_index, rentang ini masih heuristik dan perlu
# divalidasi manual terhadap foto daun sakit asli (idealnya dengan latar netral) sebelum
# dipakai untuk laporan akhir — lihat catatan keterbatasan di analyzer.py.
_LESION_HSV_LOWER = np.array([8, 60, 60])
_LESION_HSV_UPPER = np.array([35, 255, 255])


def detect_lesion_mask(image_rgb_uint8: np.ndarray) -> np.ndarray:
    """Deteksi piksel bercak/lesi (kecoklatan/kekuningan) lewat threshold HSV."""
    bgr = cv2.cvtColor(image_rgb_uint8, cv2.COLOR_RGB2BGR)
    hsv = cv2.cvtColor(bgr, cv2.COLOR_BGR2HSV)
    return cv2.inRange(hsv, _LESION_HSV_LOWER, _LESION_HSV_UPPER) > 0


def compute_affected_area_pct(lesion_mask: np.ndarray, leaf_mask: np.ndarray) -> float:
    """affected_area_pct = proporsi piksel lesi terhadap total area daun.

    leaf_mask di sini HARUS berupa union piksel hijau sehat + piksel lesi (lihat
    analyzer.py) — bukan cuma piksel hijau. Jaringan yang sudah rusak/nekrotik biasanya
    justru punya ExG rendah (mirip background), jadi kalau leaf_mask hanya dari ExG,
    area yang paling parah kena penyakit malah bisa salah terhitung sebagai "background"
    dan hilang dari penyebut.
    """
    total_leaf_px = int(leaf_mask.sum())
    if total_leaf_px == 0:
        return 0.0
    affected_px = int(np.logical_and(lesion_mask, leaf_mask).sum())
    return (affected_px / total_leaf_px) * 100
