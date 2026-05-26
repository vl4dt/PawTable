import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network connectivity status
class ConnectivityState {
  final bool isConnected;
  final String connectionType; // 'wifi', 'mobile', 'offline'
  final bool isSyncing;
  final String? lastSyncTime;

  const ConnectivityState({
    this.isConnected = false,
    this.connectionType = 'offline',
    this.isSyncing = false,
    this.lastSyncTime,
  });

  ConnectivityState copyWith({
    bool? isConnected,
    String? connectionType,
    bool? isSyncing,
    String? lastSyncTime,
  }) {
    return ConnectivityState(
      isConnected: isConnected ?? this.isConnected,
      connectionType: connectionType ?? this.connectionType,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// StateNotifier for connectivity management
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  ConnectivityNotifier(super.state);

  /// Update connectivity status
  void updateConnection(bool connected, String type) {
    state = state.copyWith(
      isConnected: connected,
      connectionType: connected ? type : 'offline',
    );
  }

  /// Start sync
  void startSync() {
    state = state.copyWith(isSyncing: true);
  }

  /// Complete sync
  void completeSync(String? lastSync) {
    state = state.copyWith(
      isSyncing: false,
      lastSyncTime: lastSync,
    );
  }

  /// Check if sync can proceed
  bool canSync() => state.isConnected && !state.isSyncing;
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>(
  (ref) => ConnectivityNotifier(const ConnectivityState()),
);

/// Convenience provider: is online
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).isConnected;
});

/// Convenience provider: is syncing
final isSyncingProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).isSyncing;
});
