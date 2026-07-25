import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/glassmorphism.dart';
import '../../data/remote/voltcam_box_integration_service.dart';
import 'protect_mode_widget.dart';

enum TelemetrySimulationMode {
  normal,
  undervoltage,
  overvoltage,
  outage,
}

class TelemetryState {
  final double voltage;
  final double current;
  final int batteryPercent;
  final int riskScore;
  final String statusText;
  final List<double> history;
  final TelemetrySimulationMode mode;

  const TelemetryState({
    required this.voltage,
    required this.current,
    required this.batteryPercent,
    required this.riskScore,
    required this.statusText,
    required this.history,
    required this.mode,
  });

  TelemetryState copyWith({
    double? voltage,
    double? current,
    int? batteryPercent,
    int? riskScore,
    String? statusText,
    List<double>? history,
    TelemetrySimulationMode? mode,
  }) {
    return TelemetryState(
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      riskScore: riskScore ?? this.riskScore,
      statusText: statusText ?? this.statusText,
      history: history ?? this.history,
      mode: mode ?? this.mode,
    );
  }
}

final deviceTelemetryProvider = StateProvider<TelemetryState>((ref) {
  return const TelemetryState(
    voltage: 220.4,
    current: 4.2,
    batteryPercent: 92,
    riskScore: 18,
    statusText: 'Réseau Stable',
    history: [218.5, 221.0, 219.8, 220.4, 222.1, 220.0, 220.4],
    mode: TelemetrySimulationMode.normal,
  );
});

class DeviceDashboardScreen extends ConsumerStatefulWidget {
  const DeviceDashboardScreen({super.key});

  @override
  ConsumerState<DeviceDashboardScreen> createState() => _DeviceDashboardScreenState();
}

class _DeviceDashboardScreenState extends ConsumerState<DeviceDashboardScreen> {
  bool _isConnectingBox = false;
  bool _isBoxConnected = false;
  final VoltCamBoxIntegrationService _integrationService = VoltCamBoxIntegrationService();

  @override
  void dispose() {
    _integrationService.dispose();
    super.dispose();
  }

