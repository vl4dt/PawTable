import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Analytics event types for tracking user behavior
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  const AnalyticsEvent({
    required this.name,
    this.parameters = const {},
    required this.timestamp,
  });

  factory AnalyticsEvent.screenView({
    required String screenName,
    Map<String, dynamic>? parameters,
  }) {
    return AnalyticsEvent(
      name: 'screen_view',
      parameters: {
        'screen_name': screenName,
        ...?parameters,
      },
      timestamp: DateTime.now(),
    );
  }

  factory AnalyticsEvent.buttonTap({
    required String buttonName,
    Map<String, dynamic>? parameters,
  }) {
    return AnalyticsEvent(
      name: 'button_tap',
      parameters: {
        'button_name': buttonName,
        ...?parameters,
      },
      timestamp: DateTime.now(),
    );
  }

  factory AnalyticsEvent.featureUsed({
    required String featureName,
    Map<String, dynamic>? parameters,
  }) {
    return AnalyticsEvent(
      name: 'feature_used',
      parameters: {
        'feature_name': featureName,
        ...?parameters,
      },
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'parameters': parameters,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Analytics state - stores queued events for batch sending
class AnalyticsState {
  final List<AnalyticsEvent> eventQueue;
  final int totalEvents;
  final DateTime? lastSendTime;

  const AnalyticsState({
    this.eventQueue = const [],
    this.totalEvents = 0,
    this.lastSendTime,
  });

  AnalyticsState copyWith({
    List<AnalyticsEvent>? eventQueue,
    int? totalEvents,
    DateTime? lastSendTime,
  }) {
    return AnalyticsState(
      eventQueue: eventQueue ?? this.eventQueue,
      totalEvents: totalEvents ?? this.totalEvents,
      lastSendTime: lastSendTime ?? this.lastSendTime,
    );
  }
}

/// StateNotifier for analytics tracking
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier(super.state);

  /// Record an analytics event
  void track(AnalyticsEvent event) {
    final queue = List<AnalyticsEvent>.from(state.eventQueue);
    queue.add(event);

    // Keep queue size manageable (max 100 events)
    if (queue.length > 100) {
      queue.removeRange(0, queue.length - 100);
    }

    state = state.copyWith(
      eventQueue: queue,
      totalEvents: state.totalEvents + 1,
    );
  }

  /// Record a screen view
  void screenView(String screenName, [Map<String, dynamic>? params]) {
    track(AnalyticsEvent.screenView(
      screenName: screenName,
      parameters: params,
    ));
  }

  /// Record a button tap
  void buttonTap(String buttonName, [Map<String, dynamic>? params]) {
    track(AnalyticsEvent.buttonTap(
      buttonName: buttonName,
      parameters: params,
    ));
  }

  /// Record feature usage
  void featureUsed(String featureName, [Map<String, dynamic>? params]) {
    track(AnalyticsEvent.featureUsed(
      featureName: featureName,
      parameters: params,
    ));
  }

  /// Clear event queue (after sending to analytics service)
  void clearQueue() {
    state = state.copyWith(
      eventQueue: const [],
      lastSendTime: DateTime.now(),
    );
  }
}

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>(
  (ref) => AnalyticsNotifier(const AnalyticsState()),
);

/// Convenience providers
final eventQueueProvider = Provider<List<AnalyticsEvent>>((ref) {
  return ref.watch(analyticsProvider).eventQueue;
});

final totalEventsProvider = Provider<int>((ref) {
  return ref.watch(analyticsProvider).totalEvents;
});
