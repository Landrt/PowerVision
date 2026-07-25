import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/glassmorphism.dart';

class ApplianceRecommendation {
  final String id;
  final String name;
  final String sensitivity;
  final IconData icon;
  final bool defaultSafeState;

  const ApplianceRecommendation({
    required this.id,
    required this.name,
    required this.sensitivity,
    required this.icon,
    required this.defaultSafeState,
  });
}

class ProtectModeWidget extends StatefulWidget {
  final int riskScore; // 0 to 100
  final VoidCallback? onTelemetrySimulateToggle;

  const ProtectModeWidget({
    super.key,
    required this.riskScore,
    this.onTelemetrySimulateToggle,
  });

  @override
  State<ProtectModeWidget> createState() => _ProtectModeWidgetState();
}

class _ProtectModeWidgetState extends State<ProtectModeWidget> {
  late Map<String, bool> _applianceToggles;

  static const List<ApplianceRecommendation> _appliances = [
    ApplianceRecommendation(
      id: 'app-1',
      name: 'Réfrigérateur & Congélateur',
      sensitivity: 'Haute sensibilité (Compresseur)',
      icon: Icons.kitchen_rounded,
      defaultSafeState: true,
    ),
    ApplianceRecommendation(
      id: 'app-2',
      name: 'Téléviseur & Home Cinéma',
      sensitivity: 'Moyenne (Processeur vidéo)',
      icon: Icons.tv_rounded,
      defaultSafeState: true,
    ),
    ApplianceRecommendation(
      id: 'app-3',
      name: 'Climatiseur',
      sensitivity: 'Charge forte (Surtension)',
      icon: Icons.ac_unit_rounded,
      defaultSafeState: false,
    ),
    ApplianceRecommendation(
      id: 'app-4',
      name: 'Ordinateur Portable & Serveur',
      sensitivity: 'Données critiques (Batterie)',
      icon: Icons.laptop_rounded,
      defaultSafeState: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _applianceToggles = {
      for (var app in _appliances) app.id: app.defaultSafeState,
    };
  }

  Color get _statusColor {
    if (widget.riskScore < 40) return AppColors.successGreen;
    if (widget.riskScore < 70) return AppColors.voltYellow;
    return AppColors.dangerRed;
  }

  String get _statusLabel {
    if (widget.riskScore < 40) return 'Stable';
    if (widget.riskScore < 70) return 'À surveiller';
    return 'Protéger';
  }

  String get _recommendationText {
    if (widget.riskScore < 40) return 'Continuer la surveillance normale';
    if (widget.riskScore < 70) return 'Éviter de brancher des appareils sensibles';
    return 'Débrancher de façon sûre les appareils sensibles';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor;

    return GlassCard(
      key: const Key('protect_mode_card'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Fixed Overflow)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.electricCyan, size: 24),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Protect Mode',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GlassBadge(
                label: 'Score: ${widget.riskScore}/100',
                color: statusColor,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Radial Radial Risk Gauge & Status Summary
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(170, 170),
                        painter: RadialRiskPainter(
                          score: widget.riskScore,
                          color: statusColor,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${widget.riskScore}',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          const Text(
                            'RISK SCORE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Status Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Statut : $_statusLabel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _recommendationText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Appliance Safety Recommendations Cards
          const Text(
            'Recommandations pour vos Équipements',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          ..._appliances.map((app) {
            final isProtected = _applianceToggles[app.id] ?? false;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isProtected ? AppColors.electricCyan.withOpacity(0.4) : AppColors.glassBorderSubtle,
                ),
              ),
              child: Row(
                children: [
                  Icon(app.icon, color: isProtected ? AppColors.electricCyan : AppColors.textMuted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          app.sensitivity,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isProtected,
                    activeColor: AppColors.electricCyan,
                    onChanged: (val) {
                      setState(() {
                        _applianceToggles[app.id] = val;
                      });
                    },
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Live Simulation Button (Fixed Overflow)
          if (widget.onTelemetrySimulateToggle != null)
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                onPressed: widget.onTelemetrySimulateToggle,
                label: 'Simuler événement Télémétrie',
                icon: Icons.bolt_rounded,
                color: AppColors.voltYellow,
              ),
            ),
        ],
      ),
    );
  }
}

class RadialRiskPainter extends CustomPainter {
  final int score;
  final Color color;

  RadialRiskPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;

    // Background track arc
    final trackPaint = Paint()
      ..color = AppColors.glassBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      trackPaint,
    );

    // Active progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * (math.pi * 1.5);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RadialRiskPainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}
