# Sécurité et confidentialité — VoltCam Standard (Flutter + Firebase)

## 1. Objectifs

VoltCam gère des informations sensibles sur l'état électrique d'un foyer. La sécurité doit protéger les personnes, le boîtier, le compte et la qualité de l'information collective.

Les priorités sont de ne jamais créer de risque électrique, de ne pas exposer un foyer sur la carte, de bloquer les écritures malveillantes et de garder toutes les alertes explicables.

## 2. Frontières de confiance

| Zone | Risque principal | Contrôle |
| --- | --- | --- |
| Boîtier et mesure | Matériel exposé, données falsifiées | Isolation, provisionnement, heartbeat et contrôle d'intégrité des trames. |
| BLE | Interception ou boîtier non reconnu | Appairage sécurisé, identifiant provisionné et validation de protocole. |
| Application Flutter | Téléphone perdu ou application modifiée | Stockage chiffré, clé protégée par Keystore/Keychain et session Firebase. |
| Internet | Rejeu, interception ou surcharge | HTTPS, App Check, lots idempotents et limites de taille. |
| Firebase | Écriture ou lecture non autorisée | Auth, règles Firestore, Cloud Functions serveur et journal d'audit. |
| Carte et communauté | Réidentification ou désinformation | GridZone, agrégation minimale, modération et source visible. |

## 3. Contrôles Firebase obligatoires

### 3.1 Authentification et autorisation

- Utiliser Firebase Authentication pour toute opération cloud ; un compte anonyme peut être amélioré plus tard vers une authentification persistante.
- Associer le rôle administrateur à des custom claims émises uniquement par un environnement serveur autorisé.
- Activer Firebase App Check pour Firestore et Cloud Functions avant toute démonstration publique.
- Réserver les écritures d'incident, preuves, appareils, consentements et contenus officiels aux Cloud Functions avec Admin SDK.
- Déployer les règles présentes dans `firebase/firestore.rules` et les tester avec Firebase Emulator Suite.

### 3.2 Application Flutter

- Stocker les clés locales avec `flutter_secure_storage`, qui s'appuie sur Android Keystore et iOS Keychain.
- Chiffrer la file locale d'événements et séparer celle-ci du cache Firestore.
- Protéger les écrans sensibles de la capture lorsque le mode confidentialité est activé.
- Demander les permissions Bluetooth, notifications et carte au moment utile avec une explication simple.
- Ne demander aucune position GPS précise pour le fonctionnement normal.
- Ne pas supprimer un lot local avant la réponse idempotente de `submitSyncBatch`.

### 3.3 Cloud Functions et Firestore

- Vérifier le jeton Auth, App Check, consentement, propriétaire du boîtier et statut d'installation à chaque `submitSyncBatch`.
- Créer un document de lot dont l'identifiant est le `batchId` afin de rendre l'idempotence vérifiable.
- Encadrer les transactions Firestore par des limites strictes de nombre d'événements et de taille de payload.
- Écrire uniquement des résumés et événements utiles ; ne jamais verser un flux de télémétrie à haute fréquence dans Firestore.
- Journaliser les changements d'association, consentement, rôle et publication officielle sans secret ni donnée inutile.
- Restreindre les clés Google Maps par application, plateforme et API autorisée.

## 4. Menaces et réponses

| Menace | Conséquence | Réponse |
| --- | --- | --- |
| Mesure secteur non isolée | Danger matériel ou humain | Maquette basse tension ou chaîne isolée validée ; aucune commande du secteur. |
| Rejeu de lot | Incidents dupliqués | `batchId`, empreinte de charge et transaction Cloud Function. |
| Client modifié | Fausses écritures publiques | App Check, règles sans écriture directe et logique serveur. |
| Faux boîtier BLE | Fausses alertes | Provisionnement, appairage sécurisé et validation d'identifiant. |
| Carte trop précise | Identification d'un foyer | Zone préconfigurée, seuil minimal de sources et aucun GPS résidentiel. |
| Message trompeur | Panique ou désinformation | Publication `PENDING`, modération et badge officiel. |
| Compte compromis | Accès aux préférences | Session courte, révocation et contrôle d'accès par UID. |
| Coût Firestore excessif | Dépassement de budget | Event-first, pagination, index et métriques de lecture/écriture. |
| IA erronée | Mauvais conseil | Gemini uniquement post-hackathon et limité à la reformulation validée. |

## 5. Consentements séparés

| Portée | Choix utilisateur | Effet du refus |
| --- | --- | --- |
| `TELEMETRY_SYNC` | Autoriser l'envoi différé de résumés et événements ? | L'usage local continue, aucune synchronisation concernée. |
| `AGGREGATED_MAP` | Autoriser l'usage agrégé d'événements dans la carte ? | L'événement n'alimente pas la vue publique. |
| `PUSH_NOTIFICATIONS` | Recevoir les alertes de zone ? | Les alertes restent consultables dans l'application. |
| `COMMUNITY_CONTENT` | Publier dans la communauté ? | La publication est désactivée. |

Les consentements sont écrits par `setConsent`, versionnés et auditables. Ils ne sont pas modifiables directement depuis le client Firestore.

## 6. Politique de rétention initiale

| Catégorie | Emplacement | Rétention cible |
| --- | --- | --- |
| Mesures brutes récentes | Stockage local chiffré | 7 jours ou suppression utilisateur. |
| Événements détaillés | Firestore privé | 30 jours lors du MVP. |
| Incidents agrégés | Firestore | 12 mois. |
| Notifications et messages | Firestore | 90 jours par défaut. |
| Consentements et audit | Firestore privé | Durée imposée par la politique pilote. |

## 7. Réponse à un incident de sécurité

1. Détecter et journaliser sans divulguer de données supplémentaires.
2. Désactiver le jeton, App Check, une Function ou un boîtier selon la gravité.
3. Préserver les éléments nécessaires à l'audit dans un accès restreint.
4. Vérifier l'impact sur les incidents et notifications déjà affichés.
5. Corriger puis tester dans Firebase Emulator Suite avant redéploiement.
6. Informer les parties concernées selon la politique du pilote.

## 8. Vérifications avant démo et pilote

- Tests Emulator des règles Firestore : lecture d'autrui, écriture d'incident, modification de rôle et accès non authentifié refusés.
- Tests de Function : rejeu de lot, boîtier non associé, consentement retiré et payload invalide.
- Tests Flutter : fichier local chiffré, reprise réseau et absence de données résidentielles dans la carte.
- Revue des clés API et activation d'App Check.
- Validation matérielle et électrique séparée par une personne qualifiée avant usage hors maquette.
