import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/diagnosis_list_item.dart';
import '../../../routing/route_paths.dart';
import '../../../shared/widgets/severity_chip.dart';

class HistoryListTile extends StatelessWidget {
  const HistoryListTile({super.key, required this.item});
  final DiagnosisListItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(RoutePaths.diagnosisResultPath(item.diagnosisId)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.diseaseName, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    '${item.zoneName} · ${Formatters.relativeOrTime(item.createdAt)}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.sage),
                  ),
                ],
              ),
            ),
            SeverityChip(severity: item.severity),
          ],
        ),
      ),
    );
  }
}
