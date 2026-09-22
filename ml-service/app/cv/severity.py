def map_severity(affected_area_pct: float) -> str:
    """Aturan mapping persis sesuai docs/05-ml-pipeline.md."""
    if affected_area_pct < 15:
        return "ringan"
    if affected_area_pct < 40:
        return "sedang"
    return "parah"
