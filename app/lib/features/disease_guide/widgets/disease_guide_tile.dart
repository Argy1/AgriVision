import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../data/models/disease_reference.dart';
import '../../../shared/widgets/icons.dart';

class DiseaseGuideTile extends StatelessWidget {
  const DiseaseGuideTile({super.key, required this.entry});
  final DiseaseReference entry;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 14),
        leading: Icon(
          entry.isHealthyEntry ? AppIcons.check : AppIcons.bugReport,
          color: entry.isHealthyEntry ? AppColors.moss : AppColors.rust,
          size: 20,
        ),
        title: Text(entry.diseaseName, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        subtitle: entry.isVerified
            ? const Text('Terverifikasi', style: TextStyle(fontSize: 11, color: AppColors.moss))
            : null,
        children: [
          if (entry.description != null) ...[
            Text(entry.description!, style: const TextStyle(fontSize: 12.5, height: 1.5)),
            const SizedBox(height: 10),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.rustTintSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rekomendasi Penanganan',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.rustDarkText),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.dosage != null
                      ? '${entry.recommendationText} — dosis ${entry.dosage}'
                      : entry.recommendationText,
                  style: const TextStyle(fontSize: 12, color: AppColors.rustDarkText, height: 1.4),
                ),
                if (entry.applicationSchedule != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.applicationSchedule!,
                    style: const TextStyle(fontSize: 12, color: AppColors.rustDarkText, height: 1.4),
                  ),
                ],
                if (entry.warningNote != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.warningNote!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.rustDarkText,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
