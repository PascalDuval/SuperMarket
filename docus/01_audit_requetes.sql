-- Partie 2 - Requetes d'audit (SQLite)
-- Base cible: SuperMarketOlap.db

-- 1) CA du 14/08/2024 dans le cube OLAP (date Excel 45518)
SELECT ROUND(SUM(p.prix), 2) AS ca_14_08_2024
FROM Faits_Ventes v
JOIN Dim_Produits p ON p.EAN = v.EAN
WHERE v.Date_Achat = '45518';

-- 2) Nombre de ventes inserees le 15/08/2024 selon logs
-- Hypothese: date_ecriture/date = 45519 correspond au 15/08/2024.
SELECT COUNT(DISTINCT id_ligne) AS nb_ventes_log_15_08
FROM Logs
WHERE table_insert = 'Ventes'
  AND operation = 'INSERT'
  AND date = 45519;

-- 3) Valeur de ces ventes loguees le 15/08/2024
SELECT ROUND(SUM(p.prix), 2) AS ca_ventes_log_15_08
FROM Faits_Ventes v
JOIN Dim_Produits p ON p.EAN = v.EAN
JOIN (
    SELECT DISTINCT id_ligne
    FROM Logs
    WHERE table_insert = 'Ventes'
      AND operation = 'INSERT'
      AND date = 45519
) l ON l.id_ligne = v.ID_BDD;

-- 4) Controle de coherence: repartition des ventes du 14/08/2024
-- selon la date d'ecriture log (14 ou 15 aout)
SELECT
    lg.date AS date_log_excel,
    COUNT(DISTINCT v.ID_BDD) AS nb_ventes,
    ROUND(SUM(p.prix), 2) AS ca
FROM Faits_Ventes v
JOIN Dim_Produits p ON p.EAN = v.EAN
JOIN Logs lg
  ON lg.id_ligne = v.ID_BDD
 AND lg.table_insert = 'Ventes'
 AND lg.operation = 'INSERT'
WHERE v.Date_Achat = '45518'
GROUP BY lg.date
ORDER BY lg.date;

-- 5) Top 10 clients par CA (scope initial)
SELECT
    v.CUSTOMER_ID,
    ROUND(SUM(p.prix), 2) AS ca_client
FROM Faits_Ventes v
JOIN Dim_Produits p ON p.EAN = v.EAN
GROUP BY v.CUSTOMER_ID
ORDER BY ca_client DESC
LIMIT 10;

-- 6) Part du CA par employe (scope initial)
SELECT
    e.id_employe,
    e.prenom || ' ' || e.nom AS employe,
    ROUND(SUM(p.prix), 2) AS ca_employe,
    ROUND(100.0 * SUM(p.prix) / (SELECT SUM(p2.prix)
                                 FROM Faits_Ventes v2
                                 JOIN Dim_Produits p2 ON p2.EAN = v2.EAN), 2) AS pct_ca
FROM Faits_Ventes v
JOIN Dim_Produits p ON p.EAN = v.EAN
JOIN Dim_Employe e ON e.id_employe = v.id_employe
GROUP BY e.id_employe, e.prenom, e.nom
ORDER BY ca_employe DESC;

-- 7) Qualite des logs: ids utilisateur non conformes (non hex MD5 32)
SELECT COUNT(*) AS nb_ids_user_invalides
FROM Logs
WHERE id_user NOT GLOB '[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]';
