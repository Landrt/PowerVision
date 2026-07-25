## 2026-07-24T17:18:51Z
You are worker_m1 assigned to Milestone 1: Data Models & Encrypted Offline Storage (R3) for VoltCam.
Your working directory is `d:/GDG Hackthon build with IA/.agents/worker_m1`. Create your progress.md and handoff.md in that directory.

TASK:
1. Initialize the Flutter app scaffold in `d:/GDG Hackthon build with IA/voltcam` if needed (create `pubspec.yaml` with packages: `flutter_riverpod`, `go_router`, `google_maps_flutter`, `flutter_secure_storage`, `crypto`, `uuid`, etc.).
2. Create full Dart data models in `lib/domain/models/` matching `docs/08-modele-firestore.md`:
   - `user_model.dart`: UserModel (uid, email, displayName, role, preferredZoneId, createdAt)
   - `device_model.dart`: DeviceModel (deviceId, ownerUid, hardwareId, status [ONLINE/OFFLINE], firmwareVersion, lastSeenAt)
   - `sync_batch_model.dart`: SyncBatchModel (batchId, ownerUid, deviceId, installationId, payloadHash, status [ACCEPTED/REJECTED/PENDING], eventCount, receivedAt, result)
   - `device_event_model.dart`: DeviceEventModel (eventId, deviceId, installationId, zoneId, syncBatchId, type [OUTAGE/INSTABILITY/NORMALIZED], occurredAt, lastGasp, summary)
   - `incident_model.dart`: IncidentModel (incidentId, zoneId, type, status [PENDING/CONFIRMED/RESOLVED], startedAt, confidenceScore, independentDeviceCount, publicSummary, mapLayer, updatedAt)
   - `grid_zone_model.dart`: GridZoneModel (zoneId, name, polygon, activeIncidentCount, status)
   - `community_post_model.dart`: CommunityPostModel (id, authorUid, authorType, type [NEWS/REPORT/QUESTION/MAINTENANCE/ALERT/TIPS], title, content, zoneId, status, isOfficial, likesCount, commentsCount, createdAt)
   Include JSON `toMap()` and `fromMap()` or `toJson()` and `fromJson()` serialization and `copyWith()` helper methods for all models.
3. Create local encrypted storage & offline queue service in `lib/data/local/`:
   - `encrypted_storage.dart`: Local storage service with encryption (using `flutter_secure_storage` or AES payload encryption for telemetry & sensitive preferences).
   - `offline_queue.dart`: Local offline queue for device events, buffering raw telemetry, and generating batch payloads with UUID `batchId` and SHA-256 `payloadHash`.
4. Create unit tests in `test/models_test.dart` and `test/offline_queue_test.dart` verifying model serialization/deserialization, offline queue enqueue/dequeue, and payload hash generation.
5. Run build and test checks: `flutter analyze` and `flutter test` (or `dart test`).
6. Write a complete handoff report to `d:/GDG Hackthon build with IA/.agents/worker_m1/handoff.md` detailing build/test results, implementation details, and verification commands.
7. Send a message to parent ("57978ccd-b59e-4fe0-91fb-7ad9c132a0c2") when finished.

MANDATORY INTEGRITY WARNING: DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.
