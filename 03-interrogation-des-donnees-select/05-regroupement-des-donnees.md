🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 3.5 Regroupement des données

## Introduction

Jusqu'à présent, nous avons appris à interroger des données en sélectionnant des colonnes, en filtrant des lignes avec `WHERE`, et en triant les résultats avec `ORDER BY`. Toutes ces opérations travaillent sur des **lignes individuelles**.

Mais que faire si vous voulez répondre à des questions comme :
- Combien de produits avons-nous dans chaque catégorie ?
- Quel est le salaire moyen par département ?
- Quel vendeur a réalisé le plus de ventes ce mois-ci ?
- Quelle est la somme totale des commandes par client ?

Pour répondre à ces questions, nous devons **regrouper** plusieurs lignes ensemble et effectuer des **calculs sur ces groupes**. C'est exactement ce que permet le **regroupement de données** en SQL.

## Qu'est-ce que le regroupement de données ?

Le regroupement de données est une technique qui permet de :
1. **Rassembler** plusieurs lignes qui partagent une caractéristique commune (même catégorie, même département, même client, etc.)
2. **Calculer** des valeurs résumées pour chaque groupe (total, moyenne, nombre, minimum, maximum, etc.)
3. **Obtenir** un résultat condensé, avec une ligne par groupe au lieu d'une ligne par enregistrement

### Analogie : Le classeur de factures

Imaginez que vous avez un classeur rempli de centaines de factures de différents clients. Vous voulez savoir combien chaque client a dépensé au total.

**Sans regroupement :**
Vous lisez chaque facture une par une. Vous voyez 200 factures avec tous les détails, mais pas de vue d'ensemble.

