/// Helper tanggal Asia/Jakarta (UTC+7 tetap, tanpa DST) -- WAJIB dipakai untuk
/// apa pun yang menyentuh `zone_health_daily.date` atau batas "hari ini"/
/// "minggu ini", supaya tidak kena bug class yang sama dengan yang sudah
/// diperbaiki di web (`toIsoString()`/UTC vs tanggal lokal Jakarta yang
/// disimpan trigger DB).
library;

const _jakartaOffset = Duration(hours: 7);

/// Konversi timestamp UTC (atau timestamp apa pun) ke waktu lokal Jakarta.
DateTime toJakartaTime(DateTime utc) => utc.toUtc().add(_jakartaOffset);

/// String tanggal "YYYY-MM-DD" dalam kalender Jakarta -- cocok dengan format
/// yang dipakai kolom `date` di tabel `zone_health_daily`.
String toJakartaDateString(DateTime utc) {
  final jakarta = toJakartaTime(utc);
  final y = jakarta.year.toString().padLeft(4, '0');
  final m = jakarta.month.toString().padLeft(2, '0');
  final d = jakarta.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// "Hari ini" dalam kalender Jakarta, sebagai string "YYYY-MM-DD".
String jakartaTodayString() => toJakartaDateString(DateTime.now().toUtc());

/// N hari sebelum hari ini (kalender Jakarta), sebagai string "YYYY-MM-DD".
String jakartaDateMinusDays(int days) {
  final nowJakarta = toJakartaTime(DateTime.now().toUtc());
  final target = nowJakarta.subtract(Duration(days: days));
  return toJakartaDateString(target.subtract(_jakartaOffset));
}

/// Awal minggu (Senin) dalam kalender Jakarta untuk sebuah timestamp UTC,
/// dipakai untuk agregasi mingguan (mis. tren severity).
DateTime jakartaWeekStart(DateTime utc) {
  final jakarta = toJakartaTime(utc);
  final daysFromMonday = jakarta.weekday - DateTime.monday;
  final mondayLocal = DateTime(jakarta.year, jakarta.month, jakarta.day)
      .subtract(Duration(days: daysFromMonday));
  return mondayLocal;
}

/// Parse string "YYYY-MM-DD" sebagai tengah malam LOKAL (bukan UTC), supaya
/// tidak bergeser hari saat ditampilkan di berbagai zona waktu device.
DateTime parseDateOnly(String yyyyMmDd) {
  final parts = yyyyMmDd.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}
