🔝 Retour au [Sommaire](/SOMMAIRE.md)

# Annexe D — Aide-mémoire T-SQL (cheat sheet)

> Mémo condensé des principales commandes T-SQL. Gardez-le ouvert pendant que vous travaillez. Chaque rubrique renvoie au chapitre correspondant pour les détails.

---

## DDL — Définition des objets (ch. 2)

```sql
-- Base
CREATE DATABASE MaBase;
DROP DATABASE MaBase;

-- Table
CREATE TABLE Clients (
    ClientID  INT IDENTITY(1,1) PRIMARY KEY,
    Nom       NVARCHAR(50) NOT NULL,
    Email     NVARCHAR(255) UNIQUE,
    Ville     NVARCHAR(100) DEFAULT N'Paris',
    Age       INT CHECK (Age >= 0)
);

-- Modifier
ALTER TABLE Clients ADD DateNaissance DATE;          -- ajouter colonne
ALTER TABLE Clients ALTER COLUMN Nom NVARCHAR(100);  -- modifier colonne
ALTER TABLE Clients DROP COLUMN DateNaissance;       -- supprimer colonne

-- Clé étrangère
ALTER TABLE Commandes ADD CONSTRAINT FK_Cmd_Cli
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID);

DROP TABLE Clients;        -- supprime table + données
TRUNCATE TABLE Clients;    -- vide la table (rapide, pas de WHERE)
```

---

## DML — Manipulation des données (ch. 2)

```sql
-- Insertion
INSERT INTO Clients (Nom, Email) VALUES (N'Dupont', N'd@x.fr');
INSERT INTO Clients (Nom, Email) VALUES (N'A', N'a@x.fr'), (N'B', N'b@x.fr');  -- multi
INSERT INTO Archive (Nom) SELECT Nom FROM Clients;  -- depuis un SELECT

-- Mise à jour (NE PAS oublier WHERE !)
UPDATE Produits SET PrixUnitaire = PrixUnitaire * 1.1 WHERE CategorieID = 1;

-- Suppression
DELETE FROM Commandes WHERE Statut = N'Annulée';
```

---

## SELECT — Interrogation (ch. 3)

```sql
SELECT col1, col2 AS Alias
FROM Table
WHERE condition
GROUP BY col1
HAVING COUNT(*) > 1
ORDER BY col1 DESC
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;   -- pagination
```

**Ordre LOGIQUE d'exécution** : `FROM` → `WHERE` → `GROUP BY` → `HAVING` → `SELECT` → `ORDER BY`.

```sql
SELECT TOP (5) * FROM Produits ORDER BY PrixUnitaire DESC;  -- 5 premiers
SELECT DISTINCT Ville FROM Clients;                         -- valeurs uniques
```

---

## Filtrage — opérateurs (ch. 3)

```sql
WHERE Prix > 100 AND Stock > 0
WHERE Ville IN (N'Paris', N'Lyon')
WHERE Prix BETWEEN 20 AND 50          -- bornes incluses
WHERE Nom LIKE N'M%'                  -- commence par M  (_ = 1 caractère)
WHERE EmployeID IS NULL               -- jamais "= NULL"
WHERE NOT (Statut = N'Annulée')
```

---

## Agrégation (ch. 3)

```sql
SELECT COUNT(*), SUM(Montant), AVG(Prix), MIN(Prix), MAX(Prix)
FROM Ventes;

SELECT CategorieID, COUNT(*) AS Nb
FROM Produits
GROUP BY CategorieID
HAVING COUNT(*) >= 3;     -- filtre les GROUPES (vs WHERE = lignes)
```

---

## Jointures (ch. 4)

```sql
-- INNER : correspondances des deux côtés
SELECT * FROM A INNER JOIN B ON A.id = B.aid;

-- LEFT : tout A, + B si correspondance (sinon NULL)
SELECT * FROM A LEFT JOIN B ON A.id = B.aid;

-- RIGHT / FULL : symétrique / les deux
-- CROSS : produit cartésien
SELECT * FROM A CROSS JOIN B;

-- Auto-jointure
SELECT e.Nom, m.Nom AS Manager
FROM Employes e LEFT JOIN Employes m ON e.ManagerID = m.EmployeID;
```

---

## Sous-requêtes & CTE (ch. 4)

```sql
-- Sous-requête scalaire
SELECT * FROM Produits WHERE Prix > (SELECT AVG(Prix) FROM Produits);

-- EXISTS (corrélée)
SELECT * FROM Clients c WHERE EXISTS (SELECT 1 FROM Commandes o WHERE o.ClientID = c.ClientID);

-- CTE
WITH CA AS (
    SELECT CommandeID, SUM(Quantite*PrixUnitaire) AS Total
    FROM LignesCommande GROUP BY CommandeID
)
SELECT * FROM CA WHERE Total > 200;

-- CTE récursive
WITH H AS (
    SELECT EmployeID, ManagerID, 1 AS Niveau FROM Employes WHERE ManagerID IS NULL
    UNION ALL
    SELECT e.EmployeID, e.ManagerID, H.Niveau+1 FROM Employes e JOIN H ON e.ManagerID = H.EmployeID
)
SELECT * FROM H;
```

