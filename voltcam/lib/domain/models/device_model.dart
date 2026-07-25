import 'dart:convert';

class DeviceModel {
  final String deviceId;
  final String ownerUid;
  final String hardwareId;
  final String status; // e.g. ONLINE, OFFLINE
  final String firmwareVersion;
  final DateTime lastSeenAt;

  const DeviceModel({
    required this.deviceId,
    required this.ownerUid,
    required this.hardwareId,
    required this.status,
    required this.firmwareVersion,
    required this.lastSeenAt,
  });

  DeviceModel copyWith({
    String? deviceId,
    String? ownerUid,
    String? hardwareId,
    String? status,
    String? firmwareVersion,
    DateTime? lastSeenAt,
  }) {
    return DeviceModel(
      deviceId: deviceId ?? this.deviceId,
      ownerUid: ownerUid ?? this.ownerUid,
      hardwareId: hardwareId ?? this.hardwareId,
      status: status ?? this.status,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'ownerUid': ownerUid,
      'hardwareId': hardwareId,
      'status': status,
      'firmwareVersion': firmwareVersion,
      'lastSeenAt': lastSeenAt.toIso8601String(),
    };
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      deviceId: map['deviceId'] as String? ?? '',
      ownerUid: map['ownerUid'] as String? ?? '',
      hardwareId: map['hardwareId'] as String? ?? '',
      status: map['status'] as String? ?? 'OFFLINE',
      firmwareVersion: map['firmwareVersion'] as String? ?? '1.0.0',
      lastSeenAt: _parseDateTime(map['lastSeenAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceModel.fromJson(String source) =>
      DeviceModel.fromMap(json.decode(source) as Map<String, dynamic>);

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  @override
  String toString() {
    return 'DeviceModel(deviceId: $deviceId, ownerUid: $ownerUid, hardwareId: $hardwareId, status: $status, firmwareVersion: $firmwareVersion, lastSeenAt: $lastSeenAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceModel &&
        other.deviceId == deviceId &&
        other.ownerUid == ownerUid &&
        other.hardwareId == hardwareId &&
        other.status == status &&
        other.firmwareVersion == firmwareVersion &&
        other.lastSeenAt == lastSeenAt;
  }

  @override
  int get hashCode {
    return deviceId.hashCode ^
        ownerUid.hashCode ^
        hardwareId.hashCode ^
        status.hashCode ^
        firmwareVersion.hashCode ^
        lastSeenAt.hashCode;
  }
}
