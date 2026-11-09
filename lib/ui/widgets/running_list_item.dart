import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/running_record.dart';

class RunningListItem extends StatelessWidget {
  final RunningRecord record;
  final VoidCallback onTap;

  const RunningListItem({
    super.key,
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.35)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단: 일시 및 기기 태그
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      record.dateFormatted,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getDeviceIcon(record.source),
                            size: 11,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            record.source,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 러닝 타이틀
                Text(
                  record.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),

                // 주요 지표 4칸 (거리, 페이스, 시간, 심박수)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric('거리', '${record.distanceKmFormatted} km', isHighlight: true),
                    _buildMetric('페이스', record.paceFormatted),
                    _buildMetric('시간', record.durationFormatted),
                    _buildMetric('평균심박', '${record.avgHeartRate} bpm'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            fontSize: isHighlight ? 15 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _getDeviceIcon(String source) {
    final lower = source.toLowerCase();
    if (lower.contains('apple') || lower.contains('watch')) {
      return Icons.watch_outlined;
    } else if (lower.contains('garmin')) {
      return Icons.navigation_outlined;
    } else {
      return Icons.fitness_center_outlined;
    }
  }
}
