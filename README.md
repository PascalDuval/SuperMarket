# SuperMarket - Audit Architecture Donnees (Projet 4)

## 1) Objectif du projet
Ce projet reproduit une mission d'audit data sur un systeme retail.
Le probleme metier est une instabilite du chiffre d'affaires historique dans les reportings.

Le perimetre couvre:
- la reconstruction locale d'un prototype analytique,
- la verification SQL des indicateurs cles,
- l'analyse des logs techniques,
- la proposition de correctifs de robustesse (transactionnalite, triggers, gouvernance logs).

## 2) Solution base de donnees choisie
### Choix technique
La solution retenue est SQLite pour le POC local.

Pourquoi SQLite:
- execution locale simple, sans serveur a installer,
- format fichier unique facile a partager,
- SQL standard suffisant pour l'audit,
- support des transactions et triggers pour simuler des controles ACID.

### Modele de donnees
Le modele principal est un schema en etoile:
- table de faits: Faits_Ventes
- dimensions: Dim_Clients, Dim_Produits, Dim_Employe, Dim_Calendrier

Ce modele est adapte a l'analyse du CA et aux agregations (top clients, part par employe, etc.).

### Correctifs de robustesse (Partie 2)
Un script de hardening ajoute:
- verification FK explicite a l'insertion des faits,
- blocage des insertions retroactives apres cloture,
- blocage des suppressions de dimensions referencees,
- table de controle Batch_Control pour la date de cloture journaliere.

## 3) Arborescence et role des fichiers

### Bases et scripts SQL
- SuperMarketOlap.db: base analytique principale (schema en etoile)
- SuperMarketOlap.db.sql: dump SQL de la base analytique
- SuperMarket1.db: base relationnelle source/prototype
- SuperMarket1.db.sql: dump SQL de la base relationnelle
- SuperMarket1.sqbpro: projet SQLite Browser (SuperMarket1)
- SuperMarketOlap.sqbpro: projet SQLite Browser (SuperMarketOlap)

### Donnees dimensions/faits (CSV)
- Dim_Calendrier.csv: dimension calendrier
- Dim_Clients.csv: dimension clients
- Dim_Employe.csv: dimension employes
- Dim_Produits.csv: dimension produits
- Faits_Ventes.csv: table de faits brute
- Faits_Ventes_valid.csv: faits valides
- Faits_Ventes_invalid.csv: faits invalides
- Produits.csv: extraction produits complete
- PourInsertionBD.csv: donnees preparees pour insertion en base

### Logs
- Logs.csv: logs techniques principaux
- LogsPourInsert.csv: version logs orientee insertion
- Logs.xlsx: logs au format tableur

### Notebooks
- InsertionDBprojet4.ipynb: notebook d'insertion/transformation
- SuperMarketOlap1.ipynb: notebook d'analyse OLAP (Partie 1/2)
- SuperMarket2.ipynb: notebook principal de restitution et audit

### Documentation source
- documentation/Mission-audit-architecture-donnees.pdf: scope de mission
- documentation/structure.pdf: support structure/data
- documentation/Glossaire+des+données.pdf: definitions metier et techniques
- documentation/Rapport+d'audit.docx: rapport d'audit
- documentation/RapportauditRempli.docx: version rapport completee
- documentation/Mission d'audit d'architecture et données.pptx: support mission
- documentation/schemaBD.png: schema base (PNG)
- documentation/schemaBD.svg: schema base (SVG)
- documentation/Schéma+architecture+.jpg: schema architecture

### Livrables d'audit produits dans ce projet
- docus/01_audit_requetes.sql: requetes SQL de verification
- docus/02_hardening_triggers.sql: triggers de durcissement ACID
- docus/03_plan_execution.md: plan d'execution des controles
- docus/04_rapport_oral_court.md: trame orale courte (5 min)

### Fichiers de travail/archives ignores
- docus/archive/: artefacts locaux non versionnes (temp/checkpoints)
- .venv/ et .venv-1/: environnements virtuels locaux

## 4) Installation et execution

### Prerequis
- Git
- Python 3.10+
- Jupyter (optionnel, pour notebooks)
- DB Browser for SQLite ou sqlite3 (optionnel, pour SQL manuel)

### Cloner le projet
```bash
git clone https://github.com/PascalDuval/SuperMarket.git
cd SuperMarket
```

### Configurer l'environnement Python (optionnel notebooks)
```bash
python -m venv .venv
# Windows PowerShell
.\.venv\Scripts\Activate.ps1
pip install jupyter pandas matplotlib
```

### Lancer les notebooks
```bash
jupyter notebook
```
Puis ouvrir SuperMarket2.ipynb.

### Executer l'audit SQL (Partie 2)
1. Ouvrir SuperMarketOlap.db dans SQLite Browser.
2. Executer docus/02_hardening_triggers.sql.
3. Executer:
   UPDATE Batch_Control SET closed_date_excell = '45518' WHERE id = 1;
4. Executer docus/01_audit_requetes.sql.

Resultats attendus:
- CA du 14/08/2024 autour de 284243.88
- mise en evidence du decalage d'ecriture en logs
- blocage des insertions retroactives et suppressions destructrices

## 5) Versioning et hygiene git
Le fichier .gitignore exclut:
- environnements Python locaux,
- checkpoints Jupyter,
- docus/archive (fichiers inutiles au depot).

## 6) Statut
Projet structure pour une remise technique avec:
- preuves SQL,
- correctifs de robustesse,
- documentation d'execution,
- support de restitution orale.
