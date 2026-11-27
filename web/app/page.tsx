import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";

import { Mascot } from "@/components/brand/Mascot";
import {
  BarChartIcon,
  CameraIcon,
  CheckCircleIcon,
  ClockIcon,
  LeafLogoIcon,
  SearchIcon,
  TrendLineIcon,
} from "@/components/icons";
import { createClient } from "@/lib/supabase/server";

export const metadata: Metadata = {
  title: "AgriVision — Diagnosis Penyakit Daun Tomat",
};

const STEPS = [
  {
    no: "01",
    title: "Foto daun tomat",
    text: "Potret satu daun dari dekat, lalu geser kotak ke bagian daun yang ingin diperiksa.",
    pose: "wave" as const,
  },
  {
    no: "02",
    title: "AI memeriksa",
    text: "Penyaring memastikan itu daun tomat, lalu model mengenali 9 penyakit dan kondisi sehat.",
    pose: "lens" as const,
  },
  {
    no: "03",
    title: "Terima saran",
    text: "Dapatkan tingkat keparahan, skor kesehatan, dan rekomendasi penanganan bersumber.",
    pose: "happy" as const,
  },
];

const DISEASES = [
  { img: "/images/landing/pv-healthy.webp", name: "Daun sehat", note: "Hijau merata, tanpa bercak" },
  { img: "/images/landing/pv-early_blight.webp", name: "Early blight", note: "Bercak cokelat bercincin" },
  { img: "/images/landing/pv-late_blight.webp", name: "Late blight", note: "Busuk basah, cepat menyebar" },
  { img: "/images/landing/pv-septoria_leaf_spot.webp", name: "Septoria", note: "Bercak kecil berpusat abu-abu" },
  { img: "/images/landing/pv-bacterial_spot.webp", name: "Bercak bakteri", note: "Titik gelap bertepi kuning" },
  { img: "/images/landing/pv-tomato_yellow_leaf_curl_virus.webp", name: "Virus keriting kuning", note: "Daun menguning & mengeriting" },
];

const FEATURES = [
  {
    icon: SearchIcon,
    title: "Penyaring daun tomat",
    text: "Foto daun cabai, tanaman lain, atau benda acak ditolak sebelum didiagnosis.",
  },
  {
    icon: CameraIcon,
    title: "Potong ke satu daun",
    text: "Buah, tangan, atau mulsa di sekitar daun tidak ikut membingungkan model.",
  },
  {
    icon: TrendLineIcon,
    title: "Pantau per zona kebun",
    text: "Skor kesehatan harian per blok/bedengan, lengkap dengan grafik tren.",
  },
  {
    icon: CheckCircleIcon,
    title: "Rekomendasi bersumber",
    text: "Saran penanganan dari panduan Kementan–JICA dan pedoman PHT universitas.",
  },
  {
    icon: BarChartIcon,
    title: "Analitik penyakit",
    text: "Penyakit tersering dan tren keparahan per minggu untuk PPL dan petani.",
  },
  {
    icon: ClockIcon,
    title: "Riwayat lengkap",
    text: "Setiap diagnosis tersimpan beserta foto dan rekomendasinya.",
  },
];

