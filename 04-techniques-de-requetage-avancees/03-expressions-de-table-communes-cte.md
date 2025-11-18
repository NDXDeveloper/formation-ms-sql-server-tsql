🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 4.3 Expressions de Table Communes (CTE)

## Introduction

Les **CTE** (Common Table Expressions), ou **Expressions de Table Communes** en français, sont l'une des fonctionnalités les plus puissantes et les plus élégantes de T-SQL. Introduites avec SQL Server 2005, elles ont révolutionné la façon d'écrire des requêtes SQL complexes en offrant une alternative plus lisible et plus flexible aux sous-requêtes traditionnelles.

### Qu'est-ce qu'une CTE ?

Une CTE est un **ensemble de résultats temporaire nommé** que vous pouvez référencer dans une instruction SELECT, INSERT, UPDATE ou DELETE. C'est comme créer une "table virtuelle" qui n'existe que le temps d'exécution de votre requête.

**Analogie simple :**
Imaginez que vous préparez un repas complexe :
- **Sans CTE** : Vous faites tout en même temps dans une seule casserole géante, en mélangeant tous les ingrédients
- **Avec CTE** : Vous préparez chaque composant dans un récipient séparé avec une étiquette claire, puis vous les assemblez à la fin

Les CTE vous permettent de **nommer** vos étapes intermédiaires, rendant votre code SQL plus structuré et plus facile à comprendre.

## Pourquoi les CTE ont changé la donne ?

### Le problème avec les approches traditionnelles

Avant les CTE, pour écrire des requêtes complexes, vous aviez principalement trois options :

#### Option 1 : Sous-requêtes imbriquées (difficiles à lire)

```sql
-- Exemple : Trouver les départements avec salaire moyen > moyenne générale
SELECT DepartementID, SalaireMoyen
FROM (
    SELECT DepartementID, AVG(Salaire) AS SalaireMoyen
    FROM Employes
    GROUP BY DepartementID
) AS Stats
WHERE SalaireMoyen > (
    SELECT AVG(MoyenneDept)
    FROM (
        SELECT AVG(Salaire) AS MoyenneDept
        FROM Employes
        GROUP BY DepartementID
    ) AS Moyennes
);
```

**Problèmes :**
- ❌ Difficile à lire (imbrication complexe)
- ❌ On doit lire "de l'intérieur vers l'extérieur"
- ❌ Impossible de réutiliser un résultat intermédiaire
- ❌ Difficile à déboguer

#### Option 2 : Tables temporaires (verbose)

```sql
-- Étape 1 : Créer une table temporaire
CREATE TABLE #Stats (
    DepartementID INT,
    SalaireMoyen DECIMAL(10,2)
);

-- Étape 2 : Insérer les données
INSERT INTO #Stats
SELECT DepartementID, AVG(Salaire)
FROM Employes
GROUP BY DepartementID;

-- Étape 3 : Utiliser la table
SELECT * FROM #Stats WHERE SalaireMoyen > 3000;

-- Étape 4 : Nettoyer
DROP TABLE #Stats;
```

**Problèmes :**
- ❌ Verbeux (4 étapes pour une logique simple)
- ❌ Nécessite la gestion (CREATE/DROP)
- ❌ Impact sur tempdb
- ❌ Pollution de l'espace de noms

#### Option 3 : Vues (trop permanentes)

```sql
-- Créer une vue (permanente)
CREATE VIEW VueSalairesMoyens AS
SELECT DepartementID, AVG(Salaire) AS SalaireMoyen
FROM Employes
GROUP BY DepartementID;

-- Utiliser la vue
SELECT * FROM VueSalairesMoyens WHERE SalaireMoyen > 3000;
```

**Problèmes :**
- ❌ Permanente (stockée dans la base)
- ❌ Nécessite des permissions CREATE VIEW
- ❌ Peut polluer le schéma de la base
- ❌ Pas adaptée pour de la logique ponctuelle

