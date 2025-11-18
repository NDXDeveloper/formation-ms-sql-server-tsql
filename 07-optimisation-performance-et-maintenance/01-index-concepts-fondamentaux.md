🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 7.1 Index : Concepts fondamentaux

## Introduction au Chapitre

Bienvenue dans l'un des chapitres les plus importants de cette formation sur SQL Server et T-SQL : **les index**.

Si vous avez déjà utilisé SQL Server pour créer des tables, insérer des données et exécuter des requêtes SELECT, vous avez probablement remarqué que certaines requêtes sont rapides tandis que d'autres prennent beaucoup de temps. La différence réside souvent dans un élément fondamental : **les index**.

### Qu'est-ce qu'un index en quelques mots ?

Un **index** dans une base de données est similaire à l'index d'un livre. Imaginez que vous cherchez un sujet spécifique dans un livre de 500 pages :

- **Sans index** : Vous devez parcourir chaque page une par une jusqu'à trouver ce que vous cherchez
- **Avec index** : Vous consultez l'index à la fin du livre qui vous indique directement les pages concernées

Dans SQL Server, les index permettent à la base de données de **trouver rapidement** les données sans avoir à parcourir toutes les lignes d'une table.

### Pourquoi ce chapitre est-il si important ?

Les index sont **cruciaux** pour les performances d'une base de données :

📊 **Impact sur les performances** :
- Une requête peut passer de **plusieurs minutes à quelques millisecondes** avec le bon index
- Une table de 10 millions de lignes peut être interrogée en moins d'une seconde
- L'absence d'index appropriés est la cause n°1 des problèmes de performance

💰 **Impact économique** :
- Des requêtes lentes coûtent cher en ressources serveur
- Une mauvaise expérience utilisateur due à des lenteurs peut impacter votre activité
- Des index bien conçus peuvent réduire vos coûts d'infrastructure

🎯 **Compétence essentielle** :
- Comprendre les index est indispensable pour tout développeur ou administrateur de bases de données
- C'est l'une des compétences les plus demandées dans les offres d'emploi liées à SQL Server
- La maîtrise des index vous différencie d'un débutant

## Les deux visages des index

Les index ont une **dualité** qu'il est important de comprendre dès le départ :

### ✅ Le côté positif : Accélération des lectures

```sql
-- Rechercher un client par email
SELECT * FROM Clients WHERE Email = 'marie@email.com';
```

**Sans index sur Email** :
- SQL Server doit lire **toutes** les lignes de la table (Table Scan)
- Si la table contient 1 million de clients : 1 million de lectures
- Temps : Peut prendre plusieurs secondes

**Avec index sur Email** :
- SQL Server consulte l'index pour trouver directement la ligne concernée (Index Seek)
- Nombre de lectures : 3-5 lectures seulement
- Temps : Quelques millisecondes

**Gain** : Une requête **200 000 fois plus rapide** !

### ⚠️ Le côté négatif : Ralentissement des écritures

```sql
-- Insérer un nouveau client
INSERT INTO Clients (Nom, Prenom, Email, Ville)
VALUES ('Dupont', 'Marie', 'marie@email.com', 'Paris');
```

**Sans index** :
- SQL Server ajoute simplement la nouvelle ligne
- 1 opération : rapide

**Avec 5 index sur la table** :
- SQL Server doit :
  1. Ajouter la ligne dans la table
  2. Mettre à jour l'index sur Nom
  3. Mettre à jour l'index sur Email
  4. Mettre à jour l'index sur Ville
  5. Mettre à jour l'index sur DateInscription
  6. Mettre à jour l'index sur CodePostal
- 6 opérations : plus lent

**Le dilemme** : Plus vous avez d'index, plus les SELECT sont rapides mais plus les INSERT, UPDATE et DELETE sont lents.

### L'équilibre à trouver

La clé de la gestion des index est de trouver le **bon équilibre** entre :
- 📖 **Performances de lecture** (SELECT) → Favorisées par les index
- ✍️ **Performances d'écriture** (INSERT, UPDATE, DELETE) → Pénalisées par les index

