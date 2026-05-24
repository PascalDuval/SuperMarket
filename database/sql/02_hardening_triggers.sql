-- Partie 2 - Durcissement ACID pour le prototype SQLite
-- Base cible: database/db/SuperMarketOlap.db
-- Remarque: activer les FK sur la session SQLite courante.
PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- Metadonnees de cloture batch (1 ligne max).
CREATE TABLE IF NOT EXISTS Batch_Control (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    closed_date_excell TEXT NOT NULL
);

INSERT OR IGNORE INTO Batch_Control (id, closed_date_excell)
VALUES (1, '0');

-- Trigger de controle supplementaire des FK sur la table de faits.
CREATE TRIGGER IF NOT EXISTS trg_check_fk_vente
BEFORE INSERT ON Faits_Ventes
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN NOT EXISTS (SELECT 1 FROM Dim_Clients c WHERE c.CUSTOMER_ID = NEW.CUSTOMER_ID)
        THEN RAISE(ABORT, 'FK client inexistante')
    END;

    SELECT CASE
        WHEN NOT EXISTS (SELECT 1 FROM Dim_Produits p WHERE p.EAN = NEW.EAN)
        THEN RAISE(ABORT, 'FK produit inexistante')
    END;

    SELECT CASE
        WHEN NOT EXISTS (SELECT 1 FROM Dim_Employe e WHERE e.id_employe = NEW.id_employe)
        THEN RAISE(ABORT, 'FK employe inexistante')
    END;

    SELECT CASE
        WHEN NOT EXISTS (SELECT 1 FROM Dim_Calendrier d WHERE d.date_excell = NEW.Date_Achat)
        THEN RAISE(ABORT, 'FK calendrier inexistante')
    END;
END;

-- Interdit les insertions retroactives anterieures a la date de cloture.
CREATE TRIGGER IF NOT EXISTS trg_block_retroactive_insert
BEFORE INSERT ON Faits_Ventes
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN CAST(NEW.Date_Achat AS INTEGER) < (
            SELECT CAST(closed_date_excell AS INTEGER)
            FROM Batch_Control
            WHERE id = 1
        )
        THEN RAISE(ABORT, 'Insertion retroactive interdite')
    END;
END;

-- Protege les dimensions utilisees par la table de faits.
CREATE TRIGGER IF NOT EXISTS trg_block_delete_client
BEFORE DELETE ON Dim_Clients
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (SELECT 1 FROM Faits_Ventes v WHERE v.CUSTOMER_ID = OLD.CUSTOMER_ID)
        THEN RAISE(ABORT, 'Suppression client interdite: reference en faits')
    END;
END;

CREATE TRIGGER IF NOT EXISTS trg_block_delete_produit
BEFORE DELETE ON Dim_Produits
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (SELECT 1 FROM Faits_Ventes v WHERE v.EAN = OLD.EAN)
        THEN RAISE(ABORT, 'Suppression produit interdite: reference en faits')
    END;
END;

CREATE TRIGGER IF NOT EXISTS trg_block_delete_employe
BEFORE DELETE ON Dim_Employe
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (SELECT 1 FROM Faits_Ventes v WHERE v.id_employe = OLD.id_employe)
        THEN RAISE(ABORT, 'Suppression employe interdite: reference en faits')
    END;
END;

CREATE TRIGGER IF NOT EXISTS trg_block_delete_date
BEFORE DELETE ON Dim_Calendrier
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (SELECT 1 FROM Faits_Ventes v WHERE v.Date_Achat = OLD.date_excell)
        THEN RAISE(ABORT, 'Suppression date interdite: reference en faits')
    END;
END;

COMMIT;

-- Exemple de cloture quotidienne (a executer en fin de batch du jour J):
-- UPDATE Batch_Control SET closed_date_excell = '45518' WHERE id = 1;