### La solution : Les CTE

Les CTE combinent les **avantages** de toutes ces approches sans leurs inconvénients :

```sql
WITH SalairesMoyens AS (
    -- Première étape : Calculer les moyennes
    SELECT DepartementID, AVG(Salaire) AS SalaireMoyen
    FROM Employes
    GROUP BY DepartementID
)
-- Deuxième étape : Utiliser les moyennes
SELECT *
FROM SalairesMoyens
WHERE SalaireMoyen > 3000;
```

**Avantages :**
- ✅ **Lisible** : Se lit de haut en bas, comme un texte normal
- ✅ **Nommé** : `SalairesMoyens` explique ce que contient le résultat
- ✅ **Temporaire** : N'existe que pour cette requête
- ✅ **Simple** : Pas de gestion CREATE/DROP
- ✅ **Réutilisable** : Peut être référencé plusieurs fois
- ✅ **Modulaire** : Facile de tester chaque partie

## Aperçu conceptuel des CTE

### Structure de base

Une CTE commence toujours par le mot-clé `WITH` et se compose de deux parties :

```sql
WITH NomDeLaCTE AS (
    -- PARTIE 1 : Définition
    -- Une requête SELECT qui définit le contenu de la CTE
    SELECT colonnes
    FROM table
    WHERE conditions
)
-- PARTIE 2 : Utilisation
-- La requête principale qui utilise la CTE
SELECT *
FROM NomDeLaCTE
WHERE autres_conditions;
```

### Plusieurs CTE dans une seule requête

Vous pouvez définir **plusieurs CTE** séparés par des virgules :

```sql
WITH
    CTE1 AS (
        SELECT ...
    ),
    CTE2 AS (
        SELECT ...
        FROM CTE1  -- Peut utiliser CTE1
    ),
    CTE3 AS (
        SELECT ...
    )
-- Requête finale utilisant les CTE
SELECT *
FROM CTE1
JOIN CTE2 ON ...
WHERE ...;
```

## Les trois grands types de CTE

### 1. CTE simples (non récursifs)

Les plus courants, utilisés pour améliorer la lisibilité et structurer le code.

```sql
WITH VentesParClient AS (
    SELECT ClientID, SUM(Montant) AS Total
    FROM Ventes
    GROUP BY ClientID
)
SELECT *
FROM VentesParClient
WHERE Total > 10000;
```

**Usage typique :**
- Simplifier des requêtes complexes
- Nommer des résultats intermédiaires
- Éviter la répétition de code
- Améliorer la maintenabilité

### 2. CTE récursifs

Une fonctionnalité unique et puissante qui permet à un CTE de **se référencer lui-même**.

```sql
WITH HierarchieEmployes AS (
    -- Point de départ
    SELECT EmployeID, NomEmploye, ManagerID, 0 AS Niveau
    FROM Employes
    WHERE ManagerID IS NULL

    UNION ALL

    -- Récursion : Le CTE se référence lui-même
    SELECT E.EmployeID, E.NomEmploye, E.ManagerID, H.Niveau + 1
    FROM Employes E
    INNER JOIN HierarchieEmployes H ON E.ManagerID = H.EmployeID
)
SELECT * FROM HierarchieEmployes;
```

**Usage typique :**
- Parcourir des hiérarchies (organigrammes)
- Gérer des structures en arbre (catégories)
- Explorer des graphes (réseaux sociaux)
- Générer des séquences (dates, nombres)

### 3. CTE multiples chaînés

Plusieurs CTE qui s'enchaînent, chacun utilisant les résultats du précédent.

```sql
WITH
    Etape1 AS (
        SELECT ... -- Extraction
    ),
    Etape2 AS (
        SELECT ... FROM Etape1  -- Transformation
    ),
    Etape3 AS (
        SELECT ... FROM Etape2  -- Enrichissement
    )
SELECT * FROM Etape3;  -- Résultat final
```

