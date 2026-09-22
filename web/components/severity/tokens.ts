import type { Enums } from "@/types/database.types";

// Satu-satunya sumber pemetaan warna severity/status di seluruh app (CLAUDE.md:
// moss=sehat/ringan, ochre=waspada/sedang, rust=perlu tindakan/parah -- jangan
// pakai kombinasi lain di mana pun untuk severity/status).

export const SEVERITY_LABEL: Record<Enums<"severity_level">, string> = {
  ringan: "Ringan",
  sedang: "Sedang",
  parah: "Parah",
};

export const SEVERITY_PILL_CLASSES: Record<Enums<"severity_level">, string> = {
  ringan: "bg-moss-tint text-moss-deep",
  sedang: "bg-ochre-tint text-ochre-text",
  parah: "bg-rust-tint text-rust-text",
};

export const SEVERITY_DOT_CLASSES: Record<Enums<"severity_level">, string> = {
  ringan: "bg-moss",
  sedang: "bg-ochre",
  parah: "bg-rust",
};

export const ZONE_STATUS_LABEL: Record<Enums<"zone_status">, string> = {
  sehat: "Sehat",
  waspada: "Waspada",
  perlu_tindakan: "Perlu tindakan",
};

export const ZONE_STATUS_DOT_CLASSES: Record<Enums<"zone_status">, string> = {
  sehat: "bg-moss",
  waspada: "bg-ochre",
  perlu_tindakan: "bg-rust",
};

export const ZONE_STATUS_PILL_CLASSES: Record<Enums<"zone_status">, string> = {
  sehat: "bg-moss-tint text-moss-deep",
  waspada: "bg-ochre-tint text-ochre-text",
  perlu_tindakan: "bg-rust-tint text-rust-text",
};
