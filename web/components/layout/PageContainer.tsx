import { cn } from "@/lib/cn";

/**
 * Bungkus isi halaman di area (app). Di layar < lg halaman mengalir mengikuti scroll
 * jendela (ada top bar, bukan sidebar); di lg+ tinggi dikunci setinggi layar dan
 * isinya scroll sendiri di samping sidebar tetap.
 */
export function PageContainer({
  className,
  ...props
}: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        "flex flex-col gap-5 p-4 pb-16 sm:p-6 sm:pb-16 lg:h-screen lg:overflow-y-auto lg:p-9 lg:pb-16",
        className,
      )}
      {...props}
    />
  );
}
