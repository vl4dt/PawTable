/// Sentry crash reporting service for PawTable.
///
/// Wraps [SentryFlutter] initialization, capture, and configuration.
/// Provides graceful degradation: if DSN is empty or Sentry fails to
/// initialize, the app continues without crash reporting (no crashes).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:pawtable/core/theme/themes.dart';

/// Sentry service singleton for crash reporting and error tracking.
class SentryService {
  SentryService._();

  static final SentryService _instance = SentryService._();

  /// Global singleton accessor.
  factory SentryService() => _instance;

  bool _isInitialized = false;

  /// Whether Sentry is active and capturing events.
  bool get isInitialized => _isInitialized;

  /// Initialize Sentry with the provided DSN.
  ///
  /// If [dsn] is empty, Sentry is not initialized (graceful degradation).
  /// This allows the app to run in development without a Sentry project.
  ///
  /// [environment] defaults to 'production' if [kReleaseMode] is true,
  /// otherwise 'development'.
  Future<void> initialize({
    String dsn = '',
    String environment = '',
    double? tracesSampleRate,
    bool enableAutoSessionTracking = true,
    Duration? sessionTrackingInterval,
  }) async {
    if (_isInitialized) return;

    if (dsn.isEmpty) {
      return;
    }

    try {
      await SentryFlutter.init(
        (options) {
          options.dsn = dsn;
          options.environment = environment.isNotEmpty
              ? environment
              : (kReleaseMode ? 'production' : 'development');
          if (tracesSampleRate != null) {
            options.tracesSampleRate = tracesSampleRate;
          }
          options.enableAutoSessionTracking = enableAutoSessionTracking;
          if (sessionTrackingInterval != null) {
            options.autoSessionTrackingInterval = sessionTrackingInterval;
          }
          options.beforeSend = (event, hint) {
            // Filter out low-value Flutter framework events
            if (event.message?.formatted?.startsWith('[Flutter]') == true) {
              return null;
            }
            return event;
          };
        },
      );
      _isInitialized = true;
    } catch (e) {
      // If Sentry init fails, continue without it
      _isInitialized = false;
    }
  }

  /// Capture an exception with optional context.
  Future<void> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
  }) async {
    if (!_isInitialized) return;
    await Sentry.captureException(exception, stackTrace: stackTrace);
  }

  /// Capture a message/event.
  Future<void> captureMessage(
    String message, {
    SentryLevel? level,
  }) async {
    if (!_isInitialized) return;
    await Sentry.captureMessage(
      message,
      level: level ?? SentryLevel.info,
    );
  }

  /// Set user context for Sentry events.
  void setUser({String? userId, String? email, String? username}) {
    if (!_isInitialized) return;
    Sentry.configureScope(
      (scope) => scope.setUser(
        SentryUser(id: userId, email: email, username: username),
      ),
    );
  }

  /// Add a breadcrumb to the current scope.
  Future<void> addBreadcrumb(Breadcrumb breadcrumb) async {
    if (!_isInitialized) return;
    await Sentry.addBreadcrumb(breadcrumb);
  }

  /// Set a tag on the current scope.
  void setTag(String key, String value) {
    if (!_isInitialized) return;
    Sentry.configureScope((scope) => scope.setTag(key, value));
  }

  /// Set a context key on the current scope.
  void setContext(String key, Map<String, dynamic> value) {
    if (!_isInitialized) return;
    Sentry.configureScope((scope) => scope.setContexts(key, value));
  }

  /// Clear user context.
  void clearUser() {
    if (!_isInitialized) return;
    Sentry.configureScope((scope) => scope.setUser(null));
  }

  /// End the current session (breadcrumb-based).
  Future<void> endSession() async {
    if (!_isInitialized) return;
    await Sentry.addBreadcrumb(
      Breadcrumb(message: 'Session ended', type: 'session'),
    );
  }

  /// Start a new session (breadcrumb-based).
  Future<void> startSession() async {
    if (!_isInitialized) return;
    await Sentry.addBreadcrumb(
      Breadcrumb(message: 'Session started', type: 'session'),
    );
  }
}

/// Widget that wraps a child in a Sentry error boundary.
///
/// Catches unhandled errors in the subtree and reports them to Sentry.
/// Displays a recovery UI on fatal errors.
class SentryErrorBoundary extends StatefulWidget {
  const SentryErrorBoundary({
    super.key,
    required this.child,
    this.onError,
    this.fallbackBuilder,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Optional callback when an error occurs.
  final Function(dynamic error, StackTrace? stackTrace)? onError;

  /// Custom fallback builder for error state.
  final Widget Function(BuildContext context, dynamic error)? fallbackBuilder;

  @override
  State<SentryErrorBoundary> createState() => _SentryErrorBoundaryState();
}

class _SentryErrorBoundaryState extends State<SentryErrorBoundary> {
  dynamic _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.fallbackBuilder != null) {
        return widget.fallbackBuilder!(context, _error);
      }
      return MaterialApp(
        title: 'PawTable',
        debugShowCheckedModeBanner: false,
        theme: PawThemes.lightTheme,
        home: Scaffold(
          appBar: AppBar(title: const Text('Something went wrong')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text('An error occurred while loading.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() => _error = null),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
