# Contrats Firebase et BLE — VoltCam Standard

## 1. Principes de contrat

- Firebase est la plateforme du MVP : le client Flutter lit les vues autorisées dans Firestore et appelle les mutations sensibles via Cloud Functions.
- Les Cloud Functions sont protégées par Firebase Auth et App Check.
- Toute synchronisation est identifiée par une clé d'idempotence unique.
- Les documents publics sont déjà agrégés ; ils ne transportent ni adresse, ni identifiant matériel, ni télémétrie brute.
- Les clients n'écrivent jamais directement un incident, un score GridTrust ou un message officiel.

## 2. Fonctions callable

| Fonction | Rôle | Autorisation |
| --- | --- | --- |
| `claimDevice` | Associe un boîtier provisionné à l'utilisateur et crée l'installation active. | Utilisateur authentifié et propriétaire légitime. |
| `submitSyncBatch` | Reçoit un lot d'événements, vérifie l'idempotence et met à jour GridTrust. | Utilisateur authentifié, App Check valide et consentement actif. |
| `setConsent` | Enregistre ou retire un consentement versionné. | Utilisateur concerné. |
| `setZoneSubscription` | Crée ou met à jour les alertes de zone. | Utilisateur concerné. |
| `createCommunityPost` | Crée un message `PENDING` soumis à la modération. | Utilisateur authentifié avec consentement concerné. |
| `publishOfficialUpdate` | Publie une information officielle ou maintenance. | Administrateur autorisé. |

## 3. Contrat `submitSyncBatch`

### Entrée logique

```json
{
  "batchId": "b8a2aee4-481d-48c6-a242-3c84b2dbce2e",
  "deviceId": "VTC-2026-DEMO-001",
  "installationId": "installation-demo-001",
  "sentAt": "2026-07-24T10:12:00Z",
  "events": [
    {
      "eventId": "VTC-2026-DEMO-001-4822",
      "type": "OUTAGE",
      "occurredAt": "2026-07-24T10:11:58Z",
      "lastGasp": true,
      "summary": {
        "voltageBeforeLoss": 218.7,
        "batteryPercent": 93
      }
    }
  ]
}
```

### Règles serveur

1. Vérifier Auth, App Check, rôle, propriété du boîtier et statut de l'installation.
2. Refuser le lot si `batchId` a déjà été traité avec une charge différente.
3. Retourner le résultat initial si `batchId` existe déjà avec la même charge.
4. Limiter un lot à un nombre et une taille de documents sûrs pour Firestore.
5. Créer événements et lot de façon atomique ou avec reprise explicite.
6. Réserver les mises à jour d'incidents et notifications à la fonction serveur.

### Sortie logique

```json
{
  "batchId": "b8a2aee4-481d-48c6-a242-3c84b2dbce2e",
  "status": "ACCEPTED",
  "acceptedEvents": 1,
  "duplicate": false,
  "incidentUpdates": [
    {
      "incidentId": "incident-biyem-assi-20260724-01",
      "status": "PENDING",
      "confidenceScore": 35,
      "independentDeviceCount": 1
    }
  ]
}
```

## 4. Lectures Firestore autorisées

| Collection | Consommateur | Contenu exposé |
| --- | --- | --- |
| `users/{uid}` | Utilisateur concerné | Profil, préférences et statut de compte. |
| `users/{uid}/notifications` | Utilisateur concerné | Alertes personnelles. |
| `zones` | Utilisateur authentifié | Zones agrégées et métadonnées publiques. |
| `incidents` | Utilisateur authentifié | Incidents agrégés, confiance et conseils. |
| `communityPosts` | Utilisateur authentifié | Messages publiés et source. |
| `maintenanceWindows` | Utilisateur authentifié | Informations officielles validées. |

Les collections `devices`, `installations`, `syncBatches`, `deviceEvents`, `incidentEvidence`, `consents` et `auditLogs` ne sont pas accessibles en écriture directe au client.

## 5. Erreurs normalisées

| Code | Signification | Action Flutter |
| --- | --- | --- |
| `unauthenticated` | Session absente ou expirée | Renouveler la session Firebase. |
| `failed-precondition` | Consentement, installation ou App Check invalide | Afficher la cause et guider l'utilisateur. |
| `already-exists` | Lot déjà traité avec une charge différente | Conserver le journal et éviter le réessai aveugle. |
| `permission-denied` | Boîtier ou opération non autorisé | Bloquer l'action et demander une vérification. |
| `invalid-argument` | Trame ou payload hors contrat | Conserver localement, journaliser et proposer le diagnostic. |
| `resource-exhausted` | Taille ou fréquence de lot trop élevée | Fragmenter et réessayer avec temporisation. |

## 6. Contrat BLE GATT

Les UUID définitifs sont réservés pendant le sprint firmware. Les noms ci-dessous constituent le contrat fonctionnel v1.

| Caractéristique | Sens | Données minimales |
| --- | --- | --- |
| `device-info` | Lecture | Identifiant matériel, modèle, firmware et capacité de batterie. |
| `live-telemetry` | Notification | Séquence, horodatage, tension, courant, puissance, batterie et indicateurs de qualité. |
| `event-stream` | Indication confirmée | Identifiant d'événement, type, horodatage, dernier souffle et résumé minimal. |
| `device-health` | Lecture ou notification | Heartbeat, qualité BLE, batterie et état de mesure. |
| `configuration` | Lecture | Version de configuration et seuils actifs. |

Une trame inclut au minimum `protocolVersion`, `sequence`, `sampledAt`, `eventType`, `payload` et un contrôle d'intégrité. Flutter la valide avant affichage et avant ajout à la file locale.

## 7. Réessai et cohérence

1. Chaque événement garde un identifiant stable créé par le boîtier ou le client.
2. Chaque lot garde un `batchId` stable tant que sa charge n'est pas acquittée.
3. L'application ne retire un lot local qu'après réponse `ACCEPTED` ou réponse idempotente équivalente.
4. Firestore conserve le document de lot et son empreinte pour empêcher les doublons.
5. Les événements hors ordre sont traités selon `occurredAt` dans la fenêtre GridTrust configurée.

## 8. Endpoints et opérations absents

VoltCam ne propose aucune fonction permettant de lire un compteur prépayé, agir sur un compteur, couper une alimentation, modifier un tarif, localiser précisément un foyer ou déclarer automatiquement une personne fraudeuse.