```
Pas assez d'index          Le bon équilibre          Trop d'index
      │                           │                        │
      ▼                           ▼                        ▼
SELECT lents              SELECT rapides            SELECT rapides
INSERT rapides            INSERT acceptables        INSERT très lents
UPDATE rapides            UPDATE acceptables        UPDATE très lents
DELETE rapides            DELETE acceptables        DELETE très lents
```

**Règle générale** :
- Applications **OLTP** (transactionnelles : e-commerce, ERP) → Peu d'index (2-5 par table)
- Applications **OLAP** (analytiques : datawarehouse, BI) → Beaucoup d'index (10-30 par table)

**OLTP** = Online Transaction Processing (beaucoup d'écritures)
**OLAP** = Online Analytical Processing (surtout des lectures)

## Vue d'ensemble des concepts à découvrir

Dans ce chapitre 7.1, nous allons explorer quatre concepts fondamentaux des index :

### 1. Pourquoi utiliser des index ? (Section 7.1.1)

Nous approfondirons l'analogie avec l'index d'un livre pour comprendre :
- Le problème des recherches sans index (Table Scan)
- Comment les index résolvent ce problème
- Les gains de performance spectaculaires
- Le coût des index (espace disque et ralentissement des écritures)
- Quand créer ou ne pas créer d'index

### 2. Index Clustered : La table elle-même (Section 7.1.2)

Nous découvrirons un type d'index très particulier :
- Qu'est-ce qu'un **Heap** (table sans index clustered) ?
- Qu'est-ce qu'un **index clustered** ?
- Pourquoi l'index clustered **EST** la table (concept fondamental)
- La structure B-Tree pour des recherches ultra-rapides
- Comment choisir la bonne clé clustered
- Pourquoi presque toutes vos tables devraient avoir un index clustered

**Concept clé** : Une table ne peut avoir qu'**un seul** index clustered car les données ne peuvent être physiquement triées que d'une seule manière.

### 3. Index Non-Clustered : Structures séparées (Section 7.1.3)

Nous étudierons les index les plus courants :
- Qu'est-ce qu'un **index non-clustered** ?
- Comment ils sont **séparés** de la table principale
- La structure B-Tree en détail
- Le concept de **Key Lookup** (accès en deux étapes)
- Les **Covering Index** pour des performances maximales
- Comment les pointeurs fonctionnent (vers la clé clustered ou RID)

**Concept clé** : Vous pouvez avoir jusqu'à **999** index non-clustered par table (mais n'en abusez pas !).

### 4. Index Uniques (Section 7.1.4)

Nous verrons comment garantir l'unicité des données :
- Qu'est-ce qu'un **index unique** ?
- Différence entre contrainte UNIQUE et index unique
- Gestion des valeurs NULL
- Cas d'usage : email, username, matricule, numéro de facture
- Index uniques clustered vs non-clustered
- Quand utiliser des index uniques

**Concept clé** : Les index uniques combinent **intégrité des données** (pas de doublons) et **performance** (recherches rapides).

## Prérequis pour ce chapitre

Avant de plonger dans les détails des index, assurez-vous d'être à l'aise avec :

✅ **Création de tables** (CREATE TABLE)
```sql
CREATE TABLE Clients (
    ClientID INT,
    Nom NVARCHAR(100),
    Email NVARCHAR(255)
);
```

✅ **Insertion de données** (INSERT)
```sql
INSERT INTO Clients VALUES (1, 'Dupont', 'dupont@email.com');
```

✅ **Requêtes SELECT basiques**
```sql
SELECT * FROM Clients WHERE Email = 'dupont@email.com';
```

✅ **Clause WHERE** et filtrage
```sql
SELECT * FROM Clients WHERE Ville = 'Paris' AND DateInscription > '2024-01-01';
```

✅ **Jointures** (INNER JOIN)
```sql
SELECT c.Nom, co.NumeroCommande
FROM Clients c
INNER JOIN Commandes co ON c.ClientID = co.ClientID;
```

