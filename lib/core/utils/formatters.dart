import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _fullDateFormat = DateFormat('yyyy.MM.dd (E) HH:mm', 'ko');
  static final DateFormat _simpleDateFormat = DateFormat('MM.dd (E)', 'ko');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  /// 날짜 및 시간 포맷 (예: 2026.11.09 (월) 19:30)
  static String formatFullDate(DateTime dateTime) {
    try {
      return _fullDateFormat.format(dateTime);
    } catch (_) {
      return "${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
  }

  /// 간단 날짜 포맷 (예: 11.09 (월))
  static String formatSimpleDate(DateTime dateTime) {
    try {
      return _simpleDateFormat.format(dateTime);
    } catch (_) {
      return "${dateTime.month}.${dateTime.day}";
    }
  }

  /// 시간만 포맷 (예: 19:30)
  static String formatTime(DateTime dateTime) {
    try {
      return _timeFormat.format(dateTime);
    } catch (_) {
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
  }

  /// 초 단위 시간을 00:00:00 또는 00:00 형식으로 변환
  static String formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// 미터(m)를 킬로미터(km) 문자열로 변환 (소수점 2자리)
  static String formatDistanceKm(double distanceMeters) {
    final km = distanceMeters / 1000.0;
    return km.toStringAsFixed(2);
  }

  /// 초/km 페이스를 5'32" 형식의 문자열로 변환
  static String formatPace(int paceSecondsPerKm) {
    if (paceSecondsPerKm <= 0 || paceSecondsPerKm > 3600) {
      return "--'--\"";
    }
    final minutes = paceSecondsPerKm ~/ 60;
    final seconds = paceSecondsPerKm % 60;
    return "$minutes'${seconds.toString().padLeft(2, '0')}\"";
  }

  /// 칼로리 포맷 (예: 420 kcal)
  static String formatCalories(double kcal) {
    return '${kcal.round()} kcal';
  }

  /// 심박수 포맷 (예: 148 bpm)
  static String formatBpm(int bpm) {
    if (bpm <= 0) return "-- bpm";
    return "$bpm bpm";
  }
}
