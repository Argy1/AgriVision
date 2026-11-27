/**
 * Daftar batang horizontal (HTML, bukan Recharts): label di atas batang supaya nama
 * penyakit yang panjang tidak memakan lebar plot di layar HP/tablet.
 *
 * Warna netral (moss-mid) -- SENGAJA bukan moss/ochre/rust, supaya urutan frekuensi
 * ini tidak salah dibaca sebagai indikator severity/status.
 */
export function DiseaseFrequencyChart({
  data,
}: {
  data: { disease_name: string; count: number }[];
}) {
  if (data.length === 0) {
    return (
      <div className="flex h-[260px] items-center justify-center text-center font-sans text-[13px] text-sage">
        Belum ada data diagnosis pada rentang ini.
      </div>
    );
  }

  const max = Math.max(...data.map((d) => d.count), 1);

  return (
    <ul className="flex flex-col gap-3.5" aria-label="Distribusi penyakit">
      {data.map((d) => (
        <li key={d.disease_name}>
          <div className="mb-1 flex items-baseline justify-between gap-3">
            <span className="min-w-0 break-words font-sans text-[12.5px] text-ink">{d.disease_name}</span>
            <span className="shrink-0 font-sans text-[12.5px] font-semibold text-sage">{d.count}×</span>
          </div>
          <div className="h-2 w-full rounded-pill bg-meter-inactive/60">
            <div
              className="h-2 rounded-pill bg-ink/70"
              style={{ width: `${Math.max(3, (d.count / max) * 100)}%` }}
            />
          </div>
        </li>
      ))}
    </ul>
  );
}
