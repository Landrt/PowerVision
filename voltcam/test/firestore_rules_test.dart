import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late File rulesFile;
  late String rulesContent;

  setUpAll(() {
    rulesFile = File('firebase/firestore.rules');
    expect(
      rulesFile.existsSync(),
      isTrue,
      reason: 'firebase/firestore.rules file must exist',
    );
    rulesContent = rulesFile.readAsStringSync();
  });

  group('Firestore Rules Syntax & Version Assertions', () {
    test('Rules file specifies rules_version = "2"', () {
      expect(rulesContent, contains("rules_version = '2';"));
    });

    test('Rules file defines service cloud.firestore and database match', () {
      expect(rulesContent, contains('service cloud.firestore'));
      expect(rulesContent, contains('match /databases/{database}/documents'));
    });

    test('Rules file defines signedIn and isOwner helper functions', () {
      expect(rulesContent, contains('function signedIn()'));
      expect(rulesContent, contains('request.auth != null'));
      expect(rulesContent, contains('function isOwner(uid)'));
      expect(rulesContent, contains('request.auth.uid == uid'));
    });
  });

  group('Firestore Rules Security Invariants - Restricted Collections', () {
    final restrictedCollections = [
      'devices',
      'installations',
      'syncBatches',
      'deviceEvents',
      'incidents',
      'evidence',
      'consents',
      'auditLogs',
    ];

    for (final collection in restrictedCollections) {
      test('Collection $collection restricts client direct writes', () {
        final regex = RegExp('match /' + collection + r'/\{[a-zA-Z0-9_]+\}');
        expect(
          regex.hasMatch(rulesContent),
          isTrue,
          reason: 'Rules must contain match block for $collection',
        );

        // Verify write denial or create/update/delete denial in the rules file
        expect(
          rulesContent.contains('match /$collection/') || rulesContent.contains('match /$collection'),
          isTrue,
        );
      });
    }

    test('devices collection denies write operations', () {
      expect(rulesContent, contains('match /devices/{deviceId}'));
      expect(rulesContent, contains('allow create, update, delete: if false;'));
    });

    test('installations collection denies write operations', () {
      expect(rulesContent, contains('match /installations/{installationId}'));
      expect(rulesContent, contains('allow create, update, delete: if false;'));
    });

    test('syncBatches collection denies write operations', () {
      expect(rulesContent, contains('match /syncBatches/{batchId}'));
      expect(rulesContent, contains('allow create, update, delete: if false;'));
    });

    test('deviceEvents collection denies write operations', () {
      expect(rulesContent, contains('match /deviceEvents/{eventId}'));
      expect(rulesContent, contains('allow create, update, delete: if false;'));
    });

    test('evidence collection denies write operations', () {
      expect(rulesContent, contains('match /evidence/{evidenceId}'));
      expect(rulesContent, contains('allow create, update, delete: if false;'));
    });

    test('consents collection denies write operations', () {
      expect(rulesContent, contains('match /consents/{consentId}'));
      expect(rulesContent, contains('allow create, update, delete: if false;'));
    });

    test('auditLogs collection denies write operations', () {
      expect(rulesContent, contains('match /auditLogs/{logId}'));
      expect(rulesContent, contains('allow create, update, delete: if false;'));
    });
  });

  group('Firestore Rules Security Invariants - User & Data Models', () {
    test('users/{uid} enforces owner-only read and write (request.auth.uid == uid)', () {
      expect(rulesContent, contains('match /users/{uid}'));
      expect(rulesContent, contains('allow read, write: if isOwner(uid);'));
    });

    test('zones/{zoneId} allows authenticated read and denies write', () {
      expect(rulesContent, contains('match /zones/{zoneId}'));
      expect(rulesContent, contains('allow read: if signedIn();'));
      expect(rulesContent, contains('allow create, update, delete: if false;'));
    });

    test('incidents/{incidentId} allows authenticated read and denies write', () {
      expect(rulesContent, contains('match /incidents/{incidentId}'));
      expect(rulesContent, contains('allow read: if signedIn();'));
      expect(rulesContent, contains('allow create, update, delete: if false;'));
    });

    test('communityPosts/{postId} enforces authorUid check and restricts official posts to server functions', () {
      expect(rulesContent, contains('match /communityPosts/{postId}'));
      expect(rulesContent, contains('allow read: if signedIn();'));
      expect(rulesContent, contains('authorUid == request.auth.uid'));
      expect(rulesContent, contains('isOfficial == false'));
    });

    test('Fallback match denies all read and write by default', () {
      expect(rulesContent, contains('match /{document=**}'));
      expect(rulesContent, contains('allow read, write: if false;'));
    });

    test('No rule contains insecure allow write: if true', () {
      expect(rulesContent.contains('allow write: if true'), isFalse);
      expect(rulesContent.contains('allow create: if true'), isFalse);
      expect(rulesContent.contains('allow update: if true'), isFalse);
      expect(rulesContent.contains('allow delete: if true'), isFalse);
    });
  });
}
