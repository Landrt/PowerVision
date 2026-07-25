import { DeviceEventDoc, IncidentDoc, EvidenceDoc } from '../types';

export interface IGridTrustStore {
  findActiveIncident(zoneId: string, type: string, eventTimestampMs: number, windowMs?: number): Promise<IncidentDoc | null>;
  createIncident(incident: IncidentDoc): Promise<void>;
  updateIncident(incidentId: string, updates: Partial<IncidentDoc>): Promise<void>;
  addEvidence(incidentId: string, evidence: EvidenceDoc): Promise<void>;
  getEvidences(incidentId: string): Promise<EvidenceDoc[]>;
}

export const SLIDING_WINDOW_MS = 10 * 60 * 1000; // 10 minutes

/**
 * Calculates the GridTrust confidence score (0 - 100).
 * Based on:
 * - Independent device count (60% weight)
 * - Signal consistency (lastGasp flag / voltage telemetry) (25% weight)
 * - Event recency & time clustering (15% weight)
 */
export function calculateConfidenceScore(
  independentDeviceCount: number,
  evidences: EvidenceDoc[],
  startedAtIso: string,
  latestOccurredAtIso: string
): number {
  // 1. Device count component (60%)
  let scoreDevice = 0;
  if (independentDeviceCount === 1) scoreDevice = 25;
  else if (independentDeviceCount === 2) scoreDevice = 55;
  else if (independentDeviceCount === 3) scoreDevice = 85;
  else if (independentDeviceCount >= 4) scoreDevice = 100;

  // 2. Signal consistency component (25%)
  let scoreConsistency = 50;
  if (evidences.length > 0) {
    const lastGaspCount = evidences.filter(e => e.lastGasp).length;
    scoreConsistency = Math.round((lastGaspCount / evidences.length) * 100);
  }

  // 3. Recency & clustering component (15%)
  const startMs = new Date(startedAtIso).getTime();
  const latestMs = new Date(latestOccurredAtIso).getTime();
  const timeSpanMinutes = Math.abs(latestMs - startMs) / (60 * 1000);
  const scoreRecency = Math.max(0, Math.min(100, Math.round(100 - (timeSpanMinutes / 10) * 50)));

  // Combine weighted components
  const rawScore = 0.60 * scoreDevice + 0.25 * scoreConsistency + 0.15 * scoreRecency;
  return Math.min(100, Math.max(0, Math.round(rawScore)));
}

/**
 * Processes a single telemetry event through GridTrust consensus logic.
 */
export async function processEventWithGridTrust(
  store: IGridTrustStore,
  event: DeviceEventDoc
): Promise<IncidentDoc> {
  const eventTimeMs = new Date(event.occurredAt).getTime();
  
  // 1. Sliding 10-minute window query
  let incident = await store.findActiveIncident(event.zoneId, event.type, eventTimeMs, SLIDING_WINDOW_MS);
  
  if (!incident) {
    const incidentId = `inc_${event.zoneId}_${event.type}_${eventTimeMs}`;
    const mapLayer = event.type.toUpperCase() === 'OUTAGE' ? 'OUTAGES' : 'INSTABILITY';

    incident = {
      incidentId,
      zoneId: event.zoneId,
      type: event.type,
      status: 'PENDING',
      startedAt: event.occurredAt,
      lastEventAt: event.occurredAt,
      confidenceScore: 0,
      independentDeviceCount: 0,
      publicSummary: 'Signalement en cours de vérification (1 boîtier).',
      mapLayer,
      updatedAt: new Date().toISOString()
    };
    await store.createIncident(incident);
  }

  // 2. Add evidence entry
  const evidence: EvidenceDoc = {
    eventId: event.eventId,
    deviceId: event.deviceId,
    occurredAt: event.occurredAt,
    lastGasp: event.lastGasp ?? false,
    addedAt: new Date().toISOString()
  };
  await store.addEvidence(incident.incidentId, evidence);

  // 3. Aggregate evidence & count unique devices
  const allEvidences = await store.getEvidences(incident.incidentId);
  const distinctDevices = new Set(allEvidences.map(e => e.deviceId));
  const independentDeviceCount = distinctDevices.size;

  // 4. Update timestamps and recency
  const lastEventAt = event.occurredAt;

  // 5. Calculate confidence score
  const confidenceScore = calculateConfidenceScore(
    independentDeviceCount,
    allEvidences,
    incident.startedAt,
    lastEventAt
  );

  // 6. Transition status: PENDING -> CONFIRMED if independentDeviceCount >= 3
  let newStatus = incident.status;
  if (independentDeviceCount >= 3 && incident.status === 'PENDING') {
    newStatus = 'CONFIRMED';
  }

  const publicSummary = newStatus === 'CONFIRMED'
    ? `Coupure confirmée par ${independentDeviceCount} boîtiers de la zone.`
    : `Signalement en cours de vérification (${independentDeviceCount} boîtier(s)).`;

  const updates: Partial<IncidentDoc> = {
    independentDeviceCount,
    confidenceScore,
    status: newStatus,
    publicSummary,
    lastEventAt,
    updatedAt: new Date().toISOString()
  };

  await store.updateIncident(incident.incidentId, updates);

  return {
    ...incident,
    ...updates
  };
}

/**
 * Firestore implementation of IGridTrustStore for production Cloud Functions.
 */
export class FirestoreGridTrustStore implements IGridTrustStore {
  constructor(private db: FirebaseFirestore.Firestore) {}

  async findActiveIncident(zoneId: string, type: string, eventTimestampMs: number, windowMs = SLIDING_WINDOW_MS): Promise<IncidentDoc | null> {
    const snapshot = await this.db.collection('incidents')
      .where('zoneId', '==', zoneId)
      .where('type', '==', type)
      .where('status', 'in', ['PENDING', 'CONFIRMED'])
      .get();

    for (const doc of snapshot.docs) {
      const data = doc.data() as IncidentDoc;
      const lastEventMs = new Date(data.lastEventAt || data.startedAt).getTime();
      if (Math.abs(eventTimestampMs - lastEventMs) <= windowMs) {
        return data;
      }
    }
    return null;
  }

  async createIncident(incident: IncidentDoc): Promise<void> {
    await this.db.collection('incidents').doc(incident.incidentId).set(incident);
  }

  async updateIncident(incidentId: string, updates: Partial<IncidentDoc>): Promise<void> {
    await this.db.collection('incidents').doc(incidentId).update(updates);
  }

  async addEvidence(incidentId: string, evidence: EvidenceDoc): Promise<void> {
    await this.db.collection('incidents').doc(incidentId).collection('evidence').doc(evidence.eventId).set(evidence);
  }

  async getEvidences(incidentId: string): Promise<EvidenceDoc[]> {
    const snapshot = await this.db.collection('incidents').doc(incidentId).collection('evidence').get();
    return snapshot.docs.map(doc => doc.data() as EvidenceDoc);
  }
}
