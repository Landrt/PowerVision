# Prisma — option post-pilote

Le MVP VoltCam utilise **Flutter + Firebase**. Ce dossier ne fait pas partie du déploiement hackathon et aucune migration Prisma ne doit être exécutée pour la démonstration.

Le schéma `schema.prisma` est conservé comme projection relationnelle pour une phase pilote ultérieure, lorsque les besoins d'analyse, de contraintes relationnelles ou d'intégration institutionnelle justifieront une architecture PostgreSQL distincte.

## Décision d'usage

- **Hackathon** : Cloud Firestore, Cloud Functions et le modèle décrit dans `../docs/08-modele-firestore.md` font autorité.
- **Post-pilote** : évaluer une synchronisation Firestore → BigQuery/PostgreSQL ou une migration progressive, après étude de gouvernance et de coûts.
- **Jamais** : utiliser les deux bases comme sources de vérité concurrentes.

Avant toute adoption de Prisma, revoir le modèle Firestore réel, les règles de conservation, les exigences du partenaire et la stratégie de migration.
