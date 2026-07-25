import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltcam/core/theme/app_theme.dart';
import 'package:voltcam/features/map/map_screen.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: child,
      ),
    );
  }

  group('MapScreen Widget Tests', () {
    testWidgets('renders MapScreen scaffold and top filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const MapScreen()));

      expect(find.byKey(const Key('map_screen_scaffold')), findsOneWidget);
      expect(find.text('Carte Live Grid Monitoring'), findsOneWidget);

      // Verify filter chips presence
      expect(find.text('Tous'), findsOneWidget);
      expect(find.text('Coupures (Outage)'), findsOneWidget);
      expect(find.text('Instabilités'), findsOneWidget);
      expect(find.text('Maintenance'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
    });

    testWidgets('can filter zones using ChoiceChips', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const MapScreen()));

      await tester.tap(find.text('Coupures (Outage)'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Normal'));
      await tester.pumpAndSettle();
    });
  });
}
