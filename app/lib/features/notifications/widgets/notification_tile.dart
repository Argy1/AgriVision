import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/app_notification.dart';
import '../../../routing/route_paths.dart';
import '../../../shared/widgets/icons.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification});
  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final isSevere = notification.type == NotificationType.severeDiagnosis;
    return InkWell(
      onTap: () => notification.diagnosisId != null
          ? context.push(RoutePaths.diagnosisResultPath(notification.diagnosisId!))
          : context.push(RoutePaths.zonaDetailPath(notification.zoneId)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(color: AppColors.rustTintSoft, shape: BoxShape.circle),
              child: Icon(
                isSevere ? AppIcons.bugReport : AppIcons.warning,
                size: 17,
                color: AppColors.rust,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(notification.message, style: const TextStyle(fontSize: 12, color: AppColors.sage)),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.relativeOrTime(notification.createdAt),
                    style: const TextStyle(fontSize: 11, color: AppColors.navInactive),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
