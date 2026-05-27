import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/app_module.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/activity_feed_entity.dart';
import '../../domain/repositories/activity_feed_repository.dart';

/// Provider for activity feed repository
final activityFeedRepositoryProvider = Provider<ActivityFeedRepository>((ref) {
  return getIt<ActivityFeedRepository>();
});

/// State for activity feed data
class ActivityFeedState {
  final bool isLoading;
  final String? error;
  final List<ActivityFeedEntry> entries;
  final ActivityFeedSummary? summary;
  final bool hasMore;
  final int offset;

  const ActivityFeedState({
    this.isLoading = false,
    this.error,
    this.entries = const [],
    this.summary,
    this.hasMore = false,
    this.offset = 0,
  });

  /// Create a copy with overridden fields
  ActivityFeedState copyWith({
    bool? isLoading,
    String? error,
    List<ActivityFeedEntry>? entries,
    ActivityFeedSummary? summary,
    bool? hasMore,
    int? offset,
  }) {
    return ActivityFeedState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      entries: entries ?? this.entries,
      summary: summary ?? this.summary,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
    );
  }

  /// Check if this state is loading
  bool get isEmpty => entries.isEmpty && !isLoading;
}

/// Notifier for activity feed operations
class ActivityFeedNotifier extends StateNotifier<ActivityFeedState> {
  final ActivityFeedRepository _repository;
  String? _currentGroupId;

  ActivityFeedNotifier(this._repository) : super(const ActivityFeedState());

  /// Load activity feed for a group
  Future<void> loadFeed(String groupId, {bool refresh = false}) async {
    if (refresh) {
      state = const ActivityFeedState();
    }
    _currentGroupId = groupId;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final entries = await _repository.getEntriesByGroup(groupId);
      final summary = await _repository.getSummary(groupId);

      state = state.copyWith(
        entries: entries,
        summary: summary,
        isLoading: false,
        hasMore: entries.length >= 50,
        offset: entries.length,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Load more entries (pagination)
  Future<void> loadMore() async {
    if (_currentGroupId == null || state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final newEntries = await _repository.getEntriesByGroup(
        _currentGroupId!,
        limit: 50,
        offset: state.offset,
      );

      final updatedEntries = [...state.entries, ...newEntries];

      state = state.copyWith(
        entries: updatedEntries,
        offset: updatedEntries.length,
        hasMore: newEntries.length >= 50,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Add a new activity entry
  Future<bool> addEntry({
    required String groupId,
    required String userId,
    required String userName,
    required String petId,
    required String petName,
    required ActivityFeedType type,
    required String title,
    String description = '',
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) async {
    try {
      final entry = await _repository.insertEntry(
        groupId: groupId,
        userId: userId,
        userName: userName,
        petId: petId,
        petName: petName,
        type: type,
        title: title,
        description: description,
        metadata: metadata,
        timestamp: timestamp,
      );

      // Prepend the new entry to the list
      state = state.copyWith(
        entries: [entry, ...state.entries],
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Batch insert activity entries
  Future<bool> addEntriesBatch(List<ActivityFeedEntry> entries) async {
    if (_currentGroupId == null) return false;

    try {
      final count = await _repository.insertEntriesBatch(entries);
      if (count > 0) {
        // Reload the feed to get accurate data
        await loadFeed(_currentGroupId!, refresh: false);
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete an activity entry
  Future<bool> deleteEntry(String entryId) async {
    if (_currentGroupId == null) return false;

    try {
      await _repository.deleteEntry(entryId);
      state = state.copyWith(
        entries: state.entries.where((e) => e.id != entryId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Refresh the summary statistics
  Future<void> refreshSummary() async {
    if (_currentGroupId == null) return;

    try {
      final summary = await _repository.getSummary(_currentGroupId!);
      state = state.copyWith(summary: summary);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get filtered entries by type
  List<ActivityFeedEntry> getEntriesByType(ActivityFeedType type) {
    return state.entries.where((e) => e.type == type).toList();
  }

  /// Get filtered entries by user
  List<ActivityFeedEntry> getEntriesByUser(String userId) {
    return state.entries.where((e) => e.userId == userId).toList();
  }

  /// Get filtered entries by pet
  List<ActivityFeedEntry> getEntriesByPet(String petId) {
    return state.entries.where((e) => e.petId == petId).toList();
  }
}

final activityFeedProvider =
    StateNotifierProvider<ActivityFeedNotifier, ActivityFeedState>((ref) {
  final repo = ref.watch(activityFeedRepositoryProvider);
  return ActivityFeedNotifier(repo);
});

/// Provider for activity feed summary statistics
final activityFeedSummaryProvider = Provider.family<ActivityFeedSummary?, String>((ref, groupId) {
  final repo = ref.watch(activityFeedRepositoryProvider);
  // This would be better as a FutureProvider, but for now we return null
  // and let the UI handle async loading
  return null;
});
