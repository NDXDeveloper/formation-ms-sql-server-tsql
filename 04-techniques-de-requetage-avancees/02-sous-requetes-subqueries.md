🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 4.2 Sous-requêtes (Subqueries)

## Introduction

Une **sous-requête** (ou **requête imbriquée**) est une requête SQL placée à l'intérieur d'une autre requête SQL. C'est l'un des concepts les plus puissants de SQL, permettant de résoudre des problèmes complexes en décomposant une requête en plusieurs étapes logiques.

### Analogie simple

Imaginez que vous devez résoudre un problème mathématique complexe :
- **Sans sous-requête** : Vous devez tout calculer en une seule étape, ce qui peut être compliqué
- **Avec sous-requête** : Vous pouvez d'abord calculer une partie du résultat, puis utiliser ce résultat intermédiaire pour obtenir la réponse finale

Par exemple, pour trouver "les étudiants qui ont une note supérieure à la moyenne" :
1. D'abord, calculer la moyenne de toutes les notes
2. Ensuite, comparer chaque note à cette moyenne

En SQL, la sous-requête permet de faire cette première étape (calculer la moyenne) à l'intérieur de la requête principale.

## Qu'est-ce qu'une sous-requête ?

Une sous-requête est une instruction `SELECT` complète qui est **imbriquée** dans une autre instruction SQL. Elle est toujours **entourée de parenthèses** et peut apparaître dans différentes parties d'une requête :
- Dans la clause `SELECT`
- Dans la clause `FROM`
- Dans la clause `WHERE`
- Dans la clause `HAVING`
- Même dans les clauses `INSERT`, `UPDATE`, ou `DELETE`

### Structure de base

```sql
SELECT colonne1, colonne2
FROM table1
WHERE colonne3 = (SELECT colonne FROM table2 WHERE condition);
                  └──────────────────────────────────────┘
                          Sous-requête
```

## Pourquoi utiliser des sous-requêtes ?

### 1. Résoudre des problèmes complexes étape par étape

Les sous-requêtes permettent de décomposer un problème complexe en problèmes plus simples.

**Exemple sans sous-requête (impossible directement) :**
```sql
-- Comment trouver les produits plus chers que la moyenne ?
-- On ne peut pas faire : WHERE Prix > AVG(Prix) directement
```

**Avec sous-requête (possible) :**
```sql
SELECT NomProduit, Prix
FROM Produits
WHERE Prix > (SELECT AVG(Prix) FROM Produits);
```

### 2. Éviter les requêtes multiples

Au lieu de faire deux requêtes séparées et traiter le résultat dans votre application, vous pouvez tout faire en une seule fois.

**Deux requêtes séparées :**
```sql
-- Requête 1 : Trouver le salaire maximum
SELECT MAX(Salaire) FROM Employes;  -- Résultat : 5000

-- Requête 2 : Trouver qui a ce salaire (en utilisant 5000 trouvé précédemment)
SELECT NomEmploye FROM Employes WHERE Salaire = 5000;
```

**Une seule requête avec sous-requête :**
```sql
SELECT NomEmploye
FROM Employes
WHERE Salaire = (SELECT MAX(Salaire) FROM Employes);
```

### 3. Comparer des données provenant de contextes différents

Les sous-requêtes permettent de comparer une ligne avec un ensemble de données calculé différemment.

```sql
-- Trouver les employés qui gagnent plus que la moyenne de leur département
SELECT NomEmploye, Salaire
FROM Employes E
WHERE Salaire > (
    SELECT AVG(Salaire)
    FROM Employes
    WHERE DepartementID = E.DepartementID
);
```

### 4. Travailler avec des données agrégées

Effectuer des calculs sur des résultats déjà agrégés.

