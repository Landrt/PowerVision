/**
 * VoltCam Firestore Data Models & Document Types
 * Reference: docs/08-modele-firestore.md
 */

export interface UserDoc {
  uid: string;
  email?: string;
  displayName?: string;
  role?: 'user' | 'admin';
  createdAt: string;
  updatedAt: string;
}

export interface DeviceDoc {
  deviceId: string;
  hardwareId: string;
  ownerUid: string;
  status: 'ONLINE' | 'OFFLINE' | 'MAINTENANCE';
  firmwareVersion: string;
  lastSeenAt: string;
  createdAt?: string;
}

export interface InstallationDoc {
  installationId: string;
  ownerUid: string;
  deviceId: string;
  zoneId: string;
  address?: string;
  createdAt?: string;
}

export interface SyncBatchResult {
  incidentIds: string[];
  processedEvents: number;
}

export interface SyncBatchDoc {
  batchId: string;
  ownerUid: string;
  deviceId: string;
  installationId: string;
  payloadHash: string;
  status: 'ACCEPTED' | 'REJECTED';
  eventCount: number;
  receivedAt: string;
  result: SyncBatchResult;
}

export interface DeviceEventSummary {
  voltageBeforeLoss?: number;
  batteryPercent?: number;
  variance?: number;
  [key: string]: any;
}

export interface DeviceEventDoc {
  eventId: string;
  deviceId: string;
  installationId: string;
  zoneId: string;
  syncBatchId: string;
  type: 'OUTAGE' | 'INSTABILITY' | 'LOW_VOLTAGE' | 'SURGE' | string;
  occurredAt: string; // ISO 8601 string format
  lastGasp: boolean;
  summary?: DeviceEventSummary;
}

export type IncidentStatus = 'PENDING' | 'CONFIRMED' | 'RESOLVED';

export interface IncidentDoc {
  incidentId: string;
  zoneId: string;
  type: string;
  status: IncidentStatus;
  startedAt: string;
  lastEventAt: string;
  confidenceScore: number; // 0-100
  independentDeviceCount: number;
  publicSummary: string;
  mapLayer: string;
  updatedAt: string;
}

export interface EvidenceDoc {
  eventId: string;
  deviceId: string;
  occurredAt: string;
  lastGasp: boolean;
  addedAt: string;
}

export interface GridZoneDoc {
  zoneId: string;
  name: string;
  region: string;
  activeIncidentsCount: number;
  updatedAt: string;
}

export interface CommunityPostDoc {
  postId: string;
  authorUid: string;
  title: string;
  content: string;
  type: 'OFFICIAL_ANNOUNCEMENT' | 'GRID_MAINTENANCE' | 'COMMUNITY_UPDATE';
  zoneId?: string;
  isOfficial: boolean;
  publishedAt: string;
  scheduledStart?: string;
  scheduledEnd?: string;
}

export interface ConsentDoc {
  consentId: string;
  uid: string;
  telemetrySharing: boolean;
  locationZone: string;
  version: string;
  updatedAt: string;
}
