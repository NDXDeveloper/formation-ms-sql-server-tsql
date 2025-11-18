🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 5.8 SQL Dynamique

## Introduction générale

Bienvenue dans le chapitre sur le **SQL Dynamique** (Dynamic SQL) ! Cette technique puissante mais parfois controversée permet de construire et d'exécuter des requêtes SQL "à la volée", au moment de l'exécution, plutôt que de les écrire de manière fixe dans votre code.

### Qu'est-ce que le SQL Dynamique ?

Le **SQL Dynamique** est la capacité de :
1. **Construire** une requête SQL sous forme de chaîne de caractères
2. **Exécuter** cette chaîne comme si c'était du véritable code SQL

En d'autres termes, votre programme écrit du code SQL, puis l'exécute.

### SQL Statique vs SQL Dynamique

#### SQL Statique (Ce que vous connaissez déjà)

Le SQL **statique** est écrit directement dans votre code, et sa structure est connue à l'avance :

```sql
-- SQL Statique : Requête figée dans le code
SELECT * FROM Clients WHERE ClientID = 5;

-- Procédure avec SQL statique
CREATE PROCEDURE sp_GetClient
    @ClientID INT
AS
BEGIN
    SELECT * FROM Clients WHERE ClientID = @ClientID;
    --            ↑
    -- La structure de la requête est FIXE
END;
```

**Caractéristiques** :
- ✅ La requête est écrite une fois pour toutes
- ✅ SQL Server peut la vérifier lors de la compilation
- ✅ Plus sûr et plus simple
- ❌ Moins flexible

#### SQL Dynamique (Ce que vous allez apprendre)

Le SQL **dynamique** est construit au moment de l'exécution, sous forme de chaîne :

```sql
-- SQL Dynamique : Requête construite au moment de l'exécution
DECLARE @TableName VARCHAR(50) = 'Clients';
DECLARE @SQL NVARCHAR(500);

-- Construction de la requête (c'est du TEXTE)
SET @SQL = 'SELECT * FROM ' + @TableName;
--                            ↑
-- Le nom de la table est VARIABLE

-- Exécution de la chaîne comme du SQL
EXEC(@SQL);
```

**Caractéristiques** :
- ✅ Très flexible, s'adapte aux besoins
- ✅ Permet des structures de requêtes variables
- ❌ Plus complexe à écrire et maintenir
- ⚠️ Risques de sécurité si mal utilisé

### Analogie pour comprendre

Imaginez deux façons de donner des instructions :

**Instructions statiques** (SQL statique) :
```
Recette de cuisine classique :
1. Préchauffer le four à 180°C
2. Mélanger 200g de farine avec 100g de sucre
3. Ajouter 2 œufs
4. Cuire pendant 30 minutes
```
La recette est fixe et ne change jamais.

**Instructions dynamiques** (SQL dynamique) :
```
Recette adaptable :
1. Préchauffer le four à [température choisie]°C
2. Mélanger [quantité] de farine avec [quantité] de sucre
3. Ajouter [nombre] œufs
4. Cuire pendant [durée] minutes

Vous construisez la recette finale au moment de cuisiner,
selon ce que vous voulez faire et ce que vous avez sous la main.
```

De même, le SQL dynamique vous permet de construire votre requête selon le contexte.

## Pourquoi utiliser le SQL Dynamique ?

### Raison 1 : Noms d'objets variables

En SQL standard, vous ne pouvez pas utiliser de variable pour un nom de table ou de colonne :

```sql
-- ❌ CECI NE FONCTIONNE PAS
DECLARE @MaTable VARCHAR(50) = 'Clients';
SELECT * FROM @MaTable;  -- ERREUR !

DECLARE @MaColonne VARCHAR(50) = 'Nom';
SELECT @MaColonne FROM Clients;  -- Retourne le texte "Nom", pas la colonne !
```

**Avec SQL dynamique**, c'est possible :

```sql
-- ✅ CECI FONCTIONNE
DECLARE @MaTable VARCHAR(50) = 'Clients';
DECLARE @SQL NVARCHAR(500) = 'SELECT * FROM ' + @MaTable;
EXEC(@SQL);  -- Fonctionne !
```

**Cas d'usage** :
- Outils d'administration qui opèrent sur plusieurs tables
- Génération de rapports sur des tables différentes
- Scripts de maintenance automatisés

