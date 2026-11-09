import '../models/running_record.dart';

enum RunningFilterRange {
  all,
  thisWeek,
  thisMonth,
  thisYear,
}

class RunningRepository {
  final List<RunningRecord> _records = [];

  List<RunningRecord> get records => List.unmodifiable(_records);

  void setRecords(List<RunningRecord> newRecords) {
    _records.clear();
    _records.addAll(newRecords);
    _records.sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  void addRecords(List<RunningRecord> newRecords) {
    for (final r in newRecords) {
      final index = _records.indexWhere((existing) => existing.id == r.id);
      if (index >= 0) {
        _records[index] = r;
      } else {
        _records.add(r);
      }
    }
    _records.sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  RunningRecord? getById(String id) {
    try {
      return _records.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 특정 기간 필터링 레코드 목록 반환
  List<RunningRecord> getFilteredRecords(RunningFilterRange filter) {
    final now = DateTime.now();
    switch (filter) {
      case RunningFilterRange.thisWeek:
        // 이번 주 월요일 00:00:00부터 (경계값 포함)
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeek = DateTime(monday.year, monday.month, monday.day);
        return _records
            .where((r) => !r.startTime.isBefore(startOfWeek) && !r.startTime.isAfter(now))
            .toList();

      case RunningFilterRange.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return _records
            .where((r) => !r.startTime.isBefore(startOfMonth) && !r.startTime.isAfter(now))
            .toList();

      case RunningFilterRange.thisYear:
        final startOfYear = DateTime(now.year, 1, 1);
        return _records
            .where((r) => !r.startTime.isBefore(startOfYear) && !r.startTime.isAfter(now))
            .toList();

      case RunningFilterRange.all:
      default:
        return _records;
    }
  }

  /// 총 달린 거리 (km)
  double getTotalDistanceKm(RunningFilterRange filter) {
    final list = getFilteredRecords(filter);
    if (list.isEmpty) return 0.0;
    final totalMeters = list.fold<double>(0.0, (sum, r) => sum + r.distanceMeters);
    return totalMeters / 1000.0;
  }

  /// 총 달린 시간 (초)
  int getTotalDurationSeconds(RunningFilterRange filter) {
    final list = getFilteredRecords(filter);
    return list.fold<int>(0, (sum, r) => sum + r.durationSeconds);
  }

  /// 총 소모 칼로리 (kcal)
  double getTotalCalories(RunningFilterRange filter) {
    final list = getFilteredRecords(filter);
    return list.fold<double>(0.0, (sum, r) => sum + r.caloriesKcal);
  }

  /// 평균 페이스 (초/km)
  int getAveragePaceSeconds(RunningFilterRange filter) {
    final list = getFilteredRecords(filter);
    if (list.isEmpty) return 0;
    final totalMeters = list.fold<double>(0.0, (sum, r) => sum + r.distanceMeters);
    final totalSeconds = list.fold<int>(0, (sum, r) => sum + r.durationSeconds);
    if (totalMeters <= 0) return 0;
    return (totalSeconds / (totalMeters / 1000.0)).round();
  }

  /// 연속 러닝 스트릭 일수 (Streak) 계산
  int calculateStreakDays() {
    if (_records.isEmpty) return 0;

    final runDates = _records
        .map((r) => DateTime(r.startTime.year, r.startTime.month, r.startTime.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayClean = DateTime(today.year, today.month, today.day);
    final yesterdayClean = DateTime(today.year, today.month, today.day - 1);

    // 최근 러닝이 오늘 또는 어제가 아니면 스트릭 끊김
    final latestRunDate = runDates.first;
    final isToday = latestRunDate.year == todayClean.year &&
        latestRunDate.month == todayClean.month &&
        latestRunDate.day == todayClean.day;
    final isYesterday = latestRunDate.year == yesterdayClean.year &&
        latestRunDate.month == yesterdayClean.month &&
        latestRunDate.day == yesterdayClean.day;

    if (!isToday && !isYesterday) {
      return 0;
    }

    int streak = 1;
    DateTime checkDate = latestRunDate;

    for (int i = 1; i < runDates.length; i++) {
      // 서머타임(DST) 왜곡 방지를 위한 달력 일자 기반 감산 (연/월/일 - 1)
      final expectedPrev = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
      if (runDates[i].year == expectedPrev.year &&
          runDates[i].month == expectedPrev.month &&
          runDates[i].day == expectedPrev.day) {
        streak++;
        checkDate = runDates[i];
      } else {
        break;
      }
    }
    return streak;
  }
}
