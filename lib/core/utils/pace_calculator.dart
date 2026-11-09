class PaceCalculator {
  /// 거리(m)와 소요 시간(초)을 바탕으로 km당 페이스(초) 계산
  static int calculatePaceSecondsPerKm(double distanceMeters, int durationSeconds) {
    if (distanceMeters <= 0 || durationSeconds <= 0) return 0;
    final km = distanceMeters / 1000.0;
    return (durationSeconds / km).round();
  }

  /// 속도(m/s 또는 km/h)를 바탕으로 km당 페이스(초) 계산
  static int speedKmHToPaceSeconds(double speedKmH) {
    if (speedKmH <= 0.1) return 0;
    return (3600 / speedKmH).round();
  }

  /// 심박수를 기반으로 심박 존 (1~5구간) 계산 (기본 최대 심박수 공식: 220 - 나이, 기본 30세 기준 190bpm)
  static int getHeartRateZone(int currentBpm, {int maxHeartRate = 190}) {
    if (currentBpm <= 0) return 1;
    final percentage = (currentBpm / maxHeartRate) * 100.0;

    if (percentage < 60) return 1; // 워밍업/회복 (Zone 1)
    if (percentage < 70) return 2; // 지방 연소/이지런 (Zone 2)
    if (percentage < 80) return 3; // 유산소/템포런 (Zone 3)
    if (percentage < 90) return 4; // 역치/인터벌 (Zone 4)
    return 5; // 최대 심박 (Zone 5)
  }
}
