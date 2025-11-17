🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 3. Interrogation des Données - SELECT

## Introduction

Bienvenue dans le chapitre le plus fondamental et le plus utilisé de SQL : **l'interrogation des données avec SELECT**.

Si SQL était une langue, `SELECT` serait le verbe le plus employé. C'est l'instruction qui vous permet de **lire**, **consulter** et **extraire** des informations depuis vos bases de données. Que vous soyez développeur, analyste de données, administrateur de bases de données ou utilisateur métier, vous utiliserez `SELECT` quotidiennement.

Dans ce chapitre, nous allons explorer en profondeur toutes les facettes de l'instruction `SELECT`, depuis les requêtes les plus simples jusqu'aux techniques les plus avancées.

## Qu'est-ce que l'interrogation de données ?

L'**interrogation de données** (ou *querying* en anglais) est l'action de **poser des questions** à une base de données pour obtenir des informations spécifiques.

### Analogie : La bibliothèque

Imaginez une immense bibliothèque contenant des millions de livres (vos données) :

- **Sans SQL** : Vous devriez parcourir physiquement chaque étagère, ouvrir chaque livre, lire chaque page pour trouver l'information recherchée. Cela prendrait des heures, voire des jours.

- **Avec SQL (SELECT)** : Vous demandez au bibliothécaire expert (le moteur SQL) : "Donne-moi tous les livres de science-fiction publiés après 2020, écrits en français, triés par popularité". En quelques secondes, vous obtenez exactement ce que vous cherchez.

C'est exactement ce que fait `SELECT` : il vous permet de formuler précisément vos besoins et d'obtenir rapidement les données pertinentes parmi potentiellement des millions d'enregistrements.

## Pourquoi SELECT est-il si important ?

### 1. C'est la base de tout

`SELECT` est l'instruction SQL la plus utilisée, et de loin. On estime que dans une application typique, 80 à 90% des requêtes SQL sont des `SELECT`.

**Pourquoi ?** Parce que :
- Les données sont **lues** beaucoup plus souvent qu'elles ne sont **écrites**
- Chaque affichage d'information nécessite une requête `SELECT`
- Tous les rapports, tableaux de bord et analyses utilisent `SELECT`

### 2. C'est la porte d'entrée vers vos données

Avant de pouvoir modifier, analyser ou comprendre vos données, vous devez d'abord les **voir**. `SELECT` est votre outil pour :
- Explorer le contenu de vos tables
- Vérifier les données après une insertion ou modification
- Analyser les tendances et patterns
- Générer des rapports pour la prise de décision

### 3. C'est un outil puissant et flexible

Une simple instruction `SELECT` peut :
- Extraire une seule ligne ou des millions de lignes
- Combiner des données de plusieurs tables
- Effectuer des calculs complexes
- Filtrer selon des critères précis
- Trier et organiser les résultats
- Résumer et agréger des informations

### 4. C'est une compétence universelle

`SELECT` fonctionne de manière similaire sur tous les systèmes de bases de données relationnelles :
- SQL Server (Microsoft)
- MySQL
- PostgreSQL
- Oracle
- SQLite

Apprendre `SELECT` vous ouvre les portes de presque tous les environnements de données.

## De la lecture simple à l'analyse avancée

Le grand avantage de `SELECT` est sa **progressivité**. Vous pouvez commencer très simplement et augmenter progressivement la complexité de vos requêtes.

### Niveau débutant : Lecture simple

```sql
SELECT *
FROM Clients;
```

*"Montre-moi tous les clients"*

### Niveau intermédiaire : Filtrage et tri

```sql
SELECT Nom, Email, Ville
FROM Clients
WHERE Pays = 'France' AND Actif = 1
ORDER BY Nom;
```

*"Montre-moi le nom, l'email et la ville des clients français actifs, triés par nom"*

### Niveau avancé : Agrégation et regroupement

```sql
SELECT
    Ville,
    COUNT(*) AS NombreClients,
    AVG(ChiffreAffaires) AS CAMoyen
FROM Clients
WHERE Pays = 'France'
GROUP BY Ville
HAVING COUNT(*) > 10
ORDER BY CAMoyen DESC;
```

*"Pour chaque ville de France ayant plus de 10 clients, montre-moi le nombre de clients et leur chiffre d'affaires moyen, triés par CA décroissant"*

### Niveau expert : Jointures et sous-requêtes

