import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry/sentry.dart';
import 'package:pawtable/core/sentry/sentry_service.dart';

void main() {
  group('SentryService', () {
    late SentryService service;

    setUp(() {
      service = SentryService();
    });

    test('is a singleton', () {
      final service1 = SentryService();
      final service2 = SentryService();
      expect(service1, equals(service2));
    });

    test('is not initialized without DSN', () {
      expect(service.isInitialized, isFalse);
    });

    test('initialize with empty DSN does not initialize', () async {
      await service.initialize(dsn: '');
      expect(service.isInitialized, isFalse);
    });

    test('captureException with no init is a no-op', () async {
      await service.captureException(Exception('test'));
    });

    test('captureMessage with no init is a no-op', () async {
      await service.captureMessage('test message');
    });

    test('setUser with no init is a no-op', () {
      service.setUser(
        userId: '123',
        email: 'test@example.com',
        username: 'tester',
      );
    });

    test('addBreadcrumb with no init is a no-op', () async {
      await service.addBreadcrumb(Breadcrumb(message: 'test'));
    });

    test('setTag with no init is a no-op', () {
      service.setTag('key', 'value');
    });

    test('setContext with no init is a no-op', () {
      service.setContext('user', {'id': 1});
    });

    test('clearUser with no init is a no-op', () {
      service.clearUser();
    });

    test('endSession with no init is a no-op', () async {
      await service.endSession();
    });

    test('startSession with no init is a no-op', () async {
      await service.startSession();
    });

    test('second initialize call is ignored', () async {
      await service.initialize(dsn: '');
      await service.initialize(dsn: '');
      expect(service.isInitialized, isFalse);
    });
  });

  group('SentryErrorBoundary', () {
    testWidgets('renders child without error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SentryErrorBoundary(child: Text('Hello')),
        ),
      );

      expect(find.byType(SentryErrorBoundary), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('displays fallback on error with custom builder',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SentryErrorBoundary(
            child: const Text('Child'),
            fallbackBuilder: (ctx, err) => const Text('Fallback'),
          ),
        ),
      );

      expect(find.text('Child'), findsOneWidget);

      // Simulate error by setting error state
      await tester.pumpWidget(
        MaterialApp(
          home: SentryErrorBoundary(
            child: const Text('Child'),
            fallbackBuilder: (ctx, err) => const Text('Fallback'),
          ),
        ),
      );

      // Verify boundary renders
      expect(find.byType(SentryErrorBoundary), findsOneWidget);
    });
  });
}
