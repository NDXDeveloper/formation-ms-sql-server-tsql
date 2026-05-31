🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 3.4 Fonctions d'agrégation

## Introduction

Jusqu'à présent, nous avons appris à interroger des bases de données pour récupérer des **lignes individuelles** : des clients, des produits, des commandes. Chaque ligne de résultat correspond à une ligne dans la table source. Mais dans le monde professionnel, on ne consulte pas toujours les données ligne par ligne. Souvent, on veut des **résumés**, des **statistiques**, des **totaux**.

Imaginez que votre directeur commercial vous demande :
- "Combien de clients avons-nous ?"
- "Quel est notre chiffre d'affaires total ce mois-ci ?"
- "Quel est le prix moyen de nos produits ?"
- "Quel client a dépensé le plus ?"

Ces questions ne peuvent pas être répondues en listant toutes les lignes une par une. Vous avez besoin de **calculer** des valeurs à partir d'un ensemble de données. C'est précisément le rôle des **fonctions d'agrégation**.

## Qu'est-ce qu'une agrégation ?

Le terme **agrégation** vient du latin *aggregare* qui signifie "rassembler en un groupe". En SQL, une agrégation est une opération qui :

1. **Prend en entrée** un ensemble de valeurs (plusieurs lignes)
2. **Effectue un calcul** sur ces valeurs
3. **Retourne un résultat unique** (une seule valeur)

**Analogie simple :** Imaginez un panier de pommes :
- Sans agrégation : vous comptez chaque pomme individuellement (ligne par ligne)
- Avec agrégation : vous demandez "Combien de pommes au total ?" et obtenez un seul nombre

### Le passage de "plusieurs" à "un"

C'est la caractéristique fondamentale des fonctions d'agrégation : elles **transforment plusieurs lignes en une seule valeur**.

**Exemple visuel :**

**Table Ventes :**
```
VenteID  Montant
-------  -------
1        100
2        200
3        150
4        300
5        250
```

**Sans agrégation (5 lignes) :**
```sql
SELECT Montant FROM Ventes;
```
Résultat : 100, 200, 150, 300, 250 (5 valeurs)

**Avec agrégation (1 ligne) :**
```sql
SELECT SUM(Montant) FROM Ventes;
```
Résultat : 1000 (1 seule valeur)

## Pourquoi les fonctions d'agrégation sont-elles essentielles ?

### 1. Répondre aux questions métier

Les décideurs ont besoin de **chiffres clés**, pas de listes interminables :

| Question métier | Type d'agrégation nécessaire |
|-----------------|------------------------------|
| "Combien de produits vendons-nous ?" | **Comptage** |
| "Quel est notre CA annuel ?" | **Somme** |
| "Quel est le panier moyen ?" | **Moyenne** |
| "Quel est notre meilleur vendeur ?" | **Maximum** |
| "Quel est le produit le moins cher ?" | **Minimum** |

### 2. Créer des tableaux de bord et des rapports

Les tableaux de bord affichent des **indicateurs clés de performance (KPI)** :
- Nombre de clients actifs
- Taux de conversion
- Revenus mensuels
- Stock moyen
- Délai moyen de livraison

Tous ces indicateurs utilisent des fonctions d'agrégation.

### 3. Prendre des décisions basées sur les données

Les agrégations permettent de transformer des données brutes en **informations exploitables** :

```
Données brutes → Agrégation → Information → Décision
```

**Exemple concret :**
- **Données** : 10 000 transactions individuelles
- **Agrégation** : Chiffre d'affaires par produit
- **Information** : Le produit X génère 60% du CA
- **Décision** : Augmenter le stock du produit X

### 4. Optimiser les performances

Au lieu de transférer des milliers de lignes entre le serveur et l'application, vous calculez directement sur le serveur et ne récupérez qu'un résultat :

```sql
-- ❌ Inefficace : transférer 100 000 lignes pour calculer côté application
SELECT Prix FROM Produits;
-- L'application calcule la moyenne

-- ✅ Efficace : calculer sur le serveur, récupérer 1 seule valeur
SELECT AVG(Prix) FROM Produits;
```