```sql
-- Trouver le département avec le salaire moyen le plus élevé
SELECT DepartementID
FROM Employes
GROUP BY DepartementID
HAVING AVG(Salaire) = (
    SELECT MAX(MoyenneSalaire)
    FROM (
        SELECT AVG(Salaire) AS MoyenneSalaire
        FROM Employes
        GROUP BY DepartementID
    ) AS Moyennes
);
```

## Contexte : Tables d'exemple

Pour illustrer les concepts dans cette section, nous utiliserons ces tables simples :

**Table Produits**
| ProduitID | NomProduit | Prix | CategorieID |
|-----------|------------|------|-------------|
| 1 | Clavier | 25.00 | 1 |
| 2 | Souris | 15.00 | 1 |
| 3 | Écran | 200.00 | 2 |
| 4 | Webcam | 50.00 | 2 |
| 5 | Casque | 80.00 | 1 |

**Table Categories**
| CategorieID | NomCategorie |
|-------------|--------------|
| 1 | Accessoires |
| 2 | Périphériques |

**Table Commandes**
| CommandeID | ClientID | DateCommande | Montant |
|------------|----------|--------------|---------|
| 101 | 1 | 2024-01-15 | 150.00 |
| 102 | 1 | 2024-02-20 | 200.00 |
| 103 | 2 | 2024-01-18 | 75.00 |
| 104 | 3 | 2024-03-10 | 300.00 |

**Table Clients**
| ClientID | NomClient | Ville |
|----------|-----------|-------|
| 1 | Dupont | Paris |
| 2 | Martin | Lyon |
| 3 | Bernard | Paris |

## Types de sous-requêtes

Il existe plusieurs types de sous-requêtes, classées selon :
1. **Leur emplacement** dans la requête
2. **Le type de résultat** qu'elles retournent
3. **Leur dépendance** vis-à-vis de la requête externe

### Classification par résultat retourné

#### 1. Sous-requêtes scalaires
Retournent **une seule valeur** (une ligne, une colonne).

```sql
-- Exemple : Comparer à une valeur unique
SELECT NomProduit, Prix
FROM Produits
WHERE Prix > (SELECT AVG(Prix) FROM Produits);
              └─────────────────────────────┘
                    Retourne : 74.00
```

#### 2. Sous-requêtes multi-lignes
Retournent **plusieurs lignes** (mais une seule colonne).

```sql
-- Exemple : Vérifier l'appartenance à une liste
SELECT NomClient
FROM Clients
WHERE ClientID IN (SELECT ClientID FROM Commandes);
                   └───────────────────────────┘
                   Retourne : 1, 1, 2, 3
```

#### 3. Sous-requêtes multi-colonnes
Retournent **plusieurs colonnes** (peuvent retourner plusieurs lignes aussi).

⚠️ **Important** : contrairement à d'autres SGBD (PostgreSQL, MySQL), **SQL Server ne supporte PAS** la comparaison de plusieurs colonnes via un constructeur de lignes du type `WHERE (Prix, CategorieID) IN (SELECT MAX(Prix), CategorieID ...)`. En T-SQL, on exprime cette comparaison multi-colonnes avec une **jointure sur une table dérivée** (ou avec `EXISTS`) :

```sql
-- Exemple : le produit le plus cher de chaque catégorie
SELECT P.NomProduit, P.Prix, P.CategorieID
FROM Produits P
INNER JOIN (
    SELECT CategorieID, MAX(Prix) AS MaxPrix
    FROM Produits
    GROUP BY CategorieID
) M ON P.CategorieID = M.CategorieID
   AND P.Prix = M.MaxPrix;
```

#### 4. Sous-requêtes table (Tables dérivées)
Retournent **un ensemble de résultats complet** (plusieurs lignes et colonnes).

```sql
-- Exemple : Créer une table temporaire dans le FROM
SELECT *
FROM (
    SELECT CategorieID, AVG(Prix) AS PrixMoyen
    FROM Produits
    GROUP BY CategorieID
) AS Moyennes
WHERE PrixMoyen > 50;
```

### Classification par dépendance

