import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../data/models/zone_health_daily.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/state_views.dart';

/// Tren histori PENUH satu zona (bukan dibatasi 30 hari seperti dashboard) --
/// memaksimalkan Modul 2 (monitoring).
class ZoneTrendChartCard extends StatelessWidget {
  const ZoneTrendChartCard({super.key, required this.history});
  final List<ZoneHealthDaily> history;

  @override
  Widget build(BuildContext context) {
    final withValue = history.where((h) => h.avgHealthScore != null).toList();

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tren kesehatan zona', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            withValue.isEmpty ? '' : '${withValue.length} hari data terekam',
            style: const TextStyle(fontSize: 11, color: AppColors.sage),
          ),
          const SizedBox(height: 10),
          if (withValue.length < 2)
            const EmptyState(message: 'Belum ada cukup data untuk menampilkan tren.')
          else
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.borderAlt, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 50,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 9, color: AppColors.sage),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < withValue.length; i++)
                          FlSpot(i.toDouble(), withValue[i].avgHealthScore!),
                      ],
                      isCurved: true,
                      color: AppColors.moss,
                      barWidth: 2.2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: AppColors.mossTint.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
