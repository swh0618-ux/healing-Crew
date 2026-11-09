import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/running_record.dart';
import '../widgets/heart_rate_chart.dart';
import '../widgets/pace_split_chart.dart';

class RunningDetailScreen extends StatelessWidget {
  final RunningRecord record;

  const RunningDetailScreen({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '러닝 상세 분석',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 러닝 헤더 (타이틀, 일시, 기기 소스)
          _buildHeader(),
          const SizedBox(height: 16),

          // 핵심 4대 메트릭 하이라이트
          _buildPrimaryMetrics(),
          const SizedBox(height: 16),

          // 세부 메트릭 (심박수, 케이던스, 고도 등)
          _buildSecondaryMetrics(),
          const SizedBox(height: 24),

          // 심박수 차트 및 5개 심박 존
          HeartRateChart(
            samples: record.heartRateSamples,
            avgHeartRate: record.avgHeartRate,
            maxHeartRate: record.maxHeartRate,
            zones: record.heartRateZones,
          ),
          const SizedBox(height: 24),

          // 1km 구간별 페이스 스플릿
          PaceSplitChart(
            splits: record.splits,
            avgPaceSeconds: record.avgPaceSecondsPerKm,
          ),
          const SizedBox(height: 24),

          // 힐링 메모 카드
          if (record.memo != null && record.memo!.isNotEmpty) ...[
            _buildMemoCard(),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.dateFormatted,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record.source,
                  style: const TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            record.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryMetrics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceVariant,
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          // 상단: 거리 대형 표시
          Center(
            child: Column(
              children: [
                const Text(
                  '총 달린 거리',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      record.distanceKmFormatted,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'km',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),

          // 하단 3개 메트릭 (시간, 평균 페이스, 칼로리)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricColumn('러닝 시간', record.durationFormatted),
              _buildMetricColumn('평균 페이스', record.paceFormatted),
              _buildMetricColumn('소모 칼로리', Formatters.formatCalories(record.caloriesKcal)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSmallMetric('평균 심박', '${record.avgHeartRate} bpm', Icons.favorite_rounded, AppColors.zone4Threshold),
          _buildSmallMetric('최대 심박', '${record.maxHeartRate} bpm', Icons.show_chart_rounded, AppColors.zone5Max),
          _buildSmallMetric('케이던스', '${record.cadence} spm', Icons.directions_walk_rounded, AppColors.accent),
          _buildSmallMetric('획득 고도', '${record.elevationGainMeters.round()} m', Icons.terrain_rounded, AppColors.zone2FatBurn),
        ],
      ),
    );
  }

  Widget _buildSmallMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildMemoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                '러닝 다이어리 & 회고 메모',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            record.memo!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
