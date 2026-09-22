import { z } from "zod";

export const createZoneSchema = z.object({
  name: z.string().min(1, { message: "Nama zona wajib diisi." }),
  crop_type: z.enum(["tomat", "cabai"], { message: "Pilih jenis tanaman." }),
  location_note: z.string().optional(),
});
export type CreateZoneInput = z.infer<typeof createZoneSchema>;
