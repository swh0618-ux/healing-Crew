import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_status.dart';
import '../services/health_sync_service.dart';
import '../repositories/running_repository.dart';
import 'running_dashboard_provider.dart';

final healthSyncServiceProvider = Provider<HealthSyncService>((ref) {
  return HealthSyncService();
});

final healthSyncProvider = StateNotifierProvider<HealthSyncNotifier, SyncStatus>((ref) {
  final healthService = ref.watch(healthSyncServiceProvider);
  final repository = ref.watch(runningRepositoryProvider);
  return HealthSyncNotifier(healthService, repository, ref);
});

class HealthSyncNotifier extends StateNotifier<SyncStatus> {
  final HealthSyncService _service;
  final RunningRepository _repository;
  final Ref _ref;

  HealthSyncNotifier(this._service, this._repository, this._ref)
      : super(SyncStatus(providerName: _service.platformProviderName)) {
    checkInitialPermissions();
  }

  /// 초기 권한 상태 확인
  Future<void> checkInitialPermissions() async {
    state = state.copyWith(state: SyncState.checkingPermissions);
    final hasPerm = await _service.checkPermissions();
    state = state.copyWith(
      state: hasPerm ? SyncState.idle : SyncState.permissionRequired,
      hasPermissions: hasPerm,
      providerName: _service.platformProviderName,
    );

    // 기본 데이터가 비어있으면 초기 동기화(또는 샘플 로드) 1회 수행
    if (_repository.records.isEmpty) {
      await syncWorkouts(daysBack: 30);
    }
  }

  /// 사용자 권한 요청 대화상자 호출
  Future<bool> requestPermissions() async {
    state = state.copyWith(state: SyncState.checkingPermissions);
    final granted = await _service.requestPermissions();
    state = state.copyWith(
      hasPermissions: granted,
      state: granted ? SyncState.idle : SyncState.permissionRequired,
      errorMessage: granted ? null : '건강 데이터 접근 권한이 거부되었습니다. 설정에서 허용해 주세요.',
    );

    if (granted) {
      await syncWorkouts();
    }
    return granted;
  }

  /// 워치 및 건강 앱 러닝 데이터 동기화
  Future<void> syncWorkouts({int daysBack = 14, bool forceMock = false}) async {
    // 중복 동기화 방지 (Race Condition 가드)
    if (state.isSyncing) return;

    state = state.copyWith(state: SyncState.syncing, errorMessage: null);

    try {
      final now = DateTime.now();
      final startTime = now.subtract(Duration(days: daysBack));

      final fetchedRecords = await _service.fetchRunningWorkouts(
        startTime: startTime,
        endTime: now,
        forceUseMock: forceMock,
      );

      final prevCount = _repository.records.length;
      _repository.addRecords(fetchedRecords);
      final newCount = _repository.records.length - prevCount;

      state = state.copyWith(
        state: SyncState.success,
        lastSyncTime: DateTime.now(),
        totalSyncedCount: _repository.records.length,
        newSyncedCount: newCount > 0 ? newCount : fetchedRecords.length,
        errorMessage: null,
      );

      // 대시보드 갱신 알림
      _ref.read(runningDashboardProvider.notifier).refresh();
    } catch (e) {
      state = state.copyWith(
        state: SyncState.failed,
        errorMessage: '동기화 중 오류가 발생했습니다: $e',
      );
    }
  }
}
