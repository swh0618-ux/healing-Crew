import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/pace_split.dart';

class PaceSplitChart extends StatelessWidget {
  final List<PaceSplit> splits;
  final int avgPaceSeconds;

  const PaceSplitChart({
    super.key,
    required this.splits,
    required this.avgPaceSeconds,
  });

  @override
  Widget build(BuildContext context) {
    if (splits.isEmpty) {
      return const SizedBox.shrink();
    }

    final fastestSplit = splits.map((s) => s.durationSeconds).reduce((a, b) => a < b ? a : b);
    final slowestSplit = splits.map((s) => s.durationSeconds).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1km 구간별 페이스 (Lap Splits)',
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
            children: [
              // 헤더
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text('구간', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ),
                    Expanded(
                      child: Text('페이스 그래프', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ),
                    SizedBox(
                      width: 65,
                      child: Text('페이스', textAlign: TextAlign.right, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text('심박', textAlign: TextAlign.right, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 8),

              ...splits.map((s) => _buildSplitRow(s, fastestSplit, slowestSplit)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSplitRow(PaceSplit split, int fastest, int slowest) {
    // 상대적 바 길이 (빠를수록 더 길게 표현)
    final range = (slowest - fastest).clamp(10, 120);
    final diff = slowest - split.durationSeconds;
    final ratio = 0.45 + (diff / range) * 0.55;

    final isFastest = split.durationSeconds == fastest;
    final barColor = isFastest ? AppColors.primary : AppColors.accent.withOpacity(0.85);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '${split.kilometerIndex} km',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: ratio.clamp(0.2, 1.0),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 65,
            child: Text(
              split.paceFormatted,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isFastest ? AppColors.primaryLight : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: isFastest ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              split.avgHeartRate > 0 ? '${split.avgHeartRate} bpm' : '--',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
