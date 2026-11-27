"use client";

import { useRef, useState } from "react";
import type { PointerEvent as ReactPointerEvent } from "react";

import { Button } from "@/components/ui/Button";

/** Kotak potong dalam piksel ASLI foto (bukan piksel layar). */
interface Box {
  x: number;
  y: number;
  size: number;
}

const MIN_FRACTION = 0.25; // kotak terkecil = 25% sisi terpendek foto
const DEFAULT_FRACTION = 0.8;
const JPEG_QUALITY = 0.92;

function clampBox(box: Box, width: number, height: number): Box {
  const size = Math.min(box.size, width, height);
  return {
    size,
    x: Math.min(Math.max(box.x, 0), width - size),
    y: Math.min(Math.max(box.y, 0), height - size),
  };
}

function centeredBox(width: number, height: number, fraction: number): Box {
  const size = Math.round(Math.min(width, height) * fraction);
  return { size, x: Math.round((width - size) / 2), y: Math.round((height - size) / 2) };
}

async function cropToFile(image: HTMLImageElement, box: Box, originalName: string): Promise<File> {
  const canvas = document.createElement("canvas");
  canvas.width = Math.round(box.size);
  canvas.height = Math.round(box.size);
  const ctx = canvas.getContext("2d");
  if (!ctx) throw new Error("Peramban tidak mendukung pemotongan gambar.");
  ctx.drawImage(image, box.x, box.y, box.size, box.size, 0, 0, canvas.width, canvas.height);
  const blob = await new Promise<Blob | null>((resolve) => canvas.toBlob(resolve, "image/jpeg", JPEG_QUALITY));
  if (!blob) throw new Error("Gagal memotong foto.");
  const base = originalName.replace(/\.[^.]+$/, "") || "foto";
  return new File([blob], `${base}-potong.jpg`, { type: "image/jpeg" });
}

/**
 * Langkah potong foto sebelum diunggah: pengguna menggeser kotak persegi ke daun yang ingin
 * didiagnosis (buah, tangan, mulsa di luar kotak tidak ikut dinilai model), atau memakai foto utuh.
 */
