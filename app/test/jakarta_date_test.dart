import 'package:agrivision_app/core/utils/jakarta_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toJakartaDateString', () {
    test('UTC 17:30 (00:30 hari berikutnya di Jakarta, UTC+7) bergeser ke hari berikutnya', () {
      // 2026-09-22 17:30 UTC == 2026-09-23 00:30 WIB.
      final utc = DateTime.utc(2026, 9, 22, 17, 30);
      expect(toJakartaDateString(utc), '2026-09-23');
    });

    test('UTC 16:59 (masih 23:59 di Jakarta) belum berpindah hari', () {
      final utc = DateTime.utc(2026, 9, 22, 16, 59);
      expect(toJakartaDateString(utc), '2026-09-22');
    });

    test('tengah hari UTC tidak dekat batas hari mana pun', () {
      final utc = DateTime.utc(2026, 1, 15, 4, 0);
      // 04:00 UTC + 7 jam = 11:00 WIB, masih tanggal yang sama.
      expect(toJakartaDateString(utc), '2026-01-15');
    });
  });

  group('parseDateOnly', () {
    test('parse sebagai tengah malam LOKAL, bukan UTC', () {
      final parsed = parseDateOnly('2026-09-23');
      expect(parsed.year, 2026);
      expect(parsed.month, 9);
      expect(parsed.day, 23);
      expect(parsed.isUtc, isFalse);
    });
  });

  group('jakartaWeekStart', () {
    test('Selasa mundur ke Senin minggu yang sama', () {
      // 2026-09-22 adalah Selasa.
      final utc = DateTime.utc(2026, 9, 22, 3, 0); // 10:00 WIB Selasa
      final weekStart = jakartaWeekStart(utc);
      expect(weekStart.weekday, DateTime.monday);
      expect(weekStart.day, 21);
    });
  });
}
