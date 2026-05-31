🔝 Retour au [Sommaire](/SOMMAIRE.md)

# C.5 — Exercices du chapitre 5 : Programmabilité en T-SQL

Variables, structures de contrôle, vues, procédures, fonctions et triggers, sur la base `Boutique`.

---

## Exercice 5.1 ⭐ — Variables

📝 **Énoncé** : Déclarez une variable contenant le prix moyen des produits et affichez-la avec un message.

✅ **Corrigé** :
```sql
DECLARE @prixMoyen DECIMAL(10,2);
SELECT @prixMoyen = AVG(PrixUnitaire) FROM Produits;
PRINT N'Prix moyen : ' + CAST(@prixMoyen AS NVARCHAR(20)) + N' €';
```

🧠 **Explication** : `DECLARE` crée la variable, `SELECT @var = ...` l'assigne depuis une requête. On convertit en texte pour la concaténer (voir §5.1.1).

---

## Exercice 5.2 ⭐⭐ — IF / ELSE

📝 **Énoncé** : Affichez « Catalogue fourni » s'il y a plus de 10 produits, sinon « Petit catalogue ».

✅ **Corrigé** :
```sql
IF (SELECT COUNT(*) FROM Produits) > 10
    PRINT N'Catalogue fourni';
ELSE
    PRINT N'Petit catalogue';
```

🧠 **Explication** : `IF ... ELSE` exécute conditionnellement. Pour plusieurs instructions, on les encadre par `BEGIN ... END` (voir §5.2.1, §5.2.2).

---

## Exercice 5.3 ⭐⭐ — CASE

📝 **Énoncé** : Affichez chaque produit avec une étiquette de gamme : « Économique » (< 30 €), « Standard » (30–150 €), « Premium » (> 150 €).

✅ **Corrigé** :
```sql
SELECT
    NomProduit,
    PrixUnitaire,
    CASE
        WHEN PrixUnitaire < 30  THEN N'Économique'
        WHEN PrixUnitaire <= 150 THEN N'Standard'
        ELSE N'Premium'
    END AS Gamme
FROM Produits;
```

🧠 **Explication** : le `CASE` « searched » évalue les conditions dans l'ordre et renvoie la première vraie (voir §5.2.4).

---

## Exercice 5.4 ⭐⭐ — Vue

📝 **Énoncé** : Créez une vue `v_DetailCommandes` exposant, pour chaque ligne de commande : le n° de commande, le client, le produit, la quantité et le montant de ligne.

✅ **Corrigé** :
```sql
CREATE VIEW v_DetailCommandes AS
SELECT
    cmd.CommandeID,
    cl.Nom + ' ' + cl.Prenom    AS Client,
    p.NomProduit,
    l.Quantite,
    l.Quantite * l.PrixUnitaire AS MontantLigne
FROM Commandes      AS cmd
JOIN Clients        AS cl ON cl.ClientID  = cmd.ClientID
JOIN LignesCommande AS l  ON l.CommandeID = cmd.CommandeID
JOIN Produits       AS p  ON p.ProduitID  = l.ProduitID;
GO
-- Utilisation :
SELECT * FROM v_DetailCommandes WHERE CommandeID = 1;
```

🧠 **Explication** : une **vue** encapsule une requête complexe sous un nom simple, réutilisable comme une table (voir §5.4).

---

## Exercice 5.5 ⭐⭐⭐ — Procédure stockée avec paramètre

📝 **Énoncé** : Créez une procédure `usp_CommandesParClient` qui prend un `@ClientID` et renvoie ses commandes.

✅ **Corrigé** :
```sql
CREATE OR ALTER PROCEDURE usp_CommandesParClient
    @ClientID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CommandeID, DateCommande, Statut
    FROM Commandes
    WHERE ClientID = @ClientID
    ORDER BY DateCommande DESC;
END;
GO
-- Exécution :
EXEC usp_CommandesParClient @ClientID = 1;
```

🧠 **Explication** : `CREATE OR ALTER PROCEDURE` (dispo depuis SQL 2016 SP1) crée/modifie la procédure. `SET NOCOUNT ON` évite les messages parasites « N lignes affectées ». Voir §5.5.

---

## Exercice 5.6 ⭐⭐⭐ — Procédure avec paramètre OUTPUT

