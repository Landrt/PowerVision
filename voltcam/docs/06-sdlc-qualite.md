# SDLC et qualité — VoltCam Standard (Flutter + Firebase)

## 1. Cycle de vie retenu

VoltCam suit un SDLC itératif. Chaque lot doit conserver la traçabilité entre besoin, décision, code, test et résultat de démonstration.

| Phase | Livrables | Porte de sortie |
| --- | --- | --- |
| Cadrage | Vision, périmètre, risques et parties prenantes | MVP accepté. |
| Exigences | Cahier des charges et critères d'acceptation | Exigences Must validées. |
| Conception | Architecture Flutter/Firebase, UML, Firestore, BLE et sécurité | Revue technique réussie. |
| Construction | Flutter, firmware, Cloud Functions, règles et index Firebase | Code relu et intégré. |
| Vérification | Tests Dart, Flutter, Emulator, fonctions, E2E et UAT | Critères Must réussis. |
| Déploiement | Firebase projet de démo, Remote Config et plan de repli | Démo reproductible. |
| Pilote | Monitoring, support, calibration et retours | Décision de poursuivre, corriger ou arrêter. |

## 2. Responsabilités

| Rôle | Responsabilités |
| --- | --- |
| Product Owner | Priorise le backlog et accepte le résultat visible. |
| Tech Lead | Valide architecture Flutter/Firebase, BLE et décisions de sécurité. |
| Développeur Flutter | UI, BLE, stockage local, Firebase, cartes et tests mobiles. |
| Développeur firmware | Trames, états du boîtier, simulateur et tests de maquette. |
| Développeur Cloud Functions | Fonctions callable, Firestore, GridTrust, FCM et tests Emulator. |
| QA | Plans de test, régression, UAT et traçabilité. |
| Référent sécurité | App Check, règles, données, dépendances et sécurité électrique avec l'expert compétent. |
| Partenaire pilote | Valide zones, communications officielles et conditions terrain. |

## 3. Stratégie de test

| Niveau | Objet | Outil ou exemple |
| --- | --- | --- |
| Unitaire Dart | Règle de risque, parseur BLE, déduplication et score GridTrust | `flutter test` |
| Widget Flutter | Écrans Mon boîtier, Protect Mode, carte et consentement | `flutter test` |
| Intégration Flutter | Offline queue, Firebase Auth, notification et reprise réseau | `integration_test` |
| Cloud Functions | Validation de lot, propriété boîtier, transaction et FCM | Tests TypeScript et Emulator Suite |
| Règles Firestore | UID, rôles, documents publics et écritures interdites | `@firebase/rules-unit-testing` |
| End-to-end | Boîtier simulé → Flutter hors ligne → Function → Firestore → carte | Scénario de démonstration automatisé ou guidé |
| Sécurité | Rejeu, App Check absent, compte non autorisé et fuite de zone | Emulator et revue de payload |
| UAT | Compréhension par un public non technique | Session guidée de testeurs |

## 4. Jeux de tests de référence

| ID | Scénario | Résultat attendu |
| --- | --- | --- |
| T-01 | Appairage d'un boîtier provisionné | L'installation est créée et l'état est affiché. |
| T-02 | Appairage d'un boîtier inconnu | L'opération est refusée et auditée. |
| T-03 | Coupure avec dernier souffle | Événement local, Protect Mode puis synchronisation au retour réseau. |
| T-04 | Heartbeat absent sans dernier souffle | `DEVICE_DISCONNECTED`, sans coupure confirmée. |
| T-05 | Tension instable simulée | Jauge de risque et conseil explicables. |
| T-06 | Redémarrage sans Internet | Les événements en attente restent présents. |
| T-07 | Rejeu de `batchId` | Une seule écriture métier est créée. |
| T-08 | Trois boîtiers d'une zone | Incident `CONFIRMED` et FCM ciblé. |
| T-09 | Événements de deux zones | Incidents séparés, aucune fusion. |
| T-10 | Retrait de consentement carte | Aucun nouvel événement n'alimente la carte. |
| T-11 | Lecture Firestore publique | Aucune adresse, télémétrie brute ou identifiant matériel. |
| T-12 | Écriture directe d'incident | Les règles Firestore la refusent. |
| T-13 | Changement FR/EN | Les écrans critiques restent compréhensibles. |

## 5. Matrice de traçabilité

| Exigences | Conception | Tests minimaux |
| --- | --- | --- |
| FR-01, FR-02 | Flutter `device`, `BleGateway`, stockage local | T-01, T-02 |
| FR-03, FR-04, FR-05 | États boîtier, règles locales et trames | T-03, T-04, T-05 |
| FR-06, FR-07 | File chiffrée, `submitSyncBatch`, `syncBatches` | T-06, T-07 |
| FR-08, FR-14 | Cloud Function GridTrust et `incidents` | T-08, T-09 |
| FR-09, FR-11, FR-18 | GridZone, Firestore rules et consentements | T-10, T-11, T-12 |
| FR-10, FR-12 | FCM, abonnements et publications | Test de notification et modération |
| FR-13 | Module de démonstration Flutter | T-03, T-05, T-08 |
| FR-15, FR-16 | `protect_mode`, score local et Remote Config | T-03, T-05 |
| FR-17 | ARB/i18n Flutter | T-13 |

## 6. Definition of Done

Une fonctionnalité est terminée si :

- l'exigence et le critère d'acceptation sont reliés au ticket ;
- son comportement hors ligne et ses erreurs sont définis ;
- le code est relu ;
- les tests Flutter, Function et règles pertinents passent ;
- les accès Firestore et données personnelles sont revus ;
- aucun secret n'apparaît dans le dépôt, Crashlytics ou Analytics ;
- la documentation et le scénario de démo sont actualisés ;
- le Product Owner valide la valeur visible.

## 7. Qualité de code et CI

| Domaine | Pratique minimale |
| --- | --- |
| Flutter | `dart format`, `flutter analyze`, tests unitaires et widget critiques. |
| Firebase Functions | Lint TypeScript, tests métier et tests Emulator. |
| Firestore | Règles et index versionnés, tests de sécurité avant déploiement. |
| Firmware | Compilation reproductible, parseur de trame testé et version de protocole documentée. |
| CI | Analyse, tests, build Flutter et exécution ciblée des Emulators. |
| Configurations | Séparer développement, démo et pilote ; ne jamais committer les secrets. |

## 8. Critères de passage en démo

- T-03, T-05, T-07, T-08, T-11 et T-12 sont réussis.
- La démonstration reste valable sans Internet initial.
- La carte n'affiche que les documents agrégés autorisés.
- App Check, règles Firestore et Remote Config du projet de démo sont actifs.
- Un simulateur BLE est prêt si le boîtier réel est indisponible.

## 9. Critères de passage en pilote

- Validation indépendante de la sécurité électrique et de la chaîne de mesure.
- Politique de consentement et rétention approuvée.
- Seuils de risque et GridTrust calibrés sur banc et terrain contrôlé.
- Monitoring Firebase, budgets Firestore, sauvegardes et support actifs.
- Accord écrit du partenaire pour zones, messages officiels et données agrégées.
