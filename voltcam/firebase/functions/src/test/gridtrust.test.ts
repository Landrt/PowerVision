import {
  InMemoryGridTrustStore,
  MockSyncBatchService
} from './gridtrust.mock';
import {
  processEventWithGridTrust,
  calculateConfidenceScore
} from '../services/gridtrust';
import { DeviceEventDoc, EvidenceDoc } from '../types';

describe('GridTrust Consensus Engine & Cloud Functions Unit Tests', () => {
  let store: InMemoryGridTrustStore;

  beforeEach(() => {
    store = new InMemoryGridTrustStore();
  });

  describe('submitSyncBatch Idempotency', () => {
    it('should return cached result gracefully on duplicate batchId submission', async () => {
      const service = new MockSyncBatchService();

      const batchPayload = {
        uid: 'user_123',
        batchId: 'batch_alpha_001',
        deviceId: 'dev_volt_01',
        installationId: 'inst_01',
        payloadHash: 'hash_abc123',
        events: [
          {
            eventId: 'evt_001',
            zoneId: 'yaounde-vi-biyem-assi',
            type: 'OUTAGE',
            occurredAt: '2026-07-24T10:00:00Z',
            lastGasp: true
          }
        ]
      };

      // First submission
      const result1 = await service.submitSyncBatch(batchPayload);
      expect(result1.cached).toBe(false);
      expect(result1.status).toBe('ACCEPTED');
      expect(result1.incidentIds.length).toBe(1);

      // Duplicate submission with same batchId
      const result2 = await service.submitSyncBatch(batchPayload);
      expect(result2.cached).toBe(true);
      expect(result2.status).toBe('ACCEPTED');
      expect(result2.incidentIds).toEqual(result1.incidentIds);

      // Verify batch was stored only once
      const storedBatch = service.getBatch('batch_alpha_001');
      expect(storedBatch).toBeDefined();
      expect(storedBatch?.eventCount).toBe(1);
    });
  });

  describe('10-Minute Sliding Window & Device Count Aggregation', () => {
    it('should group events within 10 minutes into same incident and aggregate distinct devices', async () => {
      const zoneId = 'yaounde-vi-biyem-assi';
      const eventType = 'OUTAGE';

      // Event 1 from dev_1 at 10:00:00
      const event1: DeviceEventDoc = {
        eventId: 'evt_101',
        deviceId: 'dev_1',
        installationId: 'inst_1',
        zoneId,
        syncBatchId: 'b1',
        type: eventType,
        occurredAt: '2026-07-24T10:00:00.000Z',
        lastGasp: true
      };

      const inc1 = await processEventWithGridTrust(store, event1);
      expect(inc1.independentDeviceCount).toBe(1);
      expect(inc1.status).toBe('PENDING');

      // Event 2 from dev_2 at 10:05:00 (within 10 mins window)
      const event2: DeviceEventDoc = {
        eventId: 'evt_102',
        deviceId: 'dev_2',
        installationId: 'inst_2',
        zoneId,
        syncBatchId: 'b2',
        type: eventType,
        occurredAt: '2026-07-24T10:05:00.000Z',
        lastGasp: true
      };

      const inc2 = await processEventWithGridTrust(store, event2);
      expect(inc2.incidentId).toBe(inc1.incidentId); // Same incident
      expect(inc2.independentDeviceCount).toBe(2);
      expect(inc2.status).toBe('PENDING');

      // Event 3 from dev_1 AGAIN (duplicate device) at 10:07:00
      const event3: DeviceEventDoc = {
        eventId: 'evt_103',
        deviceId: 'dev_1',
        installationId: 'inst_1',
        zoneId,
        syncBatchId: 'b3',
        type: eventType,
        occurredAt: '2026-07-24T10:07:00.000Z',
        lastGasp: true
      };

      const inc3 = await processEventWithGridTrust(store, event3);
      expect(inc3.incidentId).toBe(inc1.incidentId);
      expect(inc3.independentDeviceCount).toBe(2); // Distinct device count remains 2!

      // Event 4 from dev_3 at 10:20:00 (15 minutes after event2 - outside 10 min sliding window)
      const event4: DeviceEventDoc = {
        eventId: 'evt_104',
        deviceId: 'dev_3',
        installationId: 'inst_3',
        zoneId,
        syncBatchId: 'b4',
        type: eventType,
        occurredAt: '2026-07-24T10:20:00.000Z',
        lastGasp: true
      };

      const inc4 = await processEventWithGridTrust(store, event4);
      expect(inc4.incidentId).not.toBe(inc1.incidentId); // New incident created
      expect(inc4.independentDeviceCount).toBe(1);
    });
  });

  describe('Status Transition PENDING -> CONFIRMED & Confidence Score Calculation', () => {
    it('should transition status to CONFIRMED when independentDeviceCount >= 3', async () => {
      const zoneId = 'zone_douala_akwa';
      const eventType = 'OUTAGE';

      // 1st device
      const event1: DeviceEventDoc = {
        eventId: 'e1',
        deviceId: 'dev_A',
        installationId: 'inst_A',
        zoneId,
        syncBatchId: 'batch_1',
        type: eventType,
        occurredAt: '2026-07-24T12:00:00Z',
        lastGasp: true
      };
      const inc1 = await processEventWithGridTrust(store, event1);
      expect(inc1.status).toBe('PENDING');
      expect(inc1.confidenceScore).toBeGreaterThan(0);

      // 2nd device
      const event2: DeviceEventDoc = {
        eventId: 'e2',
        deviceId: 'dev_B',
        installationId: 'inst_B',
        zoneId,
        syncBatchId: 'batch_2',
        type: eventType,
        occurredAt: '2026-07-24T12:02:00Z',
        lastGasp: true
      };
      const inc2 = await processEventWithGridTrust(store, event2);
      expect(inc2.status).toBe('PENDING');
      expect(inc2.confidenceScore).toBeGreaterThan(inc1.confidenceScore);

      // 3rd distinct device -> triggers PENDING -> CONFIRMED transition
      const event3: DeviceEventDoc = {
        eventId: 'e3',
        deviceId: 'dev_C',
        installationId: 'inst_C',
        zoneId,
        syncBatchId: 'batch_3',
        type: eventType,
        occurredAt: '2026-07-24T12:04:00Z',
        lastGasp: true
      };
      const inc3 = await processEventWithGridTrust(store, event3);
      expect(inc3.status).toBe('CONFIRMED');
      expect(inc3.independentDeviceCount).toBe(3);
      expect(inc3.publicSummary).toContain('Coupure confirmée par 3 boîtiers');
      expect(inc3.confidenceScore).toBeGreaterThanOrEqual(80);
    });

    it('should correctly compute confidence score with formula bounds (0-100)', () => {
      const evidences: EvidenceDoc[] = [
        { eventId: '1', deviceId: 'dev_1', occurredAt: '2026-07-24T10:00:00Z', lastGasp: true, addedAt: '2026-07-24T10:00:00Z' },
        { eventId: '2', deviceId: 'dev_2', occurredAt: '2026-07-24T10:02:00Z', lastGasp: true, addedAt: '2026-07-24T10:02:00Z' },
        { eventId: '3', deviceId: 'dev_3', occurredAt: '2026-07-24T10:03:00Z', lastGasp: true, addedAt: '2026-07-24T10:03:00Z' },
        { eventId: '4', deviceId: 'dev_4', occurredAt: '2026-07-24T10:04:00Z', lastGasp: true, addedAt: '2026-07-24T10:04:00Z' }
      ];

      const score = calculateConfidenceScore(
        4,
        evidences,
        '2026-07-24T10:00:00Z',
        '2026-07-24T10:04:00Z'
      );

      expect(score).toBeGreaterThanOrEqual(0);
      expect(score).toBeLessThanOrEqual(100);
      expect(score).toBeGreaterThanOrEqual(95); // 4+ devices with 100% lastGasp and tight recency
    });
  });
});