### Raison 2 : Construction de requêtes conditionnelles

Parfois, vous voulez construire une requête différente selon les paramètres fournis :

```sql
-- Sans SQL dynamique : Code répétitif et complexe
CREATE PROCEDURE sp_SearchClients_Static
    @Nom VARCHAR(50) = NULL,
    @Ville VARCHAR(50) = NULL,
    @AgeMin INT = NULL
AS
BEGIN
    -- Vous devez gérer TOUTES les combinaisons possibles !
    IF @Nom IS NOT NULL AND @Ville IS NOT NULL AND @AgeMin IS NOT NULL
        SELECT * FROM Clients WHERE Nom = @Nom AND Ville = @Ville AND Age >= @AgeMin;
    ELSE IF @Nom IS NOT NULL AND @Ville IS NOT NULL
        SELECT * FROM Clients WHERE Nom = @Nom AND Ville = @Ville;
    ELSE IF @Nom IS NOT NULL AND @AgeMin IS NOT NULL
        SELECT * FROM Clients WHERE Nom = @Nom AND Age >= @AgeMin;
    -- ... et ainsi de suite pour TOUTES les combinaisons !
    -- C'est TRÈS répétitif ! 😫
END;
```

**Avec SQL dynamique** :

```sql
-- Plus élégant et maintenable
CREATE PROCEDURE sp_SearchClients_Dynamic
    @Nom VARCHAR(50) = NULL,
    @Ville VARCHAR(50) = NULL,
    @AgeMin INT = NULL
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX) = 'SELECT * FROM Clients WHERE 1=1';

    IF @Nom IS NOT NULL
        SET @SQL = @SQL + ' AND Nom = @Nom_Param';

    IF @Ville IS NOT NULL
        SET @SQL = @SQL + ' AND Ville = @Ville_Param';

    IF @AgeMin IS NOT NULL
        SET @SQL = @SQL + ' AND Age >= @AgeMin_Param';

    -- Une seule exécution avec la requête adaptée
    EXEC sp_executesql @SQL,
         N'@Nom_Param VARCHAR(50), @Ville_Param VARCHAR(50), @AgeMin_Param INT',
         @Nom_Param = @Nom, @Ville_Param = @Ville, @AgeMin_Param = @AgeMin;
END;
```

### Raison 3 : Tri et colonnes dynamiques

Vous ne pouvez pas utiliser de variable pour ORDER BY en SQL statique :

```sql
-- ❌ CECI NE FONCTIONNE PAS
DECLARE @TrierPar VARCHAR(50) = 'Nom';
SELECT * FROM Clients ORDER BY @TrierPar;  -- Trie par la VALEUR "Nom", pas la colonne !
```

**Avec SQL dynamique** :

```sql
-- ✅ CECI FONCTIONNE
DECLARE @TrierPar VARCHAR(50) = 'Nom';
DECLARE @SQL NVARCHAR(500) = 'SELECT * FROM Clients ORDER BY ' + QUOTENAME(@TrierPar);
EXEC sp_executesql @SQL;
```

### Raison 4 : Génération de scripts automatisés

Créer automatiquement des opérations pour toutes les tables d'une base :

```sql
-- Générer un COUNT(*) pour chaque table
DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = @SQL +
    'PRINT ''' + TABLE_NAME + '''; SELECT COUNT(*) FROM ' + TABLE_NAME + ';' + CHAR(13)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

EXEC(@SQL);
-- Exécute automatiquement un COUNT pour chaque table !
```

### Raison 5 : Outils génériques et frameworks

Les outils d'administration, les frameworks ORM, et les générateurs de code utilisent massivement le SQL dynamique pour leur flexibilité.

## Quand NE PAS utiliser le SQL Dynamique

Le SQL dynamique est puissant, mais il a un coût. Voici quand l'**éviter** :

### ❌ Cas 1 : Quand le SQL statique suffit

```sql
-- ❌ INUTILEMENT DYNAMIQUE
DECLARE @SQL NVARCHAR(100) = N'SELECT * FROM Clients WHERE ClientID = 5';
EXEC sp_executesql @SQL;

-- ✅ PLUS SIMPLE EN STATIQUE
SELECT * FROM Clients WHERE ClientID = 5;
```

**Règle** : Si votre requête ne change jamais de structure, utilisez du SQL statique.

