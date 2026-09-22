import io

import numpy as np
from PIL import Image


def decode_image(image_bytes: bytes) -> np.ndarray:
    """Decode bytes foto jadi array RGB uint8 (H, W, 3) pada resolusi asli.

    Dipakai sebagai satu-satunya titik decode per request — hasilnya dipakai bersama oleh
    modul diagnosis (di-resize lagi sesuai input model) dan modul monitoring/affected-area
    (dihitung pada resolusi asli untuk akurasi yang lebih baik).
    """
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    return np.asarray(image, dtype=np.uint8)