## Les cinq fonctions d'agrégation fondamentales

SQL Server propose cinq fonctions d'agrégation principales que tout développeur doit maîtriser :

### 1. COUNT() - Compter

**Question :** "Combien ?"

**Utilisation :**
- Combien de clients ?
- Combien de commandes ce mois ?
- Combien de produits en rupture de stock ?

**Exemple conceptuel :**
```sql
SELECT COUNT(*) FROM Clients;
-- Résultat : 5234
```

### 2. SUM() - Additionner

**Question :** "Quel est le total ?"

**Utilisation :**
- Quel est le chiffre d'affaires total ?
- Quelle est la somme des quantités vendues ?
- Quel est le montant total des factures impayées ?

**Exemple conceptuel :**
```sql
SELECT SUM(MontantTotal) FROM Commandes;
-- Résultat : 1254389.50
```

### 3. AVG() - Calculer la moyenne

**Question :** "Quelle est la moyenne ?"

**Utilisation :**
- Quel est le panier moyen ?
- Quel est le salaire moyen ?
- Quelle est la note moyenne des produits ?

**Exemple conceptuel :**
```sql
SELECT AVG(Prix) FROM Produits;
-- Résultat : 45.67
```

### 4. MIN() - Trouver le minimum

**Question :** "Quel est le plus petit / le premier ?"

**Utilisation :**
- Quel est le produit le moins cher ?
- Quelle est la date de première commande ?
- Quel est le délai de livraison le plus court ?

**Exemple conceptuel :**
```sql
SELECT MIN(Prix) FROM Produits;
-- Résultat : 2.99
```

### 5. MAX() - Trouver le maximum

**Question :** "Quel est le plus grand / le dernier ?"

**Utilisation :**
- Quel est le produit le plus cher ?
- Quelle est la dernière date de commande ?
- Quel est le montant maximal de commande ?

**Exemple conceptuel :**
```sql
SELECT MAX(Prix) FROM Produits;
-- Résultat : 1299.99
```

## Le concept de "réduction" de données

Les fonctions d'agrégation effectuent ce qu'on appelle une **réduction** (ou *reduction* en anglais) : elles réduisent un ensemble de valeurs à une seule valeur.

### Schéma conceptuel

```
Données d'entrée (N lignes)
    ↓
[Fonction d'agrégation]
    ↓
Résultat (1 valeur)
```

**Exemple :**
```
Prix des produits : [10, 20, 30, 40, 50]
        ↓
    AVG(Prix)
        ↓
    Résultat : 30
```

### Différents types de réductions

| Type | Opération | Fonction SQL | Exemple |
|------|-----------|--------------|---------|
| **Comptage** | Compter les éléments | `COUNT()` | 5 produits |
| **Somme** | Additionner | `SUM()` | Total : 150 |
| **Moyenne** | Moyenne arithmétique | `AVG()` | Moyenne : 30 |
| **Minimum** | Plus petite valeur | `MIN()` | Minimum : 10 |
| **Maximum** | Plus grande valeur | `MAX()` | Maximum : 50 |

## Agrégation simple vs agrégation par groupe

Il existe deux façons d'utiliser les fonctions d'agrégation :

### 1. Agrégation simple (toute la table)

Calculer sur **toutes les lignes** de la table :

```sql
SELECT COUNT(*) AS TotalClients
FROM Clients;
```

**Résultat :** Une seule valeur pour toute la table (ex: 5234 clients)

### 2. Agrégation par groupe (GROUP BY)

Calculer des valeurs **par catégorie** :

```sql
SELECT Ville, COUNT(*) AS NombreClients
FROM Clients
GROUP BY Ville;
```

**Résultat :** Une ligne par ville avec le nombre de clients dans chaque ville

```
Ville        NombreClients
---------    -------------
Paris        1523
Lyon         842
Marseille    456
...
```

**Note :** La clause `GROUP BY` sera étudiée en détail dans la section 3.5. Pour l'instant, concentrons-nous sur les agrégations simples.

## Caractéristiques communes des fonctions d'agrégation

Toutes les fonctions d'agrégation partagent certaines caractéristiques :

### 1. Elles retournent une seule valeur

