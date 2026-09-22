// Ikon hand-authored, direproduksi persis dari design/screens/*.html (stroke-width
// per-ikon TIDAK dinormalisasi -- disalin apa adanya supaya konsisten dengan mockup).
import type { SVGProps } from "react";

export type IconProps = SVGProps<SVGSVGElement> & { size?: number };

function base(size: number | undefined, props: IconProps) {
  // props sudah tidak punya `size` -- setiap ikon men-destructure { size, ...props }
  // sebelum memanggil helper ini.
  return { width: size ?? 18, height: size ?? 18, viewBox: "0 0 24 24", ...props };
}

export function LeafLogoIcon({ size, ...props }: IconProps) {
  return (
    <svg
      {...base(size, props)}
      fill="none"
      stroke="currentColor"
      strokeWidth={1.7}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M5 19C5 9 12 5 20 4c1 8-3 15-13 15-1 0-2 0-2 0z" />
      <path d="M6 18C10 14 14 10 19 5.5" />
    </svg>
  );
}

export function GridIcon({ size, ...props }: IconProps) {
  return (
    <svg
      {...base(size, props)}
      fill="none"
      stroke="currentColor"
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <rect x="4" y="4" width="7" height="7" rx="1" />
      <rect x="13" y="4" width="7" height="7" rx="1" />
      <rect x="4" y="13" width="7" height="7" rx="1" />
      <rect x="13" y="13" width="7" height="7" rx="1" />
    </svg>
  );
}

export function CameraIcon({ size, ...props }: IconProps) {
  return (
    <svg
      {...base(size, props)}
      fill="none"
      stroke="currentColor"
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <rect x="3" y="7" width="18" height="13" rx="2" />
      <path d="M8 7l1.5-2.5h5L16 7" />
      <circle cx="12" cy="13.5" r="3.2" />
    </svg>
  );
}

export function ClockIcon({ size, ...props }: IconProps) {
  return (
    <svg
      {...base(size, props)}
      fill="none"
      stroke="currentColor"
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <circle cx="12" cy="12" r="8.5" />
      <path d="M12 7.5V12l3 2" />
    </svg>
  );
}

export function SlidersIcon({ size, ...props }: IconProps) {
  return (
    <svg {...base(size, props)} fill="none" stroke="currentColor" strokeWidth={1.6} strokeLinecap="round">
      <path d="M4 7h10M18 7h2M4 17h2M10 17h10" />
      <circle cx="16" cy="7" r="2" />
      <circle cx="8" cy="17" r="2" />
    </svg>
  );
}

// Ikon baru (tidak ada di mockup) untuk /monitoring dan /analitik -- dibuat manual
// dengan gaya stroke yang sama (bukan lucide) supaya sidebar tetap satu set kustom.
export function TrendLineIcon({ size, ...props }: IconProps) {
  return (
    <svg
      {...base(size, props)}
      fill="none"
      stroke="currentColor"
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M4 16l5-6 4 3 7-9" />
      <path d="M15 4h5v5" />
    </svg>
  );
}

export function BarChartIcon({ size, ...props }: IconProps) {
  return (
    <svg
      {...base(size, props)}
      fill="none"
      stroke="currentColor"
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M4 20V10M12 20V4M20 20v-7" />
    </svg>
  );
}

export function ChevronRightIcon({ size, ...props }: IconProps) {
  return (
    <svg {...base(size, props)} fill="none" stroke="currentColor" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round">
      <path d="M9 5l7 7-7 7" />
    </svg>
  );
}

export function ChevronDownIcon({ size, ...props }: IconProps) {
  return (
    <svg {...base(size, props)} fill="none" stroke="currentColor" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round">
      <path d="M6 9l6 6 6-6" />
    </svg>
  );
}

export function BackArrowIcon({ size, ...props }: IconProps) {
  return (
    <svg
      {...base(size, props)}
      fill="none"
      stroke="currentColor"
      strokeWidth={1.8}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M19 12H5" />
      <path d="M11 6l-6 6 6 6" />
    </svg>
  );
}

export function CheckCircleIcon({ size, ...props }: IconProps) {
  return (
    <svg
      {...base(size, props)}
      fill="none"
      stroke="currentColor"
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <circle cx="12" cy="12" r="8.5" />
      <path d="M8.5 12.3l2.3 2.3 4.7-5" />
    </svg>
  );
}

export function WarningTriangleIcon({ size, ...props }: IconProps) {
  return (
    <svg
      {...base(size, props)}
      fill="none"
      stroke="currentColor"
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M12 4.5 21 19H3z" strokeLinejoin="round" />
      <path d="M12 10v4" />
    </svg>
  );
}

export function DropletIcon({ size, ...props }: IconProps) {
  return (
    <svg
      {...base(size, props)}
      fill="none"
      stroke="currentColor"
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M12 3.5C9 8 6 11.3 6 14.8a6 6 0 0012 0c0-3.5-3-6.8-6-11.3z" />
    </svg>
  );
}

export function CalendarIcon({ size, ...props }: IconProps) {
  return (
    <svg
      {...base(size, props)}
      fill="none"
      stroke="currentColor"
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <rect x="3.5" y="5.5" width="17" height="15" rx="2" />
      <path d="M3.5 10h17M8 3.5v4M16 3.5v4" />
    </svg>
  );
}

export function SearchIcon({ size, ...props }: IconProps) {
  return (
    <svg
      {...base(size, props)}
      fill="none"
      stroke="currentColor"
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <circle cx="10.5" cy="10.5" r="6" />
      <path d="M20 20l-5-5" />
    </svg>
  );
}