📝 **Énoncé** : Créez une procédure qui calcule le **chiffre d'affaires total** d'une commande et le renvoie via un paramètre `OUTPUT`.

✅ **Corrigé** :
```sql
CREATE OR ALTER PROCEDURE usp_TotalCommande
    @CommandeID INT,
    @Total DECIMAL(12,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @Total = SUM(Quantite * PrixUnitaire)
    FROM LignesCommande
    WHERE CommandeID = @CommandeID;
END;
GO
-- Exécution :
DECLARE @resultat DECIMAL(12,2);
EXEC usp_TotalCommande @CommandeID = 1, @Total = @resultat OUTPUT;
PRINT N'Total commande 1 : ' + CAST(@resultat AS NVARCHAR(20)) + N' €';
```

🧠 **Explication** : un paramètre `OUTPUT` renvoie une valeur à l'appelant (voir §5.5.2).

---

## Exercice 5.7 ⭐⭐ — Fonction scalaire

📝 **Énoncé** : Créez une fonction `fn_MontantLigne(@quantite, @prix)` qui renvoie le produit des deux.

✅ **Corrigé** :
```sql
CREATE OR ALTER FUNCTION fn_MontantLigne (@quantite INT, @prix DECIMAL(10,2))
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN @quantite * @prix;
END;
GO
SELECT dbo.fn_MontantLigne(3, 19.90) AS Montant;  -- 59.70
```

🧠 **Explication** : une **fonction scalaire** renvoie une seule valeur et s'appelle avec le préfixe de schéma `dbo.`. ⚠️ Attention à leur impact sur les performances en masse (voir §5.6.4).

---

## Exercice 5.8 ⭐⭐⭐ — Fonction table en ligne (TVF)

📝 **Énoncé** : Créez une fonction table `fn_ProduitsParCategorie(@catId)` renvoyant les produits d'une catégorie.

✅ **Corrigé** :
```sql
CREATE OR ALTER FUNCTION fn_ProduitsParCategorie (@catId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT ProduitID, NomProduit, PrixUnitaire
    FROM Produits
    WHERE CategorieID = @catId
);
GO
SELECT * FROM fn_ProduitsParCategorie(1);  -- s'utilise comme une table
```

🧠 **Explication** : une **TVF inline** renvoie une table et s'utilise dans le `FROM`. Elle est généralement **performante** (le moteur l'intègre à la requête), contrairement aux fonctions scalaires (voir §5.6.2).

---

## Exercice 5.9 ⭐⭐⭐ — Trigger AFTER

📝 **Énoncé** : Créez un trigger qui, après insertion d'une ligne de commande, **décrémente le stock** du produit concerné.

✅ **Corrigé** :
```sql
CREATE OR ALTER TRIGGER trg_MajStock
ON LignesCommande
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE p
    SET p.Stock = p.Stock - i.Quantite
    FROM Produits AS p
    JOIN inserted AS i ON i.ProduitID = p.ProduitID;
END;
GO
```

🧠 **Explication** : le trigger `AFTER INSERT` utilise la table virtuelle **`inserted`** (les lignes venant d'être insérées). On joint sur elle pour traiter **toutes** les lignes d'un coup (un trigger doit gérer les insertions multi-lignes, pas une seule !). Voir §5.7.2, §5.7.3.

---

## Exercice 5.10 ⭐⭐⭐ — Gestion d'erreurs TRY/CATCH

📝 **Énoncé** : Écrivez un bloc qui tente d'insérer un produit à prix négatif et capture l'erreur proprement.

✅ **Corrigé** :
```sql
BEGIN TRY
    INSERT INTO Produits (NomProduit, CategorieID, PrixUnitaire) VALUES (N'Erreur', 1, -10);
END TRY
BEGIN CATCH
    PRINT N'Erreur capturée : ' + ERROR_MESSAGE();
    PRINT N'Numéro : ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
END CATCH;
```

🧠 **Explication** : `TRY...CATCH` capture les erreurs d'exécution ; les fonctions `ERROR_MESSAGE()`, `ERROR_NUMBER()` décrivent l'erreur (ici, violation de la contrainte `CHECK`). Voir §5.3.

---

⏭️ [C.6 — Exercices du chapitre 6](/09-annexes/C-exercices/06-transactions.md)