export default async function LandingPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  const loggedIn = Boolean(user);
  const startHref = loggedIn ? "/upload" : "/login?redirectTo=%2Fupload";

  return (
    <div className="overflow-x-hidden bg-parchment text-ink">
      {/* ---------- Navigasi ---------- */}
      <header className="absolute inset-x-0 top-0 z-20">
        <nav className="mx-auto flex max-w-6xl items-center justify-between px-5 py-5 sm:px-8">
          <Link href="/" className="flex items-center gap-2.5">
            <span className="flex h-9 w-9 items-center justify-center rounded-full bg-parchment/90">
              <LeafLogoIcon size={18} className="text-ink" />
            </span>
            <span className="font-sans text-[19px] font-semibold text-white">AgriVision</span>
          </Link>
          <div className="hidden items-center gap-7 font-sans text-[14px] text-white/85 lg:flex">
            <a href="#cara-kerja" className="hover:text-white">Cara kerja</a>
            <a href="#penyakit" className="hover:text-white">Penyakit</a>
            <a href="#fitur" className="hover:text-white">Fitur</a>
            <a href="#tentang" className="hover:text-white">Tentang</a>
          </div>
          <Link
            href={loggedIn ? "/dashboard" : "/login"}
            className="rounded-pill border border-white/40 bg-white/10 px-4 py-2 font-sans text-[13.5px] font-semibold text-white backdrop-blur hover:bg-white/20"
          >
            {loggedIn ? "Buka Dashboard" : "Masuk"}
          </Link>
        </nav>
      </header>

      {/* ---------- Hero ---------- */}
      <section className="relative isolate overflow-hidden">
        <Image
          src="/images/latar-sawah.webp"
          alt="Hamparan sawah hijau berundak dengan gunung di kejauhan"
          fill
          priority
          sizes="100vw"
          className="-z-20 object-cover"
        />
        <div className="absolute inset-0 -z-10 bg-gradient-to-b from-night/85 via-night/75 to-night/55 lg:bg-gradient-to-r lg:from-night/90 lg:via-night/65 lg:to-night/20" />
        <div className="absolute inset-x-0 bottom-0 -z-10 h-24 bg-gradient-to-t from-parchment to-transparent" />

        <div className="mx-auto grid min-h-[640px] max-w-6xl items-center gap-10 px-5 pb-24 pt-28 sm:px-8 lg:grid-cols-[1.25fr_1fr] md:pt-32">
          <div className="rise-in">
            <div className="mb-4 lg:hidden">
              <Mascot size={92} pose="wave" />
            </div>
            <span className="inline-flex items-center gap-2 rounded-pill bg-white/10 px-3.5 py-1.5 font-sans text-[12.5px] font-medium text-straw ring-1 ring-white/20 backdrop-blur">
              <span className="h-1.5 w-1.5 rounded-full bg-straw" /> Asisten kebun tomat berbasis AI
            </span>
            <h1 className="mt-5 font-display text-[40px] font-semibold leading-[1.08] text-white sm:text-[56px]">
              Kenali penyakit daun tomat <span className="text-straw">lebih dini.</span>
            </h1>
            <p className="mt-5 max-w-[520px] font-sans text-[16px] leading-relaxed text-white/80 sm:text-[17px]">
              Cukup foto satu daun. AgriVision memeriksa penyakitnya, menilai tingkat keparahan, dan memberi
              saran penanganan — supaya panen tetap terjaga.
            </p>
            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
              <Link
                href={startHref}
                className="inline-flex items-center justify-center gap-2 rounded-sm bg-straw px-6 py-3.5 font-sans text-[15px] font-semibold text-ink shadow-lg shadow-black/20 transition hover:brightness-105"
              >
                <CameraIcon size={18} /> Mulai Diagnosis
              </Link>
              <Link
                href={loggedIn ? "/dashboard" : "/register"}
                className="inline-flex items-center justify-center rounded-sm border border-white/50 px-6 py-3.5 font-sans text-[15px] font-semibold text-white transition hover:bg-white/10"
              >
                {loggedIn ? "Buka Dashboard" : "Daftar gratis"}
              </Link>
            </div>
            <dl className="mt-10 grid max-w-[480px] grid-cols-3 gap-4 text-white">
              {[
                ["10", "kondisi daun dikenali"],
                ["3", "sumber data latih"],
                ["Gratis", "untuk petani"],
              ].map(([v, l]) => (
                <div key={l}>
                  <dt className="font-display text-[28px] font-semibold text-straw">{v}</dt>
                  <dd className="font-sans text-[12.5px] leading-snug text-white/70">{l}</dd>
                </div>
              ))}
            </dl>
          </div>

          <div className="rise-in relative mx-auto hidden lg:block" style={{ animationDelay: "0.15s" }}>
            <div className="absolute -inset-6 rounded-full bg-straw/25 blur-3xl" />
            <div className="relative rounded-[28px] bg-white/10 p-6 ring-1 ring-white/20 backdrop-blur-md">
              <Mascot size={250} pose="wave" />
              <div className="absolute -left-10 top-10 rounded-md bg-white px-3.5 py-2.5 shadow-xl">
                <p className="font-sans text-[11px] text-sage">Hasil diagnosis</p>
                <p className="font-sans text-[13.5px] font-semibold text-ink">Daun sehat</p>
              </div>
              <div className="absolute -right-8 bottom-12 rounded-md bg-white px-3.5 py-2.5 shadow-xl">
                <p className="font-sans text-[11px] text-sage">Skor kesehatan</p>
                <p className="font-display text-[20px] font-semibold text-ink">88/100</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ---------- Cara kerja ---------- */}
      <section id="cara-kerja" className="mx-auto max-w-6xl px-5 py-16 sm:px-8 sm:py-20">
        <p className="font-sans text-[13px] font-semibold uppercase tracking-[0.14em] text-moss">Cara kerja</p>
        <h2 className="mt-2 max-w-[560px] font-display text-[32px] font-semibold leading-tight sm:text-[38px]">
          Tiga langkah dari foto sampai saran penanganan
        </h2>
        <div className="mt-10 grid gap-5 md:grid-cols-3">
          {STEPS.map((s) => (
            <div
              key={s.no}
              className="group relative overflow-hidden rounded-xl border border-border-soft bg-paper p-6 transition hover:-translate-y-1 hover:shadow-lg"
            >
              <span className="font-display text-[44px] font-semibold text-moss-tint">{s.no}</span>
              <div className="absolute right-3 top-3 opacity-90 transition group-hover:scale-105">
                <Mascot size={92} pose={s.pose} animated={false} />
              </div>
              <h3 className="mt-2 font-display text-[21px] font-semibold">{s.title}</h3>
              <p className="mt-2 font-sans text-[14.5px] leading-relaxed text-tips-text">{s.text}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ---------- Dari kebun ---------- */}
      <section className="bg-ink py-16 text-white sm:py-20">
        <div className="mx-auto grid max-w-6xl items-center gap-10 px-5 sm:px-8 md:grid-cols-2">
          <div>
            <p className="font-sans text-[13px] font-semibold uppercase tracking-[0.14em] text-straw">Dari kebun sungguhan</p>
            <h2 className="mt-2 font-display text-[32px] font-semibold leading-tight sm:text-[38px]">
              Dirancang untuk foto kebun, bukan cuma foto laboratorium
            </h2>
            <p className="mt-4 font-sans text-[15.5px] leading-relaxed text-panel-body">
              Model dilatih dari gabungan foto laboratorium dan foto lapangan. Akurasi pada foto kebun naik jauh
              dibanding model yang hanya belajar dari foto lab — dan foto ramai bisa dipotong ke satu daun sebelum
              diperiksa.
            </p>
            <ul className="mt-6 flex flex-col gap-3 font-sans text-[14.5px] text-panel-headline">
              {[
                "Penyaring menolak foto yang bukan daun tomat",
                "Peringatan jujur bila model ragu",
                "Selalu disarankan konfirmasi ke penyuluh (PPL)",
              ].map((t) => (
                <li key={t} className="flex items-start gap-2.5">
                  <CheckCircleIcon size={18} className="mt-0.5 shrink-0 text-straw" /> {t}
                </li>
              ))}
            </ul>
          </div>
          <div className="grid grid-cols-2 gap-3">
            {[1, 2, 3, 4].map((n, i) => (
              <div key={n} className={`relative overflow-hidden rounded-lg ${i % 2 ? "mt-8" : ""}`}>
                <Image
                  src={`/images/landing/kebun-tomat-${n}.webp`}
                  alt="Tanaman tomat di kebun dengan mulsa plastik"
                  width={450}
                  height={600}
                  className="h-[230px] w-full object-cover transition duration-500 hover:scale-105 sm:h-[280px]"
                />
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ---------- Penyakit ---------- */}
      <section id="penyakit" className="mx-auto max-w-6xl px-5 py-16 sm:px-8 sm:py-20">
        <div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-end">
          <div>
            <p className="font-sans text-[13px] font-semibold uppercase tracking-[0.14em] text-moss">Yang dikenali</p>
            <h2 className="mt-2 font-display text-[32px] font-semibold leading-tight sm:text-[38px]">
              9 penyakit dan kondisi daun sehat
            </h2>
          </div>
          <p className="max-w-[380px] font-sans text-[14px] text-sage">
            Contoh di bawah dari dataset PlantVillage. Juga dikenali: jamur daun, bercak target, tungau, dan virus
            mosaik.
          </p>
        </div>
        <div className="mt-8 grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-6">
          {DISEASES.map((d) => (
            <figure key={d.name} className="overflow-hidden rounded-lg border border-border-soft bg-paper">
              <Image
                src={d.img}
                alt={`Contoh daun tomat: ${d.name}`}
                width={256}
                height={256}
                className="aspect-square w-full object-cover"
              />
              <figcaption className="p-3">
                <p className="font-sans text-[13.5px] font-semibold">{d.name}</p>
                <p className="mt-0.5 font-sans text-[12px] leading-snug text-sage">{d.note}</p>
              </figcaption>
            </figure>
          ))}
        </div>
      </section>

      {/* ---------- Fitur ---------- */}
      <section id="fitur" className="bg-moss-tint/60 py-16 sm:py-20">
        <div className="mx-auto max-w-6xl px-5 sm:px-8">
          <p className="font-sans text-[13px] font-semibold uppercase tracking-[0.14em] text-moss">Fitur</p>
          <h2 className="mt-2 max-w-[560px] font-display text-[32px] font-semibold leading-tight sm:text-[38px]">
            Semua yang dibutuhkan petani dan penyuluh
          </h2>
          <div className="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {FEATURES.map((f) => (
              <div key={f.title} className="rounded-xl border border-border-soft bg-paper p-5 transition hover:shadow-md">
                <span className="flex h-11 w-11 items-center justify-center rounded-md bg-ink text-straw">
                  <f.icon size={20} />
                </span>
                <h3 className="mt-4 font-sans text-[16px] font-semibold">{f.title}</h3>
                <p className="mt-1.5 font-sans text-[14px] leading-relaxed text-tips-text">{f.text}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ---------- Tentang ---------- */}
      <section
        id="tentang"
        className="mx-auto grid max-w-6xl items-center gap-10 px-5 py-16 sm:px-8 sm:py-20 md:grid-cols-[1fr_1.3fr]"
      >
        <div className="relative mx-auto">
          <div className="absolute inset-4 rounded-full bg-straw/40 blur-2xl" />
          <Mascot size={230} pose="lens" className="relative" />
        </div>
        <div>
          <p className="font-sans text-[13px] font-semibold uppercase tracking-[0.14em] text-moss">Tentang AgriVision</p>
          <h2 className="mt-2 font-display text-[32px] font-semibold leading-tight sm:text-[38px]">
            Alat bantu kebun yang terbuka soal kemampuannya
          </h2>
          <p className="mt-4 font-sans text-[15.5px] leading-relaxed text-tips-text">
            AgriVision dikembangkan sebagai Tugas Akhir program studi Teknologi Rekayasa Perangkat Lunak, Sekolah
            Vokasi IPB University. Model MobileNetV2 dilatih dari PlantVillage, PlantDoc, dan Tomato-Village. Hasil
            diagnosis adalah alat bantu — keputusan penanganan sebaiknya tetap dikonfirmasi ke penyuluh pertanian.
          </p>
          <div className="mt-6 flex flex-col gap-3 sm:flex-row">
            <Link
              href={startHref}
              className="inline-flex items-center justify-center gap-2 rounded-sm bg-moss px-6 py-3.5 font-sans text-[15px] font-semibold text-white hover:bg-moss-deep"
            >
              <CameraIcon size={18} /> Mulai Diagnosis
            </Link>
            {!loggedIn && (
              <Link
                href="/login"
                className="inline-flex items-center justify-center rounded-sm border border-moss px-6 py-3.5 font-sans text-[15px] font-semibold text-moss hover:bg-moss-tint"
              >
                Saya sudah punya akun
              </Link>
            )}
          </div>
        </div>
      </section>

      {/* ---------- Footer ---------- */}
      <footer className="border-t border-border bg-ink">
        <div className="mx-auto flex max-w-6xl flex-col gap-4 px-5 py-8 font-sans text-[12.5px] text-panel-caption sm:px-8 md:flex-row md:items-center md:justify-between">
          <div className="flex flex-wrap items-center gap-2.5 text-panel-headline">
            <LeafLogoIcon size={16} className="text-straw" />
            <span className="font-semibold">AgriVision</span>
            <span className="text-panel-caption">· Tugas Akhir TRPL, Sekolah Vokasi IPB University</span>
          </div>
          <p className="max-w-[560px] leading-relaxed">
            Contoh foto penyakit: PlantVillage (Hughes &amp; Salathé, 2015; CC BY-SA 3.0). Foto kebun: dokumentasi tim.
            Maskot &quot;Si Tomat&quot; dibuat untuk AgriVision.
          </p>
        </div>
      </footer>
    </div>
  );
}