### ❌ Cas 2 : Pour contourner un mauvais design

```sql
-- ❌ MAUVAIS : Utiliser le dynamique pour compenser une mauvaise conception
-- Si vous avez 50 tables similaires (Ventes2020, Ventes2021, Ventes2022...),
-- le problème n'est pas que vous avez besoin de SQL dynamique,
-- c'est que votre modèle de données est mal conçu !

-- ✅ MIEUX : Une seule table avec une colonne Annee
SELECT * FROM Ventes WHERE Annee = 2021;
```

### ❌ Cas 3 : Quand vous n'êtes pas sûr de la sécurité

Le SQL dynamique mal écrit est la cause **#1 des injections SQL**. Si vous n'êtes pas certain de pouvoir le sécuriser, n'en utilisez pas.

### ❌ Cas 4 : Quand la performance est critique

Le SQL dynamique a un coût en performance (compilation, pas de vérification anticipée). Pour les requêtes exécutées des millions de fois, préférez le statique.

## Avantages et inconvénients

### ✅ Avantages

**Flexibilité maximale**
- Adapter la requête au contexte d'exécution
- Construire des requêtes impossibles en statique

**Réduction de code**
- Moins de duplication pour les requêtes similaires
- Code plus maintenable dans certains cas

**Outils génériques**
- Créer des utilitaires qui fonctionnent sur n'importe quelle table
- Scripts d'administration automatisés

**Optimisation conditionnelle**
- Générer seulement les clauses nécessaires
- Éviter les "parameter sniffing" dans certains cas

### ⚠️ Inconvénients

**Complexité accrue**
- Plus difficile à écrire et à comprendre
- Débogage plus complexe
- Maintenance plus coûteuse

**Risques de sécurité**
- Vulnérable aux injections SQL si mal implémenté
- Doit être sécurisé avec des paramètres

**Performance**
- Compilation au moment de l'exécution
- Plans d'exécution non optimisés dans certains cas
- Pas de vérification de syntaxe à l'avance

**Perte de clarté**
- Le SQL généré n'est pas visible dans le code
- Difficile de savoir ce qui sera exécuté
- Outils de développement moins utiles

**Gestion des erreurs**
- Erreurs de syntaxe détectées à l'exécution, pas à la compilation
- Messages d'erreur parfois moins clairs

### Tableau récapitulatif

| Critère | SQL Statique | SQL Dynamique |
|---------|--------------|---------------|
| **Simplicité** | ✅ Simple | ⚠️ Complexe |
| **Sécurité** | ✅ Sûr par défaut | ⚠️ Risqué si mal fait |
| **Performance** | ✅ Optimisée | ⚠️ Coût de compilation |
| **Flexibilité** | ❌ Limitée | ✅ Maximum |
| **Débogage** | ✅ Facile | ❌ Difficile |
| **Maintenance** | ✅ Simple | ⚠️ Plus complexe |
| **Vérification** | ✅ À la compilation | ❌ À l'exécution |

## Les deux méthodes d'exécution

SQL Server offre deux façons d'exécuter du SQL dynamique :

### 1. EXEC (ou EXECUTE)

La méthode simple :

```sql
DECLARE @SQL NVARCHAR(500) = 'SELECT * FROM Clients';
EXEC(@SQL);  -- Exécute la chaîne
```

**Avantages** : Simple, direct
**Inconvénients** : Pas de paramètres, moins sécurisé, moins performant

### 2. sp_executesql

La méthode professionnelle avec paramètres :

```sql
DECLARE @SQL NVARCHAR(500) = N'SELECT * FROM Clients WHERE ClientID = @ID';
EXEC sp_executesql @SQL, N'@ID INT', @ID = 5;
```

**Avantages** : Paramètres, sécurisé, performant
**Inconvénients** : Syntaxe plus complexe

**Recommandation** : Utilisez **toujours** `sp_executesql` en production !

## Le danger : L'injection SQL

Le SQL dynamique mal écrit est la cause principale des **injections SQL**, l'une des vulnérabilités les plus dangereuses en informatique.

### Exemple de code dangereux

```sql
-- ❌ DANGEREUX - NE JAMAIS FAIRE CELA !
DECLARE @Nom VARCHAR(50) = 'Dupont';  -- Supposons que cela vienne d'un utilisateur
DECLARE @SQL NVARCHAR(500);

SET @SQL = 'SELECT * FROM Clients WHERE Nom = ''' + @Nom + '''';
EXEC(@SQL);
```

