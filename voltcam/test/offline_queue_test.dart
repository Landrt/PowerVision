import 'package:flutter_test/flutter_test.dart';
import 'package:voltcam/data/local/encrypted_storage.dart';
import 'package:voltcam/data/local/offline_queue.dart';
import 'package:voltcam/domain/models/device_event_model.dart';

void main() {
  late EncryptedStorageService storage;
  late OfflineQueueService queue;

  setUp(() {
    storage = EncryptedStorageService(useInMemoryFallback: true);
    queue = OfflineQueueService(storage: storage);
  });

  group('EncryptedStorageService', () {
    test('write, read, delete, and clear', () async {
      await storage.write(key: 'secret_key', value: 'secret_value');
      final val1 = await storage.read(key: 'secret_key');
      expect(val1, equals('secret_value'));

      await storage.delete(key: 'secret_key');
      final val2 = await storage.read(key: 'secret_key');
      expect(val2, isNull);

      await storage.write(key: 'k1', value: 'v1');
      await storage.write(key: 'k2', value: 'v2');
      await storage.deleteAll();
      expect(await storage.read(key: 'k1'), isNull);
      expect(await storage.read(key: 'k2'), isNull);
    });

    test('encryptPayload and decryptPayload symmetric round-trip', () {
      const plainText = '{"voltage": 220.5, "device": "VTC-001"}';
      const secret = 'my-super-secret-key-123';

      final encrypted = storage.encryptPayload(plainText, secret);
      expect(encrypted, isNot(equals(plainText)));

      final decrypted = storage.decryptPayload(encrypted, secret);
      expect(decrypted, equals(plainText));
    });
  });

  group('OfflineQueueService Operations', () {
    final now = DateTime.utc(2026, 7, 24, 12, 0, 0);
    final event1 = DeviceEventModel(
      eventId: 'evt-1',
      deviceId: 'dev-1',
      installationId: 'inst-1',
      zoneId: 'zone-1',
      type: 'OUTAGE',
      occurredAt: now,
      lastGasp: true,
      summary: {'voltage': 0},
    );

    final event2 = DeviceEventModel(
      eventId: 'evt-2',
      deviceId: 'dev-1',
      installationId: 'inst-1',
      zoneId: 'zone-1',
      type: 'NORMALIZED',
      occurredAt: now.add(const Duration(minutes: 5)),
      lastGasp: false,
      summary: {'voltage': 225.0},
    );

    test('enqueue, length, and isEmpty', () async {
      expect(queue.isEmpty, isTrue);
      expect(queue.length, equals(0));

      await queue.enqueue(event1);
      expect(queue.isEmpty, isFalse);
      expect(queue.length, equals(1));
      expect(queue.queuedEvents.first.eventId, equals('evt-1'));

      await queue.enqueue(event2);
      expect(queue.length, equals(2));
    });

    test('enqueueAll and removeEvent', () async {
      await queue.enqueueAll([event1, event2]);
      expect(queue.length, equals(2));

      final removed = await queue.removeEvent('evt-1');
      expect(removed, isTrue);
      expect(queue.length, equals(1));
      expect(queue.queuedEvents.first.eventId, equals('evt-2'));
    });

    test('createSyncBatch generates valid UUID batchId and SHA-256 payloadHash', () async {
      await queue.enqueueAll([event1, event2]);

      final batch = queue.createSyncBatch(
        ownerUid: 'usr-100',
        deviceId: 'dev-1',
        installationId: 'inst-1',
      );

      // Verify UUID v4 format regex
      final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
      );
      expect(uuidRegex.hasMatch(batch.batchId), isTrue);

      // Verify SHA-256 hash length (64 hex characters)
      expect(batch.payloadHash.length, equals(64));
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(batch.payloadHash), isTrue);

      expect(batch.ownerUid, equals('usr-100'));
      expect(batch.deviceId, equals('dev-1'));
      expect(batch.installationId, equals('inst-1'));
      expect(batch.status, equals('PENDING'));
      expect(batch.eventCount, equals(2));
    });

    test('dequeueBatch removes processed events from queue', () async {
      await queue.enqueueAll([event1, event2]);
      final batch = queue.createSyncBatch(
        ownerUid: 'usr-100',
        deviceId: 'dev-1',
        installationId: 'inst-1',
      );

      await queue.dequeueBatch(batch);
      expect(queue.isEmpty, isTrue);
    });

    test('persistence in EncryptedStorageService', () async {
      await queue.enqueue(event1);
      await queue.enqueue(event2);

      // Create new queue instance reading from same storage
      final restoredQueue = OfflineQueueService(storage: storage);
      await restoredQueue.loadFromStorage();

      expect(restoredQueue.length, equals(2));
      expect(restoredQueue.queuedEvents.first.eventId, equals('evt-1'));
      expect(restoredQueue.queuedEvents.last.eventId, equals('evt-2'));
    });
  });
}
