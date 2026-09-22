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
        "flex-1 rounded-md border p-4.5 box-border",
        attention ? "border-rust-divider bg-rust-soft" : "border-border-soft bg-paper",
      )}
    >
      {icon}
      <div
        className={cn(
          "mt-3 font-display text-[26px] font-semibold",
          attention ? "text-rust-text" : "text-ink",
        )}
      >
        {value}
        {suffix && <span className="font-sans text-[14px] font-normal text-sage">{suffix}</span>}
      </div>
      <div className={cn("font-sans text-[12.5px]", attention ? "text-rust-text" : "text-sage")}>
        {label}
      </div>
    </div>
  );
}
