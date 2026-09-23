import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/severity_tokens.dart';
import '../../../data/models/diagnosis_list_item.dart';
import '../../../routing/route_paths.dart';

/// Strip dot histori 5 diagnosis terakhir di zona yang sama -- pengayaan di
/// atas mockup 7, dot berwarna sesuai severity, tap untuk lompat.
class DiagnosisHistoryDotStrip extends StatelessWidget {
  const DiagnosisHistoryDotStrip({super.key, required this.items, required this.currentId});

  final List<DiagnosisListItem> items;
  final String currentId;

  @override
  Widget build(BuildContext context) {
    if (items.length < 2) return const SizedBox.shrink();
    return Row(
      children: [
        const Text('Histori zona:', style: TextStyle(fontSize: 11.5, color: Color(0xFF8B9280))),
        const SizedBox(width: 8),
        ...items.map((d) {
          final isCurrent = d.diagnosisId == currentId;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: isCurrent ? null : () => context.push(RoutePaths.diagnosisResultPath(d.diagnosisId)),
              child: Container(
                width: isCurrent ? 10 : 8,
                height: isCurrent ? 10 : 8,
                decoration: BoxDecoration(
                  color: SeverityTokens.dotColor(d.severity),
                  shape: BoxShape.circle,
                  border: isCurrent ? Border.all(color: Colors.black26, width: 1.4) : null,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
