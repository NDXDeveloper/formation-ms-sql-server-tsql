🔝 Retour au [Sommaire](/SOMMAIRE.md)

# C.3 — Exercices du chapitre 3 : Interrogation des données (SELECT)

Le cœur du SQL au quotidien. Tous ces exercices s'exécutent sur la base `Boutique`. Essayez d'écrire la requête avant de regarder le corrigé.

---

## Exercice 3.1 ⭐ — SELECT et alias

📝 **Énoncé** : Affichez le nom et le prix de tous les produits, en renommant les colonnes en `Produit` et `Prix`.

✅ **Corrigé** :
```sql
SELECT NomProduit AS Produit, PrixUnitaire AS Prix
FROM Produits;
```

🧠 **Explication** : `AS` crée un **alias** de colonne, pour des résultats plus lisibles (voir §3.1.3).

---

## Exercice 3.2 ⭐ — WHERE et comparaison

📝 **Énoncé** : Affichez les produits dont le prix est strictement supérieur à 100 €.

✅ **Corrigé** :
```sql
SELECT NomProduit, PrixUnitaire
FROM Produits
WHERE PrixUnitaire > 100;
```

🧠 **Explication** : `WHERE` filtre les lignes selon une condition (voir §3.2).

---

## Exercice 3.3 ⭐⭐ — IN, BETWEEN, LIKE

📝 **Énoncé** :
a) Les clients des villes Paris **ou** Lyon.  
b) Les produits dont le prix est compris entre 20 et 50 € (bornes incluses).  
c) Les clients dont le nom commence par un « M ».  

✅ **Corrigé** :
```sql
-- a)
SELECT Nom, Prenom, Ville FROM Clients WHERE Ville IN (N'Paris', N'Lyon');
-- b)
SELECT NomProduit, PrixUnitaire FROM Produits WHERE PrixUnitaire BETWEEN 20 AND 50;
-- c)
SELECT Nom, Prenom FROM Clients WHERE Nom LIKE N'M%';
```

🧠 **Explication** : `IN` teste une liste, `BETWEEN` un intervalle inclusif, `LIKE` un motif (`%` = n'importe quelle suite de caractères). Voir §3.2.4.

---

## Exercice 3.4 ⭐⭐ — Gestion des NULL

📝 **Énoncé** : Affichez les commandes sans employé associé (`EmployeID` non renseigné). Pourquoi `WHERE EmployeID = NULL` ne fonctionne-t-il pas ?

✅ **Corrigé** :
```sql
SELECT CommandeID, ClientID FROM Commandes WHERE EmployeID IS NULL;
```

🧠 **Explication** : `NULL` signifie « inconnu » : aucune comparaison avec `=` n'est vraie pour `NULL`. On utilise **`IS NULL`** / **`IS NOT NULL`** (voir §3.2.5). *(Dans le jeu de données fourni, toutes les commandes ont un employé ; la requête peut donc ne rien renvoyer — l'important est la syntaxe correcte.)*

---

## Exercice 3.5 ⭐ — ORDER BY

📝 **Énoncé** : Affichez tous les produits triés par prix **décroissant**.

✅ **Corrigé** :
```sql
SELECT NomProduit, PrixUnitaire
FROM Produits
ORDER BY PrixUnitaire DESC;
```

🧠 **Explication** : `ORDER BY ... DESC` trie du plus grand au plus petit (voir §3.3.1).

---

## Exercice 3.6 ⭐⭐ — TOP

📝 **Énoncé** : Affichez les **3 produits les plus chers**.

✅ **Corrigé** :
```sql
SELECT TOP (3) NomProduit, PrixUnitaire
FROM Produits
ORDER BY PrixUnitaire DESC;
```

🧠 **Explication** : `TOP (n)` limite le nombre de lignes ; il faut un `ORDER BY` pour que « les 3 plus chers » ait un sens (voir §3.3.2).

---

## Exercice 3.7 ⭐⭐ — Fonctions d'agrégation

📝 **Énoncé** : Calculez, pour la table `Produits` : le nombre de produits, le prix moyen, le prix minimum et le prix maximum.

✅ **Corrigé** :
```sql
SELECT
    COUNT(*)            AS NbProduits,
    AVG(PrixUnitaire)   AS PrixMoyen,
    MIN(PrixUnitaire)   AS PrixMin,
    MAX(PrixUnitaire)   AS PrixMax
FROM Produits;
```

🧠 **Explication** : les fonctions d'agrégation résument un ensemble de lignes en une valeur (voir §3.4.1).

---

## Exercice 3.8 ⭐⭐ — GROUP BY

📝 **Énoncé** : Affichez le **nombre de produits par catégorie** (`CategorieID`).

✅ **Corrigé** :
```sql
SELECT CategorieID, COUNT(*) AS NbProduits
FROM Produits
GROUP BY CategorieID
ORDER BY CategorieID;
```

🧠 **Explication** : `GROUP BY` regroupe les lignes ; l'agrégat s'applique à chaque groupe. Toute colonne non agrégée du `SELECT` doit figurer dans le `GROUP BY` (voir §3.5.1).

---

## Exercice 3.9 ⭐⭐⭐ — HAVING

📝 **Énoncé** : Affichez les catégories qui comptent **au moins 3 produits**.

✅ **Corrigé** :
```sql
SELECT CategorieID, COUNT(*) AS NbProduits
FROM Produits
GROUP BY CategorieID
HAVING COUNT(*) >= 3;
```

🧠 **Explication** : `HAVING` filtre **les groupes** (après agrégation), là où `WHERE` filtre **les lignes** (avant agrégation). On ne peut pas utiliser un agrégat dans `WHERE` (voir §3.5.2).

---

## Exercice 3.10 ⭐⭐⭐ — DISTINCT et combinaison

📝 **Énoncé** : Affichez la liste des **villes distinctes** où résident des clients, triées alphabétiquement.

✅ **Corrigé** :
```sql
SELECT DISTINCT Ville
FROM Clients
WHERE Ville IS NOT NULL
ORDER BY Ville;
```

🧠 **Explication** : `DISTINCT` élimine les doublons (plusieurs clients par ville). On exclut les `NULL` proprement avec `IS NOT NULL` (voir §3.4.2).

---

## Défi de synthèse ⭐⭐⭐

📝 **Énoncé** : Affichez, pour chaque ville, le **nombre de clients** et la **date d'inscription la plus ancienne**, en ne gardant que les villes comptant **au moins 2 clients**, triées par nombre de clients décroissant.

✅ **Corrigé** :
```sql
SELECT
    Ville,
    COUNT(*)            AS NbClients,
    MIN(DateInscription) AS PremiereInscription
FROM Clients
WHERE Ville IS NOT NULL
GROUP BY Ville
HAVING COUNT(*) >= 2
ORDER BY NbClients DESC;
```

🧠 **Explication** : ce défi combine `WHERE` (filtre lignes), `GROUP BY` (regroupement), agrégats (`COUNT`, `MIN`), `HAVING` (filtre groupes) et `ORDER BY`. C'est l'**ordre logique d'exécution** du §3.5.3.

---

⏭️ [C.4 — Exercices du chapitre 4](/09-annexes/C-exercices/04-requetage-avance.md)