#### 1. Sous-requêtes indépendantes (non corrélées)

La sous-requête peut s'exécuter **de manière autonome**, sans référence à la requête externe.

```sql
-- La sous-requête est complètement indépendante
SELECT NomProduit, Prix
FROM Produits
WHERE Prix > (SELECT AVG(Prix) FROM Produits);
```

**Caractéristiques :**
- S'exécute **une seule fois**
- Ne dépend pas de la requête externe
- Plus simple et souvent plus performante

#### 2. Sous-requêtes corrélées (dépendantes)

La sous-requête **référence** la requête externe et doit s'exécuter **pour chaque ligne** de la requête externe.

```sql
-- La sous-requête référence E.CategorieID de la requête externe
SELECT NomProduit, Prix, CategorieID
FROM Produits P
WHERE Prix > (
    SELECT AVG(Prix)
    FROM Produits
    WHERE CategorieID = P.CategorieID
    --                  ↑ Référence à la requête externe
);
```

**Caractéristiques :**
- S'exécute **pour chaque ligne** de la requête externe
- Dépend de la requête externe
- Plus flexible mais potentiellement plus lente

### Classification par emplacement

#### 1. Dans la clause SELECT

```sql
-- Ajouter une colonne calculée
SELECT
    NomProduit,
    Prix,
    (SELECT AVG(Prix) FROM Produits) AS PrixMoyenGlobal
FROM Produits;
```

#### 2. Dans la clause FROM

```sql
-- Créer une table dérivée
SELECT *
FROM (
    SELECT CategorieID, COUNT(*) AS NbProduits
    FROM Produits
    GROUP BY CategorieID
) AS Stats
WHERE NbProduits > 2;
```

#### 3. Dans la clause WHERE

```sql
-- Filtrer les résultats
SELECT NomClient
FROM Clients
WHERE ClientID IN (SELECT ClientID FROM Commandes);
```

#### 4. Dans la clause HAVING

```sql
-- Filtrer des groupes
SELECT CategorieID, AVG(Prix) AS PrixMoyen
FROM Produits
GROUP BY CategorieID
HAVING AVG(Prix) > (SELECT AVG(Prix) FROM Produits);
```

## Exemple complet pas à pas

Prenons un exemple concret pour bien comprendre le concept.

**Problème :** Trouver les produits dont le prix est supérieur au prix moyen de leur catégorie.

### Approche 1 : Sans sous-requête (requêtes multiples)

```sql
-- Étape 1 : Calculer les moyennes par catégorie
SELECT CategorieID, AVG(Prix) AS PrixMoyen
FROM Produits
GROUP BY CategorieID;
```

Résultat intermédiaire :
| CategorieID | PrixMoyen |
|-------------|-----------|
| 1 | 40.00 |
| 2 | 125.00 |

```sql
-- Étape 2 : Comparer manuellement chaque produit
-- Pour la catégorie 1, chercher Prix > 40
-- Pour la catégorie 2, chercher Prix > 125
-- (Fastidieux et impossible à automatiser en une requête)
```

### Approche 2 : Avec sous-requête corrélée

```sql
SELECT
    NomProduit,
    Prix,
    CategorieID
FROM Produits P
WHERE Prix > (
    SELECT AVG(Prix)
    FROM Produits
    WHERE CategorieID = P.CategorieID
);
```

**Déroulement :**
1. Pour chaque produit de la table `Produits`
2. La sous-requête calcule la moyenne pour la catégorie de ce produit
3. Compare le prix du produit à cette moyenne
4. Garde le produit si son prix est supérieur

**Résultat :**
| NomProduit | Prix | CategorieID |
|------------|------|-------------|
| Casque | 80.00 | 1 |
| Écran | 200.00 | 2 |

