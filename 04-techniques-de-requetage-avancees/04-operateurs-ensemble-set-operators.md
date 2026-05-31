🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 4.4 Opérateurs d'ensemble (Set Operators)

## Introduction

Les **opérateurs d'ensemble** (ou **Set Operators** en anglais) sont des opérateurs SQL qui permettent de **combiner les résultats de deux ou plusieurs requêtes SELECT**. Ils sont inspirés de la **théorie des ensembles** en mathématiques et offrent un moyen élégant de fusionner, comparer ou soustraire des ensembles de données.

### Analogie simple

Imaginez que vous avez deux listes d'invités pour une fête :
- **Liste A** : Alice, Bob, Charlie, David
- **Liste B** : Bob, Charlie, Eve, Frank

Les opérateurs d'ensemble vous permettent de répondre à différentes questions :
- **UNION** : Qui sont TOUS les invités possibles ? → Alice, Bob, Charlie, David, Eve, Frank
- **INTERSECT** : Qui est sur les DEUX listes ? → Bob, Charlie
- **EXCEPT** : Qui est sur la liste A mais PAS sur la liste B ? → Alice, David

C'est exactement ce que font les opérateurs d'ensemble avec des données SQL !

## Qu'est-ce qu'un ensemble en SQL ?

### Définition

En SQL, un **ensemble** est le résultat d'une requête SELECT. C'est un ensemble de lignes (ou tuples) retournées par une requête.

**Exemple :**
```sql
SELECT ClientID, NomClient FROM Clients WHERE Ville = 'Paris';
```

Ce SELECT retourne un **ensemble** de clients parisiens.

### Caractéristiques d'un ensemble

En théorie des ensembles mathématiques :
- Un ensemble ne contient **pas de doublons**
- L'ordre des éléments n'est **pas important**

En SQL :
- Par défaut, un SELECT **peut** contenir des doublons (sauf si on utilise DISTINCT)
- L'ordre **peut** être spécifié avec ORDER BY
- Les opérateurs d'ensemble (UNION, INTERSECT, EXCEPT) éliminent automatiquement les doublons

## Les quatre opérateurs d'ensemble

SQL Server propose **quatre opérateurs d'ensemble** principaux :

| Opérateur | Fonction | Équivalent mathématique |
|-----------|----------|-------------------------|
| **UNION** | Combine en éliminant les doublons | A ∪ B |
| **UNION ALL** | Combine en gardant les doublons | A + B |
| **INTERSECT** | Garde seulement les éléments communs | A ∩ B |
| **EXCEPT** | Garde ce qui est dans A mais pas dans B | A - B |

### Représentation visuelle (diagrammes de Venn)

```
         UNION                    UNION ALL
    ┌─────────────┐              ┌─────────────┐
    │ A       B   │              │ A       B   │
    │  ┌──────────┤              │  ┌──────────┤
    │  │  ∩   │   │              │  │  ∩   │   │
    │  └──────────┤              │  └──────────┤
    │   Tout      │              │ Tout + dups │
    └─────────────┘              └─────────────┘
     (sans doublons)              (avec doublons)

       INTERSECT                     EXCEPT
    ┌─────────┐                  ┌─────────┐
    │         │                  │ A       │
    │   ┌─┐   │                  │  ┌──────┤
    │   │∩│   │                  │  │      │
    │   └─┘   │                  │  └──────┤
    │ Commun  │                  │  A-B    │
    └─────────┘                  └─────────┘
   (intersection)               (différence)
```

## Aperçu de chaque opérateur

### 1. UNION - Combiner en éliminant les doublons

**Ce qu'il fait :** Combine les résultats de deux requêtes et **élimine automatiquement les doublons**.

**Exemple simple :**
```sql
SELECT Nom FROM EmployesParis    -- Alice, Bob, Charlie
UNION
SELECT Nom FROM EmployesLyon;    -- Bob, David, Eve
-- Résultat : Alice, Bob, Charlie, David, Eve (Bob n'apparaît qu'une fois)
```

**Quand l'utiliser :**
- Fusionner des listes provenant de plusieurs sources
- Créer une liste unique d'éléments
- Quand les doublons sont indésirables

### 2. UNION ALL - Combiner en gardant les doublons

**Ce qu'il fait :** Combine les résultats de deux requêtes et **garde tous les doublons**.

