/// Stub crash reporting service for PawTable.
///
/// Sentry is disabled due to Kotlin language version incompatibility
/// with the sentry_flutter plugin. This stub provides the same public API
/// but does nothing (no crash reports).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Crash reporting service singleton (stub — no actual crash reporting).
class SentryService {
  SentryService._();

  static final SentryService _instance = SentryService._();

  factory SentryService() => _instance;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize({
    String dsn = '',
    String environment = '',
    double? tracesSampleRate,
    bool enableAutoSessionTracking = true,
    Duration? sessionTrackingInterval,
  }) async {
    _isInitialized = false;
  }

  Future<void> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
  }) async {
    // No-op — crash reporting disabled
    if (kDebugMode) {
      debugPrint('[SentryStub] Exception (not reported): $exception');
    }
  }

  Future<void> captureMessage(
    String message, {
    dynamic level,
  }) async {
    // No-op
    if (kDebugMode) {
      debugPrint('[SentryStub] Message (not reported): $message');
    }
  }

  void setUser({String? userId, String? email, String? username}) {}

  Future<void> addBreadcrumb(dynamic breadcrumb) async {}

  void setTag(String key, String value) {}

  void setContext(String key, Map<String, dynamic> value) {}

  void clearUser() {}

  Future<void> endSession() async {}

  Future<void> startSession() async {}
}

/// Widget that wraps a child — no-op error boundary (stub).
class SentryErrorBoundary extends StatelessWidget {
  const SentryErrorBoundary({
    super.key,
    required this.child,
    this.onError,
    this.fallbackBuilder,
  });

  final Widget child;
  final Function(dynamic error, StackTrace? stackTrace)? onError;
  final Widget Function(BuildContext context, dynamic error)? fallbackBuilder;

  @override
  Widget build(BuildContext context) => child;
}