Peu importe le nombre de lignes en entrée, le résultat est **toujours une seule valeur**.

### 2. Elles ignorent les valeurs NULL

À une exception près (`COUNT(*)`), toutes les fonctions d'agrégation **ignorent les valeurs NULL**.

**Exemple :**
```
Prix : [10, 20, NULL, 30, NULL]
AVG(Prix) = (10 + 20 + 30) / 3 = 20
Les NULL ne sont ni comptés ni inclus dans le calcul
```

### 3. Elles opèrent après le filtrage WHERE

L'ordre logique d'exécution est :

```
1. FROM    → Identifier la table
2. WHERE   → Filtrer les lignes
3. SELECT  → Calculer les agrégations sur les lignes filtrées
```

**Exemple :**
```sql
SELECT AVG(Prix)
FROM Produits
WHERE Categorie = 'Électronique';
```

Le `WHERE` filtre d'abord les produits électroniques, **puis** calcule la moyenne.

### 4. Elles ne peuvent pas être mélangées avec des colonnes normales

```sql
-- ❌ ERREUR : impossible de mélanger
SELECT
    ProduitID,      -- Colonne normale (plusieurs valeurs)
    AVG(Prix)       -- Agrégation (une seule valeur)
FROM Produits;
```

**Pourquoi ?** Si `AVG(Prix)` retourne une seule valeur (ex: 45.67), quel `ProduitID` afficher ? Il y en a plusieurs !

**Solution :** Utiliser `GROUP BY` (section 3.5)

## Exemples de questions métier et fonctions d'agrégation

### Domaine : E-commerce

| Question | Fonction(s) utilisée(s) | Requête conceptuelle |
|----------|-------------------------|----------------------|
| Combien de commandes avons-nous ? | `COUNT(*)` | `SELECT COUNT(*) FROM Commandes` |
| Quel est notre CA total ? | `SUM()` | `SELECT SUM(Montant) FROM Commandes` |
| Quel est le panier moyen ? | `AVG()` | `SELECT AVG(Montant) FROM Commandes` |
| Quelle est la plus grosse commande ? | `MAX()` | `SELECT MAX(Montant) FROM Commandes` |
| Quelle est la plus petite commande ? | `MIN()` | `SELECT MIN(Montant) FROM Commandes` |

### Domaine : Ressources Humaines

| Question | Fonction(s) utilisée(s) | Requête conceptuelle |
|----------|-------------------------|----------------------|
| Combien d'employés ? | `COUNT(*)` | `SELECT COUNT(*) FROM Employes` |
| Quelle est la masse salariale ? | `SUM()` | `SELECT SUM(Salaire) FROM Employes` |
| Quel est le salaire moyen ? | `AVG()` | `SELECT AVG(Salaire) FROM Employes` |
| Quel est le salaire le plus élevé ? | `MAX()` | `SELECT MAX(Salaire) FROM Employes` |
| Quel est le salaire le plus bas ? | `MIN()` | `SELECT MIN(Salaire) FROM Employes` |

### Domaine : Inventaire

| Question | Fonction(s) utilisée(s) | Requête conceptuelle |
|----------|-------------------------|----------------------|
| Combien de produits en stock ? | `COUNT(*)` | `SELECT COUNT(*) FROM Produits WHERE Stock > 0` |
| Quelle est la valeur totale du stock ? | `SUM()` | `SELECT SUM(Stock * Prix) FROM Produits` |
| Quel est le stock moyen ? | `AVG()` | `SELECT AVG(Stock) FROM Produits` |
| Quel produit a le plus de stock ? | `MAX()` | `SELECT MAX(Stock) FROM Produits` |
| Quel produit est en rupture ? | `MIN()` | `SELECT MIN(Stock) FROM Produits` |

## Combiner plusieurs agrégations

Une des forces de SQL est la possibilité de calculer **plusieurs agrégations** dans une seule requête :

```sql
SELECT
    COUNT(*) AS NombreCommandes,
    SUM(Montant) AS TotalVentes,
    AVG(Montant) AS PanierMoyen,
    MIN(Montant) AS CommandeMinimale,
    MAX(Montant) AS CommandeMaximale
FROM Commandes;
```

