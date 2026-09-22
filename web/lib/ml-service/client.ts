import type { Enums } from "@/types/database.types";

export interface DiagnoseResponse {
  diagnosis: {
    id: string;
    disease_label: string;
    disease_name: string;
    confidence: number;
    severity: Enums<"severity_level">;
    affected_area_pct: number;
  };
  vegetation_index: {
    exg_score: number;
    vari_score: number;
    health_score: number;
  };
  recommendation: {
    recommendation_text: string;
    dosage: string | null;
    application_schedule: string | null;
    warning_note: string | null;
  };
}

export class MlServiceError extends Error {
  status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

/** Panggil POST /api/diagnose di ml-service (FastAPI, Railway) -- lihat docs/04-api-contract.md.
 * accessToken HARUS access_token user asli (bukan service role key -- itu tidak pernah
 * ada di web). */
export async function diagnose(params: {
  uploadId: string;
  imagePath: string;
  cropType: Enums<"crop_type">;
  accessToken: string;
}): Promise<DiagnoseResponse> {
  const response = await fetch(`${process.env.NEXT_PUBLIC_ML_API_URL}/api/diagnose`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${params.accessToken}`,
    },
    body: JSON.stringify({
      upload_id: params.uploadId,
      image_path: params.imagePath,
      crop_type: params.cropType,
    }),
  });

  if (!response.ok) {
    const body = await response.json().catch(() => null);
    throw new MlServiceError(
      response.status,
      body?.detail ?? `Diagnosis gagal (${response.status})`,
    );
  }

  return response.json();
}
