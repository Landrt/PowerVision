# Project: VoltCam Mobile App & Firebase Platform

## Architecture
- **Mobile Client**: Flutter application (`d:/GDG Hackthon build with IA/voltcam`) utilizing Riverpod for state management, GoRouter for navigation, Dark Mode Glassmorphism UI tokens, Google Maps integration, local encrypted offline storage.
- **Backend Platform**: Firebase Cloud Functions 2nd Gen (`d:/GDG Hackthon build with IA/voltcam/firebase/functions`) written in TypeScript, Cloud Firestore database with strict security rules, Firebase Auth.
- **GridTrust Engine**: Server-authoritative consensus engine grouping device events in 10-minute windows per `GridZone`, updating confidence scores, transitioning incident status from PENDING to CONFIRMED.
- **Protect Mode Engine**: Local/App-side calculation converting voltage telemetry & micro-outage signals into 0-100 risk scores with actionable appliance safety guidance.

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Data Models & Encrypted Offline Storage | R3: Dart data models, encrypted local storage, event queue | None | DONE |
| M2 | Cloud Functions Backend & GridTrust Engine | R2: TS Functions (`submitSyncBatch`, `claimDevice`, `setConsent`, `publishOfficialUpdate`), GridTrust engine | M1 (schema) | DONE |
| M3 | Security Rules & Quality Tests | R4: `firestore.rules`, GridTrust & risk score unit/integration tests | M1, M2 | DONE |
| M4 | Flutter Architecture & Navigation Setup | R1: `pubspec.yaml`, Riverpod, GoRouter, Dark/Glassmorphism theme tokens | M1 | DONE |
| M5 | 5 Core Tabs & Protect Mode Dashboard | R1: Carte Live, Réseau Social, Assistant IA, Communauté, Mon Boîtier (Protect Mode) | M1, M4 | DONE |
| M6 | E2E Integration & Verification | All R1-R4 requirements, build validation, test suite execution | M1-M5 | DONE |

## Interface Contracts

### Firestore Collections (`docs/08-modele-firestore.md`)
- `users/{uid}`: `{ ownerUid, email, displayName, role, preferredZoneId, createdAt }`
- `devices/{deviceId}`: `{ ownerUid, hardwareId, status, firmwareVersion, lastSeenAt }`
- `syncBatches/{batchId}`: `{ ownerUid, deviceId, installationId, payloadHash, status, eventCount, receivedAt, result }`
- `deviceEvents/{eventId}`: `{ deviceId, installationId, zoneId, syncBatchId, type, occurredAt, lastGasp, summary }`
- `zones/{zoneId}`: `{ name, polygon, activeIncidentCount, status }`
- `incidents/{incidentId}`: `{ zoneId, type, status, startedAt, confidenceScore, independentDeviceCount, publicSummary, mapLayer, updatedAt }`
- `communityPosts/{id}`: `{ authorUid, authorType, type, title, content, zoneId, status, isOfficial, likesCount, commentsCount, createdAt }`

### Cloud Functions API (`firebase/functions`)
- `submitSyncBatch(batchId, deviceId, installationId, events, payloadHash)` => `{ success, status, incidentIds }`
- `claimDevice(hardwareId, installationId, zoneId)` => `{ deviceId, claimedAt }`
- `setConsent(scope, granted)` => `{ consentId, version }`
- `publishOfficialUpdate(title, content, type, zoneId)` => `{ postId, publishedAt }`

### Dart Data Models (`lib/domain/models`)
- `UserModel`, `DeviceModel`, `SyncBatchModel`, `DeviceEventModel`, `IncidentModel`, `GridZoneModel`, `CommunityPostModel`.

## Code Layout
```
d:/GDG Hackthon build with IA/voltcam/
├── android/
├── ios/
├── web/
├── firebase/
│   ├── firestore.rules
│   ├── firestore.indexes.json
│   └── functions/
│       ├── package.json
│       ├── tsconfig.json
│       └── src/
│           ├── index.ts
│           ├── types.ts
│           ├── services/
│           │   ├── gridtrust.ts
│           │   └── sync.ts
│           └── test/
│               └── gridtrust.test.ts
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── glassmorphism.dart
│   │   │   └── app_colors.dart
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   └── providers/
│   │       ├── auth_provider.dart
│   │       ├── device_provider.dart
│   │       ├── incident_provider.dart
│   │       └── sync_provider.dart
│   ├── data/
│   │   ├── local/
│   │   │   ├── encrypted_storage.dart
│   │   │   └── offline_queue.dart
│   │   └── repositories/
│   │       ├── device_repository.dart
│   │       └── incident_repository.dart
│   ├── domain/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── device_model.dart
│   │   │   ├── sync_batch_model.dart
│   │   │   ├── device_event_model.dart
│   │   │   ├── incident_model.dart
│   │   │   ├── grid_zone_model.dart
│   │   │   └── community_post_model.dart
│   │   └── protect_mode/
│   │       └── risk_score_calculator.dart
│   ├── features/
│   │   ├── map/
│   │   ├── social/
│   │   ├── assistant/
│   │   ├── community/
│   │   └── device/
│   │       ├── protect_mode_widget.dart
│   │       └── device_dashboard_screen.dart
├── test/
│   ├── models_test.dart
│   ├── offline_queue_test.dart
│   ├── protect_mode_test.dart
│   └── widget_tests/
└── pubspec.yaml
```