  void _cycleTelemetrySimulation() {
    final currentMode = ref.read(deviceTelemetryProvider).mode;
    late TelemetryState nextState;

    switch (currentMode) {
      case TelemetrySimulationMode.normal:
        nextState = const TelemetryState(
          voltage: 172.5,
          current: 2.1,
          batteryPercent: 89,
          riskScore: 58,
          statusText: 'Baisse de tension (Under-voltage)',
          history: [220.0, 210.0, 195.0, 182.0, 175.0, 172.5],
          mode: TelemetrySimulationMode.undervoltage,
        );
        break;
      case TelemetrySimulationMode.undervoltage:
        nextState = const TelemetryState(
          voltage: 258.0,
          current: 6.8,
          batteryPercent: 90,
          riskScore: 88,
          statusText: 'Surtension critique (Over-voltage)',
          history: [172.5, 210.0, 240.0, 252.0, 258.0],
          mode: TelemetrySimulationMode.overvoltage,
        );
        break;
      case TelemetrySimulationMode.overvoltage:
        nextState = const TelemetryState(
          voltage: 0.0,
          current: 0.0,
          batteryPercent: 95,
          riskScore: 96,
          statusText: 'Coupure Réseau (Outage Event)',
          history: [258.0, 180.0, 50.0, 0.0, 0.0],
          mode: TelemetrySimulationMode.outage,
        );
        break;
      case TelemetrySimulationMode.outage:
        nextState = const TelemetryState(
          voltage: 220.4,
          current: 4.2,
          batteryPercent: 92,
          riskScore: 18,
          statusText: 'Réseau Normalisé',
          history: [0.0, 150.0, 210.0, 220.4, 220.0, 220.4],
          mode: TelemetrySimulationMode.normal,
        );
        break;
    }

    ref.read(deviceTelemetryProvider.notifier).state = nextState;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Simulation activée : ${nextState.statusText} (${nextState.voltage}V)'),
        backgroundColor: nextState.riskScore < 40
            ? AppColors.successGreen
            : (nextState.riskScore < 70 ? AppColors.voltYellow : AppColors.dangerRed),
      ),
    );
  }

  Color _getVoltageColor(double v) {
    if (v == 0) return AppColors.dangerRed;
    if (v < 185) return AppColors.voltYellow;
    if (v > 245) return AppColors.dangerRed;
    return AppColors.successGreen;
  }

  @override
  Widget build(BuildContext context) {
    final telemetry = ref.watch(deviceTelemetryProvider);
    final voltageColor = _getVoltageColor(telemetry.voltage);

    return Scaffold(
      key: const Key('device_screen_scaffold'),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.developer_board_rounded, color: AppColors.successGreen, size: 24),
            SizedBox(width: 8),
            Text('Mon Boîtier IoT Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt_rounded, color: AppColors.voltYellow),
            onPressed: _cycleTelemetrySimulation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Hardware Overview Card
            GlassCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.electricCyan.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.router_rounded, color: AppColors.electricCyan, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Boîtier VoltCam Pro #VTC-2026-001',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Firmware v1.2.0 • Zone: Yaoundé Biyem-Assi',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const GlassBadge(
                        label: 'ONLINE',
                        color: AppColors.successGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: GlassButton(
                      onPressed: () {
                        if (_isBoxConnected) {
                          _integrationService.stopSimulation();
                          setState(() => _isBoxConnected = false);
                          return;
                        }
                        _showConnectionDialog(context);
                      },
                      color: _isBoxConnected ? AppColors.successGreen : AppColors.electricCyan,
                      icon: _isConnectingBox
                          ? Icons.sync_rounded
                          : (_isBoxConnected ? Icons.bluetooth_connected_rounded : Icons.bluetooth_searching_rounded),
                      label: _isConnectingBox
                          ? 'Recherche du boîtier...'
                          : (_isBoxConnected ? 'Boîtier Connecté' : 'Jumeler l\'Appli Boîtier Android'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live Telemetry Readout Gauges (Voltage, Current, Battery)
            Row(
              children: [
                // Voltage Card
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.flash_on_rounded, size: 14, color: AppColors.voltYellow),
                            SizedBox(width: 4),
                            Expanded(child: Text('Tension', style: TextStyle(fontSize: 11, color: AppColors.textMuted), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${telemetry.voltage.toStringAsFixed(1)} V',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: voltageColor,
                            ),
                          ),
                        ),
                        Text(
                          telemetry.voltage == 0 ? 'Coupure' : (telemetry.voltage < 185 ? 'Basse' : 'Nominale'),
                          style: TextStyle(fontSize: 10, color: voltageColor, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Current Card
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.electric_meter_rounded, size: 14, color: AppColors.electricCyan),
                            SizedBox(width: 4),
                            Expanded(child: Text('Courant', style: TextStyle(fontSize: 11, color: AppColors.textMuted), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${telemetry.current.toStringAsFixed(1)} A',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.electricCyan,
                            ),
                          ),
                        ),
                        const Text('Charge', style: TextStyle(fontSize: 10, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Battery Card
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.battery_charging_full_rounded, size: 14, color: AppColors.successGreen),
                            SizedBox(width: 4),
                            Expanded(child: Text('Batterie', style: TextStyle(fontSize: 11, color: AppColors.textMuted), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${telemetry.batteryPercent}%',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.successGreen,
                            ),
                          ),
                        ),
                        const Text('Secours', style: TextStyle(fontSize: 10, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Telemetry Sparkline Line Chart
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Historique Télémétrie Tension (V)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Mode: ${telemetry.mode.name.toUpperCase()}',
                        style: TextStyle(fontSize: 11, color: voltageColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: TelemetrySparklinePainter(
                        points: telemetry.history,
                        lineColor: voltageColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Embedded Protect Mode Widget
            ProtectModeWidget(
              riskScore: telemetry.riskScore,
              onTelemetrySimulateToggle: _cycleTelemetrySimulation,
            ),
          ],
        ),
      ),
    );
  }

  void _showConnectionDialog(BuildContext context) {
    final ipController = TextEditingController(text: '10.0.2.2'); // default for Android emulator to host
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Connexion au Boîtier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Entrez l\'adresse IP de l\'application Android (ex: 192.168.1.5 ou 10.0.2.2 si émulateur local) :'),
              const SizedBox(height: 16),
              TextField(
                controller: ipController,
                decoration: const InputDecoration(
                  labelText: 'Adresse IP',
                  hintText: '192.168.x.x',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isConnectingBox = true);
                
                final success = await _integrationService.connectToBoxWebSocket(ipController.text.trim());
                
                if (mounted) {
                  setState(() {
                    _isConnectingBox = false;
                    _isBoxConnected = success;
                  });

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Boîtier connecté avec succès via WebSocket !'), backgroundColor: AppColors.successGreen),
                    );
                    
                    // Listen to telemetry
                    _integrationService.telemetryStream.listen((data) {
                      final voltage = data['voltage'] as double;
                      final current = data['current'] as double;
                      final battery = data['batteryPercent'] as int;
                      
                      final currentHistory = ref.read(deviceTelemetryProvider).history;
                      final newHistory = [...currentHistory.skip(1), voltage];
                      
                      int risk = 20;
                      if (voltage < 185) risk = 60;
                      if (voltage > 245) risk = 90;
                      if (voltage == 0) risk = 100;
                      
                      ref.read(deviceTelemetryProvider.notifier).state = TelemetryState(
                        voltage: voltage,
                        current: current,
                        batteryPercent: battery,
                        riskScore: risk,
                        statusText: voltage == 0 ? 'Coupure' : (risk > 50 ? 'Instable' : 'Normal'),
                        history: newHistory,
                        mode: TelemetrySimulationMode.normal,
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Échec de la connexion. Vérifiez l\'IP et l\'appli Android.'), backgroundColor: AppColors.dangerRed),
                    );
                  }
                }
              },
              child: const Text('Connecter'),
            ),
          ],
        );
      },
    );
  }
}

class TelemetrySparklinePainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;

  TelemetrySparklinePainter({required this.points, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double maxV = points.reduce((a, b) => a > b ? a : b).clamp(240.0, 300.0);
    final double minV = points.reduce((a, b) => a < b ? a : b).clamp(0.0, 180.0);
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);

    final path = Path();
    final dx = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final x = i * dx;
      final normalizedY = (points[i] - minV) / range;
      final y = size.height - (normalizedY * size.height * 0.8) - 10;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw reference nominal line at 220V
    final refPaint = Paint()
      ..color = AppColors.glassBorderSubtle
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), refPaint);

    canvas.drawPath(path, paint);

    // Draw point dots
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final x = i * dx;
      final normalizedY = (points[i] - minV) / range;
      final y = size.height - (normalizedY * size.height * 0.8) - 10;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TelemetrySparklinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}
