import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/device_event_model.dart';
import '../../domain/models/sync_batch_model.dart';
import 'encrypted_storage.dart';

/// Service responsible for buffering offline device events and telemetry,
/// generating sync batch payloads with SHA-256 integrity hashes and UUID batch IDs.
class OfflineQueueService {
  final List<DeviceEventModel> _queue = [];
  final EncryptedStorageService? _storage;
  final String _storageKey;
  final Uuid _uuid;

  OfflineQueueService({
    EncryptedStorageService? storage,
    String storageKey = 'voltcam_offline_queue',
    Uuid? uuid,
  })  : _storage = storage,
        _storageKey = storageKey,
        _uuid = uuid ?? const Uuid();

  /// Returns an unmodifiable list of currently queued device events.
  List<DeviceEventModel> get queuedEvents => List.unmodifiable(_queue);

  /// Number of events currently buffered in the queue.
  int get length => _queue.length;

  /// Whether the queue is currently empty.
  bool get isEmpty => _queue.isEmpty;

  /// Add a device event to the offline queue.
  Future<void> enqueue(DeviceEventModel event) async {
    _queue.add(event);
    await _persistQueue();
  }

  /// Add multiple device events to the offline queue.
  Future<void> enqueueAll(List<DeviceEventModel> events) async {
    _queue.addAll(events);
    await _persistQueue();
  }

  /// Remove a specific event from the queue by eventId.
  Future<bool> removeEvent(String eventId) async {
    final initialLength = _queue.length;
    _queue.removeWhere((e) => e.eventId == eventId);
    final removed = _queue.length < initialLength;
    if (removed) {
      await _persistQueue();
    }
    return removed;
  }

  /// Clear all queued events.
  Future<void> clear() async {
    _queue.clear();
    await _persistQueue();
  }

  /// Generates a SHA-256 hash for a given list of events.
  String calculatePayloadHash(List<DeviceEventModel> events) {
    final eventMaps = events.map((e) => e.toMap()).toList();
    // Sort keys or standard json encode for deterministic payload hashing
    final canonicalJson = json.encode(eventMaps);
    final bytes = utf8.encode(canonicalJson);
    return sha256.convert(bytes).toString();
  }

  /// Package up to [maxEvents] buffered events into a [SyncBatchModel] payload.
  /// Generates a UUID batchId and a SHA-256 payloadHash for server verification.
  SyncBatchModel createSyncBatch({
    required String ownerUid,
    required String deviceId,
    required String installationId,
    int? maxEvents,
  }) {
    if (_queue.isEmpty) {
      throw StateError('Cannot create sync batch from empty queue.');
    }

    final count = (maxEvents != null && maxEvents < _queue.length)
        ? maxEvents
        : _queue.length;

    final batchEvents = _queue.sublist(0, count);
    final batchId = _uuid.v4();
    final payloadHash = calculatePayloadHash(batchEvents);

    final updatedEvents = batchEvents
        .map((e) => e.copyWith(syncBatchId: batchId))
        .toList();

    return SyncBatchModel(
      batchId: batchId,
      ownerUid: ownerUid,
      deviceId: deviceId,
      installationId: installationId,
      payloadHash: payloadHash,
      status: 'PENDING',
      eventCount: count,
      receivedAt: DateTime.now(),
      result: {
        'events': updatedEvents.map((e) => e.toMap()).toList(),
      },
    );
  }

  /// Remove events included in a successfully synced batch from the queue.
  Future<void> dequeueBatch(SyncBatchModel batch) async {
    final batchResult = batch.result;
    if (batchResult != null && batchResult.containsKey('events')) {
      final eventsList = batchResult['events'] as List;
      final syncedIds = eventsList
          .map((e) => (e as Map)['eventId'] as String)
          .toSet();
      _queue.removeWhere((event) => syncedIds.contains(event.eventId));
    } else {
      // If result payload isn't populated, dequeue by eventCount
      final removeCount = batch.eventCount <= _queue.length
          ? batch.eventCount
          : _queue.length;
      _queue.removeRange(0, removeCount);
    }
    await _persistQueue();
  }

  /// Persist the current queue state to encrypted storage if available.
  Future<void> _persistQueue() async {
    if (_storage == null) return;
    final serialized = json.encode(_queue.map((e) => e.toMap()).toList());
    await _storage!.write(key: _storageKey, value: serialized);
  }

  /// Load persisted events from encrypted storage into the queue.
  Future<void> loadFromStorage() async {
    if (_storage == null) return;
    final data = await _storage!.read(key: _storageKey);
    if (data != null && data.isNotEmpty) {
      try {
        final List decoded = json.decode(data) as List;
        _queue.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _queue.add(DeviceEventModel.fromMap(item));
          }
        }
      } catch (_) {
        // Failed parsing persisted queue
      }
    }
  }
}
