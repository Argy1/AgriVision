import { z } from "zod";

// Proyek fokus ke tomat saja: jenis tanaman tidak dipilih user, selalu 'tomat'
// (diisi saat insert zona; kolom zones.crop_type tetap NOT NULL di database).
export const ZONE_CROP_TYPE = "tomat" as const;

export const createZoneSchema = z.object({
  name: z.string().min(1, { message: "Nama zona wajib diisi." }),
  location_note: z.string().optional(),
});
export type CreateZoneInput = z.infer<typeof createZoneSchema>;
