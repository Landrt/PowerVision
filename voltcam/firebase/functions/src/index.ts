import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { FirestoreGridTrustStore, processEventWithGridTrust } from './services/gridtrust';
import { DeviceEventDoc, SyncBatchDoc, CommunityPostDoc, ConsentDoc, DeviceDoc, InstallationDoc } from './types';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * submitSyncBatch Cloud Function
 * Idempotent sync of offline event batches.
 * Atomically records sync batch, device events, and triggers GridTrust consensus.
 */
export const submitSyncBatch = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be authenticated to submit sync batches.');
  }

  const uid = request.auth.uid;
  const { batchId, deviceId, installationId, payloadHash, events } = request.data || {};

  if (!batchId || !deviceId || !installationId || !payloadHash || !Array.isArray(events)) {
    throw new HttpsError('invalid-argument', 'Missing required batch attributes (batchId, deviceId, installationId, payloadHash, events).');
  }

  // 1. Idempotency Check: return existing result gracefully if batchId was already processed
  const batchRef = db.collection('syncBatches').doc(batchId);
  const existingBatchDoc = await batchRef.get();

  if (existingBatchDoc.exists) {
    const data = existingBatchDoc.data() as SyncBatchDoc;
    return {
      status: data.status,
      batchId: data.batchId,
      incidentIds: data.result?.incidentIds || [],
      cached: true
    };
  }

  // 2. Process events & GridTrust consensus
  const gridTrustStore = new FirestoreGridTrustStore(db);
  const incidentIdsSet = new Set<string>();
  const batchWrite = db.batch();

  for (let i = 0; i < events.length; i++) {
    const rawEvent = events[i];
    const eventId = rawEvent.eventId || `evt_${batchId}_${i}`;

    const eventDoc: DeviceEventDoc = {
      eventId,
      deviceId,
      installationId,
      zoneId: rawEvent.zoneId || 'zone-default',
      syncBatchId: batchId,
      type: rawEvent.type || 'OUTAGE',
      occurredAt: rawEvent.occurredAt || new Date().toISOString(),
      lastGasp: Boolean(rawEvent.lastGasp),
      summary: rawEvent.summary || {}
    };

    // Queue device event document write
    const eventRef = db.collection('deviceEvents').doc(eventId);
    batchWrite.set(eventRef, eventDoc);

    // Invoke GridTrust consensus algorithm
    const incident = await processEventWithGridTrust(gridTrustStore, eventDoc);
    if (incident && incident.incidentId) {
      incidentIdsSet.add(incident.incidentId);
    }
  }

  const incidentIds = Array.from(incidentIdsSet);

  // Write syncBatches record
  const syncBatchDoc: SyncBatchDoc = {
    batchId,
    ownerUid: uid,
    deviceId,
    installationId,
    payloadHash,
    status: 'ACCEPTED',
    eventCount: events.length,
    receivedAt: new Date().toISOString(),
    result: {
      incidentIds,
      processedEvents: events.length
    }
  };

  batchWrite.set(batchRef, syncBatchDoc);
  await batchWrite.commit();

  return {
    status: 'ACCEPTED',
    batchId,
    incidentIds,
    cached: false
  };
});

/**
 * claimDevice Cloud Function
 * Associates provisioned hardware (hardwareId) to calling user and installation.
 */
export const claimDevice = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be authenticated to claim a device.');
  }

  const uid = request.auth.uid;
  const { hardwareId, zoneId, address } = request.data || {};

  if (!hardwareId || !zoneId) {
    throw new HttpsError('invalid-argument', 'Missing hardwareId or zoneId.');
  }

  const deviceId = `dev_${hardwareId}`;
  const installationId = `inst_${uid}_${hardwareId}`;
  const now = new Date().toISOString();

  const deviceDoc: DeviceDoc = {
    deviceId,
    hardwareId,
    ownerUid: uid,
    status: 'ONLINE',
    firmwareVersion: '1.0.0',
    lastSeenAt: now,
    createdAt: now
  };

  const installationDoc: InstallationDoc = {
    installationId,
    ownerUid: uid,
    deviceId,
    zoneId,
    address: address || '',
    createdAt: now
  };

  const batch = db.batch();
  batch.set(db.collection('devices').doc(deviceId), deviceDoc, { merge: true });
  batch.set(db.collection('installations').doc(installationId), installationDoc, { merge: true });
  await batch.commit();

  return {
    success: true,
    deviceId,
    installationId
  };
});

/**
 * setConsent Cloud Function
 * Records consent scope (telemetry sharing, location zone) with versioning in consents/.
 */
export const setConsent = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be authenticated to set consent.');
  }

  const uid = request.auth.uid;
  const { telemetrySharing, locationZone, version } = request.data || {};

  if (typeof telemetrySharing !== 'boolean' || !locationZone || !version) {
    throw new HttpsError('invalid-argument', 'Missing or invalid consent arguments (telemetrySharing, locationZone, version).');
  }

  const consentId = `consent_${uid}_${Date.now()}`;
  const now = new Date().toISOString();

  const consentDoc: ConsentDoc = {
    consentId,
    uid,
    telemetrySharing,
    locationZone,
    version,
    updatedAt: now
  };

  const batch = db.batch();
  batch.set(db.collection('consents').doc(consentId), consentDoc);
  batch.set(db.collection('users').doc(uid), {
    consentVersion: version,
    telemetrySharing,
    locationZone,
    updatedAt: now
  }, { merge: true });

  await batch.commit();

  return {
    success: true,
    consentId
  };
});

/**
 * publishOfficialUpdate Cloud Function
 * Admin callable function to publish official news or grid maintenance posts to communityPosts.
 */
export const publishOfficialUpdate = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be authenticated.');
  }

  const uid = request.auth.uid;

  // Verify admin authorization
  let isAdmin = Boolean(request.auth.token?.admin);

  if (!isAdmin) {
    const userDoc = await db.collection('users').doc(uid).get();
    if (userDoc.exists && userDoc.data()?.role === 'admin') {
      isAdmin = true;
    }
  }

  if (!isAdmin) {
    throw new HttpsError('permission-denied', 'Only administrators can publish official updates.');
  }

  const { title, content, type, zoneId, scheduledStart, scheduledEnd } = request.data || {};

  if (!title || !content || !type) {
    throw new HttpsError('invalid-argument', 'Missing title, content, or type.');
  }

  const postId = `post_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`;
  const now = new Date().toISOString();

  const postDoc: CommunityPostDoc = {
    postId,
    authorUid: uid,
    title,
    content,
    type: type as any,
    zoneId: zoneId || undefined,
    isOfficial: true,
    publishedAt: now,
    scheduledStart: scheduledStart || undefined,
    scheduledEnd: scheduledEnd || undefined
  };

  await db.collection('communityPosts').doc(postId).set(postDoc);

  return {
    success: true,
    postId
  };
});
