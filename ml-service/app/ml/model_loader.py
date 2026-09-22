import logging
import threading
from pathlib import Path

import numpy as np

from app.config import settings

logger = logging.getLogger(__name__)

# tflite-runtime adalah pilihan paling ringan untuk deploy, tapi ketersediaan wheel-nya
# terbatas per versi Python/OS — coba beberapa alternatif sebelum jatuh ke TensorFlow penuh.
try:
    from tflite_runtime.interpreter import Interpreter
except ImportError:
    try:
        from ai_edge_litert.interpreter import Interpreter
    except ImportError:
        # fallback: paket tensorflow-cpu penuh. Sengaja BUKAN
        # "from tensorflow.lite import Interpreter" -- TF memuat tf.lite lewat lazy
        # module loader, jadi bentuk `from ... import` itu gagal (ModuleNotFoundError)
        # meski `tf.lite.Interpreter` sebagai atribut valid. Import tensorflow dulu,
        # baru akses Interpreter sebagai atribut.
        import tensorflow as _tf

        Interpreter = _tf.lite.Interpreter

_MODEL_FILENAMES = {
    "tomato": "tomato_classifier.tflite",
    "chili": "chili_classifier.tflite",
}


class ModelRegistry:
    """Load kedua model TFLite sekali saat startup service (bukan per-request), sesuai
    05-ml-pipeline.md. Invoke() TFLite Interpreter tidak thread-safe untuk instance yang
    sama, jadi setiap crop punya lock sendiri untuk menyerialkan inference per model.
    """

    def __init__(self) -> None:
        self._interpreters: dict[str, Interpreter] = {}
        self._locks: dict[str, threading.Lock] = {}

    def load_all(self) -> None:
        model_dir = Path(settings.model_dir)
        for crop_key, filename in _MODEL_FILENAMES.items():
            path = model_dir / filename
            interpreter = Interpreter(model_path=str(path))
            interpreter.allocate_tensors()
            self._interpreters[crop_key] = interpreter
            self._locks[crop_key] = threading.Lock()
            logger.info("Model '%s' dimuat dari %s", crop_key, path)

    @property
    def is_loaded(self) -> bool:
        return len(self._interpreters) == len(_MODEL_FILENAMES)

    def predict(self, crop_key: str, batched_input: np.ndarray) -> np.ndarray:
        interpreter = self._interpreters[crop_key]
        with self._locks[crop_key]:
            input_details = interpreter.get_input_details()
            output_details = interpreter.get_output_details()
            interpreter.set_tensor(input_details[0]["index"], batched_input)
            interpreter.invoke()
            output = interpreter.get_tensor(output_details[0]["index"])
        return output[0]  # buang batch dimension -> vektor probabilitas per kelas


model_registry = ModelRegistry()
