import { format, isSameDay, subDays } from "date-fns";
import { id as idLocale } from "date-fns/locale";

/** Date yang jam & tanggal LOKAL-nya sama dengan jam dinding Asia/Jakarta, di zona
 * waktu server mana pun. Fungsi format di bawah sering jalan di server component;
 * di Vercel server memakai UTC, jadi tanpa ini jam tampil mundur 7 jam dan tanggal
 * bisa mundur sehari. Hanya untuk ditampilkan -- jangan disimpan/dikirim balik. */
export function inJakarta(date: Date): Date {
  return new Date(date.toLocaleString("en-US", { timeZone: "Asia/Jakarta" }));
}

/** "Hari ini, 07:40" / "Kemarin, 16:05" / "12 Sep, 08:12" -- persis gaya di mockup. */
export function formatRelativeDateTime(iso: string) {
  const date = inJakarta(new Date(iso));
  const today = inJakarta(new Date());
  const time = format(date, "HH:mm");
  if (isSameDay(date, today)) return `Hari ini, ${time}`;
  if (isSameDay(date, subDays(today, 1))) return `Kemarin, ${time}`;
  return format(date, "d MMM, HH:mm", { locale: idLocale });
}

/** "2 jam lalu" / "3 hari lalu" -- dipakai di aktivitas terbaru dashboard. */
export function formatTimeAgo(iso: string) {
  const diffMs = Date.now() - new Date(iso).getTime();
  const minutes = Math.floor(diffMs / 60000);
  if (minutes < 1) return "Baru saja";
  if (minutes < 60) return `${minutes} menit lalu`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours} jam lalu`;
  const days = Math.floor(hours / 24);
  return `${days} hari lalu`;
}

/** "Selasa, 22 September 2026" -- header dashboard. */
export function formatLongDate(date: Date) {
  return format(inJakarta(date), "EEEE, d MMMM yyyy", { locale: idLocale });
}

/** Parse "YYYY-MM-DD" sebagai tengah malam waktu LOKAL, bukan UTC -- `new
 * Date("2026-09-23")` tanpa ini di-parse sebagai UTC, yang bisa mundur satu
 * hari saat ditampilkan di timezone ber-offset negatif. Dipakai khusus untuk
 * label chart (date-only string dari zone_health_daily/analytics), bukan untuk
 * timestamp lengkap yang sudah punya info timezone sendiri. */
export function parseDateOnly(dateStr: string): Date {
  return new Date(`${dateStr}T00:00:00`);
}

export function daysSince(iso: string) {
  const diffMs = Date.now() - new Date(iso).getTime();
  return Math.max(0, Math.floor(diffMs / (1000 * 60 * 60 * 24)));
}
