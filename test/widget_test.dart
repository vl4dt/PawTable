// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawtable/main.dart';

void main() {
  group('PawTable App Tests', () {
    testWidgets('PawTable app smoke test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const ProviderScope(
          child: PawTableApp(),
        ),
      );

      // Pump once to render the initial frame (splash/error screen)
      await tester.pump();

      // Verify that the app renders without error
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app has correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PawTableApp(),
        ),
      );

      await tester.pump();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.title, 'PawTable');
    });

    testWidgets('app has Material 3 theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PawTableApp(),
        ),
      );

      await tester.pump();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme?.useMaterial3, isTrue);
    });

    testWidgets('app initializes without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PawTableApp(),
        ),
      );

      // Pump multiple times to allow async initialization
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify app is still in valid state
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