**Problème** : Si un attaquant entre `' OR '1'='1` comme nom :

```sql
-- La requête devient :
SELECT * FROM Clients WHERE Nom = '' OR '1'='1'
-- Retourne TOUS les clients ! 🚨
```

### Exemple de code sécurisé

```sql
-- ✅ SÉCURISÉ - Utilisation de paramètres
DECLARE @Nom VARCHAR(50) = 'Dupont';
DECLARE @SQL NVARCHAR(500);

SET @SQL = N'SELECT * FROM Clients WHERE Nom = @Nom_Param';

EXEC sp_executesql @SQL, N'@Nom_Param VARCHAR(50)', @Nom_Param = @Nom;
-- L'injection est IMPOSSIBLE car @Nom_Param est traité comme une valeur, pas comme du code
```

**Protection** : Avec `sp_executesql` et des paramètres, les données sont séparées du code SQL.

## Concepts clés à comprendre

### Concept 1 : Construction de chaînes

Le SQL dynamique repose sur la **construction de chaînes de caractères** :

```sql
DECLARE @Table VARCHAR(50) = 'Clients';
DECLARE @Colonne VARCHAR(50) = 'Nom';
DECLARE @Valeur VARCHAR(50) = 'Dupont';

-- Construction étape par étape
DECLARE @SQL NVARCHAR(500) = 'SELECT * FROM ';
SET @SQL = @SQL + @Table;           -- Ajoute le nom de table
SET @SQL = @SQL + ' WHERE ';
SET @SQL = @SQL + @Colonne;         -- Ajoute le nom de colonne
SET @SQL = @SQL + ' = ''';
SET @SQL = @SQL + @Valeur;          -- Ajoute la valeur
SET @SQL = @SQL + '''';

-- Résultat : 'SELECT * FROM Clients WHERE Nom = 'Dupont''
PRINT @SQL;  -- Toujours utile pour déboguer !
EXEC(@SQL);
```

### Concept 2 : Gestion des apostrophes

Les apostrophes simples `'` doivent être **doublées** `''` dans les chaînes SQL :

```sql
-- Pour obtenir cette requête :
-- SELECT * FROM Clients WHERE Nom = 'Dupont'
--                                   ↑      ↑
--                                   Ces apostrophes font partie du SQL

-- Il faut écrire :
SET @SQL = 'SELECT * FROM Clients WHERE Nom = ''' + @Nom + '''';
--                                              ↑↑        ↑↑
--                                              Apostrophes doublées
```

**Visualisation** :
```
'                   → Début de la chaîne littérale en T-SQL
SELECT * FROM...    → Le SQL que vous construisez
''                  → Une apostrophe DANS le SQL résultat
' + @Nom + '        → Concaténation de la variable
''                  → Une apostrophe DANS le SQL résultat
'                   → Fin de la chaîne littérale
```

Avec `sp_executesql` et des paramètres, **vous n'avez plus à gérer cela** !

### Concept 3 : Le préfixe N

Pour `sp_executesql`, vous devez utiliser le préfixe **N** devant les chaînes :

```sql
-- ✅ CORRECT
EXEC sp_executesql N'SELECT * FROM Clients';
--                 ↑
--                 Le N est OBLIGATOIRE

-- ❌ INCORRECT
EXEC sp_executesql 'SELECT * FROM Clients';  -- Erreur de type
```

**Pourquoi N ?** Le N indique une chaîne **Unicode** (NVARCHAR). C'est le type requis par `sp_executesql`.

### Concept 4 : Séparation code vs données

**Principe fondamental** : Le code SQL et les données doivent être séparés.

```sql
-- ❌ MÉLANGE code et données (dangereux)
EXEC('SELECT * FROM Clients WHERE Nom = ''' + @Nom + '''');
--    ↑                                       ↑          ↑
--    Code                                    Données    Code
-- Tout est mélangé dans la chaîne !

-- ✅ SÉPARATION code et données (sécurisé)
EXEC sp_executesql
    N'SELECT * FROM Clients WHERE Nom = @Nom_P',  -- Code (structure fixe)
    N'@Nom_P VARCHAR(50)',                         -- Déclaration
    @Nom_P = @Nom;                                 -- Données (valeur variable)
-- Le code et les données sont clairement séparés !
```

