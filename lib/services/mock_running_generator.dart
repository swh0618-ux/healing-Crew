import 'dart:math';
import '../models/running_record.dart';
import '../models/pace_split.dart';
import '../core/utils/pace_calculator.dart';

class MockRunningGenerator {
  static final Random _rng = Random(42);

  /// 샘플 러닝 세션 5개 생성
  static List<RunningRecord> generateSampleRuns() {
    final now = DateTime.now();

    return [
      _createRun(
        id: 'run_sample_01',
        title: '한강 노을 힐링 러닝 🌿',
        startTime: now.subtract(const Duration(hours: 3)),
        distanceKm: 5.24,
        avgPaceSeconds: 334, // 5'34"/km
        avgHr: 146,
        maxHr: 168,
        source: 'Apple Watch Ultra 2',
        memo: '시원한 강바람 맞으며 가볍게 리프레시. 다리 피로감 없음!',
      ),
      _createRun(
        id: 'run_sample_02',
        title: '양재천 모닝 인터벌 러닝 ⚡',
        startTime: now.subtract(const Duration(days: 2, hours: 14)),
        distanceKm: 7.10,
        avgPaceSeconds: 312, // 5'12"/km
        avgHr: 158,
        maxHr: 182,
        source: 'Galaxy Watch 6 Classic',
        memo: '4km 지점에서 템포 러닝 진행. 케이던스 182 유지 완료.',
      ),
      _createRun(
        id: 'run_sample_03',
        title: '올림픽공원 주말 장거리 LSD 🏃‍♂️',
        startTime: now.subtract(const Duration(days: 4, hours: 11)),
        distanceKm: 12.50,
        avgPaceSeconds: 358, // 5'58"/km
        avgHr: 142,
        maxHr: 159,
        source: 'Garmin Forerunner 965',
        memo: 'Zone 2 저강도 유산소 훈련. 에너지 젤 1개 섭취.',
      ),
      _createRun(
        id: 'run_sample_04',
        title: '퇴근 후 도심 나이트 런 🌙',
        startTime: now.subtract(const Duration(days: 6, hours: 2)),
        distanceKm: 4.80,
        avgPaceSeconds: 345, // 5'45"/km
        avgHr: 144,
        maxHr: 162,
        source: 'Health Connect (Pixel Watch)',
        memo: '하루의 스트레스를 땀으로 비워내기.',
      ),
      _createRun(
        id: 'run_sample_05',
        title: '남산 힐클라임 파워 러닝 ⛰️',
        startTime: now.subtract(const Duration(days: 8, hours: 6)),
        distanceKm: 6.30,
        avgPaceSeconds: 375, // 6'15"/km
        avgHr: 165,
        maxHr: 188,
        elevationGain: 142.0,
        source: 'Apple Watch Series 9',
        memo: '업힐 구간에서 심박수 Zone 5 도달. 하체 훈련 최고.',
      ),
    ];
  }

  static RunningRecord _createRun({
    required String id,
    required String title,
    required DateTime startTime,
    required double distanceKm,
    required int avgPaceSeconds,
    required int avgHr,
    required int maxHr,
    required String source,
    double elevationGain = 24.0,
    String? memo,
  }) {
    final distanceMeters = distanceKm * 1000.0;
    final durationSeconds = (distanceKm * avgPaceSeconds).round();
    final endTime = startTime.add(Duration(seconds: durationSeconds));

    // 칼로리 계산: 대략 체중 68kg 기준 거리(km) * 65~70 kcal
    final caloriesKcal = distanceKm * (64.0 + _rng.nextDouble() * 6.0);

    // 1km 구간별 스플릿 데이터 생성
    final fullKms = distanceKm.floor();
    final splits = <PaceSplit>[];
    for (int k = 1; k <= fullKms; k++) {
      // ±15초 페이스 변동
      final jitter = (_rng.nextInt(31) - 15);
      final splitDuration = (avgPaceSeconds + jitter).clamp(240, 600);
      final splitHr = (avgHr + (_rng.nextInt(11) - 5)).clamp(100, maxHr);

      splits.add(
        PaceSplit(
          kilometerIndex: k,
          durationSeconds: splitDuration,
          avgHeartRate: splitHr,
          elevationChangeMeters: (_rng.nextDouble() * 8.0) - 3.0,
        ),
      );
    }

    // 잔여 거리 스플릿
    final remainder = distanceKm - fullKms;
    if (remainder > 0.1) {
      splits.add(
        PaceSplit(
          kilometerIndex: fullKms + 1,
          durationSeconds: (remainder * avgPaceSeconds).round(),
          avgHeartRate: avgHr,
          elevationChangeMeters: 1.0,
        ),
      );
    }

    // 심박수 시계열 샘플 (30초~1분 간격 30~50개 점)
    final heartRateSamples = <int>[];
    final sampleCount = 40;
    int currentBpm = (avgHr - 25).clamp(100, 140);
    for (int i = 0; i < sampleCount; i++) {
      // 러닝 진행에 따른 점진적 심박 상승 및 변동
      final drift = (i / sampleCount) * 20.0;
      final noise = (_rng.nextInt(9) - 4);
      final sample = (currentBpm + drift + noise).round().clamp(90, maxHr);
      heartRateSamples.add(sample);
    }

    return RunningRecord(
      id: id,
      title: title,
      startTime: startTime,
      endTime: endTime,
      durationSeconds: durationSeconds,
      distanceMeters: distanceMeters,
      caloriesKcal: caloriesKcal,
      avgHeartRate: avgHr,
      maxHeartRate: maxHr,
      minHeartRate: (avgHr - 35).clamp(85, 120),
      avgPaceSecondsPerKm: PaceCalculator.calculatePaceSecondsPerKm(distanceMeters, durationSeconds),
      elevationGainMeters: elevationGain,
      cadence: 176 + _rng.nextInt(8),
      source: source,
      splits: splits,
      heartRateSamples: heartRateSamples,
      memo: memo,
    );
  }
}
