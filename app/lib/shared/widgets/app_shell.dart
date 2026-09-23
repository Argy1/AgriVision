import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/color_tokens.dart';
import '../../routing/route_paths.dart';
import 'icons.dart';

/// Shell dengan bottom nav 4 item TETAP sesuai mockup (Beranda/Unggah/
/// Riwayat/Profil) -- Detail Zona, Panduan Penyakit, Notifikasi, dan layar
/// auth diakses sebagai pushed route DI ATAS shell ini, bukan tab baru.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    RoutePaths.beranda,
    RoutePaths.unggah,
    RoutePaths.riwayat,
    RoutePaths.profil,
  ];

  int _indexFor(String location) {
    final index = _tabs.indexWhere((t) => location.startsWith(t));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexFor(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.paper,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: AppIcons.home,
                  label: 'Beranda',
                  selected: currentIndex == 0,
                  onTap: () => context.go(RoutePaths.beranda),
                ),
                _NavItem(
                  icon: AppIcons.camera,
                  label: 'Unggah',
                  selected: currentIndex == 1,
                  onTap: () => context.go(RoutePaths.unggah),
                ),
                _NavItem(
                  icon: AppIcons.history,
                  label: 'Riwayat',
                  selected: currentIndex == 2,
                  onTap: () => context.go(RoutePaths.riwayat),
                ),
                _NavItem(
                  icon: AppIcons.person,
                  label: 'Profil',
                  selected: currentIndex == 3,
                  onTap: () => context.go(RoutePaths.profil),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.moss : AppColors.navInactive;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
