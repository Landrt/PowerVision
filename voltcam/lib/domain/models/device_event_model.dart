import 'dart:convert';

class DeviceEventModel {
  final String eventId;
  final String deviceId;
  final String installationId;
  final String zoneId;
  final String? syncBatchId;
  final String type; // OUTAGE, INSTABILITY, NORMALIZED
  final DateTime occurredAt;
  final bool lastGasp;
  final Map<String, dynamic>? summary;

  const DeviceEventModel({
    required this.eventId,
    required this.deviceId,
    required this.installationId,
    required this.zoneId,
    this.syncBatchId,
    required this.type,
    required this.occurredAt,
    required this.lastGasp,
    this.summary,
  });

  DeviceEventModel copyWith({
    String? eventId,
    String? deviceId,
    String? installationId,
    String? zoneId,
    String? syncBatchId,
    String? type,
    DateTime? occurredAt,
    bool? lastGasp,
    Map<String, dynamic>? summary,
  }) {
    return DeviceEventModel(
      eventId: eventId ?? this.eventId,
      deviceId: deviceId ?? this.deviceId,
      installationId: installationId ?? this.installationId,
      zoneId: zoneId ?? this.zoneId,
      syncBatchId: syncBatchId ?? this.syncBatchId,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      lastGasp: lastGasp ?? this.lastGasp,
      summary: summary ?? this.summary,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'deviceId': deviceId,
      'installationId': installationId,
      'zoneId': zoneId,
      'syncBatchId': syncBatchId,
      'type': type,
      'occurredAt': occurredAt.toIso8601String(),
      'lastGasp': lastGasp,
      'summary': summary,
    };
  }

  factory DeviceEventModel.fromMap(Map<String, dynamic> map) {
    return DeviceEventModel(
      eventId: map['eventId'] as String? ?? '',
      deviceId: map['deviceId'] as String? ?? '',
      installationId: map['installationId'] as String? ?? '',
      zoneId: map['zoneId'] as String? ?? '',
      syncBatchId: map['syncBatchId'] as String?,
      type: map['type'] as String? ?? 'OUTAGE',
      occurredAt: _parseDateTime(map['occurredAt']),
      lastGasp: map['lastGasp'] as bool? ?? false,
      summary: map['summary'] != null
          ? Map<String, dynamic>.from(map['summary'] as Map)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceEventModel.fromJson(String source) =>
      DeviceEventModel.fromMap(json.decode(source) as Map<String, dynamic>);

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  @override
  String toString() {
    return 'DeviceEventModel(eventId: $eventId, deviceId: $deviceId, installationId: $installationId, zoneId: $zoneId, syncBatchId: $syncBatchId, type: $type, occurredAt: $occurredAt, lastGasp: $lastGasp, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceEventModel &&
        other.eventId == eventId &&
        other.deviceId == deviceId &&
        other.installationId == installationId &&
        other.zoneId == zoneId &&
        other.syncBatchId == syncBatchId &&
        other.type == type &&
        other.occurredAt == occurredAt &&
        other.lastGasp == lastGasp;
  }

  @override
  int get hashCode {
    return eventId.hashCode ^
        deviceId.hashCode ^
        installationId.hashCode ^
        zoneId.hashCode ^
        syncBatchId.hashCode ^
        type.hashCode ^
        occurredAt.hashCode ^
        lastGasp.hashCode;
  }
}
