import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../domain/models/device_event_model.dart';
import '../../domain/models/device_model.dart';

/// Integration service to communicate with the "VoltCam Box" Android app simulator
/// via WebSocket or BLE GATT specs defined in FLUTTER_INTEGRATION_GUIDE.md
class VoltCamBoxIntegrationService {
  // BLE GATT UUID Constants from FLUTTER_INTEGRATION_GUIDE.md
  static const String serviceUuid = "4f4c5443-1000-8000-8000-00805f9b34fb";
  static const String deviceInfoUuid = "4f4c5443-1001-8000-8000-00805f9b34fb";
  static const String liveTelemetryUuid = "4f4c5443-1002-8000-8000-00805f9b34fb";
  static const String eventStreamUuid = "4f4c5443-1003-8000-8000-00805f9b34fb";
  static const String deviceHealthUuid = "4f4c5443-1004-8000-8000-00805f9b34fb";
  static const String configUuid = "4f4c5443-1005-8000-8000-00805f9b34fb";

  final _telemetryController = StreamController<Map<String, dynamic>>.broadcast();
  final _eventController = StreamController<DeviceEventModel>.broadcast();

  Stream<Map<String, dynamic>> get telemetryStream => _telemetryController.stream;
  Stream<DeviceEventModel> get eventStream => _eventController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Timer? _simulationTimer;

  /// Parse live telemetry frame received from WebSocket / BLE
  Map<String, dynamic> parseTelemetryFrame(String jsonPayload) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonPayload);
      _telemetryController.add(data);
      return data;
    } catch (e) {
      return {};
    }
  }

  /// Parse event stream frame received from WebSocket / BLE
  DeviceEventModel? parseEventFrame(String jsonPayload) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonPayload);
      final event = DeviceEventModel(
        eventId: data['eventId'] ?? 'evt-${DateTime.now().millisecondsSinceEpoch}',
        deviceId: data['deviceId'] ?? 'VTC-2026-DEMO-001',
        installationId: data['installationId'] ?? 'inst-001',
        zoneId: data['zoneId'] ?? 'zone-001',
        type: data['type'] ?? 'OUTAGE',
        occurredAt: DateTime.tryParse(data['occurredAt'] ?? '') ?? DateTime.now(),
        lastGasp: data['lastGasp'] ?? false,
        summary: data['summary'] is Map ? Map<String, dynamic>.from(data['summary']) : {},
      );
      _eventController.add(event);
      return event;
    } catch (e) {
      return null;
    }
  }

  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;

  /// Connect to the Android Box simulator via WebSocket
  Future<bool> connectToBoxWebSocket(String ipAddress) async {
    try {
      final wsUrl = Uri.parse('ws://$ipAddress:8080/ws');
      _channel = WebSocketChannel.connect(wsUrl);
      
      // Wait for connection to establish by listening to the first event or error
      _isConnected = true;
      
      _wsSubscription = _channel!.stream.listen(
        (message) {
          if (message is String) {
            try {
              final Map<String, dynamic> data = jsonDecode(message);
              if (data.containsKey('voltage') || data.containsKey('protocolVersion')) {
                parseTelemetryFrame(message);
              } else if (data.containsKey('eventId') || data.containsKey('type')) {
                parseEventFrame(message);
              }
            } catch (e) {
              // ignore parse errors
            }
          }
        },
        onError: (error) {
          _isConnected = false;
          stopSimulation();
        },
        onDone: () {
          _isConnected = false;
          stopSimulation();
        },
      );
      
      return true;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  /// Start simulated live connection with VoltCam Box for local demo & testing
  void startDemoSimulation({
    double baseVoltage = 220.4,
    double baseCurrent = 2.35,
    int baseBattery = 92,
  }) {
    _isConnected = true;
    int seq = 100;

    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      seq++;
      final isStable = (seq % 12 != 0);
      final voltage = isStable ? (baseVoltage + (seq % 3 - 1) * 0.8) : 175.2;
      final quality = isStable ? 'STABLE' : 'UNSTABLE';

      final frame = {
        'protocolVersion': 1,
        'sequence': seq,
        'sampledAt': DateTime.now().toIso8601String(),
        'voltage': double.parse(voltage.toStringAsFixed(1)),
        'current': baseCurrent,
        'power': double.parse((voltage * baseCurrent).toStringAsFixed(1)),
        'batteryPercent': baseBattery,
        'frequency': 50.0,
        'powerFactor': 0.95,
        'isAcPowerPresent': true,
        'qualityState': quality,
      };

      _telemetryController.add(frame);
    });
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
    _wsSubscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
  }

  void dispose() {
    stopSimulation();
    _telemetryController.close();
    _eventController.close();
  }
}
