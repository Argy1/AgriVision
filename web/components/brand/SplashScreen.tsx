import { Mascot } from "@/components/brand/Mascot";

/**
 * Splash 3 detik, SEKALI per sesi browser. Murni CSS (globals.css: .av-splash, splash-out):
 * tidak menahan pemuatan halaman — halaman sudah tampil di belakangnya dan splash memudar
 * setelah ±3 detik. Skrip kecil di app/layout.tsx memberi html[data-splash="seen"] pada
 * pemuatan berikutnya di sesi yang sama sehingga splash tidak tampil lagi.
 */
export function SplashScreen() {
  return (
    <div
      className="av-splash fixed inset-0 z-[100] flex flex-col items-center justify-center overflow-hidden bg-night"
      aria-hidden
    >
      <div
        className="absolute inset-0 scale-110 bg-cover bg-center opacity-35 blur-[2px]"
        style={{ backgroundImage: "url(/images/latar-sawah.webp)" }}
      />
      <div className="absolute inset-0 bg-gradient-to-b from-night/40 via-night/70 to-night" />

      <div className="relative flex flex-col items-center px-6 text-center">
        <div className="av-splash-pop">
          <Mascot size={170} pose="wave" />
        </div>
        <p className="av-splash-pop mt-5 font-display text-[40px] font-semibold tracking-tight text-panel-headline sm:text-[48px]" style={{ animationDelay: "0.15s" }}>
          Agri<span className="text-straw">Vision</span>
        </p>
        <p className="av-splash-pop mt-2 max-w-[320px] font-sans text-[15px] leading-relaxed text-panel-body" style={{ animationDelay: "0.3s" }}>
          Mata cerdas untuk daun tomat — kenali penyakit sejak dini.
        </p>
        <div className="mt-8 h-1.5 w-48 overflow-hidden rounded-pill bg-white/15">
          <div className="av-splash-bar h-full origin-left rounded-pill bg-straw" />
        </div>
        <p className="mt-3 font-sans text-[12px] tracking-wide text-panel-caption">Menyiapkan kebun digital Anda…</p>
      </div>
    </div>
  );
}
