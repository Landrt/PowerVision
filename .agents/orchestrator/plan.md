# Execution Plan — VoltCam Mobile App & Firebase Platform

## Overview
VoltCam is a smart electrical grid monitoring platform for Cameroon/Africa that transforms household box measurements into readable alerts, GridTrust collective consensus, and Protect Mode appliance safety recommendations.

## Project Structure & Architecture
- Mobile App: Flutter (Riverpod, GoRouter, dark/glassmorphism UI tokens, Google Maps, secure offline storage) in `d:/GDG Hackthon build with IA/voltcam`.
- Cloud Backend: Firebase Cloud Functions 2nd Gen (TypeScript) in `d:/GDG Hackthon build with IA/voltcam/firebase/functions`.
- Security: `firebase/firestore.rules` denying direct client writes to server-authoritative data.

## Milestone Breakdown

### Milestone 1 (M1): Data Models & Encrypted Offline Storage (R3)
- **Objective**: Create complete Dart data model layer mirroring `docs/08-modele-firestore.md` and encrypted local offline storage queue for telemetry buffering.
- **Deliverables**:
  - `lib/domain/models/`: `User`, `Device`, `SyncBatch`, `DeviceEvent`, `Incident`, `GridZone`, `CommunityPost`.
  - `lib/data/local/`: Encrypted offline storage service (Hive/sqflite with `flutter_secure_storage` key encryption), offline event queue & batch builder.
- **Verification**: `flutter test` unit tests for model serialization/deserialization, local queue operations, batch building.

### Milestone 2 (M2): Firebase Cloud Functions Backend & GridTrust Engine (R2)
- **Objective**: Build Firebase Cloud Functions 2nd Gen TypeScript backend package and 10-minute window consensus engine.
- **Deliverables**:
  - `firebase/functions/`: `package.json`, `tsconfig.json`, `src/index.ts`, `src/services/gridtrust.ts`.
  - Callable function `submitSyncBatch`: Idempotent batch handler using `batchId` and `payloadHash`, atomic write to `syncBatches` and `deviceEvents`, triggers GridTrust consensus.
  - GridTrust Consensus Engine: 10-minute window grouping per `GridZone`, counts independent devices, updates confidence score, transitions `PENDING` -> `CONFIRMED` when independent devices >= 3.
  - Callable functions: `claimDevice`, `setConsent`, `publishOfficialUpdate`.
- **Verification**: TypeScript compilation (`npm run build`), unit test suite verifying GridTrust consensus logic, idempotency checks.

### Milestone 3 (M3): Security Rules & Quality Verification (R4)
- **Objective**: Strict Firestore security rules and quality verification test suite.
- **Deliverables**:
  - `firebase/firestore.rules`: Prevent client direct writes to `devices`, `incidents`, `syncBatches`, `deviceEvents`, `communityPosts` (official). Allow owner-only user reads/updates, authenticated zone/incident reads.
  - Automated tests for GridTrust consensus calculation, confidence score formulas, and risk score calculation (Dart unit tests & TS tests).
- **Verification**: Firestore rules validation and full unit test execution.

### Milestone 4 (M4): Flutter Architecture, Navigation & UI Tokens Setup (R1 - Architecture)
- **Objective**: Flutter project configuration, Riverpod state management setup, GoRouter shell navigation, and glassmorphism design system tokens.
- **Deliverables**:
  - `pubspec.yaml`: `flutter_riverpod`, `go_router`, `google_maps_flutter`, `flutter_secure_storage`, `fl_chart`, etc.
  - `lib/core/theme/`: Dark mode palette, glassmorphism UI tokens, custom card containers, gradient borders, status colors (Outage, Instability, Normal, Maintenance).
  - `lib/core/router/`: GoRouter configuration with bottom navigation bar and 5 main routes (`/map`, `/social`, `/assistant`, `/community`, `/device`).
  - `lib/core/providers/`: Riverpod providers for auth state, device telemetry, sync state, and zone incidents.
- **Verification**: `flutter analyze` passes, basic router shell unit/widget tests.

### Milestone 5 (M5): 5 Core Tabs & Protect Mode Dashboard Implementation (R1 - Feature Screens)
- **Objective**: Build full UI screens for all 5 tabs and Protect Mode dashboard.
- **Deliverables**:
  - **Tab 1: Carte Live (`/map`)**: Google Maps view with `GridZone` polygon overlays, status markers (Outage, Instability, Maintenance), detail bottom sheet.
  - **Tab 2: Réseau Social (`/social`)**: Feed with official news vs community reports, 6 post types, like/comment/save actions, verification badges.
  - **Tab 3: Assistant IA (`/assistant`)**: Q&A chat interface (bilingual FR/EN/Pidgin simulated assistant answering grid status & protection queries).
  - **Tab 4: Communauté (`/community`)**: Q&A discussion board and FAQ interface.
  - **Tab 5: Mon Boîtier (`/device`)**: IoT Dashboard with real-time voltage/current gauges, battery level indicator, telemetry history charts, and **Protect Mode** (risk score 0-100 gauge with 3 safety levels: Stable 0-39, Monitor 40-69, Protect 70-100 with appliance safety recommendations).
- **Verification**: Widget tests for Protect Mode UI, risk score calculation gauge, tab navigation, and `flutter analyze` clean pass.

### Milestone 6 (M6): E2E Integration & Verification
- **Objective**: Full end-to-end integration check, build pass, and complete test run across mobile app & backend.
- **Deliverables**:
  - Combined test suite execution (`flutter test`, `npm test` in Functions).
  - Verification report confirming all 4 user requirements R1-R4 and acceptance criteria.
