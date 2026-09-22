import type { Enums } from "@/types/database.types";

const LEAF_PATH =
  "M100 8 C46 26 14 84 14 146 C14 188 52 214 100 214 C148 214 186 188 186 146 C186 84 154 26 100 8 Z";
const BLOB_PATH =
  "M118 108 C142 100 158 120 150 146 C143 170 112 180 96 164 C84 152 88 126 106 114 C110 111 114 109 118 108 Z";
// Titik jangkar skala blob, kira-kira pusat massa BLOB_PATH.
const BLOB_ANCHOR = { x: 121, y: 140 };

const OUTLINE_COLOR: Record<Enums<"severity_level">, string> = {
  ringan: "#46603C",
  sedang: "#BD8A2E",
  parah: "#AE4F2E",
};

/**
 * Ilustrasi daun besar di halaman Hasil Diagnosis -- direproduksi persis dari
 * mockup (bentuk daun, urat, blob). Satu-satunya contoh nyata di mockup adalah
 * severity=sedang & affected_area_pct=35% dengan skala blob 1.0.
 *
 * Judgment call (tidak ada spesifikasi lain): fill blob SELALU rust (merefleksikan
 * warna fisik jaringan nekrotik/lesi, terlepas dari tingkat keparahan), sedangkan
 * warna outline blob mengikuti token severity (moss/ochre/rust) sebagai indikator
 * status. Ukuran blob diskalakan dari affected_area_pct nyata:
 * scale = sqrt(pct / 35), clamp [0.4, 1.6], dikalibrasi dari satu-satunya titik
 * data yang ada (35% -> skala 1.0).
 */
export function LeafIllustration({
  severity,
  affectedAreaPct,
  width = 180,
  height = 198,
}: {
  severity: Enums<"severity_level">;
  affectedAreaPct: number;
  width?: number;
  height?: number;
}) {
  const scale = Math.min(1.6, Math.max(0.4, Math.sqrt(Math.max(affectedAreaPct, 0.1) / 35)));
  const outline = OUTLINE_COLOR[severity];
  const showBlob = affectedAreaPct > 0.5;

  return (
    <svg viewBox="0 0 200 220" width={width} height={height}>
      <path d={LEAF_PATH} fill="#5C7A4E" stroke="#33472B" strokeWidth={2.5} />
      <path d="M100 20 L100 206" stroke="#33472B" strokeWidth={1.6} opacity={0.5} />
      <path
        d="M100 60 L60 90 M100 60 L140 90 M100 100 L54 128 M100 100 L146 128 M100 145 L62 170 M100 145 L138 170"
        stroke="#33472B"
        strokeWidth={1.2}
        opacity={0.4}
        fill="none"
      />
      {showBlob && (
        <g
          transform={`translate(${BLOB_ANCHOR.x} ${BLOB_ANCHOR.y}) scale(${scale}) translate(${-BLOB_ANCHOR.x} ${-BLOB_ANCHOR.y})`}
        >
          <path d={BLOB_PATH} fill="#AE4F2E" opacity={0.9} />
          <path d={BLOB_PATH} fill="none" stroke={outline} strokeWidth={2.5} opacity={0.8} />
        </g>
      )}
    </svg>
  );
}
