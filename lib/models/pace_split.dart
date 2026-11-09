import '../core/utils/formatters.dart';

class PaceSplit {
  final int kilometerIndex; // 1km, 2km 등
  final int durationSeconds; // 해당 1km 구간 소요 시간 (초)
  final int avgHeartRate; // 해당 1km 구간 평균 심박수
  final double elevationChangeMeters; // 고도 변화

  const PaceSplit({
    required this.kilometerIndex,
    required this.durationSeconds,
    this.avgHeartRate = 0,
    this.elevationChangeMeters = 0.0,
  });

  String get paceFormatted => Formatters.formatPace(durationSeconds);

  Map<String, dynamic> toJson() => {
    'kilometerIndex': kilometerIndex,
    'durationSeconds': durationSeconds,
    'avgHeartRate': avgHeartRate,
    'elevationChangeMeters': elevationChangeMeters,
  };

  factory PaceSplit.fromJson(Map<String, dynamic> json) => PaceSplit(
    kilometerIndex: json['kilometerIndex'] as int,
    durationSeconds: json['durationSeconds'] as int,
    avgHeartRate: (json['avgHeartRate'] as num?)?.toInt() ?? 0,
    elevationChangeMeters: (json['elevationChangeMeters'] as num?)?.toDouble() ?? 0.0,
  );
}
