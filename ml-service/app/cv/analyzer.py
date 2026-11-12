import numpy as np

from app.cv.affected_area import compute_affected_area_pct, detect_lesion_mask
from app.cv.leaf_region import leaf_region, split_lesion_and_nonleaf
from app.cv.segmentation import segment_vegetation
from app.cv.severity import map_severity
from app.cv.vegetation_index import compute_vegetation_index


def analyze_image(image_rgb_uint8: np.ndarray) -> dict:
    """Jalankan seluruh pipeline classical CV (monitoring + affected area) dalam satu pass.

    leaf_mask adalah gabungan (union) piksel hijau sehat (ExG + Otsu) DAN piksel lesi/bercak
    (HSV) — bukan cuma yang hijau. Ini penting: jaringan daun yang sudah rusak/menguning/
    kecoklatan tetap bagian dari "daun", bukan background, jadi tidak boleh hilang dari
    penyebut saat menghitung affected_area_pct maupun rata-rata ExG/VARI.

    Piksel non-daun yang kebetulan berwarna seperti lesi (tangan, ajir, buah jingga) dibuang
    lebih dulu lewat leaf_region.split_lesion_and_nonleaf, supaya foto lapangan tidak
    menghasilkan luas terdampak palsu. Heuristik ini belum divalidasi terhadap anotasi pakar.

    Hasil juga memuat mask (green_mask, lesion_mask, nonleaf_mask) untuk penilaian kualitas
    foto; kunci mask TIDAK ikut dikirim ke klien.
    """
    image_float01 = image_rgb_uint8.astype(np.float32) / 255.0
    green_mask = segment_vegetation(image_float01)
    lesion_raw = detect_lesion_mask(image_rgb_uint8)
    lesion_mask, nonleaf_mask, _region = split_lesion_and_nonleaf(image_rgb_uint8, lesion_raw, green_mask)
    green_leaf = green_mask & ~nonleaf_mask
    leaf_mask = green_leaf | lesion_mask

    vegetation_index = compute_vegetation_index(image_float01, leaf_mask)
    affected_area_pct = compute_affected_area_pct(lesion_mask, leaf_mask)
    severity = map_severity(affected_area_pct)

    # Seberapa penuh foto terisi dedaunan/objek berwarna daun (indikator foto bukan close-up
    # satu daun); close-up lab: 10-59% pada sampel uji, foto kebun nyata: 78-100%.
    scene_fraction = float(leaf_region(green_mask | lesion_raw).mean())

    return {
        "vegetation_index": vegetation_index,
        "affected_area_pct": round(affected_area_pct, 2),
        "severity": severity,
        "masks": {"green": green_mask, "lesion": lesion_mask, "nonleaf": nonleaf_mask},
        "scene_fraction": scene_fraction,
    }
