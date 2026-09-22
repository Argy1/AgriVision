import "server-only";

import { createClient } from "@/lib/supabase/server";
import type { Tables } from "@/types/database.types";

import { getUser } from "./auth";

const JAKARTA_DATE_FORMATTER = new Intl.DateTimeFormat("en-CA", {
  timeZone: "Asia/Jakarta",
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
});

/** "YYYY-MM-DD" untuk `date` di Asia/Jakarta -- HARUS dipakai di mana pun kode ini
 * membandingkan tanggal dengan `zone_health_daily.date`, karena trigger Postgres
 * (`upsert_zone_health_daily`) menyimpan tanggal itu dalam waktu Jakarta, bukan
 * UTC. `date.toISOString().slice(0,10)` SALAH di sini -- itu memotong ke tanggal
 * UTC, yang bisa selisih 1 hari dari tanggal Jakarta (apalagi kalau server ini
 * nanti dijalankan di Vercel/Railway yang defaultnya UTC, bukan di mesin dev ini). */
function toJakartaDateString(date: Date): string {
  return JAKARTA_DATE_FORMATTER.format(date);
}

/** Mundurkan `days` hari kalender dari tanggal Jakarta hari ini, dikembalikan
 * sebagai Date ber-anchor UTC-tengah-malam supaya aritmetika kalender (bukan
 * konversi zona waktu sungguhan) tetap sederhana dan bebas isu DST. */
function jakartaDateMinusDays(days: number): Date {
  const todayStr = toJakartaDateString(new Date());
  const anchor = new Date(`${todayStr}T00:00:00Z`);
  anchor.setUTCDate(anchor.getUTCDate() - days);
  return anchor;
}

/** Baris zone_health_daily TERBARU per zona (bukan cuma hari ini -- supaya zona
 * tanpa aktivitas hari ini tidak hilang dari status/ranking). RLS membatasi
 * hasilnya ke zona yang boleh dilihat user (sendiri, atau semua kalau admin_ppl). */
export async function getLatestZoneHealth() {
  await getUser();
  const supabase = await createClient();

  const { data: zones, error: zonesError } = await supabase
    .from("zones")
    .select("id, name, crop_type")
    .order("name");
  if (zonesError) throw new Error(zonesError.message);

  const { data: healthRows, error: healthError } = await supabase
    .from("zone_health_daily")
    .select("zone_id, date, avg_health_score, diagnosis_count, status")
    .order("date", { ascending: false });
  if (healthError) throw new Error(healthError.message);

  const latestByZone = new Map<string, Tables<"zone_health_daily">>();
  for (const row of healthRows) {
    if (!latestByZone.has(row.zone_id)) {
      latestByZone.set(row.zone_id, row as Tables<"zone_health_daily">);
    }
  }

  return zones.map((zone) => ({
    zone,
    health: latestByZone.get(zone.id) ?? null,
  }));
}

/** Data harian mentah zone_health_daily untuk N hari terakhir, lintas zona yang
 * dipilih (atau semua kalau tidak difilter). Dipakai oleh dashboard (agregat)
 * dan /monitoring (per-zona). */
export async function getZoneHealthHistory(days: number, zoneIds?: string[]) {
  await getUser();
  const supabase = await createClient();

  const sinceStr = toJakartaDateString(jakartaDateMinusDays(days));

  let query = supabase
    .from("zone_health_daily")
    .select("zone_id, date, avg_health_score, diagnosis_count, status")
    .gte("date", sinceStr)
    .order("date", { ascending: true });

  if (zoneIds && zoneIds.length > 0) {
    query = query.in("zone_id", zoneIds);
  }

  const { data, error } = await query;
  if (error) throw new Error(error.message);
  return data;
}

/** Ratakan avg_health_score lintas semua zona per tanggal, lalu forward-fill
 * tanggal yang tidak punya data sama sekali (tidak ada aktivitas hari itu di
 * zona manapun) supaya grafik tetap rapat 30 titik. Judgment call -- lihat
 * catatan rencana implementasi. */
export function buildDailyAverageSeries(
  rows: { date: string; avg_health_score: number | null }[],
  days: number,
) {
  const byDate = new Map<string, number[]>();
  for (const row of rows) {
    if (row.avg_health_score == null) continue;
    const list = byDate.get(row.date) ?? [];
    list.push(row.avg_health_score);
    byDate.set(row.date, list);
  }

  const series: { date: string; value: number | null }[] = [];
  let lastKnown: number | null = null;

  for (let i = days - 1; i >= 0; i--) {
    const key = toJakartaDateString(jakartaDateMinusDays(i));
    const values = byDate.get(key);
    if (values && values.length > 0) {
      lastKnown = values.reduce((a, b) => a + b, 0) / values.length;
    }
    series.push({ date: key, value: lastKnown });
  }

  return series;
}

/** Sama seperti buildDailyAverageSeries tapi per-zona (bukan diratakan lintas
 * zona) -- dipakai oleh /monitoring untuk grafik perbandingan multi-zona. */
export function buildPerZoneSeries(
  rows: { zone_id: string; date: string; avg_health_score: number | null }[],
  zoneIds: string[],
  days: number,
) {
  const byZoneDate = new Map<string, Map<string, number>>();
  for (const row of rows) {
    if (row.avg_health_score == null) continue;
    if (!byZoneDate.has(row.zone_id)) byZoneDate.set(row.zone_id, new Map());
    byZoneDate.get(row.zone_id)!.set(row.date, row.avg_health_score);
  }

  const dateKeys: string[] = [];
  for (let i = days - 1; i >= 0; i--) {
    dateKeys.push(toJakartaDateString(jakartaDateMinusDays(i)));
  }

  return zoneIds.map((zoneId) => {
    const dateMap = byZoneDate.get(zoneId) ?? new Map();
    let lastKnown: number | null = null;
    const points = dateKeys.map((date) => {
      if (dateMap.has(date)) lastKnown = dateMap.get(date)!;
      return { date, value: lastKnown };
    });
    return { zoneId, points };
  });
}

/** Delta rata-rata health_score 7 hari terakhir vs 7 hari sebelumnya -- dipakai
 * untuk panah tren naik/turun di ranking /monitoring. */
export function computeTrendDelta(points: { value: number | null }[]) {
  if (points.length < 14) return null;
  const recent = points.slice(-7).map((p) => p.value).filter((v): v is number => v != null);
  const prior = points.slice(-14, -7).map((p) => p.value).filter((v): v is number => v != null);
  if (recent.length === 0 || prior.length === 0) return null;
  const avg = (arr: number[]) => arr.reduce((a, b) => a + b, 0) / arr.length;
  return avg(recent) - avg(prior);
}