**Résultat :**
```
NombreCommandes  TotalVentes  PanierMoyen  CommandeMinimale  CommandeMaximale
---------------  -----------  -----------  ----------------  ----------------
1532             425680.50    277.81       8.50              3250.00
```

Cette requête unique fournit un **tableau de bord complet** des ventes !

## Agrégations et types de données

### Fonctions numériques uniquement

`SUM()` et `AVG()` fonctionnent **uniquement avec des nombres** :

```sql
-- ✅ Correct
SELECT AVG(Prix) FROM Produits;

-- ❌ ERREUR
SELECT AVG(NomProduit) FROM Produits;
```

### Fonctions polyvalentes

`COUNT()`, `MIN()`, et `MAX()` fonctionnent avec **plusieurs types de données** :

| Type de données | COUNT() | MIN() | MAX() |
|-----------------|---------|-------|-------|
| Nombres | ✅ | ✅ | ✅ |
| Texte | ✅ | ✅ (1er alphabétique) | ✅ (dernier alphabétique) |
| Dates | ✅ | ✅ (plus ancienne) | ✅ (plus récente) |

**Exemples :**
```sql
-- MIN/MAX avec des dates
SELECT
    MIN(DateCommande) AS PremiereCommande,
    MAX(DateCommande) AS DerniereCommande
FROM Commandes;

-- MIN/MAX avec du texte
SELECT
    MIN(NomClient) AS PremierAlphabetique,
    MAX(NomClient) AS DernierAlphabetique
FROM Clients;
```

## L'importance de DISTINCT dans les agrégations

Parfois, vous voulez compter ou agréger uniquement les **valeurs uniques**. Le mot-clé `DISTINCT` (que nous étudierons en détail dans la section 3.4.2) peut être combiné avec les fonctions d'agrégation :

```sql
-- Nombre total de commandes
SELECT COUNT(*) FROM Commandes;
-- Résultat : 1532

-- Nombre de clients ayant passé au moins une commande
SELECT COUNT(DISTINCT ClientID) FROM Commandes;
-- Résultat : 428
```

**Interprétation :** 1532 commandes ont été passées par 428 clients différents. Certains clients ont donc passé plusieurs commandes.

## Performances des agrégations

### Avantages

✅ **Calcul côté serveur** : Le serveur de base de données est optimisé pour ces calculs  
✅ **Réduction du trafic réseau** : Une seule valeur est renvoyée au lieu de milliers de lignes  
✅ **Utilisation d'index** : Les agrégations peuvent bénéficier d'index appropriés

### Points d'attention

⚠️ **Grandes tables** : Les agrégations sur des millions de lignes sans filtrage peuvent être lentes  
⚠️ **Absence d'index** : Sans index sur les colonnes de filtrage ou d'agrégation, les performances se dégradent  
⚠️ **Calculs complexes** : Les fonctions complexes dans les agrégations augmentent le temps de calcul

### Optimisation

```sql
-- ❌ Lent : agrège toute la table
SELECT AVG(Prix) FROM Produits;

-- ✅ Plus rapide : filtre d'abord
SELECT AVG(Prix)
FROM Produits
WHERE Actif = 1 AND Categorie = 'Électronique';
```

Filtrer avec `WHERE` **avant** l'agrégation réduit le nombre de lignes à traiter.

## Structure de cette section

Cette section sur les fonctions d'agrégation est organisée en deux parties principales :

### 3.4.1 COUNT(), SUM(), AVG(), MIN(), MAX()

Étude détaillée de chaque fonction d'agrégation :
- Syntaxe et utilisation
- Comportement avec les valeurs NULL
- Types de données compatibles
- Exemples pratiques et cas d'usage
- Erreurs courantes et bonnes pratiques

### 3.4.2 Utilisation de DISTINCT

Approfondissement du mot-clé DISTINCT :
- Éliminer les doublons dans les résultats
- Compter les valeurs uniques avec `COUNT(DISTINCT)`
- Combinaison avec les autres fonctions d'agrégation
- Performances et optimisation

