# SuperMarket - Audit Architecture Donnees (Projet 4)

## 1. Objectif
Ce depot contient un POC d'audit data pour analyser une instabilite du chiffre d'affaires historique.

Le travail couvre:
- la reconstruction locale d'une base analytique,
- la verification SQL des indicateurs metier,
- l'analyse des logs techniques,
- la proposition de correctifs de robustesse transactionnelle.

## 2. Choix de la solution base de donnees

### 2.1 Moteur retenu: SQLite
Le projet utilise SQLite pour le prototype local.

Justification:
- aucun serveur a installer,
- execution reproductible sur un simple fichier,
- SQL standard et support des transactions/triggers,
- excellent format pour une mission d'audit et de demonstration.

### 2.2 Modele de donnees
Le modele principal est un schema en etoile:
- table de faits: `Faits_Ventes`
- dimensions: `Dim_Clients`, `Dim_Produits`, `Dim_Employe`, `Dim_Calendrier`

Ce modele est adapte aux analyses de CA (total, top clients, part par employe).

### 2.3 Renforcement de robustesse
Le script de hardening ajoute:
- controle FK explicite lors des insertions de faits,
- blocage des insertions retroactives via date de cloture,
- blocage des suppressions destructrices sur dimensions referencees,
- table `Batch_Control` pour piloter la cloture quotidienne.

## 3. Arborescence

### 3.1 Bases et SQL
- `database/db/SuperMarketOlap.db`: base analytique principale
- `database/db/SuperMarket1.db`: base relationnelle/prototype
- `database/sql/SuperMarketOlap.db.sql`: dump SQL de la base OLAP
- `database/sql/SuperMarket1.db.sql`: dump SQL de la base relationnelle
- `database/sql/01_audit_requetes.sql`: requetes d'audit metier et qualite
- `database/sql/02_hardening_triggers.sql`: script de durcissement ACID
- `database/projects/SuperMarketOlap.sqbpro`: projet DB Browser (OLAP)
- `database/projects/SuperMarket1.sqbpro`: projet DB Browser (relationnel)

### 3.2 Donnees CSV
Tous les CSV ont ete centralises dans `data/csv/`:
- dimensions: `Dim_Calendrier.csv`, `Dim_Clients.csv`, `Dim_Employe.csv`, `Dim_Produits.csv`
- faits: `Faits_Ventes.csv`, `Faits_Ventes_valid.csv`, `Faits_Ventes_invalid.csv`
- autres donnees: `Produits.csv`, `PourInsertionBD.csv`, `Logs.csv`, `LogsPourInsert.csv`

### 3.3 Donnees XLSX
Les fichiers Excel de travail ont ete centralises dans `data/xlsx/`:
- `data/xlsx/extraction_cube_olap_14_aout_2024.xlsx`: extraction Excel du cube OLAP
- `data/xlsx/dataset_cours_power_bi.xlsx`: jeu de donnees de reference pour exercices Power BI
- `data/xlsx/dictionnaire_donnees_extraction_16_sept_2025.xlsx`: dictionnaire de donnees au format Excel
- `data/xlsx/logs.xlsx`: version tableur des logs techniques
- `data/xlsx/pour_insertion_bd.xlsx`: version tableur des donnees d'insertion

### 3.4 Notebooks
- `InsertionDBprojet4.ipynb`: creation/chargement de base relationnelle
- `SuperMarketOlap1.ipynb`: analyses SQL et investigation logs
- `SuperMarket2.ipynb`: notebook principal de restitution + audit automatique

### 3.5 Documentation
- `documentation/`: mission, glossaire, schemas, rapport
- `docus/03_plan_execution.md`: mode operatoire rapide
- `docus/04_rapport_oral_court.md`: trame de presentation orale
- `docus/templates/template_support_presentation.pptx`: template de support de presentation

## 4. Installation

### 4.1 Prerequis
- Git
- Python 3.10+
- Jupyter (si execution notebooks)
- DB Browser for SQLite ou `sqlite3` (si execution SQL manuelle)

### 4.2 Clonage
```bash
git clone https://github.com/PascalDuval/SuperMarket.git
cd SuperMarket
```

### 4.3 Environnement Python (optionnel)
```bash
python -m venv .venv
# PowerShell
.\.venv\Scripts\Activate.ps1
pip install jupyter pandas matplotlib
```

### 4.4 Lancer les notebooks
```bash
jupyter notebook
```
Ouvrir ensuite `SuperMarket2.ipynb`.

## 5. Execution des scripts SQL (rigoureuse)

### 5.1 Ordre d'execution recommande
1. Ouvrir `database/db/SuperMarketOlap.db`.
2. Executer `database/sql/02_hardening_triggers.sql`.
3. Initialiser la cloture du 14/08/2024:
   ```sql
   UPDATE Batch_Control SET closed_date_excell = '45518' WHERE id = 1;
   ```
4. Executer `database/sql/01_audit_requetes.sql`.

### 5.2 Ce que fait chaque script

#### `database/sql/02_hardening_triggers.sql`
- Active les foreign keys (`PRAGMA foreign_keys = ON`).
- Cree la table `Batch_Control`.
- Cree les triggers:
  - `trg_check_fk_vente`
  - `trg_block_retroactive_insert`
  - `trg_block_delete_client`
  - `trg_block_delete_produit`
  - `trg_block_delete_employe`
  - `trg_block_delete_date`

Objectif: proteger l'integrite du cube et stabiliser l'historique.

#### `database/sql/01_audit_requetes.sql`
- Calcule le CA du 14/08/2024.
- Quantifie les ventes loguees le 15/08/2024.
- Mesure la valeur des ventes decalees.
- Produit top 10 clients et part du CA par employe.
- Controle la qualite des identifiants utilisateurs dans les logs.

Objectif: produire des preuves SQL de l'anomalie et des indicateurs attendus.

### 5.3 Resultats attendus
- CA du 14/08/2024 autour de `284243.88`.
- Mise en evidence d'un decalage d'ecriture entre date de vente et date de log.
- Blocage effectif des insertions retroactives et suppressions incoherentes.

## 6. Hygiene git
Le fichier `.gitignore` exclut:
- environnements Python locaux (`.venv`, `.venv-1`),
- checkpoints Jupyter,
- archives locales (`docus/archive/`).

## 7. Statut
Le depot est structure pour une remise technique avec:
- organisation claire des artefacts (`database/`, `data/csv/`),
- scripts SQL executables et documentes,
- notebooks alignes sur la nouvelle arborescence,
- documentation de restitution.



