"""Potongan foto (multi-crop) untuk penyaring dan diagnosis.

Foto lapangan sering memuat buah, tangan, mulsa, atau tanaman utuh; daun tomat hanya sebagian
foto. Model dilatih pada foto yang didominasi daun, jadi seluruh foto saja bisa membuat
penyaring menolak atau model diagnosis ragu. Selain foto utuh, model juga melihat beberapa
potongan persegi; penyaring menerima foto bila SALAH SATU potongan jelas daun tomat, dan
diagnosis merata-ratakan hasil dari potongan yang lolos penyaring.

Fungsi ini juga disalin apa adanya ke sel evaluasi Colab (notebook v9.1, Step 17) supaya ambang
multi-crop diukur dengan potongan yang sama persis.
"""

import numpy as np

# (posisi tengah x, posisi tengah y, sisi relatif terhadap sisi terpendek foto)
CROP_LAYOUT = (
    (0.5, 0.5, 1.0),  # persegi tengah terbesar
    (0.5, 0.5, 0.6),  # tengah, lebih dekat
    (0.3, 0.3, 0.6),  # kiri atas
    (0.7, 0.3, 0.6),  # kanan atas
    (0.3, 0.7, 0.6),  # kiri bawah
    (0.7, 0.7, 0.6),  # kanan bawah
)


def make_crops(image: np.ndarray) -> list[np.ndarray]:
    """Kembalikan [foto utuh] + potongan persegi sesuai CROP_LAYOUT (RGB uint8, ukuran asli)."""
    height, width = image.shape[:2]
    short = min(height, width)
    crops = [image]
    for cx, cy, rel in CROP_LAYOUT:
        side = max(1, int(round(short * rel)))
        x0 = int(round(cx * width - side / 2))
        y0 = int(round(cy * height - side / 2))
        x0 = min(max(x0, 0), width - side)
        y0 = min(max(y0, 0), height - side)
        crops.append(image[y0 : y0 + side, x0 : x0 + side])
    return crops