```sql
SELECT
    C.Nom,
    C.Ville,
    COUNT(O.CommandeID) AS NombreCommandes,
    SUM(O.Montant) AS TotalAchats,
    (SELECT AVG(Montant) FROM Commandes) AS MoyenneGenerale
FROM Clients C
LEFT JOIN Commandes O ON C.ClientID = O.ClientID
WHERE C.DateInscription >= '2024-01-01'
GROUP BY C.ClientID, C.Nom, C.Ville
HAVING SUM(O.Montant) > 1000
ORDER BY TotalAchats DESC;
```

*"Pour chaque client inscrit en 2024 ayant dépensé plus de 1000€, montre-moi son nom, sa ville, le nombre de commandes, le total de ses achats, ainsi que la moyenne générale de toutes les commandes, triés par total d'achats"*

Toutes ces requêtes utilisent `SELECT`, mais avec des niveaux de complexité croissants.

## Les grandes familles d'interrogations

Les requêtes `SELECT` peuvent être classées en plusieurs catégories selon leur objectif :

### 1. Requêtes de consultation simple

**Objectif :** Voir le contenu d'une table

```sql
SELECT * FROM Produits;
SELECT Nom, Prix FROM Produits;
```

**Cas d'usage :**
- Explorer une nouvelle base de données
- Vérifier le contenu après une insertion
- Afficher des listes dans une application

### 2. Requêtes de recherche

**Objectif :** Trouver des enregistrements spécifiques

```sql
SELECT *
FROM Clients
WHERE Email = 'jean.dupont@email.com';
```

**Cas d'usage :**
- Recherche d'un client par son email
- Trouver un produit par son code
- Localiser une commande par son numéro

### 3. Requêtes de filtrage

**Objectif :** Extraire un sous-ensemble de données selon des critères

```sql
SELECT *
FROM Produits
WHERE Categorie = 'Informatique'
  AND Prix < 500
  AND Stock > 0;
```

**Cas d'usage :**
- Lister les produits en stock d'une catégorie
- Afficher les commandes d'une période
- Trouver les clients d'une région

### 4. Requêtes d'analyse

**Objectif :** Calculer des statistiques et résumés

```sql
SELECT
    Categorie,
    COUNT(*) AS NombreProduits,
    AVG(Prix) AS PrixMoyen,
    SUM(Stock) AS StockTotal
FROM Produits
GROUP BY Categorie;
```

**Cas d'usage :**
- Tableaux de bord de gestion
- Rapports de vente
- Analyses de performance

### 5. Requêtes de croisement

**Objectif :** Combiner des données de plusieurs tables

```sql
SELECT
    C.Nom AS Client,
    O.DateCommande,
    O.Montant
FROM Clients C
INNER JOIN Commandes O ON C.ClientID = O.ClientID;
```

**Cas d'usage :**
- Afficher les commandes avec les noms de clients
- Lier les produits à leurs catégories
- Combiner les employés et leurs départements

## Anatomie d'une requête SELECT

Une requête `SELECT` peut contenir plusieurs clauses, chacune ayant un rôle spécifique. Voici la structure complète (toutes les clauses sont optionnelles sauf `SELECT` et `FROM`) :

```sql
SELECT      -- Quelles colonnes afficher
FROM        -- D'où viennent les données
WHERE       -- Comment filtrer les lignes
GROUP BY    -- Comment regrouper les données
HAVING      -- Comment filtrer les groupes
ORDER BY    -- Comment trier les résultats
```

**Exemple complet :**

```sql
SELECT Categorie, AVG(Prix) AS PrixMoyen
FROM Produits
WHERE Stock > 0
GROUP BY Categorie
HAVING AVG(Prix) > 100
ORDER BY PrixMoyen DESC;
```

Cette requête :
1. **SELECT** : Affiche la catégorie et le prix moyen
2. **FROM** : Utilise la table Produits
3. **WHERE** : Ne considère que les produits en stock
4. **GROUP BY** : Regroupe par catégorie
5. **HAVING** : Ne garde que les catégories avec prix moyen > 100
6. **ORDER BY** : Trie par prix moyen décroissant

## Structure de ce chapitre

Ce chapitre est organisé de manière progressive, du plus simple au plus complexe. Voici ce que vous allez apprendre :

### 3.1 La structure de base de SELECT
- Comment choisir les colonnes à afficher
- L'utilisation de `SELECT *`
- Les alias de colonnes
- Les premières requêtes simples

### 3.2 Filtrage des données
- La clause `WHERE` pour filtrer les lignes
- Les opérateurs de comparaison (=, >, <, etc.)
- Les opérateurs logiques (AND, OR, NOT)
- Les opérateurs spéciaux (IN, BETWEEN, LIKE)
- La gestion des valeurs NULL

### 3.3 Tri et limitation des résultats
- Trier avec `ORDER BY`
- Limiter le nombre de résultats avec `TOP`
- La pagination moderne avec `OFFSET` et `FETCH`