**Exemple simple :**
```sql
SELECT Nom FROM EmployesParis    -- Alice, Bob, Charlie
UNION ALL
SELECT Nom FROM EmployesLyon;    -- Bob, David, Eve
-- Résultat : Alice, Bob, Charlie, Bob, David, Eve (Bob apparaît deux fois)
```

**Quand l'utiliser :**
- Consolider des données partitionnées (par mois, année, région)
- Quand vous savez qu'il n'y a pas de doublons
- Quand la performance est critique (5-10x plus rapide que UNION)

### 3. INTERSECT - Trouver les éléments communs

**Ce qu'il fait :** Retourne uniquement les lignes qui apparaissent dans **les deux** requêtes.

**Exemple simple :**
```sql
SELECT Nom FROM EmployesParis    -- Alice, Bob, Charlie
INTERSECT
SELECT Nom FROM EmployesLyon;    -- Bob, David, Eve
-- Résultat : Bob (seul nom présent dans les deux listes)
```

**Quand l'utiliser :**
- Identifier les éléments communs à deux ensembles
- Clients présents sur plusieurs canaux
- Produits disponibles dans tous les entrepôts

### 4. EXCEPT - Trouver la différence

**Ce qu'il fait :** Retourne les lignes de la première requête qui ne sont **pas** dans la seconde.

**Exemple simple :**
```sql
SELECT Nom FROM EmployesParis    -- Alice, Bob, Charlie
EXCEPT
SELECT Nom FROM EmployesLyon;    -- Bob, David, Eve
-- Résultat : Alice, Charlie (présents à Paris mais pas à Lyon)
```

**Quand l'utiliser :**
- Trouver ce qui manque dans un ensemble
- Clients inscrits mais non actifs
- Produits en catalogue mais en rupture de stock

## Règles communes à tous les opérateurs d'ensemble

### Règle 1 : Même nombre de colonnes

Les requêtes combinées doivent avoir le **même nombre de colonnes**.

```sql
-- ❌ ERREUR : Nombre de colonnes différent
SELECT Nom, Prenom FROM Employes
UNION
SELECT Nom FROM Clients;  -- Seulement 2 colonnes !
```

```sql
-- ✅ CORRECT : Même nombre de colonnes
SELECT Nom, Prenom FROM Employes
UNION
SELECT Nom, Prenom FROM Clients;
```

**Solution si les colonnes diffèrent :**
```sql
-- Ajouter NULL ou une constante
SELECT Nom, Prenom FROM Employes
UNION
SELECT Nom, NULL AS Prenom FROM Clients;
```

### Règle 2 : Types de données compatibles

Les colonnes correspondantes doivent avoir des **types de données compatibles**.

```sql
-- ❌ ERREUR : Types incompatibles
SELECT ClientID, NomClient FROM Clients  -- INT, VARCHAR
UNION
SELECT NomClient, ClientID FROM Autres;  -- VARCHAR, INT (ordre inversé !)
```

**Types compatibles :**
- INT ↔ BIGINT, DECIMAL, SMALLINT
- VARCHAR ↔ NVARCHAR, CHAR, VARCHAR(MAX)
- DATE ↔ DATETIME, DATETIME2

> ⚠️ Les types dépréciés `TEXT`/`NTEXT`/`IMAGE` ne peuvent **pas** apparaître dans un `UNION`/`INTERSECT`/`EXCEPT` : ils ne sont ni comparables ni triables. Utilisez `VARCHAR(MAX)`/`NVARCHAR(MAX)`/`VARBINARY(MAX)`.

### Règle 3 : Noms de colonnes du premier SELECT

Le résultat final utilise les **noms de colonnes de la première requête**.

```sql
SELECT
    ClientID AS ID,
    NomClient AS Nom
FROM Clients

UNION

SELECT
    ClientID AS Identifiant,  -- Ce nom est ignoré
    NomClient AS NomComplet   -- Ce nom est ignoré
FROM Prospects;

-- Les colonnes du résultat s'appellent "ID" et "Nom"
```

### Règle 4 : ORDER BY uniquement à la fin

La clause `ORDER BY` ne peut être utilisée qu'**après tous les opérateurs d'ensemble**.

```sql
-- ❌ ERREUR : ORDER BY dans une requête intermédiaire
SELECT Nom FROM Employes
ORDER BY Nom  -- Erreur !
UNION
SELECT Nom FROM Clients;
```

