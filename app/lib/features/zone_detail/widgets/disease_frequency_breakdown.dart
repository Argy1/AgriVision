import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../data/models/disease_frequency_entry.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/state_views.dart';

class DiseaseFrequencyBreakdown extends StatelessWidget {
  const DiseaseFrequencyBreakdown({super.key, required this.entries});
  final List<DiseaseFrequencyEntry> entries;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Frekuensi Penyakit', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            const EmptyState(message: 'Belum ada riwayat diagnosis di zona ini.')
          else
            ...entries.map((e) {
              final maxCount = entries.first.count;
              final ratio = maxCount == 0 ? 0.0 : e.count / maxCount;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(e.diseaseName, style: const TextStyle(fontSize: 12.5)),
                        ),
                        Text('${e.count}x', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 6,
                        backgroundColor: AppColors.severityMeterInactive,
                        color: AppColors.mossMid,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