**Explication détaillée :**
- **Clavier** (25.00, Cat 1) : 25 > 40 ? Non ✗
- **Souris** (15.00, Cat 1) : 15 > 40 ? Non ✗
- **Écran** (200.00, Cat 2) : 200 > 125 ? Oui ✓
- **Webcam** (50.00, Cat 2) : 50 > 125 ? Non ✗
- **Casque** (80.00, Cat 1) : 80 > 40 ? Oui ✓

## Avantages et inconvénients des sous-requêtes

### ✅ Avantages

1. **Lisibilité** : Permettent d'exprimer la logique de manière naturelle et structurée
2. **Modularité** : Décomposent des problèmes complexes en étapes plus simples
3. **Puissance** : Permettent de résoudre des problèmes impossibles à résoudre autrement
4. **Réutilisation** : Évitent la duplication de code
5. **Une seule requête** : Tout se fait en un seul aller-retour vers la base de données

### ⚠️ Inconvénients et précautions

1. **Performance** : Les sous-requêtes corrélées peuvent être lentes sur de grandes tables
2. **Complexité** : Des sous-requêtes trop imbriquées deviennent difficiles à lire
3. **Optimisation** : Parfois moins bien optimisées par SQL Server que des jointures équivalentes
4. **Débogage** : Plus difficiles à déboguer qu'une requête simple

### 💡 Quand utiliser des sous-requêtes ?

**Utilisez des sous-requêtes quand :**
- Vous devez comparer une valeur à un résultat agrégé (moyenne, maximum, etc.)
- Vous devez filtrer en fonction de données d'une autre table
- La logique est plus claire avec une sous-requête qu'avec une jointure
- Vous devez effectuer des calculs en plusieurs étapes

**Préférez une alternative quand :**
- Une simple jointure suffit (généralement plus performante)
- Vous pouvez utiliser une fonction de fenêtrage (`OVER`)
- La sous-requête devient trop complexe ou trop imbriquée
- Les performances sont critiques (testez toujours !)

## Alternatives aux sous-requêtes

Il est important de savoir que les sous-requêtes ne sont pas toujours la seule solution. Voici quelques alternatives :

### 1. Jointures (JOINS)

**Avec sous-requête :**
```sql
SELECT NomClient
FROM Clients
WHERE ClientID IN (SELECT ClientID FROM Commandes);
```

**Avec jointure :**
```sql
SELECT DISTINCT C.NomClient
FROM Clients C
INNER JOIN Commandes CMD ON C.ClientID = CMD.ClientID;
```

### 2. CTE (Common Table Expressions)

**Avec sous-requête dans le FROM :**
```sql
SELECT *
FROM (
    SELECT CategorieID, AVG(Prix) AS PrixMoyen
    FROM Produits
    GROUP BY CategorieID
) AS Stats
WHERE PrixMoyen > 50;
```

**Avec CTE (plus lisible) :**
```sql
WITH Stats AS (
    SELECT CategorieID, AVG(Prix) AS PrixMoyen
    FROM Produits
    GROUP BY CategorieID
)
SELECT *
FROM Stats
WHERE PrixMoyen > 50;
```

### 3. Fonctions de fenêtrage (Window Functions)

**Avec sous-requête corrélée :**
```sql
SELECT NomProduit, Prix,
    (SELECT AVG(Prix)
     FROM Produits P2
     WHERE P2.CategorieID = P1.CategorieID) AS MoyenneCat
FROM Produits P1;
```

**Avec fonction de fenêtrage (plus performant) :**
```sql
SELECT
    NomProduit,
    Prix,
    AVG(Prix) OVER (PARTITION BY CategorieID) AS MoyenneCat
FROM Produits;
```

## Règles importantes à retenir

### 1. Les parenthèses sont obligatoires

```sql
-- ❌ Erreur : Pas de parenthèses
SELECT * FROM Produits WHERE Prix > SELECT AVG(Prix) FROM Produits;

-- ✅ Correct
SELECT * FROM Produits WHERE Prix > (SELECT AVG(Prix) FROM Produits);
```

