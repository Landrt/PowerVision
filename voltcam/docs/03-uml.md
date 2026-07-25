# Diagrammes UML — VoltCam Standard (Flutter + Firebase)

Les diagrammes sont maintenus en Mermaid afin de rester versionnables. Ils décrivent le MVP Flutter/Firebase et conservent les invariants de sécurité de VoltCam.

## 1. Cas d'utilisation

```mermaid
flowchart LR
    subscriber["Abonné volontaire"]
    visitor["Membre de la communauté"]
    admin["Administrateur autorisé"]

    pairDevice["Associer mon boîtier"]
    monitorDevice["Consulter mes mesures"]
    protectMode["Recevoir un conseil Protect Mode"]
    managePrivacy["Gérer mes consentements"]
    browseMap["Consulter la carte agrégée"]
    followZone["Suivre une zone"]
    viewPosts["Lire les messages"]
    aggregateIncident["Confirmer un incident collectif"]
    publishOfficial["Publier une information officielle"]

    subscriber --> pairDevice
    subscriber --> monitorDevice
    subscriber --> protectMode
    subscriber --> managePrivacy
    subscriber --> browseMap
    subscriber --> followZone
    visitor --> browseMap
    visitor --> followZone
    visitor --> viewPosts
    admin --> publishOfficial
    aggregateIncident --> browseMap
```

## 2. Diagramme de composants

```mermaid
flowchart LR
    sensor["Chaîne de mesure isolée"] --> device["Boîtier VoltCam"]
    battery["Batterie de secours"] --> device
    device -->|"BLE GATT"| flutterApp["Application Flutter"]
    flutterApp --> localStore["Stockage local chiffré"]
    flutterApp --> firebaseAuth["Firebase Auth et App Check"]
    flutterApp --> callable["Cloud Functions callable"]
    callable --> firestore["Cloud Firestore"]
    callable --> gridTrust["Moteur GridTrust"]
    gridTrust --> firestore
    gridTrust --> fcm["Firebase Cloud Messaging"]
    firestore --> flutterApp
    fcm --> flutterApp
    maps["Google Maps"] --> flutterApp
    config["Remote Config"] --> flutterApp
    crashlytics["Crashlytics"] <-- flutterApp
    officialSource["Source officielle autorisée"] --> callable
```

## 3. Séquence : coupure confirmée

```mermaid
sequenceDiagram
    participant Device as Boîtier
    participant App as Application Flutter
    participant LocalStore as File locale chiffrée
    participant Auth as Firebase Auth
    participant Function as Cloud Function
    participant Firestore as Cloud Firestore
    participant GridTrust as GridTrust
    participant Fcm as FCM

    Device->>App: "Événement OUTAGE avec dernier souffle"
    App->>LocalStore: "Valider et persister la trame"
    App->>App: "Afficher l'alerte et Protect Mode"
    alt "Réseau indisponible"
        App->>LocalStore: "Conserver le lot en attente"
    else "Réseau disponible et consentement actif"
        App->>Auth: "Obtenir le jeton et App Check"
        App->>Function: "submitSyncBatch avec batchId unique"
        Function->>Firestore: "Vérifier lot et propriété du boîtier"
        Function->>Firestore: "Écrire événements de manière atomique"
        Function->>GridTrust: "Recalculer l'incident de zone"
        GridTrust->>Firestore: "Mettre à jour score et statut"
        GridTrust->>Fcm: "Notifier si incident confirmé"
        Fcm->>App: "Alerte de zone"
    end
```

## 4. Machine à états du boîtier

```mermaid
stateDiagram-v2
    [*] --> Provisioned
    Provisioned --> Online: "Appairage et alimentation valides"
    Online --> Degraded: "Batterie faible ou mesure anormale"
    Degraded --> Online: "Retour dans la plage attendue"
    Online --> LastGasp: "Perte du secteur"
    Degraded --> LastGasp: "Perte du secteur"
    LastGasp --> Offline: "Événement envoyé ou batterie épuisée"
    Offline --> Online: "Alimentation et BLE restaurés"
    Online --> TamperSuspected: "Heartbeat absent sans dernier souffle"
    TamperSuspected --> Online: "Vérification ou connexion restaurée"
```

## 5. Modèle de domaine

```mermaid
classDiagram
    class User {
        +String uid
        +String locale
        +String role
    }
    class Device {
        +String id
        +String ownerUid
        +String status
        +String firmwareVersion
    }
    class Installation {
        +String id
        +String zoneId
        +String status
    }
    class SyncBatch {
        +String id
        +String idempotencyKey
        +String status
    }
    class DeviceEvent {
        +String id
        +String type
        +DateTime occurredAt
        +Boolean lastGasp
    }
    class Incident {
        +String id
        +String zoneId
        +String status
        +Int confidenceScore
    }
    class IncidentEvidence {
        +String id
        +String deviceId
        +DateTime occurredAt
    }
    class GridZone {
        +String id
        +String label
        +String city
    }
    class Consent {
        +String id
        +String scope
        +String status
    }

    User "1" --> "0..*" Device: owns
    User "1" --> "0..*" Consent: grants
    Device "1" --> "0..*" Installation: has
    Device "1" --> "0..*" SyncBatch: submits
    SyncBatch "1" --> "1..*" DeviceEvent: contains
    Installation "1" --> "0..*" DeviceEvent: contextualizes
    GridZone "1" --> "0..*" Installation: groups
    GridZone "1" --> "0..*" Incident: contains
    Incident "1" --> "1..*" IncidentEvidence: has
    DeviceEvent "1" --> "0..1" IncidentEvidence: supports
```

## 6. Déploiement logique

```mermaid
flowchart TB
    subgraph Home["Foyer volontaire"]
        esp32["Boîtier ESP32"]
        flutter["Flutter Android ou iOS"]
        esp32 <-->|"Bluetooth Low Energy"| flutter
    end

    subgraph Firebase["Projet Firebase VoltCam"]
        auth["Authentication"]
        functions["Cloud Functions"]
        firestore["Cloud Firestore"]
        messaging["Cloud Messaging"]
        appCheck["App Check"]
        functions --> firestore
        functions --> messaging
    end

    flutter -->|"HTTPS"| auth
    flutter -->|"HTTPS"| appCheck
    flutter -->|"Callable function"| functions
    firestore --> flutter
    messaging --> flutter
    maps["Google Maps"] --> flutter
```

## 7. Invariants à préserver

- Le client Flutter ne peut pas écrire directement un incident public, une preuve ou un message officiel.
- Un identifiant de lot idempotent ne peut être traité qu'une fois.
- Une preuve d'incident provient d'un boîtier associé à la zone au moment de l'événement.
- Un incident public ne contient aucun identifiant matériel, foyer ou échantillon brut.
- Le retrait de consentement coupe les synchronisations futures de la portée concernée, tout en conservant l'audit minimal requis.
