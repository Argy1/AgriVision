import type { Enums } from "@/types/database.types";

const LEAF_PATH =
  "M100 8 C46 26 14 84 14 146 C14 188 52 214 100 214 C148 214 186 188 186 146 C186 84 154 26 100 8 Z";
const BLOB_PATH =
  "M118 108 C142 100 158 120 150 146 C143 170 112 180 96 164 C84 152 88 126 106 114 C110 111 114 109 118 108 Z";

const BLOB_COLOR: Record<Enums<"severity_level">, string> = {
  ringan: undefined as unknown as string, // ringan tidak render blob sama sekali (lihat mockup "Tomat • Zona A1")
  sedang: "#BD8A2E",
  parah: "#AE4F2E",
};

/**
 * Ikon daun kecil untuk baris riwayat/aktivitas (upload page "Riwayat terbaru",
 * dashboard "Aktivitas terbaru") -- direproduksi persis dari mockup: daun polos
 * untuk severity ringan, daun + blob berwarna untuk sedang/parah.
 */
export function LeafGlyph({
  severity,
  width = 36,
  height = 40,
}: {
  severity: Enums<"severity_level">;
  width?: number;
  height?: number;
}) {
  const blobColor = BLOB_COLOR[severity];

  return (
    <svg viewBox="0 0 200 220" width={width} height={height} aria-hidden>
      <path d={LEAF_PATH} fill="#5C7A4E" />
      {blobColor && <path d={BLOB_PATH} fill={blobColor} opacity={severity === "parah" ? 0.88 : 0.85} />}
    </svg>
  );
}
