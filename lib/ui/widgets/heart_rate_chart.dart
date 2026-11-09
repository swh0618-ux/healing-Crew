import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../models/heart_rate_zone.dart';

class HeartRateChart extends StatelessWidget {
  final List<int> samples;
  final int avgHeartRate;
  final int maxHeartRate;
  final List<HeartRateZoneDistribution> zones;

  const HeartRateChart({
    super.key,
    required this.samples,
    required this.avgHeartRate,
    required this.maxHeartRate,
    required this.zones,
  });

  @override
  Widget build(BuildContext context) {
    // 실제 샘플 데이터 최소/최대값 기반 동적 Y축 스케일링
    final actualMin = samples.isNotEmpty ? samples.reduce((a, b) => a < b ? a : b) : 80;
    final actualMax = samples.isNotEmpty ? samples.reduce((a, b) => a > b ? a : b) : 180;
    final computedMinY = (actualMin - 10).clamp(40, 190).toDouble();
    final computedMaxY = (actualMax + 10).clamp(100, 240).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 심박수 시계열 라인 차트
        if (samples.length >= 2) ...[
          const Text(
            '심박수 변화 추이',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 180,
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(0.3)),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (val, meta) {
                        if (val % 30 == 0) {
                          return Text(
                            '${val.toInt()}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: computedMinY,
                maxY: computedMaxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      samples.length,
                      (i) => FlSpot(i.toDouble(), samples[i].toDouble()),
                    ),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.zone4Threshold,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.zone4Threshold.withOpacity(0.3),
                          AppColors.zone4Threshold.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // 5단계 심박 존 분포
        const Text(
          '심박 구간별 체류 시간 (Heart Rate Zones)',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: Column(
            children: zones.map((z) => _buildZoneRow(z)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildZoneRow(HeartRateZoneDistribution zone) {
    final minutes = zone.durationSeconds ~/ 60;
    final seconds = zone.durationSeconds % 60;
    final timeStr = "$minutes분 ${seconds.toString().padLeft(2, '0')}초";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: zone.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    zone.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '$timeStr (${zone.percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (zone.percentage / 100.0).clamp(0.0, 1.0),
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(zone.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