Si vous n'êtes pas encore à l'aise avec ces concepts, nous vous recommandons de réviser les chapitres précédents avant de continuer.

## Terminologie importante

Avant de commencer, familiarisons-nous avec quelques termes clés que nous utiliserons tout au long de ce chapitre :

### Table Scan (Balayage de table)
Parcourir **toutes** les lignes d'une table, une par une, pour trouver les données recherchées.
- ❌ Lent pour les grandes tables
- ✅ Acceptable pour les petites tables (< 1000 lignes)

### Index Seek (Recherche d'index)
Utiliser un index pour trouver **directement** les données sans parcourir toute la table.
- ✅ Très rapide, même pour des millions de lignes
- 🎯 L'objectif de la création d'index

### Clustered (Clusterisé)
Fait référence à l'index qui détermine l'**ordre physique** des données dans la table.
- 📚 Comme un dictionnaire où les mots sont physiquement triés
- 🔢 Un seul par table

### Non-Clustered (Non-clusterisé)
Fait référence à un index **séparé** de la table qui pointe vers les données.
- 📑 Comme l'index à la fin d'un livre
- 🔢 Jusqu'à 999 par table

### B-Tree (Balanced Tree / Arbre équilibré)
Structure de données en **arbre hiérarchique** utilisée par les index.
- 🌳 Permet des recherches très rapides (logarithmiques)
- ⚖️ Automatiquement équilibré par SQL Server

### Key Lookup (Recherche de clé)
Opération en **deux étapes** :
1. Chercher dans un index non-clustered
2. Aller chercher les données complètes dans la table

- ⏱️ Plus lent qu'un accès direct
- 🎯 Peut être évité avec un Covering Index

### Covering Index (Index couvrant)
Index non-clustered qui contient **toutes** les colonnes nécessaires à une requête.
- ✅ Évite le Key Lookup
- ⚡ Performance maximale
- 💾 Plus volumineux

### Sélectivité
Pourcentage de lignes retournées par une requête par rapport au total.
- 📊 Haute sélectivité = peu de lignes retournées (ex : 10 sur 1 million)
- 📊 Faible sélectivité = beaucoup de lignes retournées (ex : 800 000 sur 1 million)
- 🎯 Les index sont efficaces avec une haute sélectivité

### Cardinalité
Nombre de valeurs **distinctes** dans une colonne.
- 📊 Haute cardinalité = beaucoup de valeurs différentes (ex : Email, ID)
- 📊 Faible cardinalité = peu de valeurs différentes (ex : Sexe = M/F)
- 🎯 Les index sont plus efficaces sur des colonnes à haute cardinalité

## Visualisation : Architecture des index

Pour vous donner une vue d'ensemble, voici comment les différents types d'index s'organisent :

```
┌─────────────────────────────────────────────────────────────────┐
│                         TABLE CLIENTS                           │
│                                                                 │
│  Index Clustered sur ClientID (détermine l'ordre physique)      │
│  ┌──────────┬─────────┬─────────┬──────────────────┬─────────┐  │
│  │ ClientID │ Nom     │ Prenom  │ Email            │ Ville   │  │
│  ├──────────┼─────────┼─────────┼──────────────────┼─────────┤  │
│  │ 1        │ Petit   │ Luc     │ luc@email.com    │ Lyon    │  │
│  │ 2        │ Durand  │ Paul    │ paul@email.com   │ Paris   │  │
│  │ 3        │ Moreau  │ Jean    │ jean@email.com   │ Lyon    │  │
│  │ 5        │ Martin  │ Sophie  │ sophie@email.com │ Lille   │  │
│  │ 8        │ Bernard │ Marie   │ marie@email.com  │ Paris   │  │
│  └──────────┴─────────┴─────────┴──────────────────┴─────────┘  │
└─────────────────────────────────────────────────────────────────┘
           ▲                     ▲                    ▲
           │                     │                    │
      Key Lookup            Key Lookup            Key Lookup
           │                     │                    │
┌──────────┴────────┐  ┌─────────┴──────────┐  ┌──────┴─────────┐
│ Index Non-Cluster │  │ Index Non-Cluster  │  │ Index Unique   │
│ sur Nom           │  │ sur Ville          │  │ sur Email      │
│ (Standard)        │  │ (Standard)         │  │ (Garantit      │
│                   │  │                    │  │ l'unicité)     │
├───────────────────┤  ├────────────────────┤  ├────────────────┤
│ Bernard → 8       │  │ Lille → 5          │  │ jean@... → 3   │
│ Durand  → 2       │  │ Lyon  → 1          │  │ luc@...  → 1   │
│ Martin  → 5       │  │ Lyon  → 3          │  │ marie@... → 8  │
│ Moreau  → 3       │  │ Paris → 2          │  │ paul@...  → 2  │
│ Petit   → 1       │  │ Paris → 8          │  │ sophie@... → 5 │
└───────────────────┘  └────────────────────┘  └────────────────┘
  Structure B-Tree      Structure B-Tree       Structure B-Tree
  Trié par Nom          Trié par Ville         Trié par Email
                                               (Valeurs uniques)
```

