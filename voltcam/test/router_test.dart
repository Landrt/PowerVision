import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltcam/core/providers/auth_provider.dart';
import 'package:voltcam/core/providers/device_provider.dart';
import 'package:voltcam/core/providers/incident_provider.dart';
import 'package:voltcam/core/providers/sync_provider.dart';
import 'package:voltcam/core/router/app_router.dart';
import 'package:voltcam/core/theme/app_theme.dart';
import 'package:voltcam/domain/models/device_model.dart';
import 'package:voltcam/domain/models/grid_zone_model.dart';
import 'package:voltcam/domain/models/incident_model.dart';
import 'package:voltcam/domain/models/sync_batch_model.dart';
import 'package:voltcam/domain/models/user_model.dart';

void main() {
  group('GoRouter & Navigation Shell Tests', () {
    testWidgets('Renders MainNavigationShell with 5 tabs and initial Carte Live screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: appRouter,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check initial screen
      expect(find.text('Carte Live Grid Monitoring'), findsOneWidget);

      // Check all 5 tabs exist in BottomNavigationBar
      expect(find.text('Carte Live'), findsOneWidget);
      expect(find.text('Réseau Social'), findsOneWidget);
      expect(find.text('Assistant IA'), findsOneWidget);
      expect(find.text('Communauté'), findsOneWidget);
      expect(find.text('Mon Boîtier'), findsOneWidget);
    });

    testWidgets('Navigates across tabs correctly when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: appRouter,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Réseau Social tab
      await tester.tap(find.text('Réseau Social'));
      await tester.pumpAndSettle();
      expect(find.text('Réseau Social GridTrust'), findsOneWidget);

      // Tap Assistant IA tab
      await tester.tap(find.text('Assistant IA'));
      await tester.pumpAndSettle();
      expect(find.text('Assistant IA VoltCam'), findsOneWidget);

      // Tap Communauté tab
      await tester.tap(find.text('Communauté'));
      await tester.pumpAndSettle();
      expect(find.text('Communauté VoltCam'), findsOneWidget);

      // Tap Mon Boîtier tab
      await tester.tap(find.text('Mon Boîtier'));
      await tester.pumpAndSettle();
      expect(find.text('Mon Boîtier & Mode Protect'), findsOneWidget);

      // Return to Carte Live tab
      await tester.tap(find.text('Carte Live'));
      await tester.pumpAndSettle();
      expect(find.text('Carte Live Grid Monitoring'), findsOneWidget);
    });
  });

  group('Riverpod Providers Initialization & State Tests', () {
    test('AuthProvider state management and login/logout lifecycle', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialAuth = container.read(authProvider);
      expect(initialAuth.isAuthenticated, isFalse);
      expect(initialAuth.user, isNull);

      // Login
      container.read(authProvider.notifier).login('user@voltcam.org', 'Volt User');
      final loggedInAuth = container.read(authProvider);
      expect(loggedInAuth.isAuthenticated, isTrue);
      expect(loggedInAuth.user?.email, 'user@voltcam.org');
      expect(loggedInAuth.user?.displayName, 'Volt User');

      // Logout
      container.read(authProvider.notifier).logout();
      final loggedOutAuth = container.read(authProvider);
      expect(loggedOutAuth.isAuthenticated, isFalse);
      expect(loggedOutAuth.user, isNull);
    });

    test('DeviceProvider state management, telemetry, and Protect Mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialDevice = container.read(deviceProvider);
      expect(initialDevice.selectedDevice, isNull);
      expect(initialDevice.currentVoltage, 220.0);
      expect(initialDevice.frequency, 50.0);
      expect(initialDevice.isProtectModeActive, isTrue);

      final sampleDevice = DeviceModel(
        deviceId: 'dev_1001',
        ownerUid: 'usr_1',
        hardwareId: 'HW_99',
        status: 'ONLINE',
        firmwareVersion: '2.1.0',
        lastSeenAt: DateTime.now(),
      );

      // Select device
      container.read(deviceProvider.notifier).selectDevice(sampleDevice);
      expect(container.read(deviceProvider).selectedDevice?.deviceId, 'dev_1001');

      // Update telemetry
      container.read(deviceProvider.notifier).updateTelemetry(voltage: 235.5, frequency: 49.8);
      expect(container.read(deviceProvider).currentVoltage, 235.5);
      expect(container.read(deviceProvider).frequency, 49.8);

      // Toggle protect mode
      container.read(deviceProvider.notifier).toggleProtectMode(false);
      expect(container.read(deviceProvider).isProtectModeActive, isFalse);
    });

    test('IncidentProvider active grid incidents and zone overlay state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialIncident = container.read(incidentProvider);
      expect(initialIncident.activeIncidents, isEmpty);
      expect(initialIncident.zones, isEmpty);

      final sampleIncident = IncidentModel(
        incidentId: 'inc_100',
        zoneId: 'zone_north',
        type: 'OUTAGE',
        status: 'CONFIRMED',
        startedAt: DateTime.now(),
        confidenceScore: 85,
        independentDeviceCount: 12,
        publicSummary: 'Coupure réseau secteur Nord',
        mapLayer: 'OUTAGES',
        updatedAt: DateTime.now(),
      );

      final sampleZone = GridZoneModel(
        zoneId: 'zone_north',
        name: 'Secteur Nord',
        polygon: [
          {'lat': 14.7, 'lng': -17.4},
        ],
        activeIncidentCount: 1,
        status: 'WARNING',
      );

      container.read(incidentProvider.notifier).setIncidents([sampleIncident]);
      container.read(incidentProvider.notifier).setZones([sampleZone]);
      container.read(incidentProvider.notifier).selectZone('zone_north');

      final updatedState = container.read(incidentProvider);
      expect(updatedState.activeIncidents.length, 1);
      expect(updatedState.zones.length, 1);
      expect(updatedState.selectedZoneId, 'zone_north');
      expect(updatedState.filteredIncidents.length, 1);
    });

    test('SyncProvider offline queue sync status & batch trigger state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialSync = container.read(syncProvider);
      expect(initialSync.pendingQueueCount, 0);
      expect(initialSync.isSyncing, isFalse);

      // Update pending count
      container.read(syncProvider.notifier).setPendingCount(5);
      expect(container.read(syncProvider).pendingQueueCount, 5);

      // Record batch
      final batch = SyncBatchModel(
        batchId: 'batch_55',
        ownerUid: 'usr_1',
        deviceId: 'dev_1001',
        installationId: 'inst_1',
        payloadHash: 'abc123hash',
        status: 'ACCEPTED',
        eventCount: 3,
        receivedAt: DateTime.now(),
      );

      container.read(syncProvider.notifier).recordBatch(batch);
      expect(container.read(syncProvider).recentBatches.length, 1);

      // Trigger sync
      container.read(syncProvider.notifier).triggerSyncBatch();
      expect(container.read(syncProvider).pendingQueueCount, 0);
      expect(container.read(syncProvider).isSyncing, isFalse);
    });
  });
}
