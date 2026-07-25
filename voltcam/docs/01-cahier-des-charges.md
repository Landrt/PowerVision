# Cahier des charges — VoltCam Standard (Flutter + Firebase)

## 1. Objet du projet

VoltCam aide les abonnés à comprendre la disponibilité et la qualité de leur alimentation électrique. Un boîtier domestique transmet des signaux à une application **Flutter** par Bluetooth Low Energy (BLE). L'application continue de fonctionner hors ligne puis synchronise, avec consentement, des événements minimisés vers **Firebase**. Plusieurs signaux indépendants permettent de confirmer un incident par zone sans révéler l'adresse d'un foyer.

Le MVP associe trois promesses : information collective fiable, protection pratique des appareils et expérience mobile inclusive.

## 2. Vision produit

> VoltCam transforme une anomalie électrique ressentie par un foyer en une information de quartier vérifiée, explicable et respectueuse de la vie privée, même lorsque la connexion Internet manque.

## 3. Périmètre du hackathon

### 3.1 Inclus

- Application Flutter Android, iOS et Web avec une architecture de fonctionnalités partagée.
- Appairage BLE sécurisé avec le boîtier Standard et affichage local des mesures disponibles.
- Stockage local chiffré, file de synchronisation et reprise réseau contrôlée.
- Firebase Authentication, Cloud Firestore, Cloud Functions, Firebase Cloud Messaging, App Check, Crashlytics et Remote Config.
- Détection de coupure, retour du courant, instabilité de tension et déconnexion suspecte.
- Événement de dernier souffle avant extinction lorsque la batterie de secours le permet.
- GridTrust : confirmation collective par zone, fenêtre de temps et score de confiance explicable.
- Google Maps avec couches MVP : coupures confirmées, instabilité et maintenances publiées.
- Protect Mode : conseil de protection d'appareils et jauge de risque lisible.
- Messages officiels et communautaires clairement distingués.
- Français et anglais dans le MVP ; Pidgin et lecture audio préparés comme extension accessible.
- Mode démo qui rejoue des scénarios BLE sans manipulation du réseau secteur.

### 3.2 Exclus

- Mode Agent Pro et toute lecture, écriture ou action sur un compteur.
- Commande du secteur, reconfiguration réseau ou intégration SCADA réelle.
- Accusation, sanction ou identification automatique de fraude.
- Localisation précise d'un foyer ou affichage public de consommation individuelle.
- Réseau social complet, assistant Gemini conversationnel, Q&A et tableau de dispatch : phases post-hackathon.
- Synchronisation de télémétrie brute à haute fréquence dans Firestore.

## 4. Parties prenantes

| Partie prenante | Besoin principal |
| --- | --- |
| Abonné volontaire | Comprendre une coupure, protéger ses appareils et décider quoi faire. |
| Communauté locale | Savoir si une anomalie est collective sans exposer les foyers. |
| Équipe VoltCam | Démontrer une chaîne fiable et reproductible dans un temps de hackathon. |
| Partenaire pilote autorisé | Publier des maintenances et exploiter des informations agrégées. |
| Référent sécurité et protection des données | Revoir le matériel, les consentements et les accès avant pilote. |

## 5. Exigences fonctionnelles

| ID | Exigence | Priorité | Critère d'acceptation |
| --- | --- | --- | --- |
| FR-01 | L'utilisateur associe un boîtier VoltCam depuis l'application Flutter. | Must | L'appairage crée une installation active et affiche l'état du boîtier. |
| FR-02 | L'application affiche la dernière mesure BLE localement. | Must | Tension, courant, puissance, batterie et horodatage sont visibles moins de 2 s après réception. |
| FR-03 | Le boîtier signale une perte d'alimentation. | Must | Une coupure simulée crée un événement `OUTAGE` local. |
| FR-04 | Le système distingue dernier souffle et déconnexion suspecte. | Must | L'absence de heartbeat sans dernier souffle produit `DEVICE_DISCONNECTED`. |
| FR-05 | L'application identifie une instabilité à partir de seuils et d'une fenêtre glissante. | Must | La fiche d'événement explique les valeurs et la durée observées. |
| FR-06 | Les données utiles restent disponibles hors ligne. | Must | Après redémarrage, les événements en attente sont toujours présents. |
| FR-07 | Le téléphone synchronise un lot idempotent via Cloud Functions. | Must | Le renvoi d'un même lot ne crée pas de doublon Firestore. |
| FR-08 | GridTrust regroupe des événements similaires par zone et fenêtre de temps. | Must | Trois boîtiers indépendants en dix minutes peuvent confirmer un incident. |
| FR-09 | La carte affiche des zones agrégées et des couches d'incidents. | Must | Aucune adresse, coordonnée résidentielle ou identité de boîtier n'est visible. |
| FR-10 | L'utilisateur reçoit des alertes de zone pertinentes. | Should | Une notification FCM ouvre la fiche d'incident et son conseil associé. |
| FR-11 | L'utilisateur gère ses consentements et zones suivies. | Must | Le retrait empêche les nouvelles synchronisations concernées et est audité. |
| FR-12 | Les messages officiels et communautaires sont séparés. | Should | La source, le statut et la date sont visibles. |
| FR-13 | Le mode démo simule coupure, instabilité et restauration. | Must | L'équipe peut jouer les trois scénarios sans réseau secteur. |
| FR-14 | Chaque incident présente une confiance explicable. | Must | Le nombre de boîtiers, la fenêtre temporelle et le motif de confirmation sont visibles. |
| FR-15 | Protect Mode fournit une recommandation claire en cas de tension risquée. | Should | L'utilisateur voit une action non dangereuse adaptée aux appareils sensibles. |
| FR-16 | L'application expose une jauge de risque local lisible. | Should | Le score 0–100 est accompagné des facteurs qui le font évoluer. |
| FR-17 | L'interface est prête pour FR/EN et l'extension Pidgin/TTS. | Should | Aucun texte utilisateur critique n'est codé en dur dans l'interface. |
| FR-18 | Les écritures sensibles passent par des Cloud Functions protégées. | Must | Le client ne peut pas créer un incident public ni modifier le statut d'un incident. |

