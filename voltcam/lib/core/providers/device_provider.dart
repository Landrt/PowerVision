import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device_model.dart';

/// State representation for Selected Device & Telemetry.
class DeviceState {
  final DeviceModel? selectedDevice;
  final List<DeviceModel> userDevices;
  final double currentVoltage; // Volts, e.g. 220.0
  final double frequency; // Hz, e.g. 50.0
  final bool isProtectModeActive;
  final bool isLoading;
  final String? error;

  const DeviceState({
    this.selectedDevice,
    this.userDevices = const [],
    this.currentVoltage = 220.0,
    this.frequency = 50.0,
    this.isProtectModeActive = true,
    this.isLoading = false,
    this.error,
  });

  DeviceState copyWith({
    DeviceModel? selectedDevice,
    List<DeviceModel>? userDevices,
    double? currentVoltage,
    double? frequency,
    bool? isProtectModeActive,
    bool? isLoading,
    String? error,
  }) {
    return DeviceState(
      selectedDevice: selectedDevice ?? this.selectedDevice,
      userDevices: userDevices ?? this.userDevices,
      currentVoltage: currentVoltage ?? this.currentVoltage,
      frequency: frequency ?? this.frequency,
      isProtectModeActive: isProtectModeActive ?? this.isProtectModeActive,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier managing device status, telemetry, and Protect Mode.
class DeviceNotifier extends StateNotifier<DeviceState> {
  DeviceNotifier() : super(const DeviceState());

  void selectDevice(DeviceModel device) {
    state = state.copyWith(selectedDevice: device);
  }

  void setUserDevices(List<DeviceModel> devices) {
    final DeviceModel? currentSelected = state.selectedDevice ?? (devices.isNotEmpty ? devices.first : null);
    state = state.copyWith(
      userDevices: devices,
      selectedDevice: currentSelected,
    );
  }

  void updateTelemetry({required double voltage, required double frequency}) {
    state = state.copyWith(
      currentVoltage: voltage,
      frequency: frequency,
    );
  }

  void toggleProtectMode(bool active) {
    state = state.copyWith(isProtectModeActive: active);
  }

  void updateDeviceStatus(String status) {
    if (state.selectedDevice != null) {
      final updatedDevice = state.selectedDevice!.copyWith(
        status: status,
        lastSeenAt: DateTime.now(),
      );
      final updatedList = state.userDevices.map((d) {
        return d.deviceId == updatedDevice.deviceId ? updatedDevice : d;
      }).toList();

      state = state.copyWith(
        selectedDevice: updatedDevice,
        userDevices: updatedList,
      );
    }
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

/// Riverpod provider for Device & Telemetry state management.
final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>((ref) {
  return DeviceNotifier();
});
