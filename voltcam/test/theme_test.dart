import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltcam/core/theme/app_colors.dart';
import 'package:voltcam/core/theme/app_theme.dart';
import 'package:voltcam/core/theme/glassmorphism.dart';

void main() {
  group('AppColors Tests', () {
    test('verifies Dark Mode Glassmorphism palette colors', () {
      expect(AppColors.background, const Color(0xFF0B0F19));
      expect(AppColors.surface, const Color(0xFF1E293B));
      expect(AppColors.electricCyan, const Color(0xFF00F2FE));
      expect(AppColors.voltYellow, const Color(0xFFFFB800));
      expect(AppColors.dangerRed, const Color(0xFFFF3B30));
      expect(AppColors.successGreen, const Color(0xFF34C759));
      expect(AppColors.maintenancePurple, const Color(0xFFAF52DE));
    });
  });

  group('AppTheme Tests', () {
    test('verifies darkTheme configuration', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.primaryColor, AppColors.electricCyan);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.primary, AppColors.electricCyan);
      expect(theme.cardTheme.color, AppColors.surface);
      expect(theme.bottomNavigationBarTheme.selectedItemColor, AppColors.electricCyan);
    });
  });

  group('Glassmorphism Widgets Tests', () {
    testWidgets('GlassContainer renders child and BackdropFilter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassContainer(
              child: Text('Test Glass Container'),
            ),
          ),
        ),
      );

      expect(find.text('Test Glass Container'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('GlassCard handles tap event correctly', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassCard(
              onTap: () {
                tapped = true;
              },
              child: const Text('Test Glass Card'),
            ),
          ),
        ),
      );

      expect(find.text('Test Glass Card'), findsOneWidget);
      await tester.tap(find.text('Test Glass Card'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('GlassBadge displays label and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassBadge(
              label: 'ACTIVE',
              icon: Icons.check,
              color: AppColors.successGreen,
            ),
          ),
        ),
      );

      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('GlassButton handles tap event', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassButton(
              onPressed: () {
                pressed = true;
              },
              label: 'Action Button',
              icon: Icons.bolt,
            ),
          ),
        ),
      );

      expect(find.text('Action Button'), findsOneWidget);
      expect(find.byIcon(Icons.bolt), findsOneWidget);

      await tester.tap(find.byType(GlassButton));
      await tester.pump();
      expect(pressed, isTrue);
    });
  });
}
