/// Riverpod providers for the Sentry crash reporting service.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawtable/core/sentry/sentry_service.dart';

/// Provider for the global [SentryService] singleton.
final sentryServiceProvider = Provider<SentryService>(
  (ref) => SentryService(),
);

/// Provider that indicates whether Sentry is initialized.
final sentryInitializedProvider = Provider<bool>(
  (ref) => ref.watch(sentryServiceProvider).isInitialized,
);

/// Provider for the current Sentry user context (if set).
final sentryUserProvider = Provider<String?>(
  (ref) => null, // Placeholder — updated when user logs in
);
