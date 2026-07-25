# VoltCam — dossier produit et technique

VoltCam transforme les signaux d'un boîtier domestique en alertes de protection compréhensibles et en informations de quartier vérifiées. Le MVP est construit en **Flutter** et **Firebase** pour livrer rapidement une expérience Android, iOS et Web cohérente pendant le hackathon.

## Décision de périmètre

Cette version couvre le **boîtier Standard** chez un abonné volontaire. Le mode Agent Pro, toute lecture ou manipulation de compteur, toute commande du réseau et toute accusation automatique de fraude restent exclus.

## Architecture retenue

- **Mobile** : Flutter/Dart, Riverpod, GoRouter, Bluetooth Low Energy et stockage local chiffré.
- **Firebase** : Authentication, Cloud Firestore, Cloud Functions 2nd gen, Cloud Messaging, App Check, Crashlytics et Remote Config.
- **Cartographie** : Google Maps pour Flutter avec couches d'incidents anonymisées par zone.
- **Règle de données** : seules les mesures résumées et les événements utiles sont synchronisés ; la télémétrie brute fréquente reste locale.
- **Évolution pilote** : le schéma Prisma est conservé uniquement comme projection relationnelle future, sans rôle dans le MVP Firebase.

## Documents

| Document | Contenu |
| --- | --- |
| [Cahier des charges](docs/01-cahier-des-charges.md) | Besoins, priorités, critères d'acceptation et périmètre Flutter/Firebase |
| [Conception technique](docs/02-conception-technique.md) | Architecture Flutter, Firebase, BLE, GridTrust et Protect Mode |
| [UML](docs/03-uml.md) | Cas d'utilisation, composants, séquences, états et classes |
| [Contrats Firebase et BLE](docs/04-api-et-ble.md) | Cloud Functions, synchronisation, Firestore et protocole BLE |
| [Sécurité et confidentialité](docs/05-securite-confidentialite.md) | App Check, règles Firestore, consentement et rétention |
| [SDLC et qualité](docs/06-sdlc-qualite.md) | Cycle de vie, tests Flutter/Firebase, jalons et traçabilité |
| [Backlog et livraison](docs/07-backlog-et-livraison.md) | MVP, lots de réalisation et scénario de démonstration |
| [Modèle Firestore](docs/08-modele-firestore.md) | Collections, invariants et politique de synchronisation |
| [Règles Firestore](firebase/firestore.rules) | Contrôle d'accès client Firebase |
| [Index Firestore](firebase/firestore.indexes.json) | Requêtes composées du MVP |
| [Prisma post-pilote](prisma/schema.prisma) | Projection relationnelle optionnelle après le hackathon |

## Règle de sécurité matérielle

Le boîtier de démonstration est testé sur une maquette basse tension ou avec une chaîne de mesure isolée validée par une personne qualifiée. Il ne pilote jamais le secteur et un INA226 seul ne constitue pas une mesure directe sécurisée du 220 V alternatif.
