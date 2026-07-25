# Conception technique — VoltCam Standard (Flutter + Firebase)

## 1. Principes d'architecture

1. **Offline-first** : le boîtier et l'application restent utiles sans Internet ; Firebase enrichit l'expérience sans la bloquer.
2. **Event-first** : Firestore reçoit les événements, résumés et incidents, pas la télémétrie brute continue.
3. **Server-authoritative** : les Cloud Functions sont seules autorisées à confirmer un incident, calculer GridTrust et publier un contenu officiel.
4. **Privacy by design** : les cartes utilisent `GridZone` ; aucune position résidentielle n'est stockée ni affichée publiquement.
5. **Safety by design** : aucune fonction mobile ou cloud ne contrôle le secteur ni un compteur.
6. **Explicabilité** : l'application explique les signaux, le score de risque et la confiance de l'incident.

## 2. Stack retenue

| Couche | Responsabilités | Technologies |
| --- | --- | --- |
| Boîtier | Mesure isolée, heartbeat, dernier souffle, trames BLE | ESP32, firmware C/C++ ou ESP-IDF, batterie de secours |
| Client mobile | BLE, UI, cache chiffré, synchronisation, carte et notifications | Flutter, Dart, Riverpod, GoRouter, BLE GATT |
| Stockage local | Mesures locales, file d'événements et préférences sensibles | Base locale chiffrée, clé dans `flutter_secure_storage` |
| Identité et protection | Session, identité anonyme/compte, contrôle de l'intégrité | Firebase Auth, Firebase App Check |
| Données cloud | Profils, zones, événements, incidents, consentements | Cloud Firestore |
| Logique serveur | Validation, idempotence, GridTrust, notifications et contenu officiel | Cloud Functions 2nd gen avec Admin SDK |
| Communication | Notifications et messages | Firebase Cloud Messaging |
| Qualité | Erreurs, métriques, paramètres de seuils | Crashlytics, Analytics, Remote Config |
| Carte | Visualisation par zone et couches | Google Maps for Flutter |

## 3. Architecture logique

```mermaid
flowchart LR
    sensor["Chaîne de mesure isolée"] --> device["Boîtier VoltCam"]
    battery["Batterie de secours"] --> device
    device -->|"BLE GATT"| app["Application Flutter"]
    app --> localStore["Stockage local chiffré"]
    app --> auth["Firebase Auth et App Check"]
    app --> functions["Cloud Functions"]
    functions --> firestore["Cloud Firestore"]
    functions --> fcm["Firebase Cloud Messaging"]
    app --> maps["Google Maps"]
    firestore --> app
    fcm --> app
    remoteConfig["Remote Config"] --> app
    crashlytics["Crashlytics"] <-- app
```

## 4. Conception Flutter

### 4.1 Structure de projet

| Module | Rôle |
| --- | --- |
| `core` | Configuration Firebase, thème, i18n, erreurs et utilitaires. |
| `features/device` | Appairage BLE, état du boîtier, télémétrie et diagnostic. |
| `features/incidents` | Fiche d'incident, GridTrust et historique. |
| `features/map` | Carte Google Maps, couches et filtres de zone. |
| `features/protect_mode` | Jauge de risque, conseils et alertes de sécurité. |
| `features/community` | Messages officiels, publications modérées et abonnements. |
| `features/privacy` | Consentements, données personnelles et suppression de compte. |
| `data` | Sources BLE, locale, Firestore et Cloud Functions. |
| `domain` | Cas d'utilisation, règles de classification et entités métier. |
| `demo` | Générateur de scénarios pour tests et présentation. |

Riverpod gère l'état et l'injection de dépendances. Le composant BLE est isolé derrière une interface `BleGateway` afin de remplacer le plugin sans réécrire l'application si un test matériel l'exige.

### 4.2 Stockage et synchronisation

- La télémétrie visuelle récente reste locale et chiffrée.
- Les événements importants sont ajoutés à une file locale avec une clé d'événement unique.
- Firestore apporte son cache hors ligne pour les données cloud lues, mais il ne remplace pas la file de synchronisation métier.
- Une tâche de reprise déclenche `submitSyncBatch` quand le réseau, l'authentification et le consentement sont valides.
- Le lot reste local jusqu'à l'accusé de réception de la Cloud Function.

## 5. Firebase et responsabilités serveur

| Service Firebase | Responsabilité VoltCam |
| --- | --- |
| Authentication | Identifie un utilisateur anonyme ou inscrit et porte les rôles. |
| App Check | Réduit les appels clients non authentiques vers Firebase. |
| Cloud Firestore | Conserve les documents métier à faible volume et les vues d'incidents. |
| Cloud Functions | Vérifie les droits, déduplique les lots, écrit les événements et maintient GridTrust. |
| Cloud Messaging | Alerte les abonnés lors d'un incident confirmé ou d'un Protect Mode critique. |
| Remote Config | Versionne les seuils de démonstration, les fenêtres et les textes non critiques. |
| Crashlytics | Centralise les erreurs mobiles sans inclure données sensibles. |

