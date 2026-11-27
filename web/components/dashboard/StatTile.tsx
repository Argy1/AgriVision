import { cn } from "@/lib/cn";

export function StatTile({
  icon,
  value,
  suffix,
  label,
  variant = "default",
}: {
  icon: React.ReactNode;
  value: React.ReactNode;
  suffix?: React.ReactNode;
  label: string;
  variant?: "default" | "attention";
}) {
  const attention = variant === "attention";
  return (
    <div
      className={cn(
        "box-border flex-1 rounded-xl border p-4.5 shadow-[0_1px_2px_rgba(32,38,27,0.04),0_10px_28px_-18px_rgba(32,38,27,0.18)] transition hover:-translate-y-0.5",
        attention ? "border-rust-divider bg-rust-soft" : "border-border-soft bg-paper",
      )}
    >
      <span
        className={cn(
          "flex h-10 w-10 items-center justify-center rounded-full",
          attention ? "bg-rust-tint" : "bg-parchment",
        )}
      >
        {icon}
      </span>
      <div
        className={cn(
          "mt-3 font-display text-[28px] font-semibold leading-none",
          attention ? "text-rust-text" : "text-ink",
        )}
      >
        {value}
        {suffix && <span className="font-sans text-[14px] font-normal text-sage">{suffix}</span>}
      </div>
      <div className={cn("mt-1.5 font-sans text-[12.5px]", attention ? "text-rust-text" : "text-sage")}>{label}</div>
    </div>
  );
}
