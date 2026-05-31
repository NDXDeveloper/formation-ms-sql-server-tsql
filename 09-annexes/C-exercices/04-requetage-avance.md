🔝 Retour au [Sommaire](/SOMMAIRE.md)

# C.4 — Exercices du chapitre 4 : Techniques de requêtage avancées

Jointures, sous-requêtes, CTE et fonctions de fenêtrage sur la base `Boutique`. C'est ici que le SQL devient vraiment puissant.

---

## Exercice 4.1 ⭐ — INNER JOIN

📝 **Énoncé** : Affichez chaque produit avec le **nom de sa catégorie**.

✅ **Corrigé** :
```sql
SELECT p.NomProduit, c.NomCategorie
FROM Produits AS p
INNER JOIN Categories AS c ON p.CategorieID = c.CategorieID;
```

🧠 **Explication** : `INNER JOIN` ne garde que les lignes ayant une correspondance des deux côtés (voir §4.1.2).

---

## Exercice 4.2 ⭐⭐ — LEFT JOIN

📝 **Énoncé** : Affichez **tous** les clients et le nombre de commandes de chacun, **y compris ceux qui n'ont jamais commandé** (0).

✅ **Corrigé** :
```sql
SELECT c.Nom, c.Prenom, COUNT(cmd.CommandeID) AS NbCommandes
FROM Clients AS c
LEFT JOIN Commandes AS cmd ON cmd.ClientID = c.ClientID
GROUP BY c.Nom, c.Prenom
ORDER BY NbCommandes DESC;
```

🧠 **Explication** : `LEFT JOIN` conserve tous les clients ; `COUNT(cmd.CommandeID)` compte 0 pour ceux sans commande (alors que `COUNT(*)` compterait 1 à tort). Voir §4.1.3.

---

## Exercice 4.3 ⭐⭐⭐ — Jointure à plusieurs tables

📝 **Énoncé** : Pour la commande n°1, affichez le nom du client, chaque produit commandé, sa quantité et le **montant de la ligne** (`Quantite * PrixUnitaire`).

✅ **Corrigé** :
```sql
SELECT
    cl.Nom + ' ' + cl.Prenom        AS Client,
    p.NomProduit,
    l.Quantite,
    l.Quantite * l.PrixUnitaire     AS MontantLigne
FROM Commandes      AS cmd
JOIN Clients        AS cl ON cl.ClientID  = cmd.ClientID
JOIN LignesCommande AS l  ON l.CommandeID = cmd.CommandeID
JOIN Produits       AS p  ON p.ProduitID  = l.ProduitID
WHERE cmd.CommandeID = 1;
```

🧠 **Explication** : on enchaîne les jointures pour relier 4 tables. Le calcul `Quantite * PrixUnitaire` se fait colonne à colonne.

---

## Exercice 4.4 ⭐⭐⭐ — Auto-jointure (self-join)

📝 **Énoncé** : Affichez chaque employé avec le nom de **son manager** (les employés sans manager doivent apparaître aussi).

✅ **Corrigé** :
```sql
SELECT
    e.Prenom + ' ' + e.Nom          AS Employe,
    m.Prenom + ' ' + m.Nom          AS Manager
FROM Employes AS e
LEFT JOIN Employes AS m ON e.ManagerID = m.EmployeID
ORDER BY Manager;
```

🧠 **Explication** : on joint la table `Employes` **à elle-même** (alias `e` et `m`). `LEFT JOIN` garde la directrice (sans manager). Voir §4.1.7.

---

## Exercice 4.5 ⭐⭐ — Sous-requête scalaire

📝 **Énoncé** : Affichez les produits dont le prix est **supérieur au prix moyen** de tous les produits.

✅ **Corrigé** :
```sql
SELECT NomProduit, PrixUnitaire
FROM Produits
WHERE PrixUnitaire > (SELECT AVG(PrixUnitaire) FROM Produits);
```

🧠 **Explication** : la sous-requête renvoie **une seule valeur** (le prix moyen), utilisable dans la comparaison (voir §4.2.1).

---

## Exercice 4.6 ⭐⭐⭐ — EXISTS

📝 **Énoncé** : Affichez les clients qui ont **passé au moins une commande**.

