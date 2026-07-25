# Backlog et plan de livraison — VoltCam Standard (Flutter + Firebase)

## 1. Priorités produit

| Niveau | Objectif | Fonctionnalités |
| --- | --- | --- |
| P0 | Démontrer la chaîne de valeur | Flutter, BLE/simulateur, offline queue, Firebase, GridTrust, carte d'incident et Protect Mode. |
| P1 | Rendre l'expérience convaincante | FCM, couches carte, consentements, messages officiels, FR/EN et jauge de risque. |
| P2 | Préparer le pilote | Pidgin/TTS, modération enrichie, analytics, calibration, Gemini assistif et vues administratives. |

## 2. Lots de réalisation

### Lot 0 — Fondation Flutter et Firebase

- Initialiser le projet Flutter, Riverpod, routing, i18n et thème.
- Configurer Firebase Auth, Firestore, Functions, FCM, App Check, Crashlytics et Emulator Suite.
- Déployer règles Firestore, index et zones de démonstration anonymisées.
- Définir UUID BLE, version de protocole et exemples de trames.

**Sortie :** l'application démarre, Firebase est protégé et les données de démo sont lisibles.

### Lot 1 — Boîtier et expérience locale

- Émettre télémétrie, heartbeat et dernier souffle par BLE.
- Afficher l'état du boîtier dans Flutter.
- Chiffrer la file locale et rejouer coupure, instabilité et restauration.
- Implémenter Protect Mode et le score de risque local explicable.

**Sortie :** le jury voit une anomalie locale et un conseil utile sans Internet.

### Lot 2 — Synchronisation et intelligence collective

- Implémenter `claimDevice` et `submitSyncBatch`.
- Garantir l'idempotence dans `syncBatches`.
- Écrire événements minimisés dans Firestore.
- Implémenter GridTrust et l'incident de zone via Cloud Functions.

**Sortie :** trois sources simulées confirment un incident de zone.

### Lot 3 — Carte, alertes et confiance utilisateur

- Ajouter Google Maps avec couches coupures, instabilité et maintenances.
- Ajouter abonnements de zone, FCM et centre de notifications.
- Ajouter consentements, messages officiels et communauté modérée.
- Finaliser FR/EN et préparer la chaîne Pidgin/TTS.

**Sortie :** une alerte explique la situation, sa confiance et l'action recommandée.

### Lot 4 — Durcissement et démo

- Exécuter tests Flutter, Functions et règles Firestore.
- Contrôler les coûts de lecture/écriture Firestore et la taille des lots.
- Vérifier l'absence de données résidentielles dans les documents publics.
- Préparer script, simulateur, données de secours et plan de repli.

**Sortie :** une démo Firebase reproductible, sûre et crédible.

## 3. Scénario de démonstration recommandé

1. Une mesure locale devient instable ; Protect Mode affiche un risque et une action sûre.
2. Une coupure simulée produit le dernier souffle, sauvegardé hors ligne par Flutter.
3. Le réseau revient ; trois boîtiers de la même zone synchronisent leurs lots.
4. GridTrust confirme l'incident, Firestore actualise la carte et FCM alerte les abonnés.
5. Le jury vérifie que la zone est agrégée et qu'aucune maison n'est exposée.

## 4. Vision post-hackathon

- Couches cartographiques avancées et tendances agrégées.
- Communauté Q&A, réactions, réponses votées et modération renforcée.
- Assistant Gemini bilingue qui explique des données validées, sans prendre de décision critique.
- Tableau de bord partenaire, uniquement après autorisation et modèle de gouvernance.
- Évaluation d'une migration analytique ou relationnelle vers PostgreSQL/Prisma si le pilote dépasse les besoins Firestore.

## 5. Pitch produit en une phrase

> VoltCam transforme une coupure ressentie par un foyer en une information de quartier vérifiée, en un conseil de protection immédiat et en une carte respectueuse de la vie privée — avec Flutter et Firebase, même hors ligne.

## 6. Liste de vérification avant présentation

- Projet Firebase de démonstration configuré avec App Check et règles déployées.
- Boîtier réel chargé ou simulateur BLE prêt.
- Trois sources simulées disponibles pour confirmer un incident.
- Firestore prérempli et réinitialisable.
- Scénario hors ligne vérifié.
- Captures de secours des écrans critiques.
- Aucun écran ne promet lecture de compteur, commande secteur, GSM actif ou détection certaine de fraude.