**Légende** :
- **Index Clustered** : Les données elles-mêmes, triées par ClientID
- **Index Non-Clustered** : Structures séparées avec pointeurs vers la table
- **Index Unique** : Index non-clustered qui garantit l'unicité

## Les grandes questions auxquelles nous allons répondre

À la fin de ce chapitre, vous serez capable de répondre à ces questions essentielles :

### Questions sur la performance
- ❓ Pourquoi ma requête prend-elle 30 secondes ?
- ❓ Comment puis-je accélérer une recherche sur une colonne spécifique ?
- ❓ Quel est le bon nombre d'index pour ma table ?

### Questions sur la conception
- ❓ Dois-je mettre un index clustered ou non-clustered ?
- ❓ Sur quelle colonne dois-je créer mon index clustered ?
- ❓ Quelles colonnes méritent un index ?

### Questions sur l'intégrité
- ❓ Comment garantir qu'une colonne contient des valeurs uniques ?
- ❓ Quelle est la différence entre PRIMARY KEY et UNIQUE ?
- ❓ Comment gérer les NULL dans un index unique ?

### Questions sur les coûts
- ❓ Combien d'espace disque prennent mes index ?
- ❓ Pourquoi mes INSERT sont-ils devenus lents ?
- ❓ Comment trouver le bon équilibre entre lecture et écriture ?

## État d'esprit pour ce chapitre

Voici quelques points importants à garder en tête pendant votre apprentissage :

### 🎯 Il n'y a pas de solution universelle

Il n'existe **pas** de formule magique pour l'indexation. Chaque application est différente :
- Une application de e-commerce a besoin d'index différents d'un datawarehouse
- Une table de 1000 lignes a des besoins différents d'une table de 100 millions de lignes
- Les patterns d'accès (comment vous interrogez vos données) déterminent vos index

### 📊 Les index doivent être basés sur les requêtes

La règle d'or : **Créez des index en fonction de vos requêtes réelles**, pas "au cas où".

❌ **Mauvaise approche** :
```
"Je vais mettre un index sur toutes les colonnes, comme ça je suis sûr d'avoir de bonnes performances"
→ Résultat : INSERT/UPDATE/DELETE catastrophiquement lents
```

✅ **Bonne approche** :
```
"Analysons les requêtes les plus fréquentes et les plus lentes de mon application,
puis créons des index ciblés pour les optimiser"
→ Résultat : Performance optimale avec un minimum d'index
```

### 🔬 L'indexation est un processus itératif

Vous n'obtiendrez probablement pas la stratégie d'indexation parfaite du premier coup :

1. **Démarrez** avec les index évidents (clés primaires, clés étrangères)
2. **Observez** les performances en production
3. **Identifiez** les requêtes lentes
4. **Ajoutez** des index ciblés
5. **Surveillez** l'impact
6. **Ajustez** si nécessaire

