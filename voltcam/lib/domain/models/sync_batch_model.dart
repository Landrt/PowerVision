import 'dart:convert';

class SyncBatchModel {
  final String batchId;
  final String ownerUid;
  final String deviceId;
  final String installationId;
  final String payloadHash;
  final String status; // ACCEPTED, REJECTED, PENDING
  final int eventCount;
  final DateTime receivedAt;
  final Map<String, dynamic>? result;

  const SyncBatchModel({
    required this.batchId,
    required this.ownerUid,
    required this.deviceId,
    required this.installationId,
    required this.payloadHash,
    required this.status,
    required this.eventCount,
    required this.receivedAt,
    this.result,
  });

  SyncBatchModel copyWith({
    String? batchId,
    String? ownerUid,
    String? deviceId,
    String? installationId,
    String? payloadHash,
    String? status,
    int? eventCount,
    DateTime? receivedAt,
    Map<String, dynamic>? result,
  }) {
    return SyncBatchModel(
      batchId: batchId ?? this.batchId,
      ownerUid: ownerUid ?? this.ownerUid,
      deviceId: deviceId ?? this.deviceId,
      installationId: installationId ?? this.installationId,
      payloadHash: payloadHash ?? this.payloadHash,
      status: status ?? this.status,
      eventCount: eventCount ?? this.eventCount,
      receivedAt: receivedAt ?? this.receivedAt,
      result: result ?? this.result,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'batchId': batchId,
      'ownerUid': ownerUid,
      'deviceId': deviceId,
      'installationId': installationId,
      'payloadHash': payloadHash,
      'status': status,
      'eventCount': eventCount,
      'receivedAt': receivedAt.toIso8601String(),
      'result': result,
    };
  }

  factory SyncBatchModel.fromMap(Map<String, dynamic> map) {
    return SyncBatchModel(
      batchId: map['batchId'] as String? ?? '',
      ownerUid: map['ownerUid'] as String? ?? '',
      deviceId: map['deviceId'] as String? ?? '',
      installationId: map['installationId'] as String? ?? '',
      payloadHash: map['payloadHash'] as String? ?? '',
      status: map['status'] as String? ?? 'PENDING',
      eventCount: (map['eventCount'] as num?)?.toInt() ?? 0,
      receivedAt: _parseDateTime(map['receivedAt']),
      result: map['result'] != null
          ? Map<String, dynamic>.from(map['result'] as Map)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncBatchModel.fromJson(String source) =>
      SyncBatchModel.fromMap(json.decode(source) as Map<String, dynamic>);

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  @override
  String toString() {
    return 'SyncBatchModel(batchId: $batchId, ownerUid: $ownerUid, deviceId: $deviceId, installationId: $installationId, payloadHash: $payloadHash, status: $status, eventCount: $eventCount, receivedAt: $receivedAt, result: $result)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SyncBatchModel &&
        other.batchId == batchId &&
        other.ownerUid == ownerUid &&
        other.deviceId == deviceId &&
        other.installationId == installationId &&
        other.payloadHash == payloadHash &&
        other.status == status &&
        other.eventCount == eventCount &&
        other.receivedAt == receivedAt;
  }

  @override
  int get hashCode {
    return batchId.hashCode ^
        ownerUid.hashCode ^
        deviceId.hashCode ^
        installationId.hashCode ^
        payloadHash.hashCode ^
        status.hashCode ^
        eventCount.hashCode ^
        receivedAt.hashCode;
  }
}
