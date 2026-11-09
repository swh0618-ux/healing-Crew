import 'pace_split.dart';
import 'heart_rate_zone.dart';
import '../core/utils/formatters.dart';

class RunningRecord {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final double distanceMeters;
  final double caloriesKcal;
  final int avgHeartRate;
  final int maxHeartRate;
  final int minHeartRate;
  final int avgPaceSecondsPerKm;
  final double elevationGainMeters;
  final int cadence; // spm (steps per min)
  final String source; // e.g. "Apple Watch", "Galaxy Watch", "Health Connect"
  final List<PaceSplit> splits;
  final List<int> heartRateSamples;
  final String? memo;

  const RunningRecord({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.distanceMeters,
    required this.caloriesKcal,
    required this.avgHeartRate,
    this.maxHeartRate = 0,
    this.minHeartRate = 0,
    required this.avgPaceSecondsPerKm,
    this.elevationGainMeters = 0.0,
    this.cadence = 0,
    required this.source,
    this.splits = const [],
    this.heartRateSamples = const [],
    this.memo,
  });

  double get distanceKm => distanceMeters / 1000.0;
  String get distanceKmFormatted => (distanceMeters / 1000.0).toStringAsFixed(2);
  String get paceFormatted => Formatters.formatPace(avgPaceSecondsPerKm);
  String get durationFormatted => Formatters.formatDuration(durationSeconds);
  String get dateFormatted => Formatters.formatFullDate(startTime);

  List<HeartRateZoneDistribution> get heartRateZones {
    return HeartRateZoneDistribution.calculate(
      heartRateSamples: heartRateSamples,
      totalSeconds: durationSeconds,
      maxHeartRate: maxHeartRate > 150 ? maxHeartRate : 190,
    );
  }

  RunningRecord copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    double? distanceMeters,
    double? caloriesKcal,
    int? avgHeartRate,
    int? maxHeartRate,
    int? minHeartRate,
    int? avgPaceSecondsPerKm,
    double? elevationGainMeters,
    int? cadence,
    String? source,
    List<PaceSplit>? splits,
    List<int>? heartRateSamples,
    String? memo,
  }) {
    return RunningRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      minHeartRate: minHeartRate ?? this.minHeartRate,
      avgPaceSecondsPerKm: avgPaceSecondsPerKm ?? this.avgPaceSecondsPerKm,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      cadence: cadence ?? this.cadence,
      source: source ?? this.source,
      splits: splits ?? this.splits,
      heartRateSamples: heartRateSamples ?? this.heartRateSamples,
      memo: memo ?? this.memo,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'durationSeconds': durationSeconds,
    'distanceMeters': distanceMeters,
    'caloriesKcal': caloriesKcal,
    'avgHeartRate': avgHeartRate,
    'maxHeartRate': maxHeartRate,
    'minHeartRate': minHeartRate,
    'avgPaceSecondsPerKm': avgPaceSecondsPerKm,
    'elevationGainMeters': elevationGainMeters,
    'cadence': cadence,
    'source': source,
    'splits': splits.map((s) => s.toJson()).toList(),
    'heartRateSamples': heartRateSamples,
    'memo': memo,
  };

  factory RunningRecord.fromJson(Map<String, dynamic> json) => RunningRecord(
    id: json['id'] as String,
    title: json['title'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: DateTime.parse(json['endTime'] as String),
    durationSeconds: json['durationSeconds'] as int,
    distanceMeters: (json['distanceMeters'] as num).toDouble(),
    caloriesKcal: (json['caloriesKcal'] as num).toDouble(),
    avgHeartRate: (json['avgHeartRate'] as num).toInt(),
    maxHeartRate: (json['maxHeartRate'] as num?)?.toInt() ?? 0,
    minHeartRate: (json['minHeartRate'] as num?)?.toInt() ?? 0,
    avgPaceSecondsPerKm: (json['avgPaceSecondsPerKm'] as num).toInt(),
    elevationGainMeters: (json['elevationGainMeters'] as num?)?.toDouble() ?? 0.0,
    cadence: (json['cadence'] as num?)?.toInt() ?? 0,
    source: json['source'] as String? ?? 'Watch',
    splits: (json['splits'] as List<dynamic>?)
            ?.map((s) => PaceSplit.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [],
    heartRateSamples: (json['heartRateSamples'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        [],
    memo: json['memo'] as String?,
  );
}
