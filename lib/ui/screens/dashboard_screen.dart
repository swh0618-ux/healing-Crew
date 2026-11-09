import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../repositories/running_repository.dart';
import '../../providers/running_dashboard_provider.dart';
import '../../providers/health_sync_provider.dart';
import '../../models/sync_status.dart';
import '../widgets/stat_card.dart';
import '../widgets/running_list_item.dart';
import 'running_detail_screen.dart';
import 'sync_settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(runningDashboardProvider);
    final syncStatus = ref.watch(healthSyncProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_run_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Healing Crew',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '워치 & 건강 데이터 러닝 다이어리',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '건강 앱 연동 설정',
            icon: Stack(
              children: [
                const Icon(Icons.sync_rounded, color: AppColors.textPrimary),
                if (syncStatus.isSyncing)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SyncSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          await ref.read(healthSyncProvider.notifier).syncWorkouts();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 상단 스트릭 및 웰컴 배너
            _buildHealingBanner(dashboard.streakDays),
            const SizedBox(height: 16),

            // 주간 목표 마일리지 진행도
            _buildWeeklyGoalProgress(dashboard),
            const SizedBox(height: 20),

            // 필터 탭 (이번 주 / 이번 달 / 전체)
            _buildFilterChips(ref, dashboard.filter),
            const SizedBox(height: 16),

            // 핵심 4대 지표 카드 그리드
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: '총 거리',
                    value: dashboard.totalDistanceKm.toStringAsFixed(2),
                    unit: 'km',
                    icon: Icons.route_rounded,
                    accentColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: '평균 페이스',
                    value: Formatters.formatPace(dashboard.avgPaceSeconds),
                    unit: '/km',
                    icon: Icons.speed_rounded,
                    accentColor: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: '총 달린 시간',
                    value: Formatters.formatDuration(dashboard.totalDurationSeconds),
                    icon: Icons.timer_outlined,
                    accentColor: AppColors.zone3Aerobic,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: '소모 칼로리',
                    value: dashboard.totalCalories.round().toString(),
                    unit: 'kcal',
                    icon: Icons.local_fire_department_rounded,
                    accentColor: AppColors.zone4Threshold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 최근 러닝 기록 섹션 타이틀
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '러닝 기록 목록 (${dashboard.records.length}건)',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (syncStatus.isSyncing)
                  const Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '워치 동기화 중...',
                        style: TextStyle(color: AppColors.primary, fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 레코드 리스트
            if (dashboard.records.isEmpty)
              _buildEmptyState(context, ref)
            else
              ...dashboard.records.map(
                (record) => RunningListItem(
                  record: record,
                  onTap: () {
                    ref.read(runningDashboardProvider.notifier).selectRecord(record);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RunningDetailScreen(record: record),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHealingBanner(int streakDays) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark.withOpacity(0.6),
            AppColors.surfaceVariant,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('🌿', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '나만의 템포로 회복하는 시간',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  streakDays > 0
                      ? '연속 $streakDays일째 꾸준히 달리고 있어요! 👏'
                      : '오늘 저녁 가벼운 힐링 런 어떠세요?',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGoalProgress(DashboardState dashboard) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '이번 주 목표 마일리지',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${dashboard.weeklyDistanceKm.toStringAsFixed(1)} / ${dashboard.weeklyGoalKm.toStringAsFixed(0)} km (${(dashboard.weeklyProgress * 100).round()}%)',
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: dashboard.weeklyProgress,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(WidgetRef ref, RunningFilterRange currentFilter) {
    final filters = [
      {'label': '이번 주', 'value': RunningFilterRange.thisWeek},
      {'label': '이번 달', 'value': RunningFilterRange.thisMonth},
      {'label': '올해', 'value': RunningFilterRange.thisYear},
      {'label': '전체 보기', 'value': RunningFilterRange.all},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = currentFilter == f['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f['label'] as String),
              selected: isSelected,
              onSelected: (_) {
                ref
                    .read(runningDashboardProvider.notifier)
                    .setFilter(f['value'] as RunningFilterRange);
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border.withOpacity(0.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.directions_run_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text(
            '선택한 기간의 러닝 기록이 없습니다.',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            '워치나 건강 앱(HealthKit/Health Connect)에서 데이터를 동기화해보세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              ref.read(healthSyncProvider.notifier).syncWorkouts();
            },
            icon: const Icon(Icons.sync_rounded, size: 16),
            label: const Text('건강 데이터 즉시 동기화'),
          ),
        ],
      ),
    );
  }
}
