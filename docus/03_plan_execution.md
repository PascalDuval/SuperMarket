# Plan d'execution - Mission audit architecture donnees

## Contexte retenu
- Le scope est bien celui de la mission "audit architecture donnees" (partie 1 + partie 2).
- Le repository distant [PascalDuval/SuperMarket](https://github.com/PascalDuval/SuperMarket) est vide a date.
- Le travail exploitable est donc celui du workspace local.

## Ordre des notebooks (recommande)
1. `01_construction_base_relationnelle.ipynb`
2. `02_controles_olap_et_logs.ipynb`
3. `03_audit_technique_complet.ipynb`

## Livrables prepares dans ce dossier
- database/sql/01_audit_requetes.sql: requetes de verification (CA, top clients, part employe, anomalies logs).
- database/sql/02_hardening_triggers.sql: triggers de protection et controle de cloture batch.

## Execution rapide (SQLite)
1. Ouvrir la base `database/db/SuperMarketOlap.db`.
2. Executer `database/sql/02_hardening_triggers.sql`.
3. Positionner la cloture batch du 14/08/2024:
   - `UPDATE Batch_Control SET closed_date_excell = '45518' WHERE id = 1;`
4. Executer `database/sql/01_audit_requetes.sql`.

## Resultats attendus (scope)
- Validation du CA du 14/08/2024 proche de 284243.88.
- Identification d'un decalage d'ecriture (ventes du 14/08 ecrites dans les logs du 15/08).
- Blocage des insertions retroactives et des suppressions destructrices via triggers.

## Trame de restitution orale
- Architecture: OLTP -> batch -> OLAP -> Power BI.
- Probleme: instabilite du CA due a un decalage d'ecriture batch.
- Correctifs: transactionnalite, controle FK explicite, cloture quotidienne, anti-retro-insert.
- Gouvernance logs: enrichir avec transaction_id, status, source_system, niveau_droits, timestamp ISO.