## Bonnes pratiques générales

### ✅ DO : Faites cela

**1. Préférez le SQL statique quand possible**
```sql
-- Si vous n'avez pas vraiment besoin de dynamique, ne l'utilisez pas
SELECT * FROM Clients WHERE ClientID = @ID;  -- Statique suffit
```

**2. Utilisez sp_executesql avec paramètres**
```sql
-- Toujours en production
EXEC sp_executesql N'SELECT * FROM Clients WHERE ID = @ID', N'@ID INT', @ID = 5;
```

**3. Validez les entrées**
```sql
-- Vérifiez que les objets existent
IF OBJECT_ID(@TableName, 'U') IS NULL
    RAISERROR('Table invalide', 16, 1);
```

**4. Utilisez QUOTENAME pour les identifiants**
```sql
-- Protège contre les caractères spéciaux
SET @SQL = N'SELECT * FROM ' + QUOTENAME(@TableName);
```

**5. Affichez le SQL pendant le développement**
```sql
-- Toujours utile pour déboguer
PRINT @SQL;  -- Voir ce qui sera exécuté
```

**6. Documentez pourquoi vous utilisez le dynamique**
```sql
/*
    UTILISATION DE SQL DYNAMIQUE ICI CAR :
    - Le nom de la table dépend du paramètre @TableType
    - Impossible à faire en SQL statique
*/
```

### ❌ DON'T : Évitez cela

**1. Ne concaténez jamais directement les entrées utilisateur**
```sql
-- ❌ DANGEREUX
EXEC('SELECT * FROM Clients WHERE Nom = ''' + @UserInput + '''');
```

**2. N'utilisez pas le dynamique pour contourner la difficulté**
```sql
-- ❌ MAUVAIS : Si vous trouvez votre code trop complexe,
-- le SQL dynamique n'est probablement pas la solution
```

**3. N'oubliez pas de valider**
```sql
-- ❌ MAUVAIS : Faire confiance aux entrées
-- ✅ BON : Toujours valider
```

**4. Ne laissez pas d'affichages de débogage en production**
```sql
-- ❌ En production, retirer les PRINT @SQL
```

**5. N'utilisez pas EXEC si sp_executesql est possible**
```sql
-- ❌ EXEC(@SQL) avec valeurs concaténées
-- ✅ sp_executesql avec paramètres
```

## Scénarios d'utilisation typiques

### Scénario 1 : Outil d'administration

```sql
-- Compter les lignes de toutes les tables
DECLARE @TableName NVARCHAR(128);
DECLARE curseur CURSOR FOR
    SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

OPEN curseur;
FETCH NEXT FROM curseur INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @SQL NVARCHAR(500);
    SET @SQL = N'SELECT ''' + @TableName + ''' AS TableName, COUNT(*) AS RowCount FROM ' + QUOTENAME(@TableName);
    EXEC sp_executesql @SQL;

    FETCH NEXT FROM curseur INTO @TableName;
END;

CLOSE curseur;
DEALLOCATE curseur;
```

### Scénario 2 : Interface de recherche flexible

```sql
-- Recherche avec critères optionnels
CREATE PROCEDURE sp_FlexibleSearch
    @TableName NVARCHAR(128),
    @SearchColumn NVARCHAR(128),
    @SearchValue VARCHAR(100)
AS
BEGIN
    -- Validation
    IF OBJECT_ID(@TableName) IS NULL
        RETURN;

    -- Construction sécurisée
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'SELECT * FROM ' + QUOTENAME(@TableName) +
               N' WHERE ' + QUOTENAME(@SearchColumn) +
               N' LIKE @Pattern';

    -- Exécution paramétrée
    EXEC sp_executesql @SQL,
         N'@Pattern VARCHAR(102)',
         @Pattern = '%' + @SearchValue + '%';
END;
```

### Scénario 3 : Génération de rapports

