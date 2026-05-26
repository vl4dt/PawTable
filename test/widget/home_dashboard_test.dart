import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawtable/features/home/presentation/views/home_dashboard.dart';

void main() {
  group('HomeDashboard', () {
    testWidgets('renders without crashing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeDashboard(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(HomeDashboard), findsOneWidget);
    });

    testWidgets('displays scaffold structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeDashboard(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(HomeDashboard), findsOneWidget);
    });
  });
}
