# SuperMarket - Audit Architecture Donnees

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

### 3.4 Notebooks (ordre recommande)
- `01_construction_base_relationnelle.ipynb`: construit et alimente la base relationnelle `database/db/SuperMarket1.db` depuis Excel.
- `02_controles_olap_et_logs.ipynb`: controle la qualite des faits OLAP, produit les requetes d'analyse et investigue les logs.
- `03_audit_technique_complet.ipynb`: notebook principal, combine insertion/controle/restitution et audit Partie 2 automatise.

### 3.5 Documentation
- `documentation/`: mission, glossaire, schemas, rapport
- `docus/03_plan_execution.md`: mode operatoire rapide
- `docus/04_rapport_oral_court.md`: trame de presentation orale
- `docus/templates/template_support_presentation.pptx`: template de support de presentation

### 3.6 Schema de donnees de reference
- `documentation/schemaBD.png`: schema visuel de reference du modele de donnees utilise.
- Le fichier SVG n'est pas necessaire pour l'execution du projet.

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

### 4.3 Installer SQLite (sqlite3)

#### Windows
1. Telecharger les binaires SQLite depuis le site officiel:
  https://www.sqlite.org/download.html
2. Prendre le package `sqlite-tools-win-x64-*.zip`.
3. Dezipper dans un dossier (exemple: `C:\sqlite`).
4. Ajouter ce dossier au `PATH` Windows.
5. Verifier:
  ```bash
  sqlite3 --version
  ```

Alternative Windows: installer `DB Browser for SQLite` (interface graphique) depuis:
https://sqlitebrowser.org/

#### macOS
SQLite est generalement preinstalle. Verifier:
```bash
sqlite3 --version
```
Si absent:
```bash
brew install sqlite
```

#### Linux (Debian/Ubuntu)
```bash
sudo apt update
sudo apt install sqlite3
sqlite3 --version
```

### 4.4 Initialiser les bases selon le modele (schema PNG)
Le schema de reference est dans `documentation/schemaBD.png`.

Objectif:
- base relationnelle: `database/db/SuperMarket1.db`
- base analytique: `database/db/SuperMarketOlap.db`

Option A (rapide, recommande): restaurer depuis les dumps SQL
```bash
sqlite3 database/db/SuperMarket1.db ".read database/sql/SuperMarket1.db.sql"
sqlite3 database/db/SuperMarketOlap.db ".read database/sql/SuperMarketOlap.db.sql"
```

Option B (via notebooks):
1. Executer `01_construction_base_relationnelle.ipynb` pour construire/remplir la base relationnelle.
2. Executer `02_controles_olap_et_logs.ipynb` pour les controles OLAP et validations.
3. Executer `03_audit_technique_complet.ipynb` pour l'audit final.

Verification rapide des tables OLAP:
```bash
sqlite3 database/db/SuperMarketOlap.db ".tables"
```
Vous devez voir au minimum: `Dim_Calendrier`, `Dim_Clients`, `Dim_Employe`, `Dim_Produits`, `Faits_Ventes`.

### 4.5 Environnement Python (optionnel)
```bash
python -m venv .venv
# PowerShell
.\.venv\Scripts\Activate.ps1
pip install jupyter pandas matplotlib
```

### 4.6 Lancer les notebooks
```bash
jupyter notebook
```
Ouvrir ensuite les notebooks dans l'ordre 01 -> 02 -> 03.

Configuration du noyau Jupyter (important):
1. Ouvrir le notebook dans VS Code ou Jupyter.
2. Selectionner le kernel Python du projet (`.venv` ou environnement Conda choisi).
3. Verifier en cellule:
  ```python
  import sys
  print(sys.executable)
  ```
4. Le chemin affiche doit pointer vers l'environnement attendu (et non le Python systeme).
5. Si le mauvais noyau est selectionne, les imports/packages peuvent echouer.

## 5. Logique d'execution des notebooks

### 5.1 Pourquoi un ordre est necessaire
Le projet manipule plusieurs couches:
- couche relationnelle (`SuperMarket1.db`) pour l'ingestion/normalisation,
- couche analytique (`SuperMarketOlap.db`) pour les controles CA et l'audit logs.

Un ordre non maitrise peut produire des erreurs (table absente, chemins de donnees incorrects, controles lances sans preconditions).