## 6. Règles métier

1. Un événement de coupure seul reste `PENDING` tant qu'il n'est pas recoupé ou enrichi d'une source officielle autorisée.
2. Un incident passe à `CONFIRMED` après confirmation par plusieurs boîtiers indépendants et cohérents dans le temps.
3. `TAMPER_SUSPECTED` et `ANOMALY_DETECTED` restent privés et ne constituent jamais une accusation de fraude.
4. Firestore stocke les événements et résumés nécessaires ; les échantillons bruts fréquents restent dans la mémoire locale du téléphone.
5. Seules les Cloud Functions écrivent les incidents publics, leurs scores et les messages officiels.
6. Toute donnée de carte est agrégée à une `GridZone`, jamais à une habitation.
7. Gemini, s'il est activé après le hackathon, peut reformuler une information validée mais ne prend aucune décision de sécurité ou d'exploitation.

## 7. Exigences non fonctionnelles

| Domaine | Exigence |
| --- | --- |
| Portabilité | Une base Flutter commune cible Android, iOS et Web ; le BLE est activé seulement sur les plateformes compatibles. |
| Hors ligne | L'interface locale et la file de synchronisation restent disponibles sans Internet. |
| Latence locale | Une mesure BLE validée est visible en moins de 2 secondes dans 95 % des essais de démonstration. |
| Latence cloud | Après retour du réseau, un lot valide est pris en compte en moins de 10 secondes dans 95 % des essais. |
| Fiabilité | Les doublons, reprises, événements hors ordre et fermetures d'application sont gérés. |
| Sécurité | Authentification Firebase, App Check, règles Firestore, rôles et fonctions serveur pour les mutations critiques. |
| Confidentialité | Données publiques limitées à une zone et à un agrégat ; consentements séparés et auditables. |
| Coût Firebase | Aucune télémétrie continue dans Firestore ; pagination, index et limites de lot obligatoires. |
| Accessibilité | Contraste, langage simple, retours haptique/sonore et préparation multilingue. |
| Sécurité électrique | Aucun contrôle du secteur ; chaîne de mesure isolée et essais sûrs. |

## 8. Données et rétention

| Donnée | Destination MVP | Visibilité | Rétention cible |
| --- | --- | --- | --- |
| Mesures brutes fréquentes | Stockage local chiffré | Privée | 7 jours ou suppression utilisateur |
| Résumés et événements | Firestore | Privée ou agrégée | 30 jours pour événements détaillés |
| Incidents de zone | Firestore | Agrégée | 12 mois |
| Consentements et audit | Firestore | Privée | Durée du pilote selon politique |
| Notifications et messages | Firestore | Selon cible | 90 jours par défaut |

## 9. Dépendances et risques

| Risque | Réponse |
| --- | --- |
| Mesure secteur non isolée | Maquette basse tension pour la démo et validation matérielle qualifiée avant pilote. |
| Faux positifs | Score explicable, statut initial `PENDING` et confirmation multi-boîtiers. |
| Coûts Firestore élevés | Événements et agrégats seulement, pas de flux de mesures brutes. |
| Écriture client malveillante | App Check, règles Firestore restrictives et Cloud Functions pour les opérations critiques. |
| BLE instable selon plateforme | Abstraction `BleGateway`, tests sur ESP32 et plan de repli avec simulateur. |
| Absence de données opérateur | Ne jamais promettre une distinction certaine panne/délestage. |

## 10. Mesures de succès

- Trois scénarios de bout en bout sont démontrables : coupure confirmée, tension instable et déconnexion suspecte.
- Trois sources indépendantes peuvent faire évoluer un incident `PENDING` vers `CONFIRMED`.
- Protect Mode produit un conseil sûr et compréhensible.
- La carte ne révèle aucune donnée résidentielle.
- Tous les critères Must passent dans la suite de tests de démonstration.
