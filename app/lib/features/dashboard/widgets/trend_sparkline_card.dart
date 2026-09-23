import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../data/models/dashboard_summary.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/state_views.dart';

/// Sparkline tanpa axis/gridlines/legend, satu garis Moss, dot di titik
/// terakhir -- persis mockup dashboard.
class TrendSparklineCard extends StatelessWidget {
  const TrendSparklineCard({super.key, required this.points, required this.days});
  final List<TrendPoint> points;
  final int days;

  @override
  Widget build(BuildContext context) {
    final withValue = points.where((p) => p.value != null).toList();

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tren $days hari terakhir',
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (withValue.length < 2)
            const EmptyState(message: 'Belum ada cukup data kesehatan tanaman.')
          else
            SizedBox(
              height: 90,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < withValue.length; i++)
                          FlSpot(i.toDouble(), withValue[i].value!),
                      ],
                      isCurved: true,
                      color: AppColors.moss,
                      barWidth: 2.4,
                      dotData: FlDotData(
                        show: true,
                        checkToShowDot: (spot, data) => spot.x == withValue.length - 1,
                        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.moss,
                          strokeWidth: 0,
                        ),
                      ),
                      belowBarData: BarAreaData(show: false),
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
