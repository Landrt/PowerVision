import 'dart:convert';

class IncidentModel {
  final String incidentId;
  final String zoneId;
  final String type; // e.g. OUTAGE, INSTABILITY
  final String status; // PENDING, CONFIRMED, RESOLVED
  final DateTime startedAt;
  final int confidenceScore; // 0..100
  final int independentDeviceCount;
  final String publicSummary;
  final String mapLayer;
  final DateTime updatedAt;

  const IncidentModel({
    required this.incidentId,
    required this.zoneId,
    required this.type,
    required this.status,
    required this.startedAt,
    required this.confidenceScore,
    required this.independentDeviceCount,
    required this.publicSummary,
    required this.mapLayer,
    required this.updatedAt,
  });

  IncidentModel copyWith({
    String? incidentId,
    String? zoneId,
    String? type,
    String? status,
    DateTime? startedAt,
    int? confidenceScore,
    int? independentDeviceCount,
    String? publicSummary,
    String? mapLayer,
    DateTime? updatedAt,
  }) {
    return IncidentModel(
      incidentId: incidentId ?? this.incidentId,
      zoneId: zoneId ?? this.zoneId,
      type: type ?? this.type,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      independentDeviceCount:
          independentDeviceCount ?? this.independentDeviceCount,
      publicSummary: publicSummary ?? this.publicSummary,
      mapLayer: mapLayer ?? this.mapLayer,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'incidentId': incidentId,
      'zoneId': zoneId,
      'type': type,
      'status': status,
      'startedAt': startedAt.toIso8601String(),
      'confidenceScore': confidenceScore,
      'independentDeviceCount': independentDeviceCount,
      'publicSummary': publicSummary,
      'mapLayer': mapLayer,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory IncidentModel.fromMap(Map<String, dynamic> map) {
    return IncidentModel(
      incidentId: map['incidentId'] as String? ?? '',
      zoneId: map['zoneId'] as String? ?? '',
      type: map['type'] as String? ?? 'OUTAGE',
      status: map['status'] as String? ?? 'PENDING',
      startedAt: _parseDateTime(map['startedAt']),
      confidenceScore: (map['confidenceScore'] as num?)?.toInt() ?? 0,
      independentDeviceCount:
          (map['independentDeviceCount'] as num?)?.toInt() ?? 0,
      publicSummary: map['publicSummary'] as String? ?? '',
      mapLayer: map['mapLayer'] as String? ?? 'OUTAGES',
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory IncidentModel.fromJson(String source) =>
      IncidentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  @override
  String toString() {
    return 'IncidentModel(incidentId: $incidentId, zoneId: $zoneId, type: $type, status: $status, startedAt: $startedAt, confidenceScore: $confidenceScore, independentDeviceCount: $independentDeviceCount, publicSummary: $publicSummary, mapLayer: $mapLayer, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IncidentModel &&
        other.incidentId == incidentId &&
        other.zoneId == zoneId &&
        other.type == type &&
        other.status == status &&
        other.startedAt == startedAt &&
        other.confidenceScore == confidenceScore &&
        other.independentDeviceCount == independentDeviceCount &&
        other.publicSummary == publicSummary &&
        other.mapLayer == mapLayer &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return incidentId.hashCode ^
        zoneId.hashCode ^
        type.hashCode ^
        status.hashCode ^
        startedAt.hashCode ^
        confidenceScore.hashCode ^
        independentDeviceCount.hashCode ^
        publicSummary.hashCode ^
        mapLayer.hashCode ^
        updatedAt.hashCode;
  }
}