### 2. Les sous-requêtes scalaires doivent retourner UNE SEULE valeur

```sql
-- ❌ Erreur : Retourne plusieurs lignes
SELECT * FROM Produits WHERE Prix = (SELECT Prix FROM Produits);

-- ✅ Correct : Retourne une seule valeur
SELECT * FROM Produits WHERE Prix = (SELECT MAX(Prix) FROM Produits);
```

### 3. Utiliser IN pour les sous-requêtes multi-lignes

```sql
-- ✅ Correct avec IN
SELECT NomClient
FROM Clients
WHERE ClientID IN (SELECT ClientID FROM Commandes);

-- ❌ Erreur avec =
SELECT NomClient
FROM Clients
WHERE ClientID = (SELECT ClientID FROM Commandes);  -- Erreur si plusieurs résultats
```

### 4. Attention aux valeurs NULL (piège du `NOT IN`)

C'est l'un des pièges les plus dangereux en SQL. Si la sous-requête d'un `NOT IN` renvoie **ne serait-ce qu'une seule valeur NULL**, alors la condition `NOT IN` vaut `UNKNOWN` pour **toutes** les lignes → la requête ne retourne **aucun résultat** !

```sql
-- ⚠️ Si UN SEUL ClientID de Commandes est NULL,
-- cette requête renvoie un résultat VIDE (et non les clients sans commande) :
SELECT NomClient
FROM Clients
WHERE ClientID NOT IN (SELECT ClientID FROM Commandes);
```

```sql
-- ✅ Solution 1 : exclure explicitement les NULL de la sous-requête
SELECT NomClient
FROM Clients
WHERE ClientID NOT IN (SELECT ClientID FROM Commandes WHERE ClientID IS NOT NULL);

-- ✅ Solution 2 (recommandée) : NOT EXISTS, insensible aux NULL
SELECT NomClient
FROM Clients C
WHERE NOT EXISTS (SELECT 1 FROM Commandes CMD WHERE CMD.ClientID = C.ClientID);
```

> À l'inverse, `IN` (sans `NOT`) n'est pas affecté de la même manière : un NULL dans la liste n'élimine pas les correspondances réelles, il empêche seulement les non-correspondances de devenir `TRUE`.

## Plan des sections suivantes

Dans les sections qui suivent, nous allons approfondir chaque type de sous-requête :

- **4.2.1 Sous-requêtes scalaires** : Retournent une seule valeur
- **4.2.2 Sous-requêtes dans le WHERE** : Utilisation avec `IN` et `EXISTS`
- **4.2.3 Sous-requêtes corrélées** : Référencent la requête externe
- **4.2.4 Sous-requêtes dans le FROM** : Tables dérivées

Chaque section approfondira un aspect spécifique avec de nombreux exemples pratiques.

## Résumé

Les **sous-requêtes** sont des requêtes SQL imbriquées dans d'autres requêtes, permettant de :
- Décomposer des problèmes complexes en étapes logiques
- Comparer des données à des agrégations
- Filtrer en fonction de critères calculés dynamiquement
- Créer des résultats intermédiaires réutilisables

**Points clés à retenir :**
- Une sous-requête est toujours entre **parenthèses**
- Elle peut apparaître dans `SELECT`, `FROM`, `WHERE`, `HAVING`
- Les sous-requêtes **scalaires** retournent une valeur, les autres peuvent retourner plusieurs lignes/colonnes
- Les sous-requêtes **corrélées** dépendent de la requête externe
- Elles sont puissantes mais doivent être utilisées avec discernement pour la performance

Les sous-requêtes sont un outil essentiel dans votre boîte à outils SQL. Maîtriser leur utilisation vous permettra de résoudre des problèmes qui sembleraient autrement très complexes !

⏭️ [Sous-requêtes scalaires (retournant une seule valeur)](/04-techniques-de-requetage-avancees/02.1-sous-requetes-scalaires.md)