**Avec regroupement :**
1. Vous **triez** les factures par client (c'est le regroupement)
2. Pour chaque pile de factures d'un client, vous **additionnez** les montants
3. Vous obtenez **une seule ligne par client** avec le total de ses dépenses

C'est exactement ce que fait le regroupement en SQL !

## Passer des lignes individuelles aux groupes

### Exemple visuel

Imaginons une table `Ventes` avec des données brutes :

**Données individuelles (lignes) :**

| VenteID | Vendeur | Produit | Montant |
|---------|---------|---------|---------|
| 1 | Alice | Laptop | 1000 |
| 2 | Bob | Souris | 25 |
| 3 | Alice | Clavier | 75 |
| 4 | Charlie | Écran | 250 |
| 5 | Bob | Laptop | 1000 |
| 6 | Alice | Souris | 25 |
| 7 | Bob | Clavier | 75 |

Sans regroupement, cette table contient **7 lignes** (une par vente).

**Données regroupées (par vendeur) :**

Si nous regroupons par vendeur et calculons le total des ventes :

| Vendeur | NombreVentes | TotalVentes |
|---------|--------------|-------------|
| Alice | 3 | 1100 |
| Bob | 3 | 1100 |
| Charlie | 1 | 250 |

Avec le regroupement, nous obtenons **3 lignes** (une par vendeur), avec des valeurs **calculées** pour chaque groupe.

## Les fonctions d'agrégation : Le cœur du regroupement

Le regroupement devient puissant grâce aux **fonctions d'agrégation**. Ces fonctions prennent plusieurs valeurs en entrée et retournent **une seule valeur** en sortie.

### Les fonctions d'agrégation principales

| Fonction | Description | Exemple |
|----------|-------------|---------|
| `COUNT()` | Compte le nombre de lignes ou de valeurs | Nombre de ventes |
| `SUM()` | Additionne des valeurs numériques | Total des montants |
| `AVG()` | Calcule la moyenne | Salaire moyen |
| `MIN()` | Trouve la valeur minimale | Prix le plus bas |
| `MAX()` | Trouve la valeur maximale | Prix le plus élevé |

### Utilisation sans regroupement

Les fonctions d'agrégation peuvent être utilisées **sans regroupement**, auquel cas elles s'appliquent à **toutes les lignes** de la table :

```sql
SELECT
    COUNT(*) AS TotalVentes,
    SUM(Montant) AS ChiffreAffairesTotal,
    AVG(Montant) AS PanierMoyen
FROM Ventes;
```

**Résultat :**

| TotalVentes | ChiffreAffairesTotal | PanierMoyen |
|-------------|----------------------|-------------|
| 7 | 2450 | 350 |

Cette requête retourne **une seule ligne** avec des statistiques globales sur toutes les ventes.

### Utilisation avec regroupement

Avec le regroupement, ces mêmes fonctions s'appliquent **à chaque groupe** séparément :

```sql
SELECT
    Vendeur,
    COUNT(*) AS NombreVentes,
    SUM(Montant) AS TotalVentes,
    AVG(Montant) AS PanierMoyen
FROM Ventes
GROUP BY Vendeur;
```

**Résultat :**

| Vendeur | NombreVentes | TotalVentes | PanierMoyen |
|---------|--------------|-------------|-------------|
| Alice | 3 | 1100 | 366.67 |
| Bob | 3 | 1100 | 366.67 |
| Charlie | 1 | 250 | 250.00 |

Cette requête retourne **une ligne par vendeur**, avec des statistiques calculées pour chaque vendeur individuellement.

## Pourquoi le regroupement est-il important ?

Le regroupement de données est l'une des techniques les plus puissantes en SQL pour plusieurs raisons :

### 1. Analyse et reporting

Le regroupement permet de transformer des données brutes en **informations exploitables** :
- Analyser les ventes par région, par mois, par produit
- Comparer les performances entre équipes, départements, ou périodes
- Identifier les tendances et les patterns dans vos données

**Exemple :** Plutôt que de voir 10 000 lignes de ventes, vous pouvez voir un résumé mensuel avec 12 lignes, beaucoup plus facile à comprendre.

### 2. Prise de décision

Les données regroupées facilitent la prise de décision :
- Quels sont nos produits les plus vendus ?
- Quels clients génèrent le plus de revenus ?
- Quels départements ont besoin de plus de ressources ?

### 3. Optimisation des performances

En condensant les données, vous :
- Réduisez la quantité de données à transférer et afficher
- Facilitez la création de tableaux de bord et de graphiques
- Améliorez les temps de réponse de vos applications

### 4. Détection d'anomalies

Le regroupement aide à identifier les valeurs exceptionnelles :
- Des commandes anormalement élevées ou basses
- Des départements avec trop ou pas assez d'employés
- Des produits qui ne se vendent plus

## Types de regroupements courants

### Regroupement par catégorie

Regrouper des produits par catégorie, des employés par département, etc.

```sql
SELECT Categorie, COUNT(*) AS NombreProduits
FROM Produits
GROUP BY Categorie;
```

### Regroupement par période temporelle

Analyser les ventes par année, par mois, par jour, etc.

```sql
SELECT
    YEAR(DateVente) AS Annee,
    MONTH(DateVente) AS Mois,
    SUM(Montant) AS ChiffreAffaires
FROM Ventes
GROUP BY YEAR(DateVente), MONTH(DateVente);
```

### Regroupement par localisation

Analyser les données par pays, région, ville, etc.

```sql
SELECT Pays, COUNT(*) AS NombreClients
FROM Clients
GROUP BY Pays;
```

### Regroupement par statut

Compter les commandes par statut, les tickets par priorité, etc.

```sql
SELECT Statut, COUNT(*) AS NombreCommandes
FROM Commandes
GROUP BY Statut;
```

## Les trois piliers du regroupement

Le regroupement de données repose sur trois concepts principaux que nous allons explorer en détail dans les sections suivantes :

### 1. La clause GROUP BY (Section 3.5.1)

C'est l'instruction qui **crée les groupes**. Elle indique à SQL comment regrouper les lignes.

**Ce que vous apprendrez :**
- Comment créer des groupes simples et multiples
- Les règles à respecter avec GROUP BY
- L'utilisation conjointe avec les fonctions d'agrégation

### 2. La clause HAVING (Section 3.5.2)

C'est l'instruction qui **filtre les groupes** après l'agrégation. Elle est l'équivalent de `WHERE` mais pour les groupes.

**Ce que vous apprendrez :**
- La différence entre WHERE et HAVING
- Comment filtrer sur des résultats d'agrégation
- L'utilisation combinée de WHERE et HAVING

### 3. L'ordre logique d'exécution (Section 3.5.3)

C'est la compréhension de **l'ordre dans lequel SQL traite votre requête**, ce qui explique pourquoi certaines choses fonctionnent et d'autres pas.

**Ce que vous apprendrez :**
- L'ordre réel d'exécution : FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
- Pourquoi on ne peut pas utiliser les alias partout
- Comment écrire des requêtes correctes du premier coup

## Exemple de progression

Pour bien comprendre la puissance du regroupement, voyons comment nous pourrions progresser dans l'analyse d'une table `Commandes` :

### Niveau 1 : Données brutes

```sql
SELECT *
FROM Commandes;
```

Retourne toutes les commandes, ligne par ligne. Difficile d'en tirer des conclusions.

### Niveau 2 : Compter toutes les commandes

```sql
SELECT COUNT(*) AS TotalCommandes
FROM Commandes;
```

Retourne un seul nombre : le total global.

### Niveau 3 : Compter les commandes par client

```sql
SELECT
    ClientID,
    COUNT(*) AS NombreCommandes
FROM Commandes
GROUP BY ClientID;
```

Retourne une ligne par client. On commence à voir qui commande le plus.

### Niveau 4 : Ajouter des statistiques par client

```sql
SELECT
    ClientID,
    COUNT(*) AS NombreCommandes,
    SUM(Montant) AS TotalDepense,
    AVG(Montant) AS PanierMoyen,
    MAX(DateCommande) AS DerniereCommande
FROM Commandes
GROUP BY ClientID;
```

Vue d'ensemble complète de chaque client.

### Niveau 5 : Ne garder que les clients importants

```sql
SELECT
    ClientID,
    COUNT(*) AS NombreCommandes,
    SUM(Montant) AS TotalDepense
FROM Commandes
GROUP BY ClientID
HAVING COUNT(*) >= 10 AND SUM(Montant) > 5000
ORDER BY TotalDepense DESC;
```

Identifie et classe les meilleurs clients.

## Ce que le regroupement n'est pas

Pour éviter les confusions, clarifions ce que le regroupement **ne fait pas** :

### ❌ Le regroupement ne trie pas automatiquement

`GROUP BY` ne garantit **aucun ordre particulier** dans les résultats. Si vous voulez un ordre spécifique, utilisez `ORDER BY`.

### ❌ Le regroupement ne filtre pas les lignes individuelles

Pour filtrer les lignes **avant** le regroupement, utilisez `WHERE`, pas `GROUP BY`.

### ❌ Le regroupement ne remplace pas les jointures

Si vous avez besoin de données provenant de plusieurs tables, vous devrez d'abord les joindre (avec `JOIN`), puis les regrouper.

### ❌ Le regroupement ne modifie pas la table source

Comme toutes les requêtes `SELECT`, le regroupement crée un **résultat temporaire**. La table originale reste inchangée.

## Vocabulaire important

Avant de continuer, familiarisons-nous avec le vocabulaire du regroupement :

| Terme | Définition |
|-------|------------|
| **Agrégation** | Opération qui combine plusieurs valeurs en une seule (ex: somme, moyenne) |
| **Fonction d'agrégation** | Fonction qui effectue une agrégation (COUNT, SUM, AVG, MIN, MAX) |
| **Groupe** | Ensemble de lignes partageant les mêmes valeurs pour les colonnes de regroupement |
| **Colonne de regroupement** | Colonne utilisée dans GROUP BY pour créer les groupes |
| **Résultat agrégé** | Valeur calculée pour un groupe (ex: le total des ventes pour un vendeur) |

## Prérequis et rappels

Avant d'aborder le regroupement en détail, assurez-vous de maîtriser :

### ✅ Les requêtes SELECT de base
```sql
SELECT colonne1, colonne2
FROM table
WHERE condition;
```

### ✅ Les fonctions d'agrégation simples
```sql
SELECT COUNT(*) FROM Produits;
SELECT AVG(Prix) FROM Produits;
```

### ✅ Le filtrage avec WHERE
```sql
SELECT *
FROM Ventes
WHERE Montant > 100;
```

### ✅ Le tri avec ORDER BY
```sql
SELECT *
FROM Clients
ORDER BY Nom ASC;
```

Si ces concepts ne sont pas clairs, il est recommandé de les réviser avant de continuer.

## Structure des sections suivantes

Ce chapitre sur le regroupement est divisé en trois sections progressives :

```
3.5 Regroupement des données (cette introduction)
    ↓
3.5.1 La clause GROUP BY
    → Comment créer et manipuler des groupes
    → Les règles fondamentales du regroupement
    ↓
3.5.2 Filtrage des groupes avec HAVING
    → Comment filtrer après l'agrégation
    → La différence cruciale entre WHERE et HAVING
    ↓
3.5.3 Ordre logique d'exécution
    → Comment SQL traite réellement votre requête
    → Pourquoi certaines syntaxes fonctionnent et d'autres pas
```

Chaque section s'appuie sur la précédente, donc il est recommandé de les étudier dans l'ordre.

## Points clés à retenir

Avant de passer à la section suivante, retenez ces points essentiels :

1. **Le regroupement transforme des lignes individuelles en groupes résumés**
   - Plusieurs lignes en entrée → Une ligne par groupe en sortie

2. **Les fonctions d'agrégation sont au cœur du regroupement**
   - COUNT, SUM, AVG, MIN, MAX sont vos outils principaux

3. **Le regroupement est essentiel pour l'analyse de données**
   - Reporting, tableaux de bord, détection d'anomalies, prise de décision

4. **Trois concepts clés à maîtriser**
   - GROUP BY pour créer les groupes
   - HAVING pour filtrer les groupes
   - L'ordre d'exécution pour comprendre comment tout s'articule

5. **Le regroupement ne remplace pas les autres techniques SQL**
   - Il se combine avec WHERE, JOIN, ORDER BY, etc.

## Exemple récapitulatif complet

Pour conclure cette introduction, voici un exemple qui illustre la puissance du regroupement :

**Question métier :** "Quels sont nos 5 meilleurs clients en 2024, par chiffre d'affaires, qui ont passé au moins 10 commandes ?"

**Requête SQL :**
```sql
SELECT
    C.ClientID,
    C.NomClient,
    COUNT(V.VenteID) AS NombreCommandes,
    SUM(V.Montant) AS ChiffreAffaires,
    AVG(V.Montant) AS PanierMoyen,
    MIN(V.DateVente) AS PremiereVente,
    MAX(V.DateVente) AS DerniereVente
FROM Clients C
INNER JOIN Ventes V ON C.ClientID = V.ClientID
WHERE YEAR(V.DateVente) = 2024
GROUP BY C.ClientID, C.NomClient
HAVING COUNT(V.VenteID) >= 10
ORDER BY ChiffreAffaires DESC
OFFSET 0 ROWS
FETCH NEXT 5 ROWS ONLY;
```

**Ce que fait cette requête :**
1. Joint les clients et leurs ventes
2. Ne garde que les ventes de 2024
3. Regroupe par client
4. Ne garde que les clients avec ≥ 10 commandes
5. Trie par chiffre d'affaires
6. Ne prend que les 5 premiers

Cette requête utilise presque toutes les techniques que vous allez apprendre dans ce chapitre !

---

**Vous êtes maintenant prêt !** Passons à la section 3.5.1 pour apprendre en détail comment utiliser la clause `GROUP BY`.

⏭️ [La clause GROUP BY](/03-interrogation-des-donnees-select/05.1-la-clause-group-by.md)
