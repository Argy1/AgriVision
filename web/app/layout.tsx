import type { Metadata } from "next";
import { Fraunces, IBM_Plex_Sans } from "next/font/google";

import { SplashScreen } from "@/components/brand/SplashScreen";

import "./globals.css";

const fraunces = Fraunces({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
  variable: "--font-fraunces",
  display: "swap",
});

const ibmPlexSans = IBM_Plex_Sans({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
  variable: "--font-ibm-plex-sans",
  display: "swap",
});

export const metadata: Metadata = {
  title: "AgriVision",
  description:
    "Diagnosis penyakit daun tomat dari foto, lengkap dengan rekomendasi penanganan dan pemantauan kesehatan kebun.",
};

// Dijalankan sebelum halaman dilukis: splash hanya tampil pada pemuatan PERTAMA di sesi
// browser ini. Gagal diam-diam bila sessionStorage tidak tersedia (splash tetap tampil sekali).
const SPLASH_ONCE = `try{if(sessionStorage.getItem("av-splash")){document.documentElement.dataset.splash="seen"}else{sessionStorage.setItem("av-splash","1")}}catch(e){}`;

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="id" className={`${fraunces.variable} ${ibmPlexSans.variable}`} suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: SPLASH_ONCE }} />
      </head>
      <body className="antialiased">
        <SplashScreen />
        {children}
      </body>
    </html>
  );
}
