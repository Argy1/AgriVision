import 'package:intl/intl.dart';

import 'jakarta_date.dart';

abstract final class Formatters {
  static final DateFormat _fullIndonesianDate = DateFormat(
    'EEEE, d MMMM y',
    'id_ID',
  );
  static final DateFormat _shortIndonesianDate = DateFormat('d MMM', 'id_ID');
  static final DateFormat _time = DateFormat('HH:mm', 'id_ID');

  /// "Selasa, 22 September 2026" -- dari waktu UTC, ditampilkan dalam kalender
  /// Jakarta.
  static String fullDateJakarta(DateTime utc) =>
      _fullIndonesianDate.format(toJakartaTime(utc));

  static String shortDate(DateTime dateOnly) =>
      _shortIndonesianDate.format(dateOnly);

  static String timeJakarta(DateTime utc) => _time.format(toJakartaTime(utc));

  /// Sapaan berdasarkan jam Jakarta saat ini.
  static String greeting() {
    final hour = toJakartaTime(DateTime.now().toUtc()).hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 19) return 'Selamat sore';
    return 'Selamat malam';
  }

  /// "hari ini, 08:12" / "3 hari lalu" / "19 menit lalu" -- relatif terhadap
  /// sekarang, memakai kalender Jakarta untuk batas "hari ini".
  static String relativeOrTime(DateTime utc) {
    final now = DateTime.now().toUtc();
    final diff = now.difference(utc);
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return m <= 0 ? 'baru saja' : '$m menit lalu';
    }
    if (diff.inHours < 24 && toJakartaDateString(utc) == toJakartaDateString(now)) {
      return 'hari ini, ${timeJakarta(utc)}';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    }
    return fullDateJakarta(utc);
  }

  static String percent(double value) => '${value.toStringAsFixed(0)}%';

  static String healthScore(double? value) =>
      value == null ? '—' : '${value.toStringAsFixed(0)}/100';
}
