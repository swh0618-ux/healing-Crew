enum SyncState {
  idle,
  checkingPermissions,
  permissionRequired,
  syncing,
  success,
  failed,
  unsupported,
}

class SyncStatus {
  final SyncState state;
  final String providerName; // "Apple HealthKit", "Google Health Connect", "Mock Simulator"
  final DateTime? lastSyncTime;
  final int totalSyncedCount;
  final int newSyncedCount;
  final String? errorMessage;
  final bool hasPermissions;

  const SyncStatus({
    this.state = SyncState.idle,
    this.providerName = '스마트 기기 건강 앱',
    this.lastSyncTime,
    this.totalSyncedCount = 0,
    this.newSyncedCount = 0,
    this.errorMessage,
    this.hasPermissions = false,
  });

  bool get isSyncing => state == SyncState.syncing;
  bool get isSuccess => state == SyncState.success;
  bool get hasError => state == SyncState.failed;

  SyncStatus copyWith({
    SyncState? state,
    String? providerName,
    DateTime? lastSyncTime,
    int? totalSyncedCount,
    int? newSyncedCount,
    String? errorMessage,
    bool? hasPermissions,
  }) {
    return SyncStatus(
      state: state ?? this.state,
      providerName: providerName ?? this.providerName,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      totalSyncedCount: totalSyncedCount ?? this.totalSyncedCount,
      newSyncedCount: newSyncedCount ?? this.newSyncedCount,
      errorMessage: errorMessage ?? this.errorMessage,
      hasPermissions: hasPermissions ?? this.hasPermissions,
    );
  }
}
