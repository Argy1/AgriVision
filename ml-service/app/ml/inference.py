import numpy as np
from PIL import Image

from app.ml.labels import get_class_by_index, get_crop_key, get_img_size, get_model_version
from app.ml.model_loader import model_registry


def _resize_for_model(image_rgb_uint8: np.ndarray, target_size: tuple[int, int]) -> np.ndarray:
    """Resize ke ukuran input model. TIDAK melakukan rescaling manual (mis. dibagi 255):
    preprocessing MobileNetV2/EfficientNetB4 (preprocess_input) sudah dibakar ke dalam
    graph model saat training — lihat agrivision_training.ipynb, Step 5. Model
    mengharapkan input raw 0-255 float32.
    """
    resized = Image.fromarray(image_rgb_uint8).resize(target_size, Image.BILINEAR)
    array = np.asarray(resized, dtype=np.float32)  # (H, W, 3), 0-255 — JANGAN dibagi 255
    return np.expand_dims(array, axis=0)  # (1, H, W, 3)


def classify(crop_type: str, image_rgb_uint8: np.ndarray) -> dict:
    """Jalankan model CNN sesuai crop_type -> disease_label, confidence, model_version."""
    crop_key = get_crop_key(crop_type)
    width, height = get_img_size(crop_type)
    batched_input = _resize_for_model(image_rgb_uint8, (width, height))

    probabilities = model_registry.predict(crop_key, batched_input)
    class_index = int(np.argmax(probabilities))
    confidence = float(probabilities[class_index])
    class_info = get_class_by_index(crop_type, class_index)

    return {
        "disease_label": class_info["disease_label"],
        "confidence": round(confidence, 4),
        "model_version": get_model_version(crop_type),
    }
