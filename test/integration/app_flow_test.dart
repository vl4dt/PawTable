import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawtable/main.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('app initializes and renders',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PawTableApp(),
        ),
      );

      await tester.pump();

      // Verify app initializes without error
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app has correct title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PawTableApp(),
        ),
      );

      await tester.pump();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.title, 'PawTable');
    });

    testWidgets('app has Material 3 theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PawTableApp(),
        ),
      );

      await tester.pump();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme?.useMaterial3, isTrue);
    });

    testWidgets('app handles provider initialization',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PawTableApp(),
        ),
      );

      // Pump multiple times to allow async providers to initialize
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify app is still in valid state
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app handles navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PawTableApp(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify MaterialApp is present
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verify Scaffold is present
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
