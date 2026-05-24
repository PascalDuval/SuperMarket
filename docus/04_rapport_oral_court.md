# Rapport d'audit - Version orale courte (5 minutes)

## 1. Contexte et architecture
SuperSmartMarket observe une instabilite du chiffre d'affaires historique dans Power BI.
Architecture fonctionnelle:
OLTP (SQL Server) -> batch d'extraction -> cube OLAP (modele en etoile) -> Power BI.
Le perimetre d'audit est le cube OLAP et ses extractions a plat.

## 2. Constat principal
Le CA du 14/08/2024 n'est pas stable selon le moment de consultation.
La verification SQL sur le prototype local confirme un CA de reference autour de 284243.88.
Les logs montrent des insertions de ventes ecrites le 15/08/2024 alors qu'elles concernent des ventes du 14/08/2024.
Conclusion: le decalage d'ecriture batch explique la variation apparente du CA historique.

## 3. Preuves techniques
- Requete de CA sur la table de faits jointe aux produits.
- Requete de croisement entre Faits_Ventes et Logs pour isoler les insertions du 15/08.
- Quantification du nombre de lignes et du CA associe a ces lignes decalees.

## 4. Correctifs proposes (Partie 2)
- Transactions explicites (BEGIN/COMMIT) pour garantir atomicite et coherence.
- Triggers sur Faits_Ventes:
  - verification FK explicite,
  - blocage des insertions retroactives apres cloture.
- Triggers sur dimensions:
  - blocage des suppressions de dimensions deja referencees en faits.
- Table Batch_Control pour materialiser la date de cloture journaliere.

## 5. Benefices attendus
- Stabilite du CA historique (plus de variation a posteriori).
- Prevention des corruptions de referentiel dans le cube OLAP.
- Meilleure auditabilite des traitements quotidiens.

## 6. Recommandations gouvernance logs
Ajouter les champs suivants dans les logs:
- transaction_id
- status (SUCCESS/FAILED)
- source_system
- niveau_droits
- timestamp ISO 8601

## 7. Livrables techniques associes
- docus/01_audit_requetes.sql
- docus/02_hardening_triggers.sql
- docus/03_plan_execution.md
