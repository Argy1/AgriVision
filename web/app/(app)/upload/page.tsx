import type { Metadata } from "next";
import Link from "next/link";
import { Suspense } from "react";

import { CheckCircleIcon } from "@/components/icons";
import { LeafGlyph } from "@/components/leaf-illustration/LeafGlyph";
import { Card, CardTitle } from "@/components/ui/Card";
import { getRecentDiagnoses } from "@/lib/data/diagnoses";
import { getZones } from "@/lib/data/zones";
import { CROP_LABEL, formatRelativeDateTime } from "@/lib/format";

import { UploadPageClient } from "./UploadPageClient";

export const metadata: Metadata = { title: "Unggah Foto — AgriVision" };

const TIPS = [
  "Pastikan pencahayaan cukup, hindari bayangan",
  "Fokuskan kamera pada bagian daun yang bermasalah",
  "Ambil jarak 15–20 cm dari daun",
  "Hindari foto buram atau miring",
];

export default async function UploadPage() {
  const [zones, recentDiagnoses] = await Promise.all([getZones(), getRecentDiagnoses(3)]);

  return (
    <div className="flex h-screen flex-col gap-6 overflow-y-auto p-10 pb-16">
      <Suspense fallback={null}>
        <UploadPageClient initialZones={zones} />
      </Suspense>

      <div className="flex min-h-0 flex-1 gap-5">
        <Card className="w-[460px] shrink-0 p-5">
          <CardTitle className="mb-3.5">Tips foto yang baik</CardTitle>
          <div className="flex flex-col gap-3">
            {TIPS.map((tip) => (
              <div key={tip} className="flex items-start gap-2.5">
                <CheckCircleIcon size={18} className="mt-0.5 shrink-0 text-moss" />
                <span className="font-sans text-[13.5px] leading-relaxed text-tips-text">{tip}</span>
              </div>
            ))}
          </div>
        </Card>

        <Card className="flex-1 p-5">
          <CardTitle className="mb-3.5">Riwayat terbaru</CardTitle>
          {recentDiagnoses.length === 0 ? (
            <p className="font-sans text-[13.5px] text-sage">Belum ada riwayat diagnosis.</p>
          ) : (
            <div className="flex flex-col gap-3.5">
              {recentDiagnoses.map((d) => (
                <Link
                  key={d.id}
                  href={`/diagnosis/${d.id}`}
                  className="flex items-center gap-3"
                >
                  <LeafGlyph severity={d.severity} />
                  <div className="flex-1">
                    <div className="font-sans text-[13.5px] font-medium text-ink">
                      {CROP_LABEL[d.uploads.zones.crop_type]} • Zona {d.uploads.zones.name}
                    </div>
                    <div className="font-sans text-[12px] text-sage">
                      {formatRelativeDateTime(d.created_at)}
                    </div>
                  </div>
                  <div
                    className={`h-[9px] w-[9px] shrink-0 rounded-full ${
                      d.severity === "ringan"
                        ? "bg-moss"
                        : d.severity === "sedang"
                          ? "bg-ochre"
                          : "bg-rust"
                    }`}
                  />
                </Link>
              ))}
            </div>
          )}
        </Card>
      </div>
    </div>
  );
}
