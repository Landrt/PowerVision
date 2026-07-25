import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltcam/main.dart';

void main() {
  group('Tab Navigation Widget Tests', () {
    testWidgets('renders initial shell with 5 bottom navigation bar tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: VoltCamApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Check that bottom navigation bar items exist
      expect(find.text('Carte Live'), findsWidgets);
      expect(find.text('Réseau Social'), findsWidgets);
      expect(find.text('Assistant IA'), findsWidgets);
      expect(find.text('Communauté'), findsWidgets);
      expect(find.text('Mon Boîtier'), findsWidgets);
    });

    testWidgets('navigates through tabs when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: VoltCamApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Tab 2: Réseau Social
      await tester.tap(find.text('Réseau Social').last);
      await tester.pumpAndSettle();
      expect(find.text('Réseau Social GridTrust'), findsOneWidget);

      // Tap Tab 3: Assistant IA
      await tester.tap(find.text('Assistant IA').last);
      await tester.pumpAndSettle();
      expect(find.text('Assistant IA VoltCam'), findsOneWidget);

      // Tap Tab 4: Communauté
      await tester.tap(find.text('Communauté').last);
      await tester.pumpAndSettle();
      expect(find.text('Communauté & Entraide'), findsOneWidget);

      // Tap Tab 5: Mon Boîtier
      await tester.tap(find.text('Mon Boîtier').last);
      await tester.pumpAndSettle();
      expect(find.text('Mon Boîtier IoT Dashboard'), findsOneWidget);
    });
  });
}