✅ **Corrigé** :
```sql
SELECT Nom, Prenom
FROM Clients AS c
WHERE EXISTS (SELECT 1 FROM Commandes cmd WHERE cmd.ClientID = c.ClientID);
```

🧠 **Explication** : `EXISTS` teste l'existence d'au moins une ligne correspondante ; c'est une **sous-requête corrélée** (elle référence `c` de la requête externe). Souvent plus efficace que `IN` sur de gros volumes. Voir §4.2.2 et §4.2.3.

---

## Exercice 4.7 ⭐⭐ — CTE pour la lisibilité

📝 **Énoncé** : À l'aide d'une CTE, calculez le **chiffre d'affaires par commande** (somme des montants de lignes), puis affichez les commandes dont le CA dépasse 200 €.

✅ **Corrigé** :
```sql
WITH CA_Commande AS (
    SELECT CommandeID, SUM(Quantite * PrixUnitaire) AS CA
    FROM LignesCommande
    GROUP BY CommandeID
)
SELECT CommandeID, CA
FROM CA_Commande
WHERE CA > 200
ORDER BY CA DESC;
```

🧠 **Explication** : la **CTE** (`WITH ... AS`) nomme un résultat intermédiaire, rendant la requête bien plus lisible qu'une sous-requête imbriquée (voir §4.3).

---

## Exercice 4.8 ⭐⭐⭐ — CTE récursive (hiérarchie)

📝 **Énoncé** : Affichez la hiérarchie des employés avec leur **niveau** (1 = direction), en partant de la directrice générale.

✅ **Corrigé** :
```sql
WITH Hierarchie AS (
    -- Ancre : la racine (sans manager)
    SELECT EmployeID, Nom, Prenom, ManagerID, 1 AS Niveau
    FROM Employes
    WHERE ManagerID IS NULL
    UNION ALL
    -- Récursion : les subordonnés
    SELECT e.EmployeID, e.Nom, e.Prenom, e.ManagerID, h.Niveau + 1
    FROM Employes AS e
    JOIN Hierarchie AS h ON e.ManagerID = h.EmployeID
)
SELECT Niveau, Prenom, Nom
FROM Hierarchie
ORDER BY Niveau, Nom;
```

🧠 **Explication** : une **CTE récursive** comporte une **ancre** (point de départ) et une **partie récursive** liée à la CTE elle-même via `UNION ALL`. Idéale pour les structures hiérarchiques (voir §4.3.3).

---

## Exercice 4.9 ⭐⭐⭐ — Fonctions de classement

📝 **Énoncé** : Classez les produits du plus cher au moins cher **à l'intérieur de chaque catégorie**, en affichant leur rang.

✅ **Corrigé** :
```sql
SELECT
    CategorieID,
    NomProduit,
    PrixUnitaire,
    ROW_NUMBER() OVER (PARTITION BY CategorieID ORDER BY PrixUnitaire DESC) AS Rang
FROM Produits
ORDER BY CategorieID, Rang;
```

🧠 **Explication** : `OVER (PARTITION BY ... ORDER BY ...)` applique le classement **par groupe** sans réduire le nombre de lignes (contrairement à `GROUP BY`). `ROW_NUMBER` donne un rang unique ; `RANK`/`DENSE_RANK` gèrent les ex æquo. Voir §4.5.3.

---

## Exercice 4.10 ⭐⭐⭐ — Agrégat analytique (total cumulé)

📝 **Énoncé** : Pour les lignes de la commande n°1, affichez le montant de chaque ligne et le **total cumulé** au fil des lignes.

✅ **Corrigé** :
```sql
SELECT
    ProduitID,
    Quantite * PrixUnitaire AS MontantLigne,
    SUM(Quantite * PrixUnitaire) OVER (ORDER BY LigneCommandeID
        ROWS UNBOUNDED PRECEDING) AS TotalCumule
FROM LignesCommande
WHERE CommandeID = 1;
```

🧠 **Explication** : `SUM(...) OVER (ORDER BY ...)` calcule un **total mobile** (running total). La clause de fenêtre `ROWS UNBOUNDED PRECEDING` additionne depuis la première ligne jusqu'à la ligne courante. Voir §4.5.4.

---

⏭️ [C.5 — Exercices du chapitre 5](/09-annexes/C-exercices/05-programmabilite.md)
