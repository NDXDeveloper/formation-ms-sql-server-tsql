🔝 Retour au [Sommaire](/SOMMAIRE.md)

# C.2 — Exercices du chapitre 2 : DDL & DML

Ces exercices portent sur la **création/modification d'objets** (DDL) et la **manipulation de données** (DML) dans la base `Boutique`. Pensez à réinitialiser la base (script de l'[annexe B](/09-annexes/B-base-exemple/README.md)) si vous l'avez altérée.

---

## Exercice 2.1 ⭐ — CREATE TABLE avec contraintes

📝 **Énoncé** : Créez une table `Fournisseurs` avec : un identifiant auto-incrémenté (PK), un nom obligatoire, un email **unique**, un pays avec la valeur par défaut `'France'`.

✅ **Corrigé** :
```sql
CREATE TABLE Fournisseurs (
    FournisseurID INT IDENTITY(1,1) PRIMARY KEY,
    Nom           NVARCHAR(100) NOT NULL,
    Email         NVARCHAR(255) UNIQUE,
    Pays          NVARCHAR(50) NOT NULL DEFAULT (N'France')
);
```

🧠 **Explication** : `IDENTITY(1,1)` génère les valeurs, `PRIMARY KEY` impose l'unicité + non-null, `UNIQUE` empêche les doublons d'email, `DEFAULT` fournit une valeur si non précisée (voir §2.2, §2.3).

---

## Exercice 2.2 ⭐ — ALTER TABLE

📝 **Énoncé** : Ajoutez à la table `Produits` une colonne `DateAjout` de type `DATE`, avec la date du jour par défaut.

✅ **Corrigé** :
```sql
ALTER TABLE Produits
ADD DateAjout DATE NOT NULL DEFAULT (CAST(SYSDATETIME() AS DATE));
```

🧠 **Explication** : `ALTER TABLE ... ADD` ajoute une colonne. Le `DEFAULT` est indispensable ici car la colonne est `NOT NULL` et la table contient déjà des lignes (voir §2.2.3).

---

## Exercice 2.3 ⭐ — INSERT simple

📝 **Énoncé** : Insérez un nouveau client : Amélie Rousseau, `amelie.rousseau@email.fr`, à Rennes.

✅ **Corrigé** :
```sql
INSERT INTO Clients (Nom, Prenom, Email, Ville)
VALUES (N'Rousseau', N'Amélie', N'amelie.rousseau@email.fr', N'Rennes');
```

🧠 **Explication** : on ne fournit pas `ClientID` (auto) ni `DateInscription` (valeur par défaut). On nomme **toujours** les colonnes ciblées (bonne pratique). Voir §2.4.1.

---

## Exercice 2.4 ⭐⭐ — INSERT multiple

📝 **Énoncé** : Insérez en **une seule instruction** deux produits dans la catégorie Papeterie (`CategorieID = 2`) : « Surligneur (lot de 4) » à 6,90 € (stock 90) et « Agenda 2026 » à 14,90 € (stock 40).

✅ **Corrigé** :
```sql
INSERT INTO Produits (NomProduit, CategorieID, PrixUnitaire, Stock)
VALUES
    (N'Surligneur (lot de 4)', 2, 6.90, 90),
    (N'Agenda 2026',           2, 14.90, 40);
```

🧠 **Explication** : un seul `INSERT ... VALUES` accepte plusieurs tuples séparés par des virgules (voir §2.4.2).

---

## Exercice 2.5 ⭐⭐ — UPDATE ciblé

📝 **Énoncé** : Le prix de la « Souris sans fil » passe à 17,90 €. Mettez-le à jour.

💡 **Indice** : n'oubliez **jamais** la clause `WHERE` dans un `UPDATE`.

✅ **Corrigé** :
```sql
UPDATE Produits
SET PrixUnitaire = 17.90
WHERE NomProduit = N'Souris sans fil';
```

🧠 **Explication** : sans `WHERE`, **tous** les produits passeraient à 17,90 € ! La clause `WHERE` est cruciale (voir §2.5.2).

---

## Exercice 2.6 ⭐⭐ — UPDATE de masse maîtrisé

📝 **Énoncé** : Augmentez de **10 %** le prix de tous les produits de la catégorie « Informatique » (`CategorieID = 1`).

✅ **Corrigé** :
```sql
UPDATE Produits
SET PrixUnitaire = PrixUnitaire * 1.10
WHERE CategorieID = 1;
```

🧠 **Explication** : on peut utiliser la valeur actuelle de la colonne dans le calcul. Le `WHERE` limite l'effet à la bonne catégorie.

---

## Exercice 2.7 ⭐⭐⭐ — DELETE et intégrité référentielle

📝 **Énoncé** : On veut supprimer la commande n°7 (statut « Annulée »). Tentez `DELETE FROM Commandes WHERE CommandeID = 7;`. Que se passe-t-il, et comment faire correctement ?

✅ **Corrigé** :
```sql
-- La commande 7 possède une ligne (Webcam HD) : le DELETE direct sur Commandes
-- échoue (la FK FK_Lignes_Commandes l'empêche).
-- Il faut d'abord supprimer les lignes, puis la commande :
DELETE FROM LignesCommande WHERE CommandeID = 7;
DELETE FROM Commandes      WHERE CommandeID = 7;
```

🧠 **Explication** : la **clé étrangère** interdit de supprimer une commande encore référencée par des lignes (intégrité référentielle). On supprime donc d'abord les « enfants » (lignes), puis le « parent » (commande). Alternative : définir la FK avec `ON DELETE CASCADE` (voir §2.3.2). Ici, la commande 7 **possède une ligne** (une `Webcam HD`) : le `DELETE` direct sur `Commandes` **échoue** donc bel et bien, ce qui illustre concrètement le principe d'intégrité référentielle.

---

## Exercice 2.8 ⭐⭐ — Comprendre les contraintes

📝 **Énoncé** : Que renvoient ces instructions, et pourquoi ?

a) `INSERT INTO Produits (NomProduit, CategorieID, PrixUnitaire) VALUES (N'Test', 1, -5);`  
b) `INSERT INTO Clients (Nom, Prenom, Email) VALUES (N'X', N'Y', N'jean.dupont@email.fr');`  

✅ **Corrigé** :
- a) **Échec** : la contrainte `CK_Produits_Prix` impose `PrixUnitaire > 0`.
- b) **Échec** : la contrainte `UQ_Clients_Email` impose un email unique, et `jean.dupont@email.fr` existe déjà.

🧠 **Explication** : les contraintes `CHECK` et `UNIQUE` protègent l'intégrité des données dès l'insertion (voir §2.3).

---

## Exercice 2.9 ⭐ — DELETE vs TRUNCATE

📝 **Énoncé** : Quelle est la différence entre `DELETE FROM Produits;` et `TRUNCATE TABLE Produits;` ? Laquelle échouerait sur la base `Boutique` telle quelle, et pourquoi ?

✅ **Corrigé** :
- `DELETE` supprime ligne par ligne (journalisé, peut avoir un `WHERE`, déclenche les triggers).
- `TRUNCATE` vide la table d'un coup (minimalement journalisé, réinitialise l'`IDENTITY`, pas de `WHERE`).
- **Les deux échoueraient** ici : `Produits` est référencée par `LignesCommande` via une FK. `TRUNCATE` est même **interdit** sur une table référencée par une clé étrangère.

🧠 **Explication** : voir §2.6.2. Pour vider `Produits`, il faudrait d'abord traiter les lignes dépendantes.

---

⏭️ [C.3 — Exercices du chapitre 3](/09-annexes/C-exercices/03-select.md)
