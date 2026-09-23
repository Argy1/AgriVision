import 'package:agrivision_app/core/theme/color_tokens.dart';
import 'package:agrivision_app/core/theme/severity_tokens.dart';
import 'package:agrivision_app/data/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeverityTokens', () {
    test('ringan/sehat selalu Moss', () {
      expect(SeverityTokens.dotColor(SeverityLevel.ringan), AppColors.moss);
      expect(SeverityTokens.zoneStatusDot(ZoneStatus.sehat), AppColors.moss);
    });

    test('sedang/waspada selalu Ochre', () {
      expect(SeverityTokens.dotColor(SeverityLevel.sedang), AppColors.ochre);
      expect(SeverityTokens.zoneStatusDot(ZoneStatus.waspada), AppColors.ochre);
    });

    test('parah/perlu_tindakan selalu Rust', () {
      expect(SeverityTokens.dotColor(SeverityLevel.parah), AppColors.rust);
      expect(SeverityTokens.zoneStatusDot(ZoneStatus.perluTindakan), AppColors.rust);
    });

    test('trio Moss/Ochre/Rust tidak pernah tertukar antar level', () {
      final dotColors = SeverityLevel.values.map(SeverityTokens.dotColor).toSet();
      expect(dotColors.length, 3, reason: 'setiap severity harus punya warna unik');
    });
  });
}
