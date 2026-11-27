"""Tes offline (tanpa jaringan/.env) untuk analisis CV dan kelayakan foto, memakai gambar sintetis."""

import cv2
import numpy as np
import pytest

from app.cv.analyzer import analyze_image
from app.cv.photo_quality import assess_photo


def _closeup_leaf(spots: bool = True) -> np.ndarray:
    """Daun hijau elips di latar abu-abu polos; opsional 2 bercak cokelat."""
    img = np.full((400, 400, 3), 200, np.uint8)
    cv2.ellipse(img, (200, 200), (150, 110), 20, 0, 360, (40, 150, 40), -1)
    if spots:
        cv2.circle(img, (170, 190), 25, (130, 80, 30), -1)
        cv2.circle(img, (240, 220), 20, (130, 80, 30), -1)
    return img


def _quality(image: np.ndarray, confidence: float = 0.9):
    result = analyze_image(image)
    masks = result["masks"]
    return result, assess_photo(
        masks["green"], masks["lesion"], masks["nonleaf"], result["scene_fraction"], confidence
    )


def test_closeup_leaf_has_no_issues_and_spots_are_measured():
    result, quality = _quality(_closeup_leaf())
    assert quality.issues == []
    assert not quality.rejected
    # dua bercak (~1963 + ~1257 px) dari luas daun (~51.8k px) = sekitar 6%
    assert 3.0 < result["affected_area_pct"] < 10.0
    assert result["severity"] == "ringan"


def test_healthy_closeup_leaf_has_near_zero_affected_area():
    result, _ = _quality(_closeup_leaf(spots=False))
    assert result["affected_area_pct"] < 1.0


def test_health_score_orders_green_above_spotted_above_brown():
    # Skor kesehatan (VARI terkalibrasi): daun hijau > daun berbercak > daun hampir cokelat.
    # Warna daun mendekati foto asli (VARI ±0,16), bukan hijau murni yang selalu mentok di 100.
    def leaf(spot_radius):
        img = np.full((400, 400, 3), 200, np.uint8)
        cv2.ellipse(img, (200, 200), (150, 110), 20, 0, 360, (95, 120, 60), -1)
        if spot_radius:
            cv2.circle(img, (200, 200), spot_radius, (130, 85, 35), -1)
        return _quality(img)[0]["vegetation_index"]["health_score"]

    green, spotted, brown = leaf(0), leaf(45), leaf(100)
    assert green > spotted > brown
    assert green >= 75


def test_hand_next_to_leaf_is_not_counted_as_lesion():
    img = _closeup_leaf(spots=False)
    # "tangan": blok kulit besar menempel tepi bawah, di luar daun
    cv2.rectangle(img, (0, 330), (400, 400), (190, 140, 110), -1)
    result, _ = _quality(img)
    assert result["affected_area_pct"] < 2.0


def test_no_leaf_is_rejected():
    _, quality = _quality(np.full((300, 300, 3), 128, np.uint8))
    assert quality.rejected


def test_foliage_filled_frame_gets_busy_scene_warning():
    rng = np.random.default_rng(0)
    img = np.zeros((400, 400, 3), np.uint8)
    img[..., 1] = rng.integers(110, 190, (400, 400))  # hijau bertekstur memenuhi frame
    img[..., 0] = rng.integers(20, 60, (400, 400))
    img[..., 2] = rng.integers(20, 60, (400, 400))
    _, quality = _quality(img)
    assert any("dedaunan" in issue for issue in quality.issues)
    assert quality.warning_text() is not None


def test_low_confidence_is_flagged():
    _, quality = _quality(_closeup_leaf(), confidence=0.4)
    assert any("ragu" in issue for issue in quality.issues)


def test_confidence_below_reject_threshold_is_rejected():
    _, quality = _quality(_closeup_leaf(), confidence=0.25)
    assert quality.rejected
    assert quality.reject_reason == "low_confidence"
    # Pesan soal penyakit, bukan soal "daun tomat" (itu tugas penyaring app/ml/gate.py).
    assert "belum cukup yakin menentukan penyakit" in quality.reject_detail()
    assert "daun tomat" not in quality.reject_detail()


@pytest.mark.parametrize("confidence", [0.35, 0.45, 0.55])
def test_confidence_between_reject_and_low_is_warned_not_rejected(confidence):
    # Sejak penyaring daun tomat ada, keyakinan 30-60% tetap didiagnosis + peringatan "ragu".
    _, quality = _quality(_closeup_leaf(), confidence=confidence)
    assert not quality.rejected
    assert any("ragu" in issue for issue in quality.issues)


def test_no_leaf_reason_and_message():
    _, quality = _quality(np.full((300, 300, 3), 128, np.uint8), confidence=0.95)
    assert quality.reject_reason == "no_leaf"
    assert "tidak memuat daun" in quality.reject_detail()
