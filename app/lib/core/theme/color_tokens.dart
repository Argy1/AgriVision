import 'package:flutter/widgets.dart';

/// Token warna persis dari `design/design-system.md` + nilai hex yang
/// ditemukan langsung di `design/screens/5-8-app-*.html`. Satu-satunya sumber
/// hex di seluruh app -- tidak ada widget lain yang boleh menulis `Color(0xFF...)`
/// secara langsung di luar file ini.
abstract final class AppColors {
  // Netral
  static const Color ink = Color(0xFF20261B);
  static const Color parchment = Color(0xFFEEEADC);
  static const Color paper = Color(0xFFFFFFFF);

  // Moss (brand utama, sehat/ringan)
  static const Color moss = Color(0xFF46603C);
  static const Color mossTint = Color(0xFFE7ECE0);
  static const Color mossDeep = Color(0xFF33472B);
  static const Color mossMid = Color(0xFF5C7A4E);

  // Ochre (waspada/sedang)
  static const Color ochre = Color(0xFFBD8A2E);
  static const Color ochreTint = Color(0xFFF3E8CE);
  static const Color ochreText = Color(0xFF8A6620);

  // Rust (perlu tindakan/parah)
  static const Color rust = Color(0xFFAE4F2E);
  static const Color rustTint = Color(0xFFF3E2DA);
  static const Color rustTintSoft = Color(0xFFFBF1EC);
  static const Color rustText = Color(0xFF8A3B22);
  static const Color rustDarkText = Color(0xFF452216);
  static const Color rustDivider = Color(0xFFE7CFC2);

  // Sage & border
  static const Color sage = Color(0xFF8B9280);
  static const Color sageAlt = Color(0xFF8B9A7E);
  static const Color border = Color(0xFFDED9C7);
  static const Color borderAlt = Color(0xFFE3DFCF);

  // Input
  static const Color inputBorder = Color(0xFFD7D2C2);
  static const Color inputBg = Color(0xFFFBFAF5);
  static const Color inputPlaceholder = Color(0xFFB0AA96);

  // Nav & lain-lain
  static const Color navInactive = Color(0xFFB7B2A0);
  static const Color leafStroke = Color(0xFF33472B);
  static const Color leafFill = Color(0xFF5C7A4E);
  static const Color dropzoneBorder = Color(0xFFB9C2A8);
  static const Color dropzoneBg = Color(0xFFF5F3E9);
  static const Color severityMeterInactive = Color(0xFFE7E0CC);
  static const Color viewfinderBracket = Color(0xFF8B9A7A);
  static const Color panelHeadline = Color(0xFFF5F2E6);
  static const Color tipText = Color(0xFF454F3E);
}