C'est un **processus continu**, pas une tâche unique.

### 💡 La théorie rencontre la pratique

Ce chapitre combine :
- **Théorie** : Comprendre comment fonctionnent les index en interne
- **Pratique** : Savoir quels index créer pour vos applications réelles

Les deux aspects sont importants. La théorie vous aide à comprendre **pourquoi** certaines décisions fonctionnent, la pratique vous aide à savoir **quoi** faire.

## Outils pour travailler avec les index

Au fur et à mesure de votre apprentissage, vous utiliserez ces outils SQL Server :

### SQL Server Management Studio (SSMS)
- 👁️ Visualisation graphique des index
- 📊 Plans d'exécution (nous les verrons plus tard)
- ⚙️ Assistant de création d'index

### Commandes T-SQL
```sql
-- Créer un index
CREATE INDEX nom_index ON table (colonne);

-- Voir les index d'une table
EXEC sp_helpindex 'nom_table';

-- Supprimer un index
DROP INDEX nom_index ON table;

-- Statistiques d'utilisation des index
SELECT * FROM sys.dm_db_index_usage_stats;
```

### Plans d'exécution (nous les verrons au chapitre 7.3)
- 📈 Visualiser comment SQL Server exécute une requête
- 🔍 Identifier les Table Scan vs Index Seek
- 💡 Découvrir les index manquants suggérés par SQL Server

## Objectifs d'apprentissage

À la fin de ce chapitre 7.1, vous serez capable de :

✅ **Comprendre** la différence entre Heap, Index Clustered et Index Non-Clustered

✅ **Expliquer** comment fonctionne la structure B-Tree

✅ **Créer** des index clustered et non-clustered appropriés

✅ **Choisir** la bonne clé pour un index clustered

✅ **Utiliser** des index uniques pour garantir l'intégrité des données

✅ **Identifier** les situations où créer ou ne pas créer d'index

✅ **Évaluer** le coût/bénéfice d'un index

✅ **Comprendre** les concepts de Table Scan, Index Seek, Key Lookup et Covering Index

## Progression recommandée

Nous vous recommandons de suivre les sections dans l'ordre :

1. **Section 7.1.1** - Pourquoi utiliser des index ?
   - Fondation conceptuelle
   - Comprendre le problème que les index résolvent

2. **Section 7.1.2** - Index Clustered
   - Le type d'index le plus important
   - Comprendre Heap vs Clustered

3. **Section 7.1.3** - Index Non-Clustered
   - Les index les plus courants
   - Maîtriser la structure B-Tree

4. **Section 7.1.4** - Index Uniques
   - Intégrité + Performance
   - Cas d'usage pratiques

Chaque section s'appuie sur les précédentes, donc ne sautez pas d'étapes !

## Un dernier mot avant de commencer

L'indexation est souvent considérée comme l'un des sujets les plus **techniques** et **complexes** de SQL Server. Mais ne vous inquiétez pas !

Nous allons :
- 📚 Utiliser des **analogies simples** (livre, dictionnaire, répertoire)
- 🎨 Fournir des **visualisations** pour chaque concept
- 💻 Donner des **exemples concrets** et pratiques
- ✅ Résumer les **points clés** à retenir
- 🎯 Vous donner des **règles pratiques** applicables immédiatement

Notre objectif est que vous **compreniez vraiment** comment fonctionnent les index, pas seulement que vous appreniez des syntaxes par cœur.

## Prêt à commencer ?

Maintenant que vous avez une vue d'ensemble de ce qui vous attend, il est temps de plonger dans le vif du sujet !

Dans la **section 7.1.1**, nous allons découvrir en détail **pourquoi utiliser des index**, avec l'analogie de l'index d'un livre qui va vous permettre de vraiment comprendre le problème que les index résolvent.

🚀 **C'est parti pour maîtriser les index SQL Server !**

---


⏭️ [Pourquoi utiliser des index ? (Analogie : index d'un livre)](/07-optimisation-performance-et-maintenance/01.1-pourquoi-utiliser-des-index.md)