### 5.1 Fonctions serveur MVP

| Fonction | Déclencheur | Rôle |
| --- | --- | --- |
| `claimDevice` | Callable | Associe un boîtier provisionné à un compte et une installation. |
| `submitSyncBatch` | Callable | Valide le lot, assure l'idempotence, crée les événements et appelle GridTrust. |
| `recalculateIncident` | Interne | Recalcule la confiance et le statut d'un incident dans une transaction. |
| `publishOfficialUpdate` | Callable admin | Publie une maintenance ou information officiellement validée. |
| `fanOutNotification` | Écriture incident | Envoie les notifications aux abonnés de zone. |
| `revokeConsentData` | Callable | Applique le retrait de consentement et les règles de rétention. |

## 6. GridTrust dans Firestore

Pour un lot entrant, `submitSyncBatch` suit ce flux :

1. vérifier le jeton Firebase Auth, App Check, le consentement et la propriété du boîtier ;
2. vérifier que l'identifiant de lot n'a jamais été traité ;
3. écrire le lot et les événements de façon atomique ;
4. localiser la `GridZone` liée à l'installation, sans position de foyer ;
5. rechercher l'incident de même catégorie encore actif dans la fenêtre configurée ;
6. ajouter une preuve seulement si elle provient d'un boîtier indépendant ;
7. mettre à jour score, nombre de sources et statut dans une transaction ;
8. déclencher FCM seulement lorsque la règle de notification est satisfaite.

Le seuil de démo est de trois boîtiers sur dix minutes, réglable par Remote Config. Il est clairement présenté comme une estimation de confiance, pas comme la cause certaine de la panne.

## 7. Protect Mode et risque local

Protect Mode transforme une mesure difficile à lire en action utile. Le moteur local calcule un risque entre 0 et 100 à partir de la tension récente, de la variance, des microcoupures et de l'âge de la dernière mesure.

| Niveau | Affichage | Action proposée |
| --- | --- | --- |
| 0–39 | Stable | Continuer la surveillance normale. |
| 40–69 | À surveiller | Éviter de brancher des appareils sensibles tant que l'instabilité persiste. |
| 70–100 | Protéger | Débrancher de façon sûre les appareils sensibles et attendre une tension stable. |

Les seuils sont configurables et calibrés ; le score est une aide utilisateur, jamais un contrôle automatique d'appareil.

## 8. Carte et inclusion

- **Couches MVP** : coupures confirmées, instabilité, maintenances annoncées.
- **Couches post-hackathon** : tendances temporelles, heatmap agrégée, score de fiabilité par période.
- **Confidentialité** : chaque point ou polygone correspond à une zone, jamais à un foyer.
- **Langues** : toutes les chaînes passent par ARB/i18n Flutter ; FR/EN dans le MVP, Pidgin et TTS activables ensuite.

## 9. Décisions architecturales

| ID | Décision | Conséquence |
| --- | --- | --- |
| ADR-01 | Flutter est le client principal. | Un codebase couvre Android, iOS et Web ; le BLE est encapsulé par plateforme. |
| ADR-02 | Firebase est la plateforme du hackathon. | Pas de serveur à gérer ; Auth, Firestore, Functions et FCM s'intègrent rapidement. |
| ADR-03 | Firestore est event-first. | Réduction des coûts et des limites de débit ; télémétrie brute locale. |
| ADR-04 | Cloud Functions détiennent l'autorité métier. | Les clients ne peuvent pas modifier incidents, scores ou contenu officiel. |
| ADR-05 | SyncBatch reste idempotent. | Un réseau intermittent ne crée pas d'événements dupliqués. |
| ADR-06 | Prisma devient une option post-pilote. | Le modèle relationnel reste disponible si les besoins institutionnels justifient une migration. |
| ADR-07 | Gemini est post-hackathon et assistif. | Pas de décision critique ni de dépendance pour la démo. |

## 10. Observabilité

| Signal | Utilité |
| --- | --- |
| Échecs d'appairage BLE | Priorise les corrections matériel et plugin. |
| Ancienneté de dernière mesure | Distingue boîtier silencieux et absence de connexion téléphone. |
| Échecs de `submitSyncBatch` | Mesure la résilience hors ligne et les erreurs de règles. |
| Délai de confirmation | Évalue GridTrust. |
| Lectures et écritures Firestore | Contrôle les coûts du MVP. |
| Taux de crash Flutter | Protège la démonstration et le pilote. |
