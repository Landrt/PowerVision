import { IGridTrustStore, processEventWithGridTrust, SLIDING_WINDOW_MS } from '../services/gridtrust';
import { IncidentDoc, EvidenceDoc, DeviceEventDoc, SyncBatchDoc } from '../types';

export class InMemoryGridTrustStore implements IGridTrustStore {
  public incidents: Map<string, IncidentDoc> = new Map();
  public evidences: Map<string, EvidenceDoc[]> = new Map();

  async findActiveIncident(zoneId: string, type: string, eventTimestampMs: number, windowMs = SLIDING_WINDOW_MS): Promise<IncidentDoc | null> {
    for (const incident of this.incidents.values()) {
      if (incident.zoneId === zoneId && incident.type === type && (incident.status === 'PENDING' || incident.status === 'CONFIRMED')) {
        const lastEventMs = new Date(incident.lastEventAt || incident.startedAt).getTime();
        if (Math.abs(eventTimestampMs - lastEventMs) <= windowMs) {
          return incident;
        }
      }
    }
    return null;
  }

  async createIncident(incident: IncidentDoc): Promise<void> {
    this.incidents.set(incident.incidentId, { ...incident });
    this.evidences.set(incident.incidentId, []);
  }

  async updateIncident(incidentId: string, updates: Partial<IncidentDoc>): Promise<void> {
    const existing = this.incidents.get(incidentId);
    if (existing) {
      this.incidents.set(incidentId, { ...existing, ...updates });
    }
  }

  async addEvidence(incidentId: string, evidence: EvidenceDoc): Promise<void> {
    const list = this.evidences.get(incidentId) || [];
    list.push(evidence);
    this.evidences.set(incidentId, list);
  }

  async getEvidences(incidentId: string): Promise<EvidenceDoc[]> {
    return this.evidences.get(incidentId) || [];
  }
}

export class MockSyncBatchService {
  private syncBatches: Map<string, SyncBatchDoc> = new Map();
  private deviceEvents: Map<string, DeviceEventDoc> = new Map();
  public store: InMemoryGridTrustStore = new InMemoryGridTrustStore();

  async submitSyncBatch(params: {
    uid: string;
    batchId: string;
    deviceId: string;
    installationId: string;
    payloadHash: string;
    events: Array<{
      eventId?: string;
      zoneId: string;
      type: string;
      occurredAt: string;
      lastGasp?: boolean;
    }>;
  }) {
    // Idempotency check
    const existing = this.syncBatches.get(params.batchId);
    if (existing) {
      return {
        status: existing.status,
        batchId: existing.batchId,
        incidentIds: existing.result.incidentIds,
        cached: true
      };
    }

    const incidentIdsSet = new Set<string>();

    for (let i = 0; i < params.events.length; i++) {
      const raw = params.events[i];
      const eventId = raw.eventId || `evt_${params.batchId}_${i}`;
      const eventDoc: DeviceEventDoc = {
        eventId,
        deviceId: params.deviceId,
        installationId: params.installationId,
        zoneId: raw.zoneId,
        syncBatchId: params.batchId,
        type: raw.type,
        occurredAt: raw.occurredAt,
        lastGasp: Boolean(raw.lastGasp)
      };

      this.deviceEvents.set(eventId, eventDoc);
      const incident = await processEventWithGridTrust(this.store, eventDoc);
      if (incident?.incidentId) {
        incidentIdsSet.add(incident.incidentId);
      }
    }

    const incidentIds = Array.from(incidentIdsSet);
    const syncBatchDoc: SyncBatchDoc = {
      batchId: params.batchId,
      ownerUid: params.uid,
      deviceId: params.deviceId,
      installationId: params.installationId,
      payloadHash: params.payloadHash,
      status: 'ACCEPTED',
      eventCount: params.events.length,
      receivedAt: new Date().toISOString(),
      result: {
        incidentIds,
        processedEvents: params.events.length
      }
    };

    this.syncBatches.set(params.batchId, syncBatchDoc);

    return {
      status: 'ACCEPTED',
      batchId: params.batchId,
      incidentIds,
      cached: false
    };
  }

  getBatch(batchId: string) {
    return this.syncBatches.get(batchId);
  }
}
