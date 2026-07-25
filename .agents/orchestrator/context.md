# Technical Context — VoltCam Mobile App & Firebase Platform

## Overview
VoltCam is a smart electrical grid monitoring platform for Cameroon/Africa that transforms household box measurements into readable alerts, GridTrust collective consensus, and Protect Mode appliance safety recommendations.

## Tech Stack Details
- **Mobile Client**: Flutter 3.x, Dart 3.x, `flutter_riverpod`, `go_router`, `google_maps_flutter`, `flutter_secure_storage`.
- **Backend Platform**: Firebase Cloud Functions 2nd Gen (TypeScript, Node.js 18+), Cloud Firestore, Firebase Auth.
- **Data Models**:
  - `users/{uid}`: Profile, zone subscription, consent state.
  - `devices/{deviceId}`: Private device metadata, hardwareId, ownerUid, status.
  - `syncBatches/{batchId}`: Sync batch log, payloadHash, status (ACCEPTED, REJECTED), incidentIds result.
  - `deviceEvents/{eventId}`: Telemetry events (OUTAGE, INSTABILITY, NORMALIZED) linked to zoneId & installation.
  - `zones/{zoneId}`: Geo-polygon / bounding area, current incident count, active status.
  - `incidents/{incidentId}`: Aggregated public incident, GridTrust confidence score (0-100), independent device count, status (PENDING, CONFIRMED, RESOLVED).
  - `communityPosts/{id}`: Official news or community reports, post types, likes/comments, verification badge.
- **Protect Mode Risk Scoring Engine**:
  - Score formula (0-100) based on voltage level, variance, micro-outages, data age.
  - Tiers: 0-39 (Stable), 40-69 (Monitor), 70-100 (Protect).
- **GridTrust Consensus Engine**:
  - Groups device events per `GridZone` within 10-minute sliding windows.
  - Counts independent devices (distinct `deviceId`s).
  - When independent devices >= 3, updates confidence score and marks incident `CONFIRMED`.
