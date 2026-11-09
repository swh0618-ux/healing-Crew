import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/sync_status.dart';
import '../../providers/health_sync_provider.dart';

class SyncSettingsScreen extends ConsumerStatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  ConsumerState<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends ConsumerState<SyncSettingsScreen> {
  int _selectedDaysBack = 14;

  @override
  Widget build(BuildContext context) {
    final syncStatus = ref.watch(healthSyncProvider);
    final notifier = ref.read(healthSyncProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '건강 앱 및 워치 연동',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 현재 연동 상태 카드
          _buildStatusCard(syncStatus, notifier),
          const SizedBox(height: 20),

          // 수동 동기화 옵션 카드
          _buildManualSyncSection(syncStatus, notifier),
          const SizedBox(height: 20),

          // 워치 연동 원리 안내
          _buildIntegrationGuideCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusCard(SyncStatus status, HealthSyncNotifier notifier) {
    final isConnected = status.hasPermissions;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected ? AppColors.primary.withOpacity(0.5) : AppColors.warning.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isConnected ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                    color: isConnected ? AppColors.primary : AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status.providerName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isConnected ? AppColors.primary.withOpacity(0.15) : AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isConnected ? '연동 활성화됨' : '권한 필요',
                  style: TextStyle(
                    color: isConnected ? AppColors.primary : AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isConnected
                ? '스마트워치(Apple Watch, Galaxy Watch 등)에서 기록된 운동 데이터가 OS 건강 저장소를 통해 Healing Crew로 자동 공유됩니다.'
                : '운동 세션(거리, 시간, 심박수, 칼로리)을 읽어오려면 건강 데이터 접근 권한을 허용해야 합니다.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
          if (status.lastSyncTime != null) ...[
            const SizedBox(height: 12),
            Text(
              '최근 동기화: ${Formatters.formatFullDate(status.lastSyncTime!)} (총 ${status.totalSyncedCount}건)',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
          if (!isConnected) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final granted = await notifier.requestPermissions();
                  if (context.mounted && !granted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('권한 창이 뜨지 않을 경우: iPhone [설정] > [건강] > [데이터 접근 및 기기] > [Healing Crew]에서 직접 켜실 수 있습니다.'),
                        backgroundColor: AppColors.warning,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.security_rounded, size: 18),
                label: const Text(
                  '건강 데이터 읽기 권한 요청',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManualSyncSection(SyncStatus status, HealthSyncNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '러닝 데이터 즉시 동기화',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '가져올 과거 기간을 선택하고 동기화 버튼을 누르면 워치에서 기록된 최신 러닝 목록을 가져옵니다.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // 기간 선택 버튼들
          Row(
            children: [7, 14, 30, 90].map((days) {
              final isSelected = _selectedDaysBack == days;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceVariant,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border.withOpacity(0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => setState(() => _selectedDaysBack = days),
                    child: Text(
                      '최근 $days일',
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 동기화 실행 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceVariant,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
              onPressed: status.isSyncing
                  ? null
                  : () async {
                      await notifier.syncWorkouts(
                        daysBack: _selectedDaysBack,
                      );
                      if (context.mounted) {
                        final currentStatus = ref.read(healthSyncProvider);
                        if (currentStatus.hasError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(currentStatus.errorMessage ?? '동기화 중 오류가 발생했습니다.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                currentStatus.newSyncedCount > 0
                                    ? '새로운 러닝 기록 ${currentStatus.newSyncedCount}건이 동기화되었습니다.'
                                    : '최신 러닝 데이터가 이미 동기화되어 있습니다.',
                              ),
                              backgroundColor: AppColors.surfaceVariant,
                            ),
                          );
                        }
                      }
                    },
              icon: status.isSyncing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(Icons.cloud_download_rounded, color: AppColors.primary),
              label: Text(
                status.isSyncing ? '워치 데이터 가져오는 중...' : '최근 $_selectedDaysBack일 러닝 기록 가져오기',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationGuideCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: AppColors.accent),
              SizedBox(width: 8),
              Text(
                '워치 데이터 연동 파이프라인 안내',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuideItem(
            '1. Apple Watch 사용자',
            'Apple Watch에서 운동 앱으로 러닝 후 iPhone과 블루투스로 동기화되면, iOS의 Apple Health(건강) 앱에 기록됩니다. Healing Crew는 HealthKit API를 통해 실시간으로 이 기록을 조회합니다.',
          ),
          const SizedBox(height: 10),
          _buildGuideItem(
            '2. Galaxy Watch / Wear OS 사용자',
            '삼성 헬스 또는 Wear OS 피트니스 앱에서 러닝 종료 시 Android의 구글 공식 표준인 "Health Connect(헬스 커넥트)"에 데이터가 기록되며, Healing Crew가 안전하게 연동합니다.',
          ),
          const SizedBox(height: 10),
          _buildGuideItem(
            '3. Garmin 등 기타 워치',
            'Garmin Connect 앱 설정에서 "Apple 건강" 또는 "Google Health Connect" 연동을 활성화해 두시면 워치에서 저장된 러닝이 Healing Crew에 자동으로 연결됩니다.',
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 3),
        Text(
          description,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
        ),
      ],
    );
  }
}
