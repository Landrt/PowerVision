import 'package:flutter_test/flutter_test.dart';
import 'package:voltcam/domain/models/user_model.dart';
import 'package:voltcam/domain/models/device_model.dart';
import 'package:voltcam/domain/models/sync_batch_model.dart';
import 'package:voltcam/domain/models/device_event_model.dart';
import 'package:voltcam/domain/models/incident_model.dart';
import 'package:voltcam/domain/models/grid_zone_model.dart';
import 'package:voltcam/domain/models/community_post_model.dart';

void main() {
  group('UserModel Serialization & copyWith', () {
    final now = DateTime.utc(2026, 7, 24, 10, 0, 0);
    final user = UserModel(
      uid: 'usr-123',
      email: 'test@voltcam.org',
      displayName: 'Jane Doe',
      role: 'admin',
      preferredZoneId: 'zone-biyem-assi',
      createdAt: now,
    );

    test('toMap and fromMap round-trip', () {
      final map = user.toMap();
      final deserialized = UserModel.fromMap(map);
      expect(deserialized.uid, equals(user.uid));
      expect(deserialized.email, equals(user.email));
      expect(deserialized.displayName, equals(user.displayName));
      expect(deserialized.role, equals(user.role));
      expect(deserialized.preferredZoneId, equals(user.preferredZoneId));
      expect(deserialized.createdAt, equals(user.createdAt));
    });

    test('toJson and fromJson round-trip', () {
      final jsonStr = user.toJson();
      final deserialized = UserModel.fromJson(jsonStr);
      expect(deserialized, equals(user));
    });

    test('copyWith updates specified fields', () {
      final updated = user.copyWith(displayName: 'Jane Smith', role: 'operator');
      expect(updated.displayName, equals('Jane Smith'));
      expect(updated.role, equals('operator'));
      expect(updated.uid, equals(user.uid));
    });
  });

  group('DeviceModel Serialization & copyWith', () {
    final now = DateTime.utc(2026, 7, 24, 10, 15, 0);
    final device = DeviceModel(
      deviceId: 'vtc-dev-001',
      ownerUid: 'usr-123',
      hardwareId: 'VTC-2026-DEMO-001',
      status: 'ONLINE',
      firmwareVersion: '1.2.0',
      lastSeenAt: now,
    );

    test('toMap and fromMap round-trip', () {
      final map = device.toMap();
      final deserialized = DeviceModel.fromMap(map);
      expect(deserialized.deviceId, equals(device.deviceId));
      expect(deserialized.hardwareId, equals(device.hardwareId));
      expect(deserialized.status, equals('ONLINE'));
      expect(deserialized.lastSeenAt, equals(now));
    });

    test('toJson and fromJson round-trip', () {
      final jsonStr = device.toJson();
      final deserialized = DeviceModel.fromJson(jsonStr);
      expect(deserialized, equals(device));
    });

    test('copyWith works correctly', () {
      final updated = device.copyWith(status: 'OFFLINE', firmwareVersion: '1.2.1');
      expect(updated.status, equals('OFFLINE'));
      expect(updated.firmwareVersion, equals('1.2.1'));
      expect(updated.deviceId, equals(device.deviceId));
    });
  });

  group('SyncBatchModel Serialization & copyWith', () {
    final now = DateTime.utc(2026, 7, 24, 10, 30, 0);
    final batch = SyncBatchModel(
      batchId: 'batch-uuid-99',
      ownerUid: 'usr-123',
      deviceId: 'vtc-dev-001',
      installationId: 'inst-001',
      payloadHash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      status: 'ACCEPTED',
      eventCount: 2,
      receivedAt: now,
      result: {'processed': true},
    );

    test('toMap and fromMap round-trip', () {
      final map = batch.toMap();
      final deserialized = SyncBatchModel.fromMap(map);
      expect(deserialized.batchId, equals(batch.batchId));
      expect(deserialized.payloadHash, equals(batch.payloadHash));
      expect(deserialized.status, equals('ACCEPTED'));
      expect(deserialized.eventCount, equals(2));
      expect(deserialized.result?['processed'], isTrue);
    });

    test('toJson and fromJson round-trip', () {
      final jsonStr = batch.toJson();
      final deserialized = SyncBatchModel.fromJson(jsonStr);
      expect(deserialized.batchId, equals(batch.batchId));
      expect(deserialized.status, equals(batch.status));
    });

    test('copyWith creates new modified instance', () {
      final updated = batch.copyWith(status: 'REJECTED');
      expect(updated.status, equals('REJECTED'));
      expect(updated.batchId, equals(batch.batchId));
    });
  });

  group('DeviceEventModel Serialization & copyWith', () {
    final now = DateTime.utc(2026, 7, 24, 10, 11, 58);
    final event = DeviceEventModel(
      eventId: 'evt-001',
      deviceId: 'vtc-dev-001',
      installationId: 'inst-001',
      zoneId: 'yaounde-vi-biyem-assi',
      syncBatchId: 'batch-101',
      type: 'OUTAGE',
      occurredAt: now,
      lastGasp: true,
      summary: {'voltageBeforeLoss': 218.7, 'batteryPercent': 93},
    );

    test('toMap and fromMap round-trip', () {
      final map = event.toMap();
      final deserialized = DeviceEventModel.fromMap(map);
      expect(deserialized.eventId, equals(event.eventId));
      expect(deserialized.type, equals('OUTAGE'));
      expect(deserialized.lastGasp, isTrue);
      expect(deserialized.summary?['voltageBeforeLoss'], equals(218.7));
    });

    test('toJson and fromJson round-trip', () {
      final jsonStr = event.toJson();
      final deserialized = DeviceEventModel.fromJson(jsonStr);
      expect(deserialized, equals(event));
    });

    test('copyWith updates properties', () {
      final updated = event.copyWith(type: 'NORMALIZED', lastGasp: false);
      expect(updated.type, equals('NORMALIZED'));
      expect(updated.lastGasp, isFalse);
      expect(updated.eventId, equals(event.eventId));
    });
  });

  group('IncidentModel Serialization & copyWith', () {
    final now = DateTime.utc(2026, 7, 24, 10, 11, 58);
    final incident = IncidentModel(
      incidentId: 'inc-001',
      zoneId: 'yaounde-vi-biyem-assi',
      type: 'OUTAGE',
      status: 'CONFIRMED',
      startedAt: now,
      confidenceScore: 94,
      independentDeviceCount: 8,
      publicSummary: 'Coupure confirmée par plusieurs boîtiers de la zone.',
      mapLayer: 'OUTAGES',
      updatedAt: now,
    );

    test('toMap and fromMap round-trip', () {
      final map = incident.toMap();
      final deserialized = IncidentModel.fromMap(map);
      expect(deserialized.incidentId, equals(incident.incidentId));
      expect(deserialized.status, equals('CONFIRMED'));
      expect(deserialized.confidenceScore, equals(94));
      expect(deserialized.independentDeviceCount, equals(8));
    });

    test('toJson and fromJson round-trip', () {
      final jsonStr = incident.toJson();
      final deserialized = IncidentModel.fromJson(jsonStr);
      expect(deserialized, equals(incident));
    });

    test('copyWith works as expected', () {
      final updated = incident.copyWith(status: 'RESOLVED', confidenceScore: 100);
      expect(updated.status, equals('RESOLVED'));
      expect(updated.confidenceScore, equals(100));
      expect(updated.incidentId, equals(incident.incidentId));
    });
  });

  group('GridZoneModel Serialization & copyWith', () {
    final zone = GridZoneModel(
      zoneId: 'yaounde-vi-biyem-assi',
      name: 'Biyem-Assi',
      polygon: [
        {'lat': 3.84, 'lng': 11.50},
        {'lat': 3.85, 'lng': 11.51},
        {'lat': 3.84, 'lng': 11.52},
      ],
      activeIncidentCount: 1,
      status: 'WARNING',
    );

    test('toMap and fromMap round-trip', () {
      final map = zone.toMap();
      final deserialized = GridZoneModel.fromMap(map);
      expect(deserialized.zoneId, equals(zone.zoneId));
      expect(deserialized.name, equals('Biyem-Assi'));
      expect(deserialized.activeIncidentCount, equals(1));
      expect(deserialized.polygon.length, equals(3));
      expect(deserialized.polygon[0]['lat'], equals(3.84));
    });

    test('toJson and fromJson round-trip', () {
      final jsonStr = zone.toJson();
      final deserialized = GridZoneModel.fromJson(jsonStr);
      expect(deserialized.zoneId, equals(zone.zoneId));
      expect(deserialized.status, equals(zone.status));
    });

    test('copyWith modifies attributes', () {
      final updated = zone.copyWith(activeIncidentCount: 0, status: 'NORMAL');
      expect(updated.activeIncidentCount, equals(0));
      expect(updated.status, equals('NORMAL'));
    });
  });

  group('CommunityPostModel Serialization & copyWith', () {
    final now = DateTime.utc(2026, 7, 24, 11, 0, 0);
    final post = CommunityPostModel(
      id: 'post-001',
      authorUid: 'usr-123',
      authorType: 'USER',
      type: 'REPORT',
      title: 'Baisse de tension secteur',
      content: 'Tension mesurée à 180V depuis 15min à Biyem-Assi.',
      zoneId: 'yaounde-vi-biyem-assi',
      status: 'PUBLISHED',
      isOfficial: false,
      likesCount: 12,
      commentsCount: 3,
      createdAt: now,
    );

    test('toMap and fromMap round-trip', () {
      final map = post.toMap();
      final deserialized = CommunityPostModel.fromMap(map);
      expect(deserialized.id, equals(post.id));
      expect(deserialized.title, equals(post.title));
      expect(deserialized.likesCount, equals(12));
      expect(deserialized.isOfficial, isFalse);
    });

    test('toJson and fromJson round-trip', () {
      final jsonStr = post.toJson();
      final deserialized = CommunityPostModel.fromJson(jsonStr);
      expect(deserialized, equals(post));
    });

    test('copyWith updates count and status', () {
      final updated = post.copyWith(likesCount: 13, commentsCount: 4);
      expect(updated.likesCount, equals(13));
      expect(updated.commentsCount, equals(4));
      expect(updated.id, equals(post.id));
    });
  });
}
