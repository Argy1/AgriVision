"use client";

import { useId } from "react";

import { cn } from "@/lib/cn";

/**
 * "Si Tomat" — maskot AgriVision: tomat bercaping (petani), daun di kepala, membawa kaca
 * pembesar (diagnosis). SVG buatan sendiri (bebas lisensi). Warna maskot (tomat, jerami, daun)
 * HANYA untuk ilustrasi — bukan warna status; trio moss/ochre/rust tetap khusus severity.
 *
 * pose: "wave"  = melambai (sapaan, splash, landing)
 *       "lens"  = mengintip lewat kaca pembesar (diagnosis, unggah)
 *       "happy" = kedua tangan terangkat (berhasil / kosong yang ramah)
 * Animasi (CSS di globals.css) mati otomatis bila pengguna memilih prefers-reduced-motion.
 */
export function Mascot({
  size = 160,
  pose = "wave",
  animated = true,
  className,
  title = "Si Tomat, maskot AgriVision",
}: {
  size?: number;
  pose?: "wave" | "lens" | "happy";
  animated?: boolean;
  className?: string;
  title?: string;
}) {
  const id = useId().replace(/:/g, "");
  const body = `mb-${id}`;
  const glass = `mg-${id}`;
  const lensRight = pose === "lens";

  return (
    <svg
      viewBox="0 0 200 230"
      width={size}
      height={(size * 230) / 200}
      role="img"
      aria-label={title}
      className={cn("overflow-visible", animated && "mascot-animated", className)}
    >
      <defs>
        <radialGradient id={body} cx="38%" cy="32%" r="75%">
          <stop offset="0%" stopColor="#F47A5F" />
          <stop offset="55%" stopColor="#E5533D" />
          <stop offset="100%" stopColor="#B93A27" />
        </radialGradient>
        <radialGradient id={glass} cx="35%" cy="35%" r="70%">
          <stop offset="0%" stopColor="#FFFFFF" stopOpacity="0.85" />
          <stop offset="100%" stopColor="#CFE8F0" stopOpacity="0.45" />
        </radialGradient>
      </defs>

      {/* bayangan tanah */}
      <ellipse className="mascot-shadow" cx="100" cy="218" rx="46" ry="7" fill="#20261B" opacity="0.18" />

      <g className="mascot-bob">
        {/* kaki */}
        <ellipse cx="80" cy="203" rx="13" ry="7" fill="#33472B" />
        <ellipse cx="120" cy="203" rx="13" ry="7" fill="#33472B" />

        {/* lengan kiri (melambai / terangkat) */}
        <g className={pose === "lens" ? undefined : "mascot-wave"} style={{ transformOrigin: "44px 140px" }}>
          <path
            d={pose === "lens" ? "M44 142 C30 150 26 162 30 172" : "M44 140 C28 126 22 108 26 94"}
            stroke="#33472B"
            strokeWidth="6"
            strokeLinecap="round"
            fill="none"
          />
          <circle cx={pose === "lens" ? 30 : 26} cy={pose === "lens" ? 174 : 91} r="8" fill="#5C7A4E" />
        </g>

        {/* badan tomat */}
        <path
          d="M100 82 C58 82 34 110 34 146 C34 182 62 202 100 202 C138 202 166 182 166 146 C166 110 142 82 100 82 Z"
          fill={`url(#${body})`}
        />
        {/* lekuk tomat */}
        <path d="M100 86 C92 110 92 170 100 198" stroke="#B93A27" strokeWidth="2" opacity="0.25" fill="none" />
        <path d="M70 92 C58 118 60 172 74 194" stroke="#B93A27" strokeWidth="2" opacity="0.18" fill="none" />
        <path d="M130 92 C142 118 140 172 126 194" stroke="#B93A27" strokeWidth="2" opacity="0.18" fill="none" />
        {/* kilau */}
        <ellipse cx="72" cy="112" rx="14" ry="9" fill="#FFFFFF" opacity="0.35" transform="rotate(-28 72 112)" />

        {/* kelopak (daun tomat) di bawah caping */}
        <path
          d="M100 84 L84 74 L94 84 L72 82 L92 90 L82 98 L100 90 L118 98 L108 90 L128 82 L106 84 L116 74 Z"
          fill="#4F8A3F"
        />

        {/* caping (topi petani) */}
        <g className="mascot-hat">
          <path d="M28 80 Q100 58 172 80 Q100 92 28 80 Z" fill="#B8914A" opacity="0.55" />
          <path d="M30 78 L100 30 L170 78 Q100 90 30 78 Z" fill="#E8C77E" stroke="#B8914A" strokeWidth="2" strokeLinejoin="round" />
          <path d="M100 30 L64 79 M100 30 L82 81 M100 30 L100 82 M100 30 L118 81 M100 30 L136 79" stroke="#C9A35E" strokeWidth="1.5" />
          <path d="M52 64 Q100 54 148 64" stroke="#C9A35E" strokeWidth="1.5" fill="none" />
          {/* tunas daun menembus puncak caping */}
          <g className="mascot-sprout" style={{ transformOrigin: "100px 32px" }}>
            <path d="M100 32 C100 24 100 18 101 12" stroke="#33472B" strokeWidth="3" strokeLinecap="round" fill="none" />
            <path d="M101 16 C110 6 124 6 128 10 C122 18 110 20 101 16 Z" fill="#5C9A4A" />
            <path d="M100 20 C92 12 80 13 76 17 C82 24 93 24 100 20 Z" fill="#4F8A3F" />
          </g>
        </g>

        {/* wajah */}
        <g className="mascot-eyes" style={{ transformOrigin: "100px 132px" }}>
          <ellipse cx="80" cy="132" rx="7" ry="9" fill="#2A1D17" />
          <ellipse cx="120" cy="132" rx="7" ry="9" fill="#2A1D17" />
          <circle cx="82.5" cy="128.5" r="2.6" fill="#FFFFFF" />
          <circle cx="122.5" cy="128.5" r="2.6" fill="#FFFFFF" />
        </g>
        <ellipse cx="66" cy="152" rx="9" ry="5.5" fill="#FF9F8F" opacity="0.7" />
        <ellipse cx="134" cy="152" rx="9" ry="5.5" fill="#FF9F8F" opacity="0.7" />
        <path
          d={pose === "happy" ? "M86 152 Q100 170 114 152 Q100 160 86 152 Z" : "M88 154 Q100 166 112 154"}
          stroke="#2A1D17"
          strokeWidth="3.2"
          strokeLinecap="round"
          fill={pose === "happy" ? "#7A2A1C" : "none"}
        />

        {/* lengan kanan + kaca pembesar */}
        <g className="mascot-lens" style={{ transformOrigin: "156px 146px" }}>
          <path
            d={lensRight ? "M156 146 C166 132 162 118 150 112" : "M156 146 C172 150 180 160 182 170"}
            stroke="#33472B"
            strokeWidth="6"
            strokeLinecap="round"
            fill="none"
          />
          <g transform={lensRight ? "translate(118 84)" : "translate(160 150)"}>
            <rect x="22" y="26" width="8" height="26" rx="4" fill="#8A5A2B" transform="rotate(-40 26 39)" />
            <circle cx="18" cy="18" r="17" fill={`url(#${glass})`} stroke="#5B4632" strokeWidth="4" />
            <path d="M10 12 Q14 6 21 6" stroke="#FFFFFF" strokeWidth="2.5" strokeLinecap="round" fill="none" opacity="0.9" />
            {/* daun kecil di dalam lensa */}
            <path d="M12 24 C14 16 22 14 26 16 C24 24 18 27 12 24 Z" fill="#4F8A3F" opacity="0.8" />
          </g>
          <circle cx={lensRight ? 148 : 182} cy={lensRight ? 112 : 172} r="8" fill="#5C7A4E" />
        </g>
      </g>
    </svg>
  );
}