**Note :** La clause `GROUP BY`, qui permet d'effectuer des agrégations **par groupe**, sera étudiée dans la section 3.5. Pour l'instant, nous nous concentrons sur les agrégations **simples** (sur toute la table).

## Ce que vous saurez faire après cette section

Après avoir maîtrisé les fonctions d'agrégation, vous serez capable de :

- ✅ Calculer des statistiques de base (totaux, moyennes, comptages)
- ✅ Créer des indicateurs clés de performance (KPI)
- ✅ Répondre à des questions métier avec des requêtes simples
- ✅ Combiner plusieurs agrégations dans une seule requête
- ✅ Gérer les valeurs NULL dans les calculs
- ✅ Utiliser DISTINCT pour éliminer les doublons
- ✅ Comprendre quand et comment utiliser chaque fonction
- ✅ Optimiser vos requêtes d'agrégation

## Vocabulaire clé

Avant de commencer, familiarisons-nous avec les termes importants :

| Terme | Définition |
|-------|------------|
| **Agrégation** | Opération qui réduit plusieurs valeurs en une seule |
| **Fonction d'agrégation** | Fonction SQL qui effectue une agrégation |
| **Réduction** | Processus de transformation de N valeurs en 1 valeur |
| **NULL** | Valeur absente ou inconnue (ignorée par la plupart des agrégations) |
| **Valeur unique** | Valeur qui apparaît une seule fois (sans doublon) |
| **KPI** | Indicateur Clé de Performance (Key Performance Indicator) |

## Conseils pour progresser

### Approche recommandée

1. **Commencez simple** : Maîtrisez d'abord les agrégations sur une table entière
2. **Expérimentez** : Testez chaque fonction avec différents types de données
3. **Combinez** : Utilisez plusieurs fonctions dans une seule requête
4. **Filtrez** : Apprenez à combiner WHERE avec les agrégations
5. **Pratiquez** : Traduisez des questions métier en requêtes SQL

### Questions à se poser

Quand vous voyez une question métier, demandez-vous :
- Est-ce un comptage ? → `COUNT()`
- Est-ce un total ? → `SUM()`
- Est-ce une moyenne ? → `AVG()`
- Cherche-t-on le minimum ou maximum ? → `MIN()` / `MAX()`
- Faut-il éliminer les doublons ? → `DISTINCT`

### Exercice mental

Pour chacune de ces questions, identifiez la fonction d'agrégation nécessaire :

1. "Combien de produits avons-nous ?" → **COUNT()**
2. "Quel est le chiffre d'affaires annuel ?" → **SUM()**
3. "Quel est le panier moyen ?" → **AVG()**
4. "Quel est le produit le moins cher ?" → **MIN()**
5. "Qui est le client le plus récent ?" → **MAX()**
6. "Dans combien de villes sommes-nous présents ?" → **COUNT(DISTINCT)**

## Prérequis

Avant d'aborder cette section, assurez-vous de maîtriser :

- La syntaxe de base de `SELECT` et `FROM`
- La clause `WHERE` pour filtrer les données
- Les types de données SQL (INT, DECIMAL, VARCHAR, DATE, etc.)
- Le concept de valeur NULL
- L'ordre d'exécution logique d'une requête SQL

## Prêt à commencer ?

Les fonctions d'agrégation sont parmi les outils les plus puissants et les plus utilisés en SQL. Elles transforment des données brutes en informations exploitables et sont au cœur de la business intelligence et de l'analyse de données.

Maîtriser ces fonctions est **essentiel** pour tout développeur, analyste ou data scientist travaillant avec des bases de données. Elles vous permettront de répondre rapidement et efficacement aux questions métier les plus courantes.

Dans la section suivante, nous allons explorer en détail chacune des cinq fonctions d'agrégation fondamentales : `COUNT()`, `SUM()`, `AVG()`, `MIN()`, et `MAX()`. Vous découvrirez leur syntaxe, leurs spécificités, et de nombreux exemples pratiques tirés du monde réel.

---


⏭️ [COUNT(), SUM(), AVG(), MIN(), MAX()](/03-interrogation-des-donnees-select/04.1-count-sum-avg-min-max.md)