### 3.4 Fonctions d'agrégation
- Calculer avec COUNT, SUM, AVG, MIN, MAX
- L'utilisation de DISTINCT
- Comprendre la différence entre lignes individuelles et résultats agrégés

### 3.5 Regroupement des données
- Créer des groupes avec `GROUP BY`
- Filtrer les groupes avec `HAVING`
- Comprendre l'ordre logique d'exécution d'une requête

Chaque section s'appuie sur les précédentes, donc il est fortement recommandé de les étudier dans l'ordre.

## Ce que vous apprendrez dans ce chapitre

À la fin de ce chapitre, vous serez capable de :

✅ **Extraire des données** de manière précise et efficace

✅ **Filtrer** les informations selon des critères simples ou complexes

✅ **Trier et organiser** les résultats de manière logique

✅ **Calculer** des statistiques et des résumés

✅ **Regrouper** les données pour des analyses plus poussées

✅ **Comprendre** comment SQL exécute réellement vos requêtes

✅ **Écrire** des requêtes complexes en combinant plusieurs techniques

✅ **Déboguer** vos requêtes en comprenant les messages d'erreur

## Les compétences fondamentales

Avant de commencer, assurez-vous d'avoir compris les concepts des chapitres précédents :

### Prérequis du Chapitre 1 : Concepts fondamentaux
- Qu'est-ce qu'une base de données relationnelle ?
- La structure : tables, colonnes, lignes
- Les types de données de base

### Prérequis du Chapitre 2 : Structures de données
- Comment les tables sont organisées
- Les contraintes (PRIMARY KEY, FOREIGN KEY)
- Le concept de schéma

Si ces concepts ne sont pas clairs, il est recommandé de les réviser avant de continuer.

## Conseils pour bien apprendre SELECT

### 1. Pratiquez régulièrement

La théorie est importante, mais rien ne remplace la pratique. Pour chaque concept présenté :
- Lisez l'explication
- Essayez les exemples vous-même
- Modifiez les exemples pour tester votre compréhension
- Créez vos propres requêtes

### 2. Commencez simple, progressez graduellement

Ne cherchez pas à tout maîtriser d'un coup. Maîtrisez d'abord :
- `SELECT` et `FROM`
- Puis ajoutez `WHERE`
- Puis `ORDER BY`
- Puis les fonctions d'agrégation
- Enfin `GROUP BY` et `HAVING`

### 3. Comprenez les messages d'erreur

Quand une requête échoue, lisez attentivement le message d'erreur. Il vous dit souvent exactement ce qui ne va pas :
- Colonne inexistante
- Syntaxe incorrecte
- Type de données incompatible
- Etc.

### 4. Utilisez les outils de développement

SQL Server Management Studio (SSMS) et Azure Data Studio offrent des fonctionnalités utiles :
- L'auto-complétion
- La coloration syntaxique
- Les plans d'exécution
- L'affichage des résultats en grille

### 5. Commentez vos requêtes

Prenez l'habitude de commenter vos requêtes complexes :

```sql
-- Analyse des ventes par catégorie pour l'année 2024
-- Ne considère que les commandes finalisées
SELECT
    C.NomCategorie,
    COUNT(*) AS NombreVentes,        -- Nombre total de ventes
    SUM(V.Montant) AS ChiffreAffaires -- CA total de la catégorie
FROM Ventes V
INNER JOIN Produits P ON V.ProduitID = P.ProduitID
INNER JOIN Categories C ON P.CategorieID = C.CategorieID
WHERE YEAR(V.DateVente) = 2024
  AND V.Statut = 'Finalisée'
GROUP BY C.CategorieID, C.NomCategorie
ORDER BY ChiffreAffaires DESC;
```

## Conventions et bonnes pratiques

Dans ce chapitre, nous suivrons certaines conventions pour faciliter la lecture :

### Casse des mots-clés

Les mots-clés SQL seront écrits en **MAJUSCULES** pour les distinguer des noms de tables et colonnes :

```sql
SELECT Nom, Prenom
FROM Employes
WHERE Departement = 'IT'
ORDER BY Nom;
```

**Note :** SQL n'est pas sensible à la casse pour les mots-clés. `SELECT`, `select` et `SeLeCt` fonctionnent tous de la même manière. Cependant, utiliser des majuscules améliore la lisibilité.

### Indentation

Les requêtes multi-lignes seront indentées pour améliorer la lisibilité :

```sql
SELECT
    Colonne1,
    Colonne2,
    Colonne3
FROM Table1
WHERE Condition1
  AND Condition2
ORDER BY Colonne1;
```

