import 'package:agrivision_app/features/diagnosis/widgets/leaf_illustration_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('leafBlobScale', () {
    test('35% -> skala 1.0 (satu-satunya titik data mockup)', () {
      expect(leafBlobScale(35), closeTo(1.0, 0.0001));
    });

    test('clamp bawah 0.4 untuk area sangat kecil', () {
      expect(leafBlobScale(0.6), greaterThanOrEqualTo(0.4));
      expect(leafBlobScale(0), 0.4);
    });

    test('clamp atas 1.6 untuk area sangat besar', () {
      expect(leafBlobScale(100), 1.6);
    });

    test('monoton naik seiring affectedAreaPct bertambah (dalam rentang belum clamp)', () {
      expect(leafBlobScale(10), lessThan(leafBlobScale(20)));
      expect(leafBlobScale(20), lessThan(leafBlobScale(35)));
    });
  });
}