```sql
-- ✅ CORRECT : ORDER BY à la fin
SELECT Nom FROM Employes
UNION
SELECT Nom FROM Clients
ORDER BY Nom;  -- Tri du résultat final
```

### Règle 5 : Comparaison sur toutes les colonnes

Les opérateurs d'ensemble (sauf UNION ALL) comparent **toutes les colonnes** pour déterminer l'égalité.

```sql
-- Deux lignes sont considérées identiques si TOUTES les colonnes correspondent
SELECT ClientID, NomClient, Ville FROM Clients
UNION
SELECT ClientID, NomClient, Ville FROM Prospects;

-- Une ligne (1, 'Dupont', 'Paris') et (1, 'Dupont', 'Lyon')
-- sont DIFFÉRENTES (la ville diffère)
```

### Règle 6 : INTERSECT est prioritaire

Quand plusieurs opérateurs **différents** sont combinés, `INTERSECT` est évalué **en premier** (priorité plus élevée) ; `UNION` et `EXCEPT` ont la même priorité et sont évalués de **gauche à droite**.

```sql
-- INTERSECT est évalué AVANT le UNION :
SELECT col FROM A
UNION
SELECT col FROM B
INTERSECT
SELECT col FROM C;
-- équivaut à :  A UNION (B INTERSECT C)
```

Pour imposer un autre ordre, utilisez des **parenthèses** :

```sql
(SELECT col FROM A
 UNION
 SELECT col FROM B)
INTERSECT
SELECT col FROM C;
-- force : (A UNION B) INTERSECT C
```

## Contexte : Tables d'exemple

Pour illustrer les concepts, utilisons des tables simples :

**Table EmployesParis**
| EmployeID | Nom | Poste |
|-----------|---------|-----------|
| 1 | Alice | Manager |
| 2 | Bob | Développeur |
| 3 | Charlie | Designer |

**Table EmployesLyon**
| EmployeID | Nom | Poste |
|-----------|---------|-----------|
| 4 | Bob | Développeur |
| 5 | David | Manager |
| 6 | Eve | Développeur |

**Table ClientsEnLigne**
| ClientID | NomClient |
|----------|-----------|
| 1 | Dupont |
| 2 | Martin |
| 3 | Bernard |

**Table ClientsMagasin**
| ClientID | NomClient |
|----------|-----------|
| 2 | Martin |
| 3 | Bernard |
| 4 | Dubois |

## Exemples comparatifs

Voyons comment chaque opérateur traite les mêmes données.

### Scénario : Combiner les employés de deux bureaux

**Données :**
- Paris : Alice, Bob, Charlie
- Lyon : Bob, David, Eve

#### Avec UNION (élimine Bob en doublon)
```sql
SELECT Nom FROM EmployesParis
UNION
SELECT Nom FROM EmployesLyon;
```
**Résultat :** Alice, Bob, Charlie, David, Eve (5 personnes)

#### Avec UNION ALL (garde Bob deux fois)
```sql
SELECT Nom FROM EmployesParis
UNION ALL
SELECT Nom FROM EmployesLyon;
```
**Résultat :** Alice, Bob, Charlie, Bob, David, Eve (6 entrées)

#### Avec INTERSECT (seulement Bob)
```sql
SELECT Nom FROM EmployesParis
INTERSECT
SELECT Nom FROM EmployesLyon;
```
**Résultat :** Bob (1 personne présente dans les deux bureaux)

#### Avec EXCEPT (Alice et Charlie)
```sql
SELECT Nom FROM EmployesParis
EXCEPT
SELECT Nom FROM EmployesLyon;
```
**Résultat :** Alice, Charlie (2 personnes seulement à Paris)

### Tableau récapitulatif

| Opérateur | Résultat | Nombre de lignes |
|-----------|----------|------------------|
| UNION | Alice, Bob, Charlie, David, Eve | 5 |
| UNION ALL | Alice, Bob, Charlie, Bob, David, Eve | 6 |
| INTERSECT | Bob | 1 |
| EXCEPT (Paris - Lyon) | Alice, Charlie | 2 |
| EXCEPT (Lyon - Paris) | David, Eve | 2 |

## Opérateurs d'ensemble vs autres approches

### Opérateurs d'ensemble vs JOIN

**Les opérateurs d'ensemble et les jointures résolvent des problèmes différents :**