### 5.2 Ordre strict conseille
1. `01_construction_base_relationnelle.ipynb`
2. `02_controles_olap_et_logs.ipynb`
3. `03_audit_technique_complet.ipynb`

### 5.3 Role exact de chaque notebook

#### `01_construction_base_relationnelle.ipynb`
- ouvre `database/db/SuperMarket1.db`,
- cree/verifie les tables `Produits`, `Clients`, `Employé`, `Vente Détail`,
- charge `data/xlsx/pour_insertion_bd.xlsx`,
- convertit les dates Excel en ISO,
- insere les donnees et verifie les volumes + controles FK.

Fonctions cles:
- `excel_to_iso`: conversion serie Excel / formats texte -> `YYYY-MM-DD`.
- `clean_text`: normalisation des champs texte.
- `count_rows`: verification des volumes charges.

#### `02_controles_olap_et_logs.ipynb`
- ouvre `database/db/SuperMarketOlap.db`,
- charge `data/csv/Faits_Ventes.csv`,
- verifie les correspondances entre faits et dimensions,
- separe faits valides/invalides,
- execute les requetes metier (CA 14/08, top 10 clients, part employe),
- analyse les logs (`data/csv/Logs.csv`, `data/xlsx/logs.xlsx`) pour expliquer l'instabilite du CA.

#### `03_audit_technique_complet.ipynb`
- reprend un flux complet de restitution,
- applique un audit automatique Partie 2,
- copie `database/db/SuperMarketOlap.db` vers une base de travail,
- applique `database/sql/02_hardening_triggers.sql`,
- execute les controles de blocage (retro-insert, suppression dimension) et les KPI d'audit.

Fonctions utilitaires importantes:
- `excel_to_iso`, `clean_text`, `is_valid_iso_date`: qualite des donnees en entree.
- `insert_valid_rows`: encapsule l'insertion securisee avec messages d'erreur.

### 5.4 Proposition de tests (et observations attendues)

Test A - Construction relationnelle (`01_construction_base_relationnelle.ipynb`)
- Action: executer toutes les cellules du notebook 01.
- A observer:
  - creation/verification des tables sans erreur,
  - insertion des donnees avec volumes > 0,
  - controle FK sans anomalies majeures.

Test B - Controles OLAP (`02_controles_olap_et_logs.ipynb`)
- Action: executer les cellules de controle des faits/dimensions puis les requetes metier.
- A observer:
  - separation correcte des faits valides/invalides,
  - CA du 14/08/2024 autour de 284243.88,
  - tableaux Top 10 clients et part par employe coherents.

Test C - Investigation logs (`02_controles_olap_et_logs.ipynb`)
- Action: executer les cellules d'analyse logs CSV/XLSX.
- A observer:
  - presence d'un decalage entre date d'ecriture et date de vente,
  - explication de l'instabilite du CA historique.

Test D - Robustesse triggers (`03_audit_technique_complet.ipynb`)
- Action: executer la section Partie 2 (copie base + hardening + tests blocage).
- A observer:
  - blocage insertion retroactive = OK,
  - blocage suppression dimension referencee = OK,
  - KPI audit affiches sans erreur SQL.

## 6. Execution des scripts SQL (rigoureuse)

### 6.1 Ordre d'execution recommande
1. Ouvrir `database/db/SuperMarketOlap.db`.
2. Executer `database/sql/02_hardening_triggers.sql`.
3. Initialiser la cloture du 14/08/2024:
   ```sql
   UPDATE Batch_Control SET closed_date_excell = '45518' WHERE id = 1;
   ```
4. Executer `database/sql/01_audit_requetes.sql`.

### 6.2 Ce que fait chaque script

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

### 6.3 Resultats attendus
- CA du 14/08/2024 autour de `284243.88`.
- Mise en evidence d'un decalage d'ecriture entre date de vente et date de log.
- Blocage effectif des insertions retroactives et suppressions incoherentes.

## 7. Hygiene git
Le fichier `.gitignore` exclut:
- environnements Python locaux (`.venv`, `.venv-1`),
- checkpoints Jupyter,
- archives locales (`docus/archive/`).

## 8. Statut
Le depot est structure pour une remise technique avec:
- organisation claire des artefacts (`database/`, `data/csv/`),
- scripts SQL executables et documentes,
- notebooks alignes sur la nouvelle arborescence,
- documentation de restitution.



