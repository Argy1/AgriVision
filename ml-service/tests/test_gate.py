"""Tes offline (tanpa jaringan/.env) untuk penyaring daun tomat (app/ml/gate.py) dan model yang dipasang."""

import json
import os
from pathlib import Path

# app.config mewajibkan variabel Supabase; tes ini tidak memakainya (sama dengan scripts/predict_local.py).
os.environ.setdefault("SUPABASE_URL", "http://localhost")
os.environ.setdefault("SUPABASE_SERVICE_ROLE_KEY", "tidak-dipakai")

import numpy as np  # noqa: E402
import pytest  # noqa: E402

from app.ml import gate as gate_module  # noqa: E402
from app.ml.gate import GateResult, check_tomato, gate_config, gate_threshold  # noqa: E402
from app.ml.labels import get_model_version  # noqa: E402
from app.ml.model_loader import model_registry  # noqa: E402

MODELS = Path(__file__).resolve().parent.parent / "models"


@pytest.fixture(scope="module", autouse=True)
def _load_models():
    model_registry.load_all()


def test_both_models_load_and_versions_match_notebooks():
    assert model_registry.is_loaded
    assert get_model_version("tomat") == "v8"
    assert gate_config()["model_version"] == "v9.1"


def test_gate_config_is_valid():
    cfg = json.loads((MODELS / "gate_config.json").read_text(encoding="utf-8"))
    assert cfg["img_size"] == [224, 224]
    assert 0.0 < cfg["threshold"] < 1.0


def test_threshold_env_override(monkeypatch):
    monkeypatch.setenv("GATE_THRESHOLD", "0.25")
    assert gate_threshold() == 0.25
    monkeypatch.delenv("GATE_THRESHOLD")
    assert gate_threshold() == gate_config()["threshold"]


def test_gate_result_decision_and_message():
    assert GateResult(p_tomat=0.80, threshold=0.5).is_tomato
    assert GateResult(p_tomat=0.50, threshold=0.5).is_tomato  # tepat di ambang = diterima
    rejected = GateResult(p_tomat=0.12, threshold=0.5)
    assert not rejected.is_tomato
    assert "daun tomat" in rejected.reject_detail() and "12%" in rejected.reject_detail()


def test_check_tomato_runs_real_model_on_any_size():
    rng = np.random.default_rng(0)
    for shape in [(300, 500, 3), (224, 224, 3), (1000, 750, 3)]:
        result = check_tomato(rng.integers(0, 256, shape, dtype=np.uint8))
        assert 0.0 <= result.p_tomat <= 1.0
        assert result.threshold == gate_threshold()


def test_check_tomato_uses_threshold(monkeypatch):
    monkeypatch.setattr(gate_module.model_registry, "predict", lambda key, x: np.array([[0.3]], np.float32))
    img = np.zeros((50, 50, 3), np.uint8)
    monkeypatch.setenv("GATE_THRESHOLD", "0.2")
    assert check_tomato(img).is_tomato
    monkeypatch.setenv("GATE_THRESHOLD", "0.4")
    assert not check_tomato(img).is_tomato


def test_make_crops_shapes_and_bounds():
    from app.ml.crops import CROP_LAYOUT, make_crops

    for shape in [(300, 500, 3), (500, 300, 3), (224, 224, 3), (7, 9, 3)]:
        img = np.zeros(shape, np.uint8)
        crops = make_crops(img)
        assert len(crops) == 1 + len(CROP_LAYOUT)
        assert crops[0].shape == shape  # foto utuh selalu ikut dinilai
        short = min(shape[:2])
        for c, (_, _, rel) in zip(crops[1:], CROP_LAYOUT):
            assert c.shape[0] == c.shape[1] == max(1, round(short * rel))  # persegi, di dalam foto


def _corner_tomato_image():
    """Foto gelap dengan satu sudut terang: hanya potongan sudut itu yang 'mirip tomat'."""
    img = np.zeros((400, 600, 3), np.uint8)
    img[:200, :250] = 255
    return img


def _fake_p_by_brightness(image):
    return float(image.mean() / 255.0)


def test_multicrop_accepts_when_one_crop_is_tomato(monkeypatch):
    cfg = {**gate_config(), "threshold": 0.5, "threshold_multicrop": 0.5}
    monkeypatch.setattr(gate_module, "gate_config", lambda: cfg)
    monkeypatch.setattr(gate_module, "_p_tomat", _fake_p_by_brightness)
    monkeypatch.delenv("GATE_THRESHOLD", raising=False)

    monkeypatch.setenv("GATE_MULTICROP", "1")
    result = check_tomato(_corner_tomato_image())
    assert result.multicrop and result.is_tomato
    assert len(result.accepted_crops) >= 1
    assert all(c.mean() / 255.0 >= 0.5 for c in result.accepted_crops)  # hanya potongan yang lolos

    monkeypatch.setenv("GATE_MULTICROP", "0")  # foto utuh saja -> ditolak (rata-rata gelap)
    result = check_tomato(_corner_tomato_image())
    assert not result.multicrop and not result.is_tomato and result.accepted_crops == ()


def test_multicrop_off_when_config_has_no_multicrop_threshold(monkeypatch):
    cfg = {k: v for k, v in gate_config().items() if k != "threshold_multicrop"}
    monkeypatch.setattr(gate_module, "gate_config", lambda: cfg)
    monkeypatch.setenv("GATE_MULTICROP", "1")
    assert not gate_module.multicrop_enabled()


def test_installed_config_uses_full_photo_by_default(monkeypatch):
    monkeypatch.delenv("GATE_MULTICROP", raising=False)
    monkeypatch.delenv("GATE_THRESHOLD", raising=False)
    assert not gate_module.multicrop_enabled()
    assert gate_threshold() == gate_config()["threshold"]
    monkeypatch.setenv("GATE_MULTICROP", "1")
    assert gate_module.multicrop_enabled()
    assert gate_threshold() == gate_config()["threshold_multicrop"]


def test_classify_averages_over_accepted_crops(monkeypatch):
    from app.ml import inference

    def fake_predict(key, x):  # kelas 0 untuk gambar terang, kelas 1 untuk gambar gelap
        p = np.zeros(10, np.float32)
        p[0 if x.mean() > 127 else 1] = 1.0
        return p

    monkeypatch.setattr(inference.model_registry, "predict", fake_predict)
    bright, dark = np.full((50, 50, 3), 255, np.uint8), np.zeros((50, 50, 3), np.uint8)
    full = inference.classify("tomat", dark)
    assert full["disease_label"] == "tomato_early_blight" and full["confidence"] == 1.0
    mixed = inference.classify("tomat", dark, crops=[bright, bright, dark, bright])
    assert mixed["disease_label"] == "tomato_bacterial_spot" and mixed["confidence"] == 0.75


def test_classifier_output_is_10_class_distribution():
    x = np.full((1, 224, 224, 3), 128, np.float32)
    probs = model_registry.predict("tomato", x)
    assert probs.shape == (10,)
    assert abs(float(probs.sum()) - 1.0) < 1e-3