| Aspect | Opérateurs d'ensemble | JOIN |
|--------|----------------------|------|
| **Objectif** | Combiner des **lignes** verticalement | Combiner des **colonnes** horizontalement |
| **Structure** | Même structure de colonnes requise | Peut avoir des structures différentes |
| **Résultat** | Ajoute des lignes | Ajoute des colonnes |
| **Relation** | Pas de relation nécessaire | Nécessite une relation (clé) |

**Visualisation :**

```
Opérateurs d'ensemble (vertical) :
    Table A          Table B          Résultat
    ┌─────┐         ┌─────┐          ┌─────┐
    │  1  │         │  4  │          │  1  │
    │  2  │   +     │  5  │    =     │  2  │
    │  3  │         │  6  │          │  3  │
    └─────┘         └─────┘          │  4  │
                                     │  5  │
                                     │  6  │
                                     └─────┘
                 (Plus de lignes)

JOIN (horizontal) :
    Table A          Table B          Résultat
    ┌────┐          ┌────┐           ┌────┬────┐
    │ A1 │          │ B1 │           │ A1 │ B1 │
    │ A2 │   +      │ B2 │    =      │ A2 │ B2 │
    └────┘          └────┘           └────┴────┘
              (Plus de colonnes)
```

**Exemple JOIN vs UNION :**

```sql
-- JOIN : Associe des informations (horizontal)
SELECT E.Nom, D.NomDepartement
FROM Employes E
INNER JOIN Departements D ON E.DepartementID = D.DepartementID;
-- Résultat : Une colonne avec les noms, une colonne avec les départements

-- UNION : Combine des listes (vertical)
SELECT Nom FROM EmployesParis
UNION
SELECT Nom FROM EmployesLyon;
-- Résultat : Une seule colonne avec tous les noms
```

### Quand utiliser quoi ?

**Utilisez les opérateurs d'ensemble quand :**
- Vous combinez des données de **même structure**
- Vous fusionnez des listes similaires
- Vous comparez des ensembles (intersection, différence)
- Vous consolidez des données partitionnées

**Utilisez JOIN quand :**
- Vous associez des informations de **tables différentes**
- Vous enrichissez des données avec d'autres données
- Vous avez besoin de colonnes des deux tables
- Il existe une relation entre les tables

## Cas d'usage typiques des opérateurs d'ensemble

### 1. Consolidation de données partitionnées

**Problème :** Les données sont réparties par période, région, ou type.

```sql
-- Consolider les ventes de tous les mois
SELECT * FROM VentesJanvier
UNION ALL
SELECT * FROM VentesFevrier
UNION ALL
SELECT * FROM VentesMars;
```

### 2. Listes de diffusion

**Problème :** Créer une liste unique d'emails pour un mailing.

```sql
-- Tous les emails uniques (clients + prospects)
SELECT Email FROM Clients
UNION
SELECT Email FROM Prospects;
```

### 3. Analyse multi-canal

**Problème :** Identifier les clients présents sur plusieurs canaux.

```sql
-- Clients ayant acheté EN LIGNE ET en magasin
SELECT ClientID FROM VentesEnLigne
INTERSECT
SELECT ClientID FROM VentesMagasin;
```

### 4. Détection de manques

**Problème :** Identifier ce qui manque dans un ensemble.

```sql
-- Produits en catalogue mais PAS en stock
SELECT ProduitID FROM Catalogue
EXCEPT
SELECT ProduitID FROM Stock WHERE Quantite > 0;
```

### 5. Rapports avec totaux

**Problème :** Créer des rapports avec lignes de détail et totaux.

```sql
-- Détails + ligne de total
SELECT Vendeur, Montant, 'Détail' AS Type
FROM Ventes
UNION ALL
SELECT 'TOTAL', SUM(Montant), 'Total'
FROM Ventes;
```

## Performances des opérateurs d'ensemble

### Coût relatif

| Opérateur | Coût relatif | Raison |
|-----------|--------------|--------|
| **UNION ALL** | ✅ Faible | Simple concaténation |
| **UNION** | ⚠️ Moyen | Tri + élimination des doublons |
| **INTERSECT** | ⚠️ Moyen | Tri + comparaison |
| **EXCEPT** | ⚠️ Moyen | Tri + comparaison + soustraction |

### Facteurs de performance

