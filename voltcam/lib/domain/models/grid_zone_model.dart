import 'dart:convert';

class GridZoneModel {
  final String zoneId;
  final String name;
  final List<Map<String, double>> polygon;
  final int activeIncidentCount;
  final String status; // e.g. NORMAL, WARNING, CRITICAL

  const GridZoneModel({
    required this.zoneId,
    required this.name,
    required this.polygon,
    required this.activeIncidentCount,
    required this.status,
  });

  GridZoneModel copyWith({
    String? zoneId,
    String? name,
    List<Map<String, double>>? polygon,
    int? activeIncidentCount,
    String? status,
  }) {
    return GridZoneModel(
      zoneId: zoneId ?? this.zoneId,
      name: name ?? this.name,
      polygon: polygon ?? this.polygon,
      activeIncidentCount: activeIncidentCount ?? this.activeIncidentCount,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'zoneId': zoneId,
      'name': name,
      'polygon': polygon,
      'activeIncidentCount': activeIncidentCount,
      'status': status,
    };
  }

  factory GridZoneModel.fromMap(Map<String, dynamic> map) {
    final rawPolygon = map['polygon'];
    final List<Map<String, double>> parsedPolygon = [];

    if (rawPolygon is List) {
      for (final item in rawPolygon) {
        if (item is Map) {
          final lat = (item['lat'] ?? item['latitude'] ?? 0.0) as num;
          final lng = (item['lng'] ?? item['longitude'] ?? 0.0) as num;
          parsedPolygon.add({'lat': lat.toDouble(), 'lng': lng.toDouble()});
        } else if (item is List && item.length >= 2) {
          final lat = (item[0] as num).toDouble();
          final lng = (item[1] as num).toDouble();
          parsedPolygon.add({'lat': lat, 'lng': lng});
        }
      }
    }

    return GridZoneModel(
      zoneId: map['zoneId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      polygon: parsedPolygon,
      activeIncidentCount:
          (map['activeIncidentCount'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'NORMAL',
    );
  }

  String toJson() => json.encode(toMap());

  factory GridZoneModel.fromJson(String source) =>
      GridZoneModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'GridZoneModel(zoneId: $zoneId, name: $name, polygon: $polygon, activeIncidentCount: $activeIncidentCount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GridZoneModel &&
        other.zoneId == zoneId &&
        other.name == name &&
        other.activeIncidentCount == activeIncidentCount &&
        other.status == status;
  }

  @override
  int get hashCode {
    return zoneId.hashCode ^
        name.hashCode ^
        activeIncidentCount.hashCode ^
        status.hashCode;
  }
}