---

## Fonctions de fenêtrage (ch. 4)

```sql
ROW_NUMBER() OVER (PARTITION BY Cat ORDER BY Prix DESC)   -- rang unique
RANK()       OVER (ORDER BY Prix DESC)                    -- rang avec trous
DENSE_RANK() OVER (ORDER BY Prix DESC)                    -- rang sans trous
SUM(Montant) OVER (ORDER BY Date ROWS UNBOUNDED PRECEDING) -- total cumulé
LAG(Prix)    OVER (ORDER BY Date)                         -- valeur précédente
LEAD(Prix)   OVER (ORDER BY Date)                         -- valeur suivante
```

---

## Opérateurs d'ensemble (ch. 4)

```sql
SELECT col FROM A UNION     SELECT col FROM B;  -- fusion sans doublons
SELECT col FROM A UNION ALL SELECT col FROM B;  -- fusion avec doublons
SELECT col FROM A INTERSECT SELECT col FROM B;  -- présents dans les deux
SELECT col FROM A EXCEPT    SELECT col FROM B;  -- dans A mais pas B
```

---

## Fonctions courantes

```sql
-- Chaînes
LEN(s), UPPER(s), LOWER(s), LTRIM(RTRIM(s)), TRIM(s)
SUBSTRING(s, 1, 3), LEFT(s, 3), RIGHT(s, 3)
REPLACE(s, 'a', 'b'), CONCAT(a, ' ', b), FORMAT(x, 'N2')
STRING_AGG(col, ', ')          -- concaténer des lignes

-- Dates
GETDATE(), SYSDATETIME(), CAST(SYSDATETIME() AS DATE)
DATEADD(DAY, 7, d), DATEDIFF(DAY, d1, d2), DATEPART(YEAR, d)
EOMONTH(d), YEAR(d), MONTH(d), DAY(d)

-- Conversion
CAST(x AS INT), CONVERT(NVARCHAR, d, 103), TRY_CAST(x AS INT)

-- NULL
ISNULL(x, 0), COALESCE(a, b, c), NULLIF(a, b)
```

---

## Variables & contrôle de flux (ch. 5)

```sql
DECLARE @x INT = 10;
SET @x = 20;
SELECT @x = COUNT(*) FROM Clients;

IF @x > 0 BEGIN PRINT N'positif'; END ELSE BEGIN PRINT N'zéro'; END

WHILE @x > 0 BEGIN SET @x -= 1; END

SELECT CASE WHEN Prix < 30 THEN N'Éco' ELSE N'Premium' END FROM Produits;
```

---

## Procédures & fonctions (ch. 5)

```sql
-- Procédure
CREATE OR ALTER PROCEDURE usp_Clients @Ville NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Clients WHERE Ville = @Ville;
END;
EXEC usp_Clients @Ville = N'Paris';

-- Fonction scalaire
CREATE OR ALTER FUNCTION fn_TTC(@ht DECIMAL(10,2)) RETURNS DECIMAL(10,2)
AS BEGIN RETURN @ht * 1.20; END;
SELECT dbo.fn_TTC(100);

-- Fonction table inline (privilégiée pour la perf)
CREATE OR ALTER FUNCTION fn_ParCat(@c INT) RETURNS TABLE
AS RETURN (SELECT * FROM Produits WHERE CategorieID = @c);
SELECT * FROM fn_ParCat(1);
```

---

## Transactions & erreurs (ch. 5 & 6)

```sql
BEGIN TRY
    BEGIN TRANSACTION;
        -- ... opérations ...
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT ERROR_MESSAGE();
    THROW;   -- relance l'erreur (moderne) ; RAISERROR = ancien
END CATCH;
```

---

## Index & sauvegarde (ch. 7)

```sql
-- Index
CREATE NONCLUSTERED INDEX IX_Cmd_Client ON Commandes (ClientID);
CREATE NONCLUSTERED INDEX IX_Couvrant ON Produits (CategorieID) INCLUDE (NomProduit, PrixUnitaire);
DROP INDEX IX_Cmd_Client ON Commandes;

-- Sauvegarde / restauration
BACKUP DATABASE MaBase TO DISK = 'C:\b\MaBase.bak' WITH INIT, COMPRESSION, CHECKSUM;
BACKUP LOG MaBase TO DISK = 'C:\b\MaBase.trn';
RESTORE DATABASE MaBase FROM DISK = '...' WITH NORECOVERY, REPLACE;
RESTORE LOG MaBase FROM DISK = '...' WITH RECOVERY;
```

---

## Métadonnées utiles

```sql
SELECT * FROM sys.databases;
SELECT * FROM sys.tables;
SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Clients');
SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('Clients');
EXEC sp_help 'Clients';        -- structure d'un objet
EXEC sp_helpindex 'Clients';   -- index d'une table
SELECT @@VERSION;              -- version du serveur
```

---

⏭️ [Annexe E — Tableau des types de données](/09-annexes/E-types-de-donnees.md)
