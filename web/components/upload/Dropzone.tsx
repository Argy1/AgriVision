"use client";

import { useRouter } from "next/navigation";
import { useRef, useState } from "react";

import { CameraIcon } from "@/components/icons";
import { diagnose, MlServiceError } from "@/lib/ml-service/client";
import { createClient } from "@/lib/supabase/client";
import type { Tables } from "@/types/database.types";

const MAX_SIZE_BYTES = 10 * 1024 * 1024;
const ACCEPTED_TYPES = ["image/jpeg", "image/png"];

type Stage =
  | { name: "idle" }
  | { name: "uploading" }
  | { name: "diagnosing" }
  | { name: "error"; message: string; retry: () => void };

export function Dropzone({ zone }: { zone: Tables<"zones"> | null }) {
  const router = useRouter();
  const inputRef = useRef<HTMLInputElement>(null);
  const [stage, setStage] = useState<Stage>({ name: "idle" });
  const [dragOver, setDragOver] = useState(false);

  // Fungsi-fungsi di bawah SENGAJA disusun dari yang paling "hilir" (runDiagnose)
  // ke yang paling "hulu" (runUploadFlow) supaya tidak ada forward-reference
  // antar function declaration dalam komponen ini.

  async function runDiagnose(uploadId: string, path: string, cropType: Tables<"zones">["crop_type"]) {
    setStage({ name: "diagnosing" });
    const supabase = createClient();

    // Idempoten: kalau diagnosis untuk upload ini sudah pernah berhasil dibuat
    // sebelumnya (mis. respons hilang di jaringan tapi server sudah insert),
    // langsung arahkan ke situ tanpa panggil ulang ml-service (upload_id unique
    // di tabel diagnoses -- panggil ulang akan gagal constraint).
    const { data: existing } = await supabase
      .from("diagnoses")
      .select("id")
      .eq("upload_id", uploadId)
      .maybeSingle();

    if (existing) {
      router.push(`/diagnosis/${existing.id}`);
      return;
    }

    const {
      data: { session },
    } = await supabase.auth.getSession();
    if (!session) {
      setStage({
        name: "error",
        message: "Sesi berakhir, silakan masuk ulang.",
        retry: () => setStage({ name: "idle" }),
      });
      return;
    }

    try {
      const result = await diagnose({
        uploadId,
        imagePath: path,
        cropType,
        accessToken: session.access_token,
      });
      router.push(`/diagnosis/${result.diagnosis.id}`);
    } catch (err) {
      const message = err instanceof MlServiceError ? err.message : "Gagal menjalankan diagnosis.";
      setStage({ name: "error", message, retry: () => runDiagnose(uploadId, path, cropType) });
    }
  }

  async function retryInsertOnly(zone: Tables<"zones">, path: string) {
    const supabase = createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) return;

    setStage({ name: "uploading" });
    const { data: uploadRow, error } = await supabase
      .from("uploads")
      .insert({ zone_id: zone.id, uploaded_by: user.id, image_path: path })
      .select()
      .single();

    if (error || !uploadRow) {
      setStage({
        name: "error",
        message: `Gagal menyimpan data unggahan: ${error?.message ?? ""}`,
        retry: () => retryInsertOnly(zone, path),
      });
      return;
    }
    await runDiagnose(uploadRow.id, path, zone.crop_type);
  }

  async function runUploadFlow(file: File) {
    if (!zone) {
      setStage({
        name: "error",
        message: "Pilih zona dulu sebelum unggah foto.",
        retry: () => setStage({ name: "idle" }),
      });
      return;
    }
    if (!ACCEPTED_TYPES.includes(file.type)) {
      setStage({
        name: "error",
        message: "Format file harus JPG atau PNG.",
        retry: () => setStage({ name: "idle" }),
      });
      return;
    }
    if (file.size > MAX_SIZE_BYTES) {
      setStage({
        name: "error",
        message: "Ukuran file maksimum 10MB.",
        retry: () => setStage({ name: "idle" }),
      });
      return;
    }

    const supabase = createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    const {
      data: { session },
    } = await supabase.auth.getSession();

    if (!user || !session) {
      setStage({
        name: "error",
        message: "Sesi berakhir, silakan masuk ulang.",
        retry: () => setStage({ name: "idle" }),
      });
      return;
    }

    setStage({ name: "uploading" });

    const ext = file.name.split(".").pop() || "jpg";
    const path = `${user.id}/${zone.id}/${Date.now()}.${ext}`;

    const { error: uploadError } = await supabase.storage
      .from("plant-photos")
      .upload(path, file, { contentType: file.type });

    if (uploadError) {
      setStage({
        name: "error",
        message: `Gagal mengunggah foto: ${uploadError.message}`,
        retry: () => runUploadFlow(file),
      });
      return;
    }

    const { data: uploadRow, error: insertError } = await supabase
      .from("uploads")
      .insert({ zone_id: zone.id, uploaded_by: user.id, image_path: path })
      .select()
      .single();

    if (insertError || !uploadRow) {
      setStage({
        name: "error",
        message: `Gagal menyimpan data unggahan: ${insertError?.message ?? ""}`,
        retry: () => retryInsertOnly(zone, path),
      });
      return;
    }

    await runDiagnose(uploadRow.id, path, zone.crop_type);
  }

  if (stage.name === "uploading" || stage.name === "diagnosing") {
    return (
      <div className="flex h-60 flex-col items-center justify-center gap-3 rounded-lg border-2 border-dashed border-panel-body bg-dropzone-bg">
        <div className="h-8 w-8 animate-spin rounded-full border-2 border-moss border-t-transparent" />
        <span className="font-sans text-[15px] font-medium text-ink">
          {stage.name === "uploading" ? "Mengunggah foto…" : "Menjalankan diagnosis…"}
        </span>
      </div>
    );
  }

  if (stage.name === "error") {
    return (
      <div className="flex h-60 flex-col items-center justify-center gap-3 rounded-lg border-2 border-dashed border-rust bg-dropzone-bg px-8 text-center">
        <span className="font-sans text-[14px] text-rust-text">{stage.message}</span>
        <button
          type="button"
          onClick={stage.retry}
          className="rounded-sm border border-moss px-5 py-2 font-sans text-[13.5px] font-semibold text-moss"
        >
          Coba lagi
        </button>
      </div>
    );
  }

  return (
    <div
      onDragOver={(e) => {
        e.preventDefault();
        setDragOver(true);
      }}
      onDragLeave={() => setDragOver(false)}
      onDrop={(e) => {
        e.preventDefault();
        setDragOver(false);
        const file = e.dataTransfer.files?.[0];
        if (file) runUploadFlow(file);
      }}
      onClick={() => inputRef.current?.click()}
      className={`flex h-60 cursor-pointer flex-col items-center justify-center gap-2.5 rounded-lg border-2 border-dashed bg-dropzone-bg transition-colors ${
        dragOver ? "border-moss" : "border-panel-body"
      }`}
    >
      <input
        ref={inputRef}
        type="file"
        accept="image/jpeg,image/png"
        className="hidden"
        onChange={(e) => {
          const file = e.target.files?.[0];
          if (file) runUploadFlow(file);
        }}
      />
      <div className="flex h-14 w-14 items-center justify-center rounded-full bg-moss-tint">
        <CameraIcon size={26} className="text-moss" />
      </div>
      <span className="font-sans text-[16px] font-semibold text-ink">
        Seret foto ke sini atau klik untuk memilih file
      </span>
      <span className="font-sans text-[13px] text-sage">Format JPG, PNG — maksimum 10MB</span>
      <span className="mt-1.5 rounded-sm border border-moss px-5 py-2 font-sans text-[13.5px] font-semibold text-moss">
        Pilih File
      </span>
    </div>
  );
}
