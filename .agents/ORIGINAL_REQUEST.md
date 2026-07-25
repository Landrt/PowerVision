# Original User Request

## Initial Request — 2026-07-24T17:14:41Z

# Teamwork Project Prompt — VoltCam Mobile App & Firebase Platform

Working directory: d:/GDG Hackthon build with IA/voltcam
Integrity mode: development

## Overview
VoltCam is a smart electrical grid monitoring platform for Cameroon/Africa that transforms household box measurements into readable alerts, GridTrust collective consensus, and Protect Mode appliance safety recommendations. The MVP is built with Flutter and Firebase.

## Requirements

### R1. Flutter Application Architecture & Navigation
Create the Flutter application structure in `d:/GDG Hackthon build with IA/voltcam`.
- Use `flutter_riverpod` for state management and `go_router` for navigation.
- Implement the design system with dark mode / glassmorphism UI tokens.
- Build the 5 core tabs:
  1. **Carte Live** (`/map`): Google Maps view with zone polygons (`GridZone`) and status overlays (Outage, Instability, Maintenance).
  2. **Réseau Social** (`/social`): Feed with official news vs community reports, 6 post types, like/comment/save actions, and verification badges.
  3. **Assistant IA** (`/assistant`): Conversational chat interface for grid status Q&A (bilingual FR/EN/Pidgin).
  4. **Communauté** (`/community`): Q&A discussions and FAQ.
  5. **Mon Boîtier** (`/device`): IoT Dashboard showing voltage/current, battery level, telemetry charts, and **Protect Mode** (risk score 0-100 + appliance advice).

### R2. Firebase Cloud Functions Backend & GridTrust Engine
Set up Firebase Cloud Functions (TypeScript 2nd gen) in `firebase/functions`:
- Implement `submitSyncBatch` callable function for idempotent sync of offline event batches.
- Implement GridTrust consensus engine (groups correlated device events in 10-minute windows per `GridZone`, updates confidence score, converts PENDING -> CONFIRMED).
- Implement `claimDevice`, `setConsent`, and `publishOfficialUpdate` callable functions.

### R3. Data Models & Offline Storage
- Define Dart data models mirroring `docs/08-modele-firestore.md` (`User`, `Device`, `SyncBatch`, `DeviceEvent`, `Incident`, `GridZone`, `CommunityPost`).
- Set up local encrypted/offline storage for raw telemetry buffering and offline event queue.

### R4. Security & Quality Rules
- Enforce `firebase/firestore.rules` (client direct writes strictly restricted, server-authoritative mutations via Cloud Functions).
- Provide unit and widget tests for key logic (GridTrust confidence score, risk calculation).

## Acceptance Criteria

### Mobile App
- [ ] Flutter app builds and runs cleanly (`flutter analyze` passes)
- [ ] All 5 tabs accessible via bottom navigation bar
- [ ] Protect Mode UI displays risk gauge and appliance safety tips
- [ ] Live Map screen displays Google Maps overlay with zone indicators

### Backend
- [ ] Cloud Functions TypeScript project compiles without errors
- [ ] `submitSyncBatch` handles duplicate batchId gracefully (idempotency)
- [ ] Firestore rules pass unit/emulator checks
