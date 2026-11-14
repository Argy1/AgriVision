"""Tes offline untuk modul pra-pemrosesan citra (gambar sintetis)."""

import cv2
import numpy as np
import pytest

from app.ml.enhance import VARIANTS, apply_variant


def _leaf_on_plain_background() -> np.ndarray:
    img = np.full((224, 224, 3), 190, np.uint8)
    cv2.ellipse(img, (112, 112), (80, 60), 20, 0, 360, (40, 150, 40), -1)
    cv2.circle(img, (100, 105), 12, (130, 80, 30), -1)
    return img


def _low_contrast() -> np.ndarray:
    rng = np.random.default_rng(0)
    return np.clip(120 + rng.normal(0, 4, (224, 224, 3)), 0, 255).astype(np.uint8)


@pytest.mark.parametrize("name", list(VARIANTS))
def test_variants_preserve_shape_dtype_and_are_deterministic(name):
    img = _leaf_on_plain_background()
    a = apply_variant(img, name)
    b = apply_variant(img, name)
    assert a.shape == img.shape and a.dtype == np.uint8
    assert np.array_equal(a, b)


def test_none_is_identity():
    img = _leaf_on_plain_background()
    assert np.array_equal(apply_variant(img, "none"), img)


def test_clahe_increases_contrast():
    img = _low_contrast()
    out = apply_variant(img, "clahe")
    assert out.astype(float).std() > img.astype(float).std() * 2


def test_shades_of_gray_reduces_color_cast():
    img = np.full((224, 224, 3), (100, 150, 100), np.uint8)  # cahaya kehijauan merata
    out = apply_variant(img, "sog")
    spread_before = img.reshape(-1, 3).mean(0).std()
    spread_after = out.reshape(-1, 3).mean(0).std()
    assert spread_after < spread_before * 0.3


def test_unsharp_increases_edge_energy():
    img = cv2.GaussianBlur(_leaf_on_plain_background(), (0, 0), 2)
    out = apply_variant(img, "unsharp")
    lap = lambda x: cv2.Laplacian(cv2.cvtColor(x, cv2.COLOR_RGB2GRAY), cv2.CV_64F).var()
    assert lap(out) > lap(img)


def test_background_suppression_neutralizes_background_but_keeps_leaf():
    img = _leaf_on_plain_background()
    img[:, :40] = (200, 120, 60)  # latar berwarna di tepi kiri (mis. tanah/kayu)
    out = apply_variant(img, "bg")
    assert np.array_equal(out[112, 112], img[112, 112])  # daun tetap
    assert tuple(out[10, 5]) == (128, 128, 128)  # latar jadi abu-abu netral


def test_background_suppression_falls_back_when_no_leaf():
    img = np.full((224, 224, 3), 128, np.uint8)
    assert np.array_equal(apply_variant(img, "bg"), img)


def test_invalid_input_rejected():
    with pytest.raises(ValueError):
        apply_variant(np.zeros((10, 10), np.uint8), "clahe")
    with pytest.raises(ValueError):
        apply_variant(_leaf_on_plain_background(), "tidak_ada")
