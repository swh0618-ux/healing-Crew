import 'package:flutter/material.dart';

class AppColors {
  // 배경 및 표면 컬러 (Dark Slate / Deep Healing)
  static const Color background = Color(0xFF0B0F19);
  static const Color surface = Color(0xFF151D2C);
  static const Color surfaceVariant = Color(0xFF1E293B);
  static const Color border = Color(0xFF334155);

  // 포인트 & 액센트 (민트 에메랄드 / 시안 힐링 컬러)
  static const Color primary = Color(0xFF10B981); // Emerald Green
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF059669);
  static const Color accent = Color(0xFF06B6D4); // Cyan

  // 텍스트 색상
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // 심박수 5구간 존(Heart Rate Zones) 컬러
  static const Color zone1WarmUp = Color(0xFF94A3B8); // 회색 (준비 운동)
  static const Color zone2FatBurn = Color(0xFF10B981); // 녹색 (지방 연소)
  static const Color zone3Aerobic = Color(0xFF38BDF8); // 하늘색 (유산소)
  static const Color zone4Threshold = Color(0xFFF59E0B); // 주황색 (무산소 역치)
  static const Color zone5Max = Color(0xFFEF4444); // 빨간색 (최대 심박)

  // 상태 배지 컬러
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