```sql
-- Créer un rapport pour une période variable
CREATE PROCEDURE sp_GenerateReport
    @StartDate DATE,
    @EndDate DATE,
    @GroupByColumn VARCHAR(50)
AS
BEGIN
    -- Validation de la colonne
    IF @GroupByColumn NOT IN ('Ville', 'Categorie', 'Region')
    BEGIN
        RAISERROR('Colonne de regroupement invalide', 16, 1);
        RETURN;
    END;

    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'SELECT ' + QUOTENAME(@GroupByColumn) +
               N', COUNT(*) AS Total, SUM(Montant) AS Somme
                FROM Ventes
                WHERE DateVente BETWEEN @Start AND @End
                GROUP BY ' + QUOTENAME(@GroupByColumn);

    EXEC sp_executesql @SQL,
         N'@Start DATE, @End DATE',
         @Start = @StartDate, @End = @EndDate;
END;
```

## Organisation de ce chapitre

Dans les sections suivantes, nous allons explorer en détail :

### 5.8.1 - Exécution de chaînes (EXEC ou sp_executesql)
Vous apprendrez la syntaxe détaillée des deux méthodes d'exécution, leurs différences, et comment choisir entre elles.

### 5.8.2 - Risques : l'Injection SQL (Concepts)
Nous plongerons dans la compréhension des injections SQL : comment elles fonctionnent, pourquoi elles sont dangereuses, et comment les reconnaître.

### 5.8.3 - Utilisation de sp_executesql pour la paramétrisation
Enfin, nous verrons en détail comment utiliser `sp_executesql` correctement avec des paramètres pour garantir la sécurité et les performances.

## Prérequis pour ce chapitre

Pour bien comprendre le SQL dynamique, vous devriez être à l'aise avec :

- ✅ **Les bases du T-SQL** : SELECT, INSERT, UPDATE, DELETE
- ✅ **Les procédures stockées** : CREATE PROCEDURE, paramètres
- ✅ **Les variables** : DECLARE, SET, SELECT INTO
- ✅ **La manipulation de chaînes** : Concaténation avec +, QUOTENAME
- ✅ **Les concepts de sécurité** : Pourquoi la validation est importante

Si certains concepts vous semblent flous, n'hésitez pas à réviser les chapitres précédents.

## Avertissement important

⚠️ **Le SQL dynamique est un outil avancé qui nécessite une attention particulière à la sécurité.**

Avant d'utiliser le SQL dynamique en production :
1. Assurez-vous d'avoir bien compris les risques d'injection SQL
2. Utilisez TOUJOURS `sp_executesql` avec des paramètres pour les valeurs
3. Validez TOUTES les entrées utilisateur
4. Documentez votre code pour expliquer pourquoi le dynamique est nécessaire
5. Testez avec des entrées malveillantes

**Règle d'or** :
> "Le SQL dynamique devrait être votre dernier recours, pas votre premier choix. Si vous pouvez faire quelque chose en SQL statique, faites-le en statique."

## Mindset à adopter

Approchez le SQL dynamique avec cette philosophie :

### 🎯 Nécessité
Utilisez-le seulement quand c'est vraiment nécessaire. 90% du temps, le SQL statique suffit.

### 🛡️ Sécurité d'abord
La sécurité n'est pas optionnelle. Toujours paramétrer les valeurs, toujours valider les entrées.

### 📖 Clarté
Le code doit être lisible et compréhensible. Commentez abondamment.

### 🔍 Vigilance
Chaque ligne de SQL dynamique est un point d'attention. Relisez et testez.

### 🚀 Performance
Le SQL dynamique a un coût. Optimisez et mesurez.

## Conclusion de l'introduction

Le SQL dynamique est une technique puissante qui ouvre de nouvelles possibilités :
- Flexibilité maximale dans la construction de requêtes
- Outils génériques et réutilisables
- Automatisation de tâches complexes

Mais cette puissance vient avec des responsabilités :
- Risques de sécurité (injection SQL)
- Complexité accrue
- Performance potentiellement réduite

**La clé du succès** : Comprendre quand l'utiliser, comment le sécuriser, et comment l'implémenter correctement.

Dans les sections suivantes, nous allons vous donner tous les outils et connaissances nécessaires pour maîtriser le SQL dynamique de manière professionnelle et sécurisée.

Prêt à plonger dans les détails techniques ? Commençons par la section suivante qui vous montrera comment exécuter du SQL dynamique avec EXEC et sp_executesql !

---


⏭️ [Exécution de chaînes (EXEC ou sp_executesql)](/05-programmabilite-en-tsql/08.1-execution-de-chaines.md)
