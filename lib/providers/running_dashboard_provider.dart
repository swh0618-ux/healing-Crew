import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/running_record.dart';
import '../repositories/running_repository.dart';

final runningRepositoryProvider = Provider<RunningRepository>((ref) {
  return RunningRepository();
});

class DashboardState {
  final RunningFilterRange filter;
  final List<RunningRecord> records;
  final double totalDistanceKm;
  final double weeklyDistanceKm; // 필터 선택과 무관한 순수 이번 주 누적 거리
  final int totalDurationSeconds;
  final double totalCalories;
  final int avgPaceSeconds;
  final int streakDays;
  final double weeklyGoalKm;
  final RunningRecord? selectedRecord;

  const DashboardState({
    required this.filter,
    required this.records,
    required this.totalDistanceKm,
    required this.weeklyDistanceKm,
    required this.totalDurationSeconds,
    required this.totalCalories,
    required this.avgPaceSeconds,
    required this.streakDays,
    this.weeklyGoalKm = 20.0,
    this.selectedRecord,
  });

  double get weeklyProgress => weeklyGoalKm > 0 ? (weeklyDistanceKm / weeklyGoalKm).clamp(0.0, 1.0) : 0.0;

  DashboardState copyWith({
    RunningFilterRange? filter,
    List<RunningRecord>? records,
    double? totalDistanceKm,
    double? weeklyDistanceKm,
    int? totalDurationSeconds,
    double? totalCalories,
    int? avgPaceSeconds,
    int? streakDays,
    double? weeklyGoalKm,
    RunningRecord? selectedRecord,
  }) {
    return DashboardState(
      filter: filter ?? this.filter,
      records: records ?? this.records,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      weeklyDistanceKm: weeklyDistanceKm ?? this.weeklyDistanceKm,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      totalCalories: totalCalories ?? this.totalCalories,
      avgPaceSeconds: avgPaceSeconds ?? this.avgPaceSeconds,
      streakDays: streakDays ?? this.streakDays,
      weeklyGoalKm: weeklyGoalKm ?? this.weeklyGoalKm,
      selectedRecord: selectedRecord ?? this.selectedRecord,
    );
  }
}

final runningDashboardProvider = StateNotifierProvider<RunningDashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(runningRepositoryProvider);
  return RunningDashboardNotifier(repository);
});

class RunningDashboardNotifier extends StateNotifier<DashboardState> {
  final RunningRepository _repository;

  RunningDashboardNotifier(this._repository)
      : super(
          DashboardState(
            filter: RunningFilterRange.thisWeek,
            records: _repository.getFilteredRecords(RunningFilterRange.thisWeek),
            totalDistanceKm: _repository.getTotalDistanceKm(RunningFilterRange.thisWeek),
            weeklyDistanceKm: _repository.getTotalDistanceKm(RunningFilterRange.thisWeek),
            totalDurationSeconds: _repository.getTotalDurationSeconds(RunningFilterRange.thisWeek),
            totalCalories: _repository.getTotalCalories(RunningFilterRange.thisWeek),
            avgPaceSeconds: _repository.getAveragePaceSeconds(RunningFilterRange.thisWeek),
            streakDays: _repository.calculateStreakDays(),
          ),
        );

  void setFilter(RunningFilterRange filter) {
    state = state.copyWith(
      filter: filter,
      records: _repository.getFilteredRecords(filter),
      totalDistanceKm: _repository.getTotalDistanceKm(filter),
      weeklyDistanceKm: _repository.getTotalDistanceKm(RunningFilterRange.thisWeek),
      totalDurationSeconds: _repository.getTotalDurationSeconds(filter),
      totalCalories: _repository.getTotalCalories(filter),
      avgPaceSeconds: _repository.getAveragePaceSeconds(filter),
      streakDays: _repository.calculateStreakDays(),
    );
  }

  void selectRecord(RunningRecord record) {
    state = state.copyWith(selectedRecord: record);
  }

  void refresh() {
    setFilter(state.filter);
  }
}
