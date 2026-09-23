import 'package:flutter/material.dart';

/// Ikon Material outlined (stroke-thin, konsisten dengan estetika minimalis
/// design system) dipakai untuk navigasi & aksi -- ilustrasi daun/blob
/// custom-painted terpisah di `features/diagnosis/widgets/leaf_illustration_card.dart`
/// karena itu satu-satunya elemen visual yang WAJIB pixel-faithful.
abstract final class AppIcons {
  static const home = Icons.home_outlined;
  static const camera = Icons.camera_alt_outlined;
  static const history = Icons.history_outlined;
  static const person = Icons.person_outline;
  static const bell = Icons.notifications_outlined;
  static const chevronRight = Icons.chevron_right;
  static const chevronDown = Icons.keyboard_arrow_down;
  static const back = Icons.arrow_back;
  static const warning = Icons.warning_amber_rounded;
  static const leaf = Icons.eco_outlined;
  static const grid = Icons.grid_view_outlined;
  static const trendUp = Icons.trending_up;
  static const trendDown = Icons.trending_down;
  static const trendFlat = Icons.trending_flat;
  static const close = Icons.close;
  static const add = Icons.add;
  static const edit = Icons.edit_outlined;
  static const lock = Icons.lock_outline;
  static const logout = Icons.logout;
  static const gallery = Icons.photo_library_outlined;
  static const check = Icons.check_circle_outline;
  static const filter = Icons.filter_list;
  static const book = Icons.menu_book_outlined;
  static const bugReport = Icons.bug_report_outlined;
  static const emptyBox = Icons.inbox_outlined;
  static const errorIcon = Icons.error_outline;
  static const wifiOff = Icons.wifi_off;
}
