import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/icons.dart';

class UploadTipsCard extends StatelessWidget {
  const UploadTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Tips foto yang baik', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
          SizedBox(height: 10),
          _TipRow(text: 'Pencahayaan cukup, hindari bayangan'),
          SizedBox(height: 8),
          _TipRow(text: 'Fokus pada bagian daun yang bermasalah'),
          SizedBox(height: 12),
          Text(
            'Hanya untuk daun tomat. Foto yang tidak dikenali sebagai daun tomat (mis. cabai) akan ditolak. '
            'Bila model ragu, hasil tetap ditampilkan dengan peringatan — verifikasi ke penyuluh (PPL). '
            'Setelah memilih foto, geser kotak ke satu daun supaya buah, tangan, atau mulsa tidak ikut dinilai.',
            style: TextStyle(fontSize: 12, color: AppColors.tipText, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(AppIcons.check, size: 16, color: AppColors.moss),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, color: AppColors.tipText, height: 1.4),
          ),
        ),
      ],
    );
  }
}
