import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/severity_tokens.dart';
import '../../../data/models/dashboard_summary.dart';
import '../../../routing/route_paths.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/icons.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../shared/widgets/status_dot.dart';

/// Diurutkan skor kesehatan TERENDAH dulu (paling butuh perhatian) -- pola
/// yang sudah terbukti berguna di web, dipakai lagi di sini walau skalanya
/// jauh lebih kecil (zona milik satu petani).
class ZoneStatusList extends StatelessWidget {
  const ZoneStatusList({super.key, required this.zones});
  final List<ZoneStatusSummary> zones;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 4),
            child: Text('Status zona', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
          ),
          if (zones.isEmpty)
            const EmptyState(message: 'Belum ada zona. Tambahkan lewat tab Profil.')
          else
            ...List.generate(zones.length, (i) {
              final z = zones[i];
              final isLast = i == zones.length - 1;
              return InkWell(
                onTap: () => context.push(RoutePaths.zonaDetailPath(z.zone.id)),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : const Border(bottom: BorderSide(color: AppColors.borderAlt)),
                  ),
                  child: Row(
                    children: [
                      StatusDot(
                        color: z.status != null
                            ? SeverityTokens.zoneStatusDot(z.status!)
                            : AppColors.navInactive,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(z.zone.displayLabel, style: const TextStyle(fontSize: 13)),
                      ),
                      if (z.isTrendingUp)
                        const Icon(AppIcons.trendUp, size: 16, color: AppColors.moss)
                      else if (z.isTrendingDown)
                        const Icon(AppIcons.trendDown, size: 16, color: AppColors.rust),
                      const Icon(AppIcons.chevronRight, size: 18, color: AppColors.navInactive),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