export function CropPanel({
  file,
  imageUrl,
  onConfirm,
  onUseFull,
  onCancel,
}: {
  file: File;
  imageUrl: string;
  onConfirm: (cropped: File) => void;
  onUseFull: () => void;
  onCancel: () => void;
}) {
  const imgRef = useRef<HTMLImageElement>(null);
  const dragRef = useRef<{ pointerId: number; startX: number; startY: number; startBox: Box } | null>(null);
  const [natural, setNatural] = useState<{ width: number; height: number } | null>(null);
  const [box, setBox] = useState<Box | null>(null);
  const [fraction, setFraction] = useState(DEFAULT_FRACTION);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function handleLoad() {
    const img = imgRef.current;
    if (!img) return;
    const dims = { width: img.naturalWidth, height: img.naturalHeight };
    setNatural(dims);
    setBox(centeredBox(dims.width, dims.height, DEFAULT_FRACTION));
  }

  /** Ubah jarak geser di layar (px) ke piksel asli foto. */
  function toNatural(dxScreen: number, dyScreen: number) {
    const img = imgRef.current;
    if (!img || !natural) return { dx: 0, dy: 0 };
    const rect = img.getBoundingClientRect();
    return { dx: (dxScreen * natural.width) / rect.width, dy: (dyScreen * natural.height) / rect.height };
  }

  function handlePointerDown(e: ReactPointerEvent<HTMLDivElement>) {
    if (!box) return;
    e.currentTarget.setPointerCapture(e.pointerId);
    dragRef.current = { pointerId: e.pointerId, startX: e.clientX, startY: e.clientY, startBox: box };
  }

  function handlePointerMove(e: ReactPointerEvent<HTMLDivElement>) {
    const drag = dragRef.current;
    if (!drag || drag.pointerId !== e.pointerId || !natural) return;
    const { dx, dy } = toNatural(e.clientX - drag.startX, e.clientY - drag.startY);
    setBox(clampBox({ ...drag.startBox, x: drag.startBox.x + dx, y: drag.startBox.y + dy }, natural.width, natural.height));
  }

  function handlePointerUp(e: ReactPointerEvent<HTMLDivElement>) {
    if (dragRef.current?.pointerId === e.pointerId) dragRef.current = null;
  }

  function handleSize(nextFraction: number) {
    if (!box || !natural) return;
    setFraction(nextFraction);
    const size = Math.round(Math.min(natural.width, natural.height) * nextFraction);
    const cx = box.x + box.size / 2;
    const cy = box.y + box.size / 2;
    setBox(clampBox({ size, x: Math.round(cx - size / 2), y: Math.round(cy - size / 2) }, natural.width, natural.height));
  }

  async function handleConfirm() {
    const img = imgRef.current;
    if (!img || !box) return;
    setBusy(true);
    setError(null);
    try {
      onConfirm(await cropToFile(img, box, file.name));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal memotong foto.");
      setBusy(false);
    }
  }

  return (
    <div className="flex flex-col gap-4 rounded-lg border-2 border-dashed border-panel-body bg-dropzone-bg px-4 py-5 sm:px-6">
      <div>
        <p className="font-sans text-[15px] font-semibold text-ink">Pilih bagian daun yang akan didiagnosis</p>
        <p className="mt-1 font-sans text-[13px] text-sage">
          Geser kotak ke satu daun tomat dan atur ukurannya. Buah, tangan, atau mulsa di luar kotak tidak ikut dinilai.
        </p>
      </div>

      <div className="flex justify-center">
        <div className="relative inline-block max-w-full touch-none select-none overflow-hidden rounded-sm">
          {/* eslint-disable-next-line @next/next/no-img-element -- pratinjau blob lokal, bukan aset statis */}
          <img
            ref={imgRef}
            src={imageUrl}
            alt="Pratinjau foto yang akan dipotong"
            onLoad={handleLoad}
            draggable={false}
            className="block max-h-[420px] max-w-full rounded-sm"
          />
          {natural && box && (
            <>
              {/* Area di luar kotak digelapkan (4 lapisan: atas, bawah, kiri, kanan). */}
              {(() => {
                const left = (box.x / natural.width) * 100;
                const top = (box.y / natural.height) * 100;
                const w = (box.size / natural.width) * 100;
                const h = (box.size / natural.height) * 100;
                const dim = "pointer-events-none absolute bg-black/45";
                return (
                  <>
                    <div className={dim} style={{ left: 0, top: 0, width: "100%", height: `${top}%` }} />
                    <div className={dim} style={{ left: 0, top: `${top + h}%`, width: "100%", bottom: 0 }} />
                    <div className={dim} style={{ left: 0, top: `${top}%`, width: `${left}%`, height: `${h}%` }} />
                    <div className={dim} style={{ left: `${left + w}%`, top: `${top}%`, right: 0, height: `${h}%` }} />
                  </>
                );
              })()}
            <div
              role="slider"
              aria-label="Kotak potong (geser untuk memindahkan)"
              aria-valuemin={Math.round(MIN_FRACTION * 100)}
              aria-valuemax={100}
              aria-valuenow={Math.round(fraction * 100)}
              tabIndex={0}
              onPointerDown={handlePointerDown}
              onPointerMove={handlePointerMove}
              onPointerUp={handlePointerUp}
              onPointerCancel={handlePointerUp}
              className="absolute cursor-move rounded-sm border-2 border-white"
              style={{
                left: `${(box.x / natural.width) * 100}%`,
                top: `${(box.y / natural.height) * 100}%`,
                width: `${(box.size / natural.width) * 100}%`,
                height: `${(box.size / natural.height) * 100}%`,
              }}
            />
            </>
          )}
        </div>
      </div>

      <label className="flex items-center gap-3 font-sans text-[13px] text-ink">
        <span className="shrink-0">Ukuran kotak</span>
        <input
          type="range"
          min={MIN_FRACTION}
          max={1}
          step={0.01}
          value={fraction}
          disabled={!box}
          onChange={(e) => handleSize(Number(e.target.value))}
          className="w-full accent-moss"
        />
      </label>

      {error && <p className="font-sans text-[13px] text-rust-text">{error}</p>}

      <div className="flex flex-col-reverse gap-2.5 sm:flex-row sm:justify-end">
        <Button type="button" variant="ghost" onClick={onCancel} disabled={busy}>
          Batal
        </Button>
        <Button type="button" variant="outline" onClick={onUseFull} disabled={busy}>
          Pakai foto utuh
        </Button>
        <Button type="button" onClick={handleConfirm} disabled={!box} loading={busy}>
          Pakai bagian ini
        </Button>
      </div>
    </div>
  );
}
