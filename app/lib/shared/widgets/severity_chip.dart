import 'package:flutter/material.dart';

import '../../core/theme/severity_tokens.dart';
import '../../data/models/enums.dart';

class SeverityChip extends StatelessWidget {
  const SeverityChip({super.key, required this.severity});
  final SeverityLevel severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: SeverityTokens.pillBg(severity),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        'Tingkat ${severity.label.toLowerCase()}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: SeverityTokens.pillText(severity),
        ),
      ),
    );
  }
}

class ConfidenceChip extends StatelessWidget {
  const ConfidenceChip({super.key, required this.confidence});
  final double confidence;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E2DA),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '${(confidence * 100).round()}% keyakinan',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8A3B22),
        ),
      ),
    );
  }
}

class ZoneStatusPill extends StatelessWidget {
  const ZoneStatusPill({super.key, required this.status});
  final ZoneStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: SeverityTokens.zoneStatusPillBg(status),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: SeverityTokens.zoneStatusPillText(status),
        ),
      ),
    );
  }
}
