import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class HeartRateZoneDistribution {
  final int zoneIndex; // 1 ~ 5
  final String title; // 존 이름 (예: Warm-up, Aerobic)
  final String description; // 설명
  final int durationSeconds; // 해당 존에 머문 시간 (초)
  final double percentage; // 전체 운동 시간 중 비율 (%)
  final Color color;

  const HeartRateZoneDistribution({
    required this.zoneIndex,
    required this.title,
    required this.description,
    required this.durationSeconds,
    required this.percentage,
    required this.color,
  });

  static List<HeartRateZoneDistribution> calculate({
    required List<int> heartRateSamples,
    required int totalSeconds,
    int maxHeartRate = 190,
  }) {
    if (heartRateSamples.isEmpty || totalSeconds <= 0) {
      return _emptyZones();
    }

    int z1Count = 0;
    int z2Count = 0;
    int z3Count = 0;
    int z4Count = 0;
    int z5Count = 0;

    for (final bpm in heartRateSamples) {
      final ratio = bpm / maxHeartRate;
      if (ratio < 0.60) {
        z1Count++;
      } else if (ratio < 0.70) {
        z2Count++;
      } else if (ratio < 0.80) {
        z3Count++;
      } else if (ratio < 0.90) {
        z4Count++;
      } else {
        z5Count++;
      }
    }

    final totalSamples = heartRateSamples.length;

    return [
      HeartRateZoneDistribution(
        zoneIndex: 1,
        title: 'Zone 1 (회복/워밍업)',
        description: '< 60% HRmax (< 114 bpm)',
        durationSeconds: ((z1Count / totalSamples) * totalSeconds).round(),
        percentage: (z1Count / totalSamples) * 100,
        color: AppColors.zone1WarmUp,
      ),
      HeartRateZoneDistribution(
        zoneIndex: 2,
        title: 'Zone 2 (지방 연소/이지)',
        description: '60~70% HRmax (114~133 bpm)',
        durationSeconds: ((z2Count / totalSamples) * totalSeconds).round(),
        percentage: (z2Count / totalSamples) * 100,
        color: AppColors.zone2FatBurn,
      ),
      HeartRateZoneDistribution(
        zoneIndex: 3,
        title: 'Zone 3 (유산소/템포)',
        description: '70~80% HRmax (133~152 bpm)',
        durationSeconds: ((z3Count / totalSamples) * totalSeconds).round(),
        percentage: (z3Count / totalSamples) * 100,
        color: AppColors.zone3Aerobic,
      ),
      HeartRateZoneDistribution(
        zoneIndex: 4,
        title: 'Zone 4 (역치/고강도)',
        description: '80~90% HRmax (152~171 bpm)',
        durationSeconds: ((z4Count / totalSamples) * totalSeconds).round(),
        percentage: (z4Count / totalSamples) * 100,
        color: AppColors.zone4Threshold,
      ),
      HeartRateZoneDistribution(
        zoneIndex: 5,
        title: 'Zone 5 (최대 심박)',
        description: '> 90% HRmax (> 171 bpm)',
        durationSeconds: ((z5Count / totalSamples) * totalSeconds).round(),
        percentage: (z5Count / totalSamples) * 100,
        color: AppColors.zone5Max,
      ),
    ];
  }

  static List<HeartRateZoneDistribution> _emptyZones() {
    return [
      HeartRateZoneDistribution(
        zoneIndex: 1,
        title: 'Zone 1 (회복/워밍업)',
        description: '< 60% HRmax',
        durationSeconds: 0,
        percentage: 0.0,
        color: AppColors.zone1WarmUp,
      ),
      HeartRateZoneDistribution(
        zoneIndex: 2,
        title: 'Zone 2 (지방 연소/이지)',
        description: '60~70% HRmax',
        durationSeconds: 0,
        percentage: 0.0,
        color: AppColors.zone2FatBurn,
      ),
      HeartRateZoneDistribution(
        zoneIndex: 3,
        title: 'Zone 3 (유산소/템포)',
        description: '70~80% HRmax',
        durationSeconds: 0,
        percentage: 0.0,
        color: AppColors.zone3Aerobic,
      ),
      HeartRateZoneDistribution(
        zoneIndex: 4,
        title: 'Zone 4 (역치/고강도)',
        description: '80~90% HRmax',
        durationSeconds: 0,
        percentage: 0.0,
        color: AppColors.zone4Threshold,
      ),
      HeartRateZoneDistribution(
        zoneIndex: 5,
        title: 'Zone 5 (최대 심박)',
        description: '> 90% HRmax',
        durationSeconds: 0,
        percentage: 0.0,
        color: AppColors.zone5Max,
      ),
    ];
  }
}
