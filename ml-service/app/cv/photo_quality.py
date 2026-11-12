"""Penilaian kelayakan foto untuk diagnosis daun (heuristik, bukan jaminan).

Model klasifikasi dilatih pada foto close-up satu daun. Foto kebun yang memuat tangan,
ajir, buah, atau banyak daun sekaligus bisa menghasilkan diagnosis yang sangat yakin tapi
keliru (terbukti pada pengujian foto lapangan). Modul ini TIDAK memperbaiki hasil model;
ia hanya memberi tahu pengguna kapan hasilnya perlu diperlakukan hati-hati.
"""

from dataclasses import dataclass, field
from typing import Optional

import numpy as np

# Ambang heuristik; belum dikalibrasi dengan banyak foto nyata.
MIN_LEAF_PRESENCE = 0.03  # di bawah ini: tidak ada daun yang bisa dikenali -> tolak foto
LOW_LEAF_COVERAGE = 0.15  # di bawah ini: daun terlalu kecil/jauh
NONLEAF_WARN_FRACTION = 0.08  # >= 8% foto adalah tangan/ajir/buah
LOW_CONFIDENCE = 0.60  # keyakinan model di bawah ini dianggap ragu
BUSY_SCENE_FRACTION = 0.70  # >= 70% foto terisi dedaunan/objek berwarna daun (bukan close-up satu daun)


@dataclass
class PhotoQuality:
    leaf_presence: float
    issues: list[str] = field(default_factory=list)

    @property
    def rejected(self) -> bool:
        return self.leaf_presence < MIN_LEAF_PRESENCE

    def warning_text(self) -> Optional[str]:
        if not self.issues:
            return None
        return "Perhatian kualitas foto: " + "; ".join(self.issues) + (
            ". Ambil foto satu daun dari dekat (±15-20 cm) dengan latar polos, tanpa tangan/buah/ajir, "
            "lalu verifikasi hasil ke penyuluh (PPL)."
        )


def assess_photo(
    green_mask: np.ndarray,
    lesion_mask: np.ndarray,
    nonleaf_mask: np.ndarray,
    scene_fraction: float,
    confidence: float,
) -> PhotoQuality:
    # Wilayah daun yang ditutup (hijau + warna lesi) — lebih tahan terhadap jaringan nekrotik
    # yang gelap dan lolos dari ambang HSV, dibanding sekadar menghitung piksel hijau/lesi.
    leaf_presence = float(scene_fraction)
    quality = PhotoQuality(leaf_presence=leaf_presence)

    nonleaf_fraction = float(nonleaf_mask.mean())

    # leaf_presence (hijau + lesi), bukan hijau saja: daun yang sangat nekrotik tetap "besar".
    if MIN_LEAF_PRESENCE <= leaf_presence < LOW_LEAF_COVERAGE:
        quality.issues.append("daun terlalu kecil atau jauh dalam foto")
    if scene_fraction >= BUSY_SCENE_FRACTION:
        quality.issues.append(
            "foto dipenuhi dedaunan/latar ramai, bukan close-up satu daun "
            "(luas terdampak dan skor kesehatan kurang andal)"
        )
    if nonleaf_fraction >= NONLEAF_WARN_FRACTION:
        quality.issues.append(
            f"±{nonleaf_fraction * 100:.0f}% foto berisi objek non-daun (tangan, ajir, atau buah)"
        )
    if confidence < LOW_CONFIDENCE:
        quality.issues.append(f"model ragu (keyakinan {confidence * 100:.0f}%)")
    return quality
