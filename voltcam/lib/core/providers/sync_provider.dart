import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/sync_batch_model.dart';

/// State representation for Offline Sync Queue & Batch Processing.
class SyncState {
  final int pendingQueueCount;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final String? lastSyncError;
  final List<SyncBatchModel> recentBatches;

  const SyncState({
    this.pendingQueueCount = 0,
    this.isSyncing = false,
    this.lastSyncTime,
    this.lastSyncError,
    this.recentBatches = const [],
  });

  SyncState copyWith({
    int? pendingQueueCount,
    bool? isSyncing,
    DateTime? lastSyncTime,
    String? lastSyncError,
    List<SyncBatchModel>? recentBatches,
  }) {
    return SyncState(
      pendingQueueCount: pendingQueueCount ?? this.pendingQueueCount,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastSyncError: lastSyncError,
      recentBatches: recentBatches ?? this.recentBatches,
    );
  }
}

/// Notifier managing offline batch queue sync state.
class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier() : super(const SyncState());

  void setPendingCount(int count) {
    state = state.copyWith(pendingQueueCount: count);
  }

  void startSync() {
    state = state.copyWith(isSyncing: true, lastSyncError: null);
  }

  void completeSync({required List<SyncBatchModel> syncedBatches}) {
    final updatedBatches = List<SyncBatchModel>.from(state.recentBatches)..addAll(syncedBatches);
    state = state.copyWith(
      isSyncing: false,
      pendingQueueCount: 0,
      lastSyncTime: DateTime.now(),
      lastSyncError: null,
      recentBatches: updatedBatches,
    );
  }

  void failSync(String error) {
    state = state.copyWith(
      isSyncing: false,
      lastSyncError: error,
    );
  }

  void triggerSyncBatch() {
    startSync();
    // Simulate batch trigger execution
    completeSync(syncedBatches: []);
  }

  void recordBatch(SyncBatchModel batch) {
    final updated = List<SyncBatchModel>.from(state.recentBatches)..add(batch);
    state = state.copyWith(recentBatches: updated);
  }
}

/// Riverpod provider for Offline Queue Sync status & Batch trigger state.
final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier();
});