**1. Élimination des doublons**
- UNION, INTERSECT, EXCEPT doivent trier et comparer
- UNION ALL est beaucoup plus rapide (pas de traitement supplémentaire)

**2. Volume de données**
- Plus il y a de lignes, plus le tri est coûteux
- Le coût du tri croît en O(n log n) : plus que linéairement, mais ce n'est **pas** exponentiel

**3. Nombre de colonnes**
- Plus de colonnes = plus de comparaisons
- Limitez aux colonnes nécessaires

**4. Index**
- Les index sur les colonnes comparées améliorent les performances
- Particulièrement important pour INTERSECT et EXCEPT

### Exemple de différence de performance

```sql
-- Test sur 100,000 lignes par table

-- UNION ALL : ~100ms (simple combinaison)
SELECT * FROM Table1
UNION ALL
SELECT * FROM Table2;

-- UNION : ~850ms (tri + élimination doublons)
SELECT * FROM Table1
UNION
SELECT * FROM Table2;
```

**Gain de performance : 8.5x plus rapide avec UNION ALL !**

## Bonnes pratiques

### 1. Utiliser UNION ALL quand possible

```sql
-- ❌ UNION inutile si pas de doublons possibles
SELECT ClientID FROM Commandes2023  -- IDs uniques
UNION
SELECT ClientID FROM Commandes2024;

-- ✅ UNION ALL plus rapide, même résultat
SELECT ClientID FROM Commandes2023
UNION ALL
SELECT ClientID FROM Commandes2024;
```

### 2. Filtrer avant de combiner

```sql
-- ❌ Moins efficace : Filtre après UNION
SELECT * FROM (
    SELECT * FROM Table1
    UNION
    SELECT * FROM Table2
) AS Combined
WHERE Date >= '2024-01-01';

-- ✅ Plus efficace : Filtre avant UNION
SELECT * FROM Table1 WHERE Date >= '2024-01-01'
UNION
SELECT * FROM Table2 WHERE Date >= '2024-01-01';
```

### 3. Limiter le nombre de colonnes

```sql
-- ❌ Toutes les colonnes (coûteux)
SELECT * FROM Table1
UNION
SELECT * FROM Table2;

-- ✅ Seulement les colonnes nécessaires
SELECT ClientID, NomClient FROM Table1
UNION
SELECT ClientID, NomClient FROM Table2;
```

### 4. Ajouter des identifiants de source

```sql
-- ✅ Tracer l'origine des données
SELECT ClientID, NomClient, 'EnLigne' AS Source
FROM ClientsEnLigne
UNION ALL
SELECT ClientID, NomClient, 'Magasin'
FROM ClientsMagasin;
```

### 5. Documenter l'intention

```sql
-- ✅ Commenter le choix de l'opérateur
-- UNION ALL utilisé car les données sont partitionnées par mois
-- (pas de risque de doublon entre janvier et février)
SELECT * FROM VentesJanvier
UNION ALL
SELECT * FROM VentesFevrier;
```

### 6. Utiliser des CTE pour la clarté

```sql
-- ✅ Structure claire avec CTE
WITH
    VentesOnline AS (
        SELECT ClientID FROM VentesEnLigne
        WHERE DateVente >= '2024-01-01'
    ),
    VentesMagasin AS (
        SELECT ClientID FROM VentesMagasin
        WHERE DateVente >= '2024-01-01'
    )
SELECT ClientID FROM VentesOnline
UNION
SELECT ClientID FROM VentesMagasin;
```

## Limitations et considérations

### 1. Pas de ORDER BY intermédiaire

```sql
-- ❌ Impossible
SELECT * FROM Table1 ORDER BY Col1
UNION
SELECT * FROM Table2;
```

**Workaround :** Utiliser une sous-requête ou CTE si nécessaire

```sql
-- ✅ Solution avec sous-requête
SELECT * FROM (SELECT TOP 10 * FROM Table1 ORDER BY Col1) AS T1
UNION
SELECT * FROM Table2;
```

### 2. Types de données strictement compatibles

SQL Server convertit automatiquement certains types, mais pas tous.

```sql
-- ⚠️ Perte de précision possible
SELECT ClientID, 100 AS Valeur      -- INT
UNION
SELECT ClientID, 100.5 AS Valeur;   -- DECIMAL
-- La première valeur sera convertie en DECIMAL
```

### 3. NULL considérés égaux

