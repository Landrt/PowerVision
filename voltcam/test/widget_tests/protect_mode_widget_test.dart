import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltcam/core/theme/app_theme.dart';
import 'package:voltcam/features/device/protect_mode_widget.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: child,
        ),
      ),
    );
  }

  group('ProtectModeWidget Widget Tests', () {
    testWidgets('renders Stable state correctly when risk score < 40', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ProtectModeWidget(riskScore: 20),
      ));

      expect(find.text('Protect Mode Dashboard'), findsOneWidget);
      expect(find.text('Score: 20/100'), findsOneWidget);
      expect(find.text('Statut : Stable'), findsOneWidget);
      expect(find.text('Continuer la surveillance normale'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(4));
    });

    testWidgets('renders À surveiller state correctly when risk score is between 40 and 69', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ProtectModeWidget(riskScore: 55),
      ));

      expect(find.text('Score: 55/100'), findsOneWidget);
      expect(find.text('Statut : À surveiller'), findsOneWidget);
      expect(find.text('Éviter de brancher des appareils sensibles'), findsOneWidget);
    });

    testWidgets('renders Protéger state correctly when risk score >= 70', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ProtectModeWidget(riskScore: 85),
      ));

      expect(find.text('Score: 85/100'), findsOneWidget);
      expect(find.text('Statut : Protéger'), findsOneWidget);
      expect(find.text('Débrancher de façon sûre les appareils sensibles'), findsOneWidget);
    });

    testWidgets('allows toggling appliance recommendations', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ProtectModeWidget(riskScore: 30),
      ));

      final firstSwitch = find.byType(Switch).first;
      expect(firstSwitch, findsOneWidget);

      await tester.tap(firstSwitch);
      await tester.pumpAndSettle();
    });
  });
}