**Usage typique :**
- Décomposer une logique complexe en étapes
- Pipeline de transformations de données
- Améliorer la testabilité du code

## Comparaison avec les alternatives

### CTE vs Sous-requêtes (Subqueries)

| Aspect | CTE | Sous-requête |
|--------|-----|--------------|
| **Lisibilité** | ✅ Excellente (noms explicites) | ⚠️ Moyenne (imbrication) |
| **Ordre de lecture** | ✅ Haut en bas | ⚠️ Intérieur vers extérieur |
| **Réutilisation** | ✅ Multiple dans la même requête | ❌ Doit être répétée |
| **Récursivité** | ✅ Supportée | ❌ Impossible |
| **Performance** | 🟰 Similaire | 🟰 Similaire |
| **Débogage** | ✅ Facile (tester séparément) | ⚠️ Plus difficile |

### CTE vs Tables temporaires

| Aspect | CTE | Table temporaire |
|--------|-----|------------------|
| **Portée** | ⚠️ Une seule requête | ✅ Toute la session |
| **Syntaxe** | ✅ Simple et concise | ⚠️ CREATE/INSERT/DROP |
| **Performance** | ✅ Optimisée | ⚠️ Overhead tempdb |
| **Index** | ❌ Non possible | ✅ Possible |
| **Statistiques** | ⚠️ Estimées | ✅ Réelles |
| **Maintenabilité** | ✅ Code auto-contenu | ⚠️ Gestion manuelle |

### CTE vs Vues

| Aspect | CTE | Vue |
|--------|-----|-----|
| **Persistance** | ⚠️ Temporaire | ✅ Permanente |
| **Permissions** | ✅ Aucune requise | ⚠️ CREATE VIEW requise |
| **Réutilisation** | ⚠️ Une requête | ✅ Multiple requêtes/utilisateurs |
| **Maintenance** | ✅ Avec la requête | ⚠️ Objet séparé |
| **Flexibilité** | ✅ Paramétrable dans requête | ⚠️ Fixe |
| **Usage** | ✅ Logique ponctuelle | ✅ Abstraction réutilisable |

## Quand utiliser les CTE ?

### ✅ Situations idéales pour les CTE

1. **Améliorer la lisibilité**
   - Requêtes complexes avec plusieurs étapes logiques
   - Code qui sera maintenu par d'autres développeurs
   - Logique métier qu'on veut documenter clairement

2. **Décomposer des problèmes complexes**
   - Calculs en plusieurs phases
   - Transformations de données en pipeline
   - Agrégations sur des agrégations

3. **Réutiliser des calculs**
   - Même résultat intermédiaire utilisé plusieurs fois
   - Éviter la duplication de code
   - Maintenir la cohérence des calculs

4. **Gérer des hiérarchies**
   - Organigrammes d'entreprise
   - Catégories de produits imbriquées
   - Structures en arbre
   - Navigation dans des graphes

5. **Remplacer les sous-requêtes complexes**
   - Sous-requêtes imbriquées difficiles à lire
   - Multiples niveaux d'imbrication
   - Logique répétée dans plusieurs sous-requêtes

### ⚠️ Quand considérer des alternatives

1. **Tables temporaires si :**
   - Vous avez besoin d'**index** sur les résultats intermédiaires
   - Les résultats sont utilisés dans **plusieurs requêtes** distinctes
   - Vous travaillez avec de **très gros volumes** nécessitant des statistiques réelles
   - Vous devez **modifier** les données intermédiaires (UPDATE/DELETE)

2. **Vues si :**
   - La logique est **réutilisée fréquemment** par plusieurs utilisateurs/applications
   - Vous voulez **abstraire** la complexité de manière permanente
   - Vous avez besoin de **permissions** spécifiques sur l'accès aux données
   - La structure des données change rarement

3. **Sous-requêtes simples si :**
   - La logique est **très simple** (une seule ligne de calcul)
   - Le résultat n'est utilisé qu'**une seule fois**
   - Le code reste **lisible** sans CTE

