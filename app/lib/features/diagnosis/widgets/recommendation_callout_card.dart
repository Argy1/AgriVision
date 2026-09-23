import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../data/models/recommendation.dart';
import '../../../shared/widgets/icons.dart';

class RecommendationCalloutCard extends StatelessWidget {
  const RecommendationCalloutCard({super.key, required this.recommendation});
  final Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.rustTintSoft,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border(left: BorderSide(color: AppColors.rust, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rekomendasi Penanganan',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.rustDarkText),
          ),
          const SizedBox(height: 8),
          _row(
            recommendation.dosage != null
                ? '${recommendation.recommendationText} — dosis ${recommendation.dosage}'
                : recommendation.recommendationText,
          ),
          if (recommendation.applicationSchedule != null) ...[
            const SizedBox(height: 6),
            _row(recommendation.applicationSchedule!),
          ],
          if (recommendation.warningNote != null) ...[
            const SizedBox(height: 6),
            _row(recommendation.warningNote!),
          ],
        ],
      ),
    );
  }

  Widget _row(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(AppIcons.bugReport, size: 15, color: AppColors.rustText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, color: AppColors.rustDarkText, height: 1.4),
          ),
        ),
      ],
    );
  }
}
