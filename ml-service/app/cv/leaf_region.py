"""Pisahkan piksel "lesi" asli dari objek non-daun yang kebetulan berwarna sama.

Ambang HSV lesi (kecoklatan/kekuningan) juga menangkap kulit tangan, kayu/ajir, tanah,
tangkai, dan buah tomat jingga. Pada foto close-up lab itu tidak muncul, tapi pada foto
lapangan (daun dipegang tangan, buah dan ajir di latar) luas terdampak bisa membengkak
jadi 30-50% pada daun yang tampak sehat. Heuristik di sini mengurangi (bukan
menghilangkan) masalah itu:

1. Piksel berwarna buah matang (jingga jenuh & terang) bukan lesi.
2. "Wilayah daun" = piksel hijau yang ditutup secara morfologis (celah kecil terisi) dan
   lubang yang dikelilingi hijau diisi. Piksel berwarna lesi HANYA dihitung bila berada di
   dalam wilayah daun; yang di luar (tangan, ajir, tanah) dianggap non-daun.
3. Pembukaan morfologi kecil membuang garis tipis (tangkai, tepi daun) dari mask lesi.

Keterbatasan yang diketahui: nekrosis yang terbuka ke tepi daun dan jauh dari piksel hijau
bisa terpotong (luas terdampak terlalu kecil); jari/buah/daun lain yang terkurung hijau
tetap bisa terhitung. Semua ambang bersifat heuristik dan belum divalidasi terhadap
anotasi pakar.
"""

import cv2
import numpy as np

# Buah matang: jingga jenuh & terang. Lesi tomat biasanya lebih kusam (cokelat/kuning pucat).
_FRUIT_HSV_LOWER = np.array([5, 170, 170])
_FRUIT_HSV_UPPER = np.array([22, 255, 255])

_CLOSE_RADIUS_FRACTION = 0.03  # radius penutupan celah, relatif terhadap sisi terpendek foto
_MIN_GREEN_FOR_STRICT_REGION = 0.15  # di bawah ini wilayah daun juga memakai piksel lesi


def _fruit_like_mask(image_rgb_uint8: np.ndarray) -> np.ndarray:
    hsv = cv2.cvtColor(cv2.cvtColor(image_rgb_uint8, cv2.COLOR_RGB2BGR), cv2.COLOR_BGR2HSV)
    return cv2.inRange(hsv, _FRUIT_HSV_LOWER, _FRUIT_HSV_UPPER) > 0


def _fill_holes(mask: np.ndarray) -> np.ndarray:
    """Isi area yang sepenuhnya dikelilingi mask (tidak terhubung ke tepi foto)."""
    height, width = mask.shape
    padded = np.zeros((height + 2, width + 2), np.uint8)
    padded[1:-1, 1:-1] = mask.astype(np.uint8) * 255
    flood = padded.copy()
    cv2.floodFill(flood, np.zeros((height + 4, width + 4), np.uint8), (0, 0), 255)
    holes = cv2.bitwise_not(flood)
    return (padded | holes)[1:-1, 1:-1] > 0


def leaf_region(green_mask: np.ndarray) -> np.ndarray:
    """Wilayah daun: hijau yang ditutup (close) lalu lubang tertutupnya diisi."""
    height, width = green_mask.shape
    radius = max(3, int(round(_CLOSE_RADIUS_FRACTION * min(height, width))))
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (2 * radius + 1, 2 * radius + 1))
    closed = cv2.morphologyEx(green_mask.astype(np.uint8), cv2.MORPH_CLOSE, kernel) > 0
    return _fill_holes(closed)


def split_lesion_and_nonleaf(
    image_rgb_uint8: np.ndarray, lesion_raw: np.ndarray, green_mask: np.ndarray
) -> tuple:
    """Kembalikan (lesion_mask, nonleaf_mask, leaf_region_mask).

    nonleaf_mask = piksel berwarna lesi/buah yang diperkirakan BUKAN daun (tangan, ajir,
    buah jingga); harus dikeluarkan dari mask daun (penyebut) dan dari ExG/VARI.
    """
    height, width = lesion_raw.shape

    fruit = _fruit_like_mask(image_rgb_uint8)
    lesion = lesion_raw & ~fruit

    # Buang garis tipis (tangkai, tepi daun, urat) dari mask lesi.
    kernel_size = max(2, int(round(0.004 * min(height, width))))
    lesion = (
        cv2.morphologyEx(
            lesion.astype(np.uint8), cv2.MORPH_OPEN, np.ones((kernel_size, kernel_size), np.uint8)
        )
        > 0
    )

    # Daun yang sebagian besar nekrotik hampir tidak punya piksel hijau: wilayah daun tidak
    # bisa diturunkan dari hijau saja, jadi lesi ikut membentuk wilayah (perilaku lama).
    if green_mask.mean() < _MIN_GREEN_FOR_STRICT_REGION:
        region = leaf_region((green_mask | lesion_raw) & ~fruit)
    else:
        region = leaf_region(green_mask & ~fruit)
    nonleaf = (lesion_raw & ~region) | (fruit & lesion_raw)
    lesion &= region
    return lesion, nonleaf, region