## Avantages principaux des CTE

### 1. Lisibilité exceptionnelle

**Avant CTE (imbriqué et confus) :**
```sql
SELECT * FROM (
    SELECT * FROM (
        SELECT DepartementID, AVG(Salaire) AS Moy
        FROM Employes GROUP BY DepartementID
    ) T1 WHERE Moy > 3000
) T2 ORDER BY Moy DESC;
```

**Avec CTE (clair et structuré) :**
```sql
WITH MoyennesDept AS (
    SELECT DepartementID, AVG(Salaire) AS Moy
    FROM Employes
    GROUP BY DepartementID
),
DeptsAuDessusSeuil AS (
    SELECT * FROM MoyennesDept WHERE Moy > 3000
)
SELECT * FROM DeptsAuDessusSeuil ORDER BY Moy DESC;
```

### 2. Modularité et testabilité

Chaque CTE peut être testé **indépendamment** :

```sql
WITH Etape1 AS (
    SELECT ... -- Tester : SELECT * FROM Etape1
),
Etape2 AS (
    SELECT ... FROM Etape1  -- Tester : SELECT * FROM Etape2
)
SELECT * FROM Etape2;
```

### 3. Documentation intégrée

Les noms de CTE servent de **documentation vivante** :

```sql
WITH
    ClientsActifs AS (...),          -- Clients ayant commandé dans les 6 mois
    CommandesValidees AS (...),      -- Commandes payées et expédiées
    StatistiquesParClient AS (...)   -- Agrégation des statistiques
SELECT * FROM StatistiquesParClient;
```

### 4. Récursivité unique

Les CTE sont le **seul moyen natif** en T-SQL de gérer la récursivité :

```sql
-- Impossible sans CTE récursif !
WITH OrganigrammeComplet AS (
    SELECT ... WHERE ManagerID IS NULL  -- PDG
    UNION ALL
    SELECT ...
    FROM Employes E
    INNER JOIN OrganigrammeComplet O ON E.ManagerID = O.EmployeID
)
SELECT * FROM OrganigrammeComplet;
```

## Exemples d'utilisation par niveau de complexité

### Niveau débutant : CTE simple

```sql
-- Calculer et utiliser une moyenne
WITH Moyenne AS (
    SELECT AVG(Prix) AS PrixMoyen
    FROM Produits
)
SELECT P.NomProduit, P.Prix, M.PrixMoyen
FROM Produits P
CROSS JOIN Moyenne M
WHERE P.Prix > M.PrixMoyen;
```

### Niveau intermédiaire : CTE multiples

```sql
-- Pipeline de transformations
WITH
    VentesValides AS (
        SELECT * FROM Ventes WHERE Montant > 0
    ),
    VentesParClient AS (
        SELECT ClientID, SUM(Montant) AS Total
        FROM VentesValides
        GROUP BY ClientID
    ),
    ClientsClassifies AS (
        SELECT
            ClientID,
            Total,
            CASE
                WHEN Total > 10000 THEN 'Premium'
                WHEN Total > 5000 THEN 'Standard'
                ELSE 'Basique'
            END AS Categorie
        FROM VentesParClient
    )
SELECT * FROM ClientsClassifies;
```

### Niveau avancé : CTE récursif

```sql
-- Parcourir une hiérarchie complète
WITH HierarchieComplete AS (
    -- Racine
    SELECT EmployeID, NomEmploye, ManagerID, 0 AS Niveau
    FROM Employes
    WHERE ManagerID IS NULL

    UNION ALL

    -- Tous les niveaux suivants
    SELECT E.EmployeID, E.NomEmploye, E.ManagerID, H.Niveau + 1
    FROM Employes E
    INNER JOIN HierarchieComplete H ON E.ManagerID = H.EmployeID
)
SELECT
    REPLICATE('  ', Niveau) + NomEmploye AS Hierarchie,
    Niveau
FROM HierarchieComplete
ORDER BY Niveau, NomEmploye;
```