### Noms des objets

Les noms de tables et colonnes seront écrits en **PascalCase** (première lettre en majuscule) dans les exemples :
- `Clients` (table)
- `NomClient` (colonne)
- `DateCommande` (colonne)

### Alias

Les alias seront utilisés pour améliorer la clarté :

```sql
SELECT
    C.Nom AS NomClient,
    O.DateCommande AS Date,
    O.Montant AS Total
FROM Clients C
INNER JOIN Commandes O ON C.ClientID = O.ClientID;
```

## Vocabulaire important

Avant de commencer, familiarisons-nous avec le vocabulaire que nous utiliserons :

| Terme | Définition |
|-------|------------|
| **Requête** | Une instruction SQL complète (souvent appelée *query* en anglais) |
| **Clause** | Une partie spécifique d'une requête (SELECT, FROM, WHERE, etc.) |
| **Résultat** | L'ensemble des données retournées par une requête (aussi appelé *result set*) |
| **Ligne** | Un enregistrement dans une table (aussi appelé *row* ou *tuple*) |
| **Colonne** | Un champ dans une table (aussi appelé *column* ou *attribute*) |
| **Prédicat** | Une condition de filtrage (dans WHERE ou HAVING) |
| **Alias** | Un nom alternatif donné à une table ou une colonne |
| **Agrégation** | Une opération qui combine plusieurs valeurs en une seule |
| **Mot-clé** | Un mot réservé de SQL (SELECT, FROM, WHERE, etc.) |

## Un mot sur la performance

Dès le début de votre apprentissage, gardez à l'esprit que **toutes les requêtes ne se valent pas** en termes de performance.

### Principe de base

Plus vous êtes **précis** dans votre requête, plus elle sera **efficace** :

❌ **Évitez :**
```sql
SELECT *  -- Récupère toutes les colonnes (souvent inutile)
FROM GrosseTable;  -- Sans filtrage (peut retourner des millions de lignes)
```

✅ **Préférez :**
```sql
SELECT Nom, Email  -- Seulement les colonnes nécessaires
FROM GrosseTable
WHERE Actif = 1    -- Avec un filtre approprié
  AND DateCreation >= '2024-01-01';
```

Nous reviendrons sur l'optimisation en détail dans le Chapitre 7, mais gardez cette règle en tête dès maintenant.

## SELECT en contexte : L'écosystème SQL

`SELECT` ne fonctionne pas seul. Il fait partie d'un écosystème plus large :

```
Données stockées
       ↓
DDL (CREATE, ALTER) → Crée les structures
       ↓
DML (INSERT, UPDATE) → Insère/Modifie les données
       ↓
SELECT → Interroge les données
       ↓
Résultats utilisés dans l'application
```

Dans une application typique :
1. Les structures sont créées une fois (DDL)
2. Les données sont insérées/modifiées régulièrement (DML)
3. Les données sont consultées très fréquemment (**SELECT**)

`SELECT` est donc l'opération la plus courante et la plus critique pour les performances.

## Prêt à commencer ?

Vous avez maintenant une vue d'ensemble de ce qu'est l'interrogation de données et pourquoi elle est si importante. Vous comprenez la structure générale d'une requête `SELECT` et ce que vous allez apprendre dans ce chapitre.

**Objectifs de ce chapitre :**
- Maîtriser toutes les clauses de base de SELECT
- Comprendre comment filtrer, trier et regrouper les données
- Écrire des requêtes de plus en plus complexes
- Analyser vos données avec efficacité

**Ce qui vous attend :**
- Des concepts expliqués simplement
- De nombreux exemples progressifs
- Des tableaux visuels pour comprendre les résultats
- Des conseils pratiques et bonnes pratiques
- Des explications sur les erreurs courantes

## Récapitulatif

Avant de passer à la section 3.1, retenez ces points essentiels :

1. **SELECT est l'instruction la plus importante de SQL**
   - C'est votre outil principal pour accéder aux données

2. **Une requête SELECT peut être simple ou très complexe**
   - Vous progresserez graduellement

3. **Plusieurs clauses peuvent être combinées**
   - SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY

4. **La précision améliore la performance**
   - Sélectionnez uniquement ce dont vous avez besoin

5. **La pratique est essentielle**
   - Lisez, testez, expérimentez

---

**Passons maintenant à la section 3.1** où nous commencerons par les bases : la structure fondamentale de `SELECT` et comment choisir les colonnes à afficher.

**Prochaine étape :** Section 3.1 - La structure de base de SELECT

⏭️ [La structure de base de SELECT](/03-interrogation-des-donnees-select/01-structure-de-base-de-select.md)