Dans les opérateurs d'ensemble, deux valeurs NULL sont **considérées égales**.

```sql
SELECT 'Alice', NULL
UNION
SELECT 'Alice', NULL;
-- Résultat : Une seule ligne (les NULL sont égaux)
```

### 4. Performance sur de très gros volumes

Pour des dizaines de millions de lignes, considérez des alternatives :
- Tables temporaires avec index
- Vues matérialisées
- Partitionnement de tables

## Opérateurs d'ensemble vs sous-requêtes

Certains cas peuvent être résolus avec soit des opérateurs d'ensemble, soit des sous-requêtes.

**Trouver les clients communs :**

```sql
-- Avec INTERSECT (clair et concis)
SELECT ClientID FROM ClientsEnLigne
INTERSECT
SELECT ClientID FROM ClientsMagasin;

-- Avec sous-requête IN (plus verbeux)
SELECT ClientID FROM ClientsEnLigne
WHERE ClientID IN (SELECT ClientID FROM ClientsMagasin);

-- Avec EXISTS (plus performant sur gros volumes)
SELECT ClientID FROM ClientsEnLigne C1
WHERE EXISTS (
    SELECT 1 FROM ClientsMagasin C2
    WHERE C2.ClientID = C1.ClientID
);
```

**Quand préférer les opérateurs d'ensemble :**
- L'intention est claire (union, intersection, différence)
- Vous travaillez avec des ensembles complets
- La lisibilité est importante

**Quand préférer les sous-requêtes :**
- Vous avez besoin de plus de flexibilité
- La performance est critique (EXISTS peut être plus rapide)
- Vous avez des conditions complexes

## Plan des sections suivantes

Dans les sections qui suivent, nous allons approfondir chaque opérateur d'ensemble :

- **4.4.1 UNION** : Combiner en éliminant les doublons
- **4.4.2 UNION ALL** : Combiner en conservant les doublons
- **4.4.3 INTERSECT** : Trouver les éléments communs
- **4.4.4 EXCEPT** : Trouver les différences

Chaque section explorera en détail la syntaxe, les cas d'usage, les performances et les bonnes pratiques spécifiques à chaque opérateur.

## Résumé

Les **opérateurs d'ensemble** permettent de combiner les résultats de plusieurs requêtes SELECT de manière verticale (en ajoutant des lignes).

### Les quatre opérateurs

| Opérateur | Fonction | Doublons | Performance |
|-----------|----------|----------|-------------|
| **UNION** | Combine tout (unique) | Éliminés | Moyen |
| **UNION ALL** | Combine tout (avec dups) | Conservés | Rapide |
| **INTERSECT** | Éléments communs | Éliminés | Moyen |
| **EXCEPT** | Différence (A - B) | Éliminés | Moyen |

### Règles communes

1. **Même nombre de colonnes** dans les deux requêtes
2. **Types de données compatibles** pour les colonnes correspondantes
3. **Noms de la première requête** utilisés dans le résultat
4. **ORDER BY seulement à la fin** après tous les opérateurs
5. **Comparaison sur toutes les colonnes** pour l'égalité

### Quand les utiliser ?

✅ **Opérateurs d'ensemble :**
- Combiner des données de même structure
- Comparer des ensembles (communs, différences)
- Consolider des données partitionnées
- Créer des listes uniques

❌ **Pas adaptés pour :**
- Associer des informations de tables différentes → Utilisez JOIN
- Enrichir des données → Utilisez JOIN
- Conditions très complexes → Utilisez sous-requêtes

### Points clés

1. **UNION ALL est le plus rapide** - utilisez-le quand possible
2. **L'ordre compte avec EXCEPT** - A EXCEPT B ≠ B EXCEPT A
3. **Filtrez avant de combiner** - pour de meilleures performances
4. **Limitez les colonnes** - comparaisons plus rapides
5. **Documentez votre choix** - expliquez pourquoi cet opérateur

Les opérateurs d'ensemble sont des outils puissants pour manipuler des ensembles de données. Leur syntaxe simple et leur sémantique claire en font un choix excellent pour de nombreux scénarios de consolidation et de comparaison de données.

Dans les sections suivantes, nous explorerons chaque opérateur en détail avec de nombreux exemples pratiques !

⏭️ [UNION (Suppression des doublons)](/04-techniques-de-requetage-avancees/04.1-union.md)