## Contexte historique et adoption

### Avant SQL Server 2005

Les développeurs devaient utiliser :
- Des procédures stockées complexes avec curseurs
- Des tables temporaires multiples
- Du code applicatif pour gérer les hiérarchies
- Des sous-requêtes imbriquées difficiles à maintenir

### Depuis SQL Server 2005

Les CTE ont été introduites et sont rapidement devenues un **standard de l'industrie** :
- Adoptées massivement par les développeurs
- Enseignées dans toutes les formations SQL modernes
- Considérées comme une **bonne pratique** pour le code complexe
- Supportées par tous les SGBD majeurs (SQL Server, PostgreSQL, Oracle, MySQL 8+)

### Évolution continue

Les CTE continuent d'évoluer :
- **SQL Server 2008** : Améliorations des performances
- **SQL Server 2012** : Meilleure optimisation des CTE récursifs
- **SQL Server 2016+** : Intégration avec les nouvelles fonctionnalités (JSON, etc.)
- **SQL Server 2019+** : Optimisations pour les gros volumes

## Ce que vous allez apprendre

Dans les sections suivantes de ce chapitre, nous allons explorer en détail :

### 4.3.1 Syntaxe WITH ... AS (...)
- Structure complète d'un CTE
- Comment définir et utiliser un CTE
- CTE simples vs CTE multiples
- Bonnes pratiques de nommage
- Limitations et précautions

### 4.3.2 Avantages (Lisibilité, récursivité)
- Comment les CTE améliorent la lisibilité
- Comparaisons avant/après avec des exemples concrets
- Introduction à la récursivité
- CTE récursifs : structure et fonctionnement
- Cas d'usage de la récursivité

### 4.3.3 CTE récursives (Concepts de base pour hiérarchies)
- Structures hiérarchiques en profondeur
- Patterns de navigation (top-down, bottom-up)
- Calcul de chemins hiérarchiques
- Techniques avancées (détection de cycles, comptage de descendants)
- Optimisation et performances
- Exemples pratiques par domaine

## Résumé

Les **CTE (Common Table Expressions)** sont des ensembles de résultats temporaires nommés qui révolutionnent la façon d'écrire du SQL complexe :

### Points clés

✅ **Avantages :**
- **Lisibilité** : Code structuré et auto-documenté
- **Modularité** : Décomposition logique des problèmes
- **Récursivité** : Gestion élégante des hiérarchies
- **Réutilisabilité** : Même résultat référencé plusieurs fois
- **Testabilité** : Chaque CTE peut être testé séparément

⚠️ **Caractéristiques :**
- Temporaires (existent pour une seule requête)
- Pas de matérialisation garantie
- Pas d'index possibles
- Limite de récursion par défaut (100 niveaux)

### Syntaxe de base

```sql
WITH NomCTE AS (
    SELECT ...
)
SELECT * FROM NomCTE;
```

### Quand les utiliser ?

- ✅ Requêtes complexes nécessitant plusieurs étapes
- ✅ Code devant être maintenu et compris par d'autres
- ✅ Réutilisation de résultats intermédiaires
- ✅ Hiérarchies et structures en arbre
- ✅ Remplacement de sous-requêtes imbriquées

### Impact sur votre code SQL

Les CTE transforment votre approche du développement SQL :
- **Avant** : Code monolithique difficile à comprendre
- **Après** : Code structuré, lisible et maintenable

Les CTE sont devenus un **standard moderne** en T-SQL. Leur maîtrise est essentielle pour tout développeur SQL professionnel cherchant à écrire du code de qualité, maintenable et élégant.

Dans les sections suivantes, nous allons explorer en détail comment tirer le meilleur parti de cette fonctionnalité puissante !

⏭️ [Syntaxe WITH ... AS (...)](/04-techniques-de-requetage-avancees/03.1-syntaxe-with-as.md)
