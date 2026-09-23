import 'package:flutter/widgets.dart';

import '../../data/models/enums.dart';
import 'color_tokens.dart';

/// Satu-satunya sumber pemetaan warna severity/status di seluruh app --
/// port persis dari `web/components/severity/tokens.ts`.
///
/// ATURAN KERAS (jangan dilanggar): Moss = sehat/ringan, Ochre = waspada/sedang,
/// Rust = perlu tindakan/parah. Trio ini TIDAK BOLEH dipakai untuk makna lain
/// di mana pun (chart, chip, dot, meter lain).
abstract final class SeverityTokens {
  static Color dotColor(SeverityLevel severity) => switch (severity) {
    SeverityLevel.ringan => AppColors.moss,
    SeverityLevel.sedang => AppColors.ochre,
    SeverityLevel.parah => AppColors.rust,
  };

  static Color pillBg(SeverityLevel severity) => switch (severity) {
    SeverityLevel.ringan => AppColors.mossTint,
    SeverityLevel.sedang => AppColors.ochreTint,
    SeverityLevel.parah => AppColors.rustTint,
  };

  static Color pillText(SeverityLevel severity) => switch (severity) {
    SeverityLevel.ringan => AppColors.mossDeep,
    SeverityLevel.sedang => AppColors.ochreText,
    SeverityLevel.parah => AppColors.rustText,
  };

  static Color zoneStatusDot(ZoneStatus status) => switch (status) {
    ZoneStatus.sehat => AppColors.moss,
    ZoneStatus.waspada => AppColors.ochre,
    ZoneStatus.perluTindakan => AppColors.rust,
  };

  static Color zoneStatusPillBg(ZoneStatus status) => switch (status) {
    ZoneStatus.sehat => AppColors.mossTint,
    ZoneStatus.waspada => AppColors.ochreTint,
    ZoneStatus.perluTindakan => AppColors.rustTint,
  };

  static Color zoneStatusPillText(ZoneStatus status) => switch (status) {
    ZoneStatus.sehat => AppColors.mossDeep,
    ZoneStatus.waspada => AppColors.ochreText,
    ZoneStatus.perluTindakan => AppColors.rustText,
  };
}
