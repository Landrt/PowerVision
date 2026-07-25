import 'package:flutter/material.dart';

/// AppColors defines the Professional Light palette for VoltCam.
/// Inspired by official European energy & grid monitoring apps
/// (RTE ÉcoWatt, Enedis, Electricity Maps, Octopus Energy).
/// Clean, trustworthy, institutional — NOT dark/neon.
class AppColors {
  AppColors._();

  // Background & Surface (Clean Light Professional)
  static const Color background = Color(0xFFFAFBFD); // Very light blue-gray
  static const Color surface = Color(0xFFFFFFFF); // White card surfaces
  static const Color surfaceLight = Color(0xFFF1F4F8); // Light gray elevated

  // Card & Container Spec Colors
  static const Color glassSurface = Color(0x33FFFFFF);
  static const Color glassSurfaceOpaque = Color(0xCCFFFFFF);
  static const Color glassBorder = Color(0xFFE5E7EB); // Subtle gray border
  static const Color glassBorderSubtle = Color(0xFFF0F0F2);
  static const Color glassGlow = Color(0x0A1B65A6); // Very subtle blue glow

  // Primary & Accent Colors (Institutional Utility Palette)
  static const Color electricCyan = Color(0xFF1B65A6); // Deep Utility Blue (Enedis/RTE)
  static const Color voltYellow = Color(0xFFE8920C); // Warm Amber Warning (ÉcoWatt)
  static const Color dangerRed = Color(0xFFD63B3B); // Muted Safety Red
  static const Color successGreen = Color(0xFF2D9F5D); // Natural Eco Green
  static const Color maintenancePurple = Color(0xFF7C5CBA); // Slate Purple

  // Text Colors (Dark text on light background)
  static const Color textPrimary = Color(0xFF1A1D23); // Dark charcoal
  static const Color textSecondary = Color(0xFF5A6370); // Slate gray
  static const Color textMuted = Color(0xFF9CA3AF); // Light muted gray

  // Status & Priority Colors
  static const Color statusNormal = successGreen;
  static const Color statusWarning = voltYellow;
  static const Color statusCritical = dangerRed;
  static const Color statusMaintenance = maintenancePurple;

  // Gradients
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF1B65A6), Color(0xFF154E85)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient voltGradient = LinearGradient(
    colors: [Color(0xFFE8920C), Color(0xD9E8920C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x0DFFFFFF),
      Color(0x06F1F4F8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
