🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 2.2 DDL : Création et Gestion des Objets

## Introduction au DDL

Le **DDL** (Data Definition Language - Langage de Définition de Données) est l'un des sous-ensembles les plus importants du langage SQL. Il regroupe toutes les commandes qui permettent de **définir** et de **gérer la structure** de votre base de données.

**Analogie simple :** Si votre base de données était une bibliothèque :
- Le **DDL** serait l'ensemble des commandes pour **construire** les étagères, créer les sections, organiser l'espace
- Le **DML** (que nous verrons plus tard) serait les commandes pour **ranger** et **manipuler** les livres sur ces étagères

## Qu'est-ce que le DDL ?

Le DDL vous permet de créer et de modifier la **structure** (aussi appelée **schéma**) de votre base de données. Cette structure comprend :

- **Les bases de données** elles-mêmes
- **Les tables** qui contiennent vos données
- **Les colonnes** de ces tables avec leurs types de données
- **Les contraintes** qui garantissent l'intégrité des données
- **Les index** qui améliorent les performances
- **Les vues** qui simplifient l'accès aux données
- Et d'autres objets comme les procédures stockées, fonctions, etc.

## Les Principales Commandes DDL

Voici les commandes DDL que vous utiliserez le plus fréquemment :

| Commande | Description | Exemple d'usage |
|----------|-------------|-----------------|
| **CREATE** | Créer un nouvel objet | `CREATE TABLE Clients (...)` |
| **ALTER** | Modifier un objet existant | `ALTER TABLE Clients ADD Email VARCHAR(100)` |
| **DROP** | Supprimer un objet | `DROP TABLE Clients` |
| **TRUNCATE** | Vider le contenu d'une table | `TRUNCATE TABLE Logs` |

### CREATE : Créer des Objets

La commande `CREATE` vous permet de créer de nouveaux objets dans votre base de données :

```sql
-- Créer une base de données
CREATE DATABASE MaBaseDeDonnees;

-- Créer une table
CREATE TABLE Clients
(
    IdClient INT,
    Nom VARCHAR(100),
    Email VARCHAR(100)
);

-- Créer une vue (nous verrons cela plus tard)
CREATE VIEW VueClients AS
SELECT * FROM Clients WHERE EstActif = 1;
```

**Important :** Une fois un objet créé avec `CREATE`, il existe dans votre base de données jusqu'à ce que vous le supprimiez explicitement.

### ALTER : Modifier des Objets

La commande `ALTER` vous permet de modifier la structure d'objets existants sans les recréer :

```sql
-- Ajouter une colonne à une table
ALTER TABLE Clients
ADD Telephone VARCHAR(20);

-- Modifier le type d'une colonne
ALTER TABLE Clients
ALTER COLUMN Email VARCHAR(150);

-- Supprimer une colonne
ALTER TABLE Clients
DROP COLUMN Telephone;
```

**Avantage :** `ALTER` modifie la structure sans perdre les données existantes (dans la plupart des cas).

### DROP : Supprimer des Objets

La commande `DROP` supprime complètement un objet de votre base de données :

```sql
-- Supprimer une table
DROP TABLE Clients;

-- Supprimer une base de données
DROP DATABASE MaBaseDeDonnees;
```

**⚠️ ATTENTION :** `DROP` est **irréversible**. L'objet et toutes ses données sont définitivement supprimés !

### TRUNCATE : Vider une Table

La commande `TRUNCATE` vide rapidement le contenu d'une table tout en conservant sa structure :

```sql
-- Vider la table Logs
TRUNCATE TABLE Logs;
```

**Différence avec DELETE :** `TRUNCATE` est beaucoup plus rapide car il supprime toutes les données d'un coup, sans enregistrer chaque suppression individuellement.

## DDL vs Autres Sous-Langages SQL

SQL est divisé en plusieurs sous-langages, chacun avec un rôle spécifique :

### Vue d'Ensemble

| Sous-langage | Acronyme | Rôle | Commandes principales |
|--------------|----------|------|----------------------|
| **Data Definition Language** | **DDL** | Définir la structure | CREATE, ALTER, DROP, TRUNCATE |
| **Data Manipulation Language** | **DML** | Manipuler les données | SELECT, INSERT, UPDATE, DELETE |
| **Data Control Language** | **DCL** | Gérer les permissions | GRANT, DENY, REVOKE |
| **Transaction Control Language** | **TCL** | Gérer les transactions | BEGIN, COMMIT, ROLLBACK |

### DDL : Définir la Structure

```sql
-- DDL : Je crée la structure
CREATE TABLE Produits
(
    IdProduit INT PRIMARY KEY,
    Nom VARCHAR(100),
    Prix DECIMAL(10, 2)
);
```

**Caractéristiques du DDL :**
- Modifie la **structure** (le contenant)
- Les changements sont généralement **immédiats et permanents**
- Impact sur le **schéma** de la base de données
- Nécessite des **permissions élevées**

### DML : Manipuler les Données

```sql
-- DML : Je manipule les données
INSERT INTO Produits (IdProduit, Nom, Prix)
VALUES (1, 'Ordinateur', 899.99);

SELECT * FROM Produits;

UPDATE Produits SET Prix = 799.99 WHERE IdProduit = 1;

DELETE FROM Produits WHERE IdProduit = 1;
```

**Caractéristiques du DML :**
- Modifie le **contenu** (pas le contenant)
- Les changements peuvent être **annulés** (avec ROLLBACK dans une transaction)
- Impact sur les **données** de la base
- Permissions moins élevées que le DDL

### Exemple Comparatif

```sql
-- ===== DDL : Structurer =====
-- Je construis la table (structure)
CREATE TABLE Employes
(
    IdEmploye INT,
    Nom VARCHAR(100),
    Salaire DECIMAL(10, 2)
);

-- Je modifie la structure
ALTER TABLE Employes
ADD Email VARCHAR(100);

-- ===== DML : Remplir et Manipuler =====
-- Je remplis la table avec des données
INSERT INTO Employes (IdEmploye, Nom, Salaire, Email)
VALUES (1, 'Dupont', 3500.00, 'dupont@exemple.com');

-- Je consulte les données
SELECT * FROM Employes;

-- Je modifie les données
UPDATE Employes
SET Salaire = 3800.00
WHERE IdEmploye = 1;
```

## Les Objets de Base de Données

Le DDL permet de gérer différents types d'objets dans SQL Server. Voici les principaux :

### 1. Base de Données (Database)

Le conteneur principal qui regroupe tous les autres objets.

```sql
CREATE DATABASE GestionCommerciale;
```

### 2. Tables (Tables)

Les structures qui stockent vos données sous forme de lignes et de colonnes.

```sql
CREATE TABLE Clients
(
    IdClient INT,
    Nom VARCHAR(100)
);
```

### 3. Contraintes (Constraints)

Les règles qui garantissent l'intégrité et la qualité de vos données.

```sql
-- Clé primaire
ALTER TABLE Clients
ADD CONSTRAINT PK_Clients PRIMARY KEY (IdClient);

-- Clé étrangère
ALTER TABLE Commandes
ADD CONSTRAINT FK_Commandes_Clients
FOREIGN KEY (IdClient) REFERENCES Clients(IdClient);
```

### 4. Index

Les structures qui accélèrent les recherches dans vos tables (comme l'index d'un livre).

```sql
CREATE INDEX IX_Clients_Nom ON Clients(Nom);
```

### 5. Vues (Views)

Des "tables virtuelles" qui simplifient l'accès aux données.

```sql
CREATE VIEW VueClientsActifs AS
SELECT IdClient, Nom, Email
FROM Clients
WHERE EstActif = 1;
```

### 6. Schémas (Schemas)

Des conteneurs logiques pour organiser vos objets.

```sql
CREATE SCHEMA Ventes;
CREATE TABLE Ventes.Commandes (...);
```

## Hiérarchie des Objets

Voici comment les objets s'organisent dans SQL Server :

```
Serveur SQL Server
│
├── Base de Données 1
│   ├── Schéma dbo (par défaut)
│   │   ├── Tables
│   │   │   ├── Table1
│   │   │   │   ├── Colonnes
│   │   │   │   ├── Contraintes
│   │   │   │   └── Index
│   │   │   └── Table2
│   │   ├── Vues
│   │   ├── Procédures Stockées
│   │   └── Fonctions
│   └── Schéma Ventes
│       └── Tables
│
└── Base de Données 2
    └── ...
```

**Comprendre cette hiérarchie :**
- Tout commence par une **base de données**
- Les objets sont organisés dans des **schémas** (par défaut : `dbo`)
- Chaque **table** contient des **colonnes**, **contraintes** et **index**

## Pourquoi le DDL est-il Important ?

### 1. Fondation de Votre Application

Sans une structure bien définie, vous ne pouvez pas stocker de données. Le DDL est la **première étape** de tout projet de base de données.

```sql
-- D'abord la structure (DDL)
CREATE TABLE Produits (...);

-- Ensuite les données (DML)
INSERT INTO Produits VALUES (...);
```

### 2. Évolution de Votre Application

Les applications évoluent, et votre structure de données doit suivre. Le DDL vous permet d'adapter votre base de données :

```sql
-- Ajout d'une nouvelle fonctionnalité
ALTER TABLE Produits
ADD ImageURL VARCHAR(500);
```

### 3. Intégrité des Données

Le DDL vous permet de définir des règles strictes pour garantir la qualité de vos données :

```sql
-- Garantir l'unicité
ALTER TABLE Produits
ADD CONSTRAINT UQ_Produits_CodeBarre UNIQUE (CodeBarre);

-- Garantir la cohérence
ALTER TABLE Commandes
ADD CONSTRAINT CHK_Commandes_Montant CHECK (Montant > 0);
```

### 4. Performance

Une bonne structure avec les bons index améliore considérablement les performances :

```sql
-- Accélérer les recherches par nom
CREATE INDEX IX_Clients_Nom ON Clients(Nom);
```

## Principes de Base du DDL

### 1. Planifiez Avant de Créer

Avant de créer vos tables, prenez le temps de réfléchir à :
- Quelles **données** devez-vous stocker ?
- Quelles sont les **relations** entre ces données ?
- Quelles **contraintes** garantiront la qualité ?

```sql
-- ❌ MAUVAIS : Créer sans réfléchir
CREATE TABLE Data (Col1 VARCHAR(MAX), Col2 VARCHAR(MAX));

-- ✅ BON : Structure réfléchie
CREATE TABLE Clients
(
    IdClient INT PRIMARY KEY IDENTITY(1,1),
    Nom VARCHAR(100) NOT NULL,
    Prenom VARCHAR(100) NOT NULL,
    Email VARCHAR(150) UNIQUE,
    DateInscription DATE DEFAULT GETDATE()
);
```

### 2. Nommez Clairement

Utilisez des noms **descriptifs** et **cohérents** pour tous vos objets :

```sql
-- ✅ BON : Noms clairs
CREATE TABLE ClientsEntreprise (...);
CREATE TABLE CommandesVentes (...);

-- ❌ MAUVAIS : Noms vagues
CREATE TABLE Tbl1 (...);
CREATE TABLE Data (...);
```

### 3. Documentez Vos Modifications

Le DDL modifie la structure de manière permanente. Documentez toujours vos changements :

```sql
-- =========================================
-- Modification : Ajout de la colonne Email
-- Date : 2025-11-16
-- Raison : Nouvelle fonctionnalité newsletter
-- =========================================
ALTER TABLE Clients
ADD Email VARCHAR(150);
```

### 4. Testez en Développement

Ne testez **jamais** vos commandes DDL directement en production :

```
Environnement de Développement
        ↓
   Tester le DDL
        ↓
    Valider
        ↓
Environnement de Production
```

### 5. Sauvegardez Avant les Modifications Importantes

Avant des modifications DDL majeures, créez une sauvegarde :

```sql
-- Sauvegarder la table
SELECT * INTO Clients_Backup FROM Clients;

-- Effectuer la modification
ALTER TABLE Clients
DROP COLUMN ColonneObsolete;

-- En cas de problème, vous avez une copie
```

## Commandes DDL : Caractéristiques Communes

Toutes les commandes DDL partagent certaines caractéristiques :

### 1. Effets Immédiats

Les commandes DDL prennent effet **immédiatement** :

```sql
CREATE TABLE Test (Id INT);
-- La table existe maintenant, immédiatement
```

### 2. Auto-Commit (en dehors des transactions explicites)

En général, les commandes DDL sont **auto-validées** (auto-commit) :

```sql
-- Même sans COMMIT, la table sera créée
CREATE TABLE Test (Id INT);
```

**Note :** Dans certains contextes (transactions explicites), vous pouvez utiliser ROLLBACK, mais ce n'est pas la norme.

### 3. Permissions Nécessaires

Le DDL nécessite des **permissions élevées** :
- **CREATE** : permission de créer des objets
- **ALTER** : permission de modifier des objets
- **DROP** : permission de supprimer des objets

### 4. Impact sur les Métadonnées

Le DDL modifie les **métadonnées** (informations sur la structure) stockées dans les tables système :

```sql
-- Après un CREATE TABLE, vous pouvez interroger les métadonnées
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Clients';
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Clients';
```

## Ordre Logique d'Utilisation du DDL

Voici un ordre logique typique pour construire une base de données :

### Étape 1 : Créer la Base de Données

```sql
CREATE DATABASE GestionCommerciale;
USE GestionCommerciale;
```

### Étape 2 : Créer les Tables Principales

```sql
CREATE TABLE Clients (...);
CREATE TABLE Produits (...);
```

### Étape 3 : Créer les Tables de Relations

```sql
CREATE TABLE Commandes (...);
CREATE TABLE LignesCommandes (...);
```

### Étape 4 : Ajouter les Contraintes

```sql
ALTER TABLE Commandes
ADD CONSTRAINT FK_Commandes_Clients FOREIGN KEY (IdClient) REFERENCES Clients(IdClient);
```

### Étape 5 : Créer les Index

```sql
CREATE INDEX IX_Commandes_DateCommande ON Commandes(DateCommande);
```

### Étape 6 : Créer les Vues (Optionnel)

```sql
CREATE VIEW VueCommandesRecentes AS ...
```

## Ce que Nous Allons Apprendre

Dans cette section 2.2, nous allons explorer en détail :

### 2.2.1 CREATE DATABASE
Comment créer une base de données avec différentes options.

### 2.2.2 CREATE TABLE (Syntaxe de base)
Comment créer des tables pour stocker vos données.

### 2.2.3 ALTER TABLE
Comment modifier la structure de vos tables (ajouter, modifier, supprimer des colonnes).

### 2.2.4 DROP TABLE et TRUNCATE TABLE
Comment supprimer des tables ou vider leur contenu.

## Exemple Complet : Workflow DDL Typique

Voici un exemple complet montrant l'utilisation du DDL dans un projet réel :

```sql
-- ========================================
-- PROJET : Système de Gestion de Bibliothèque
-- Date : 2025-11-16
-- ========================================

-- 1. CRÉER LA BASE DE DONNÉES
CREATE DATABASE Bibliotheque;
GO

USE Bibliotheque;
GO

-- 2. CRÉER LES TABLES
CREATE TABLE Auteurs
(
    IdAuteur INT IDENTITY(1,1) PRIMARY KEY,
    Nom VARCHAR(100) NOT NULL,
    Prenom VARCHAR(100) NOT NULL,
    Nationalite VARCHAR(50)
);

CREATE TABLE Livres
(
    IdLivre INT IDENTITY(1,1) PRIMARY KEY,
    Titre VARCHAR(200) NOT NULL,
    ISBN VARCHAR(20) UNIQUE,
    AnneePublication INT,
    IdAuteur INT NOT NULL
);

CREATE TABLE Membres
(
    IdMembre INT IDENTITY(1,1) PRIMARY KEY,
    Nom VARCHAR(100) NOT NULL,
    Prenom VARCHAR(100) NOT NULL,
    Email VARCHAR(150) UNIQUE,
    DateInscription DATE DEFAULT GETDATE()
);

-- 3. AJOUTER LES CONTRAINTES DE CLÉ ÉTRANGÈRE
ALTER TABLE Livres
ADD CONSTRAINT FK_Livres_Auteurs
FOREIGN KEY (IdAuteur) REFERENCES Auteurs(IdAuteur);

-- 4. ÉVOLUTION : Ajout d'une nouvelle colonne (1 mois plus tard)
ALTER TABLE Livres
ADD NombrePages INT;

-- 5. CRÉER DES INDEX POUR LA PERFORMANCE
CREATE INDEX IX_Livres_Titre ON Livres(Titre);
CREATE INDEX IX_Membres_Email ON Membres(Email);

-- 6. NETTOYAGE : Supprimer une table de test
DROP TABLE IF EXISTS LivresTest;
```

## Résumé

- Le **DDL** (Data Definition Language) gère la **structure** de la base de données
- Les principales commandes sont : **CREATE**, **ALTER**, **DROP**, **TRUNCATE**
- Le DDL est **différent du DML** : structure vs. données
- Les commandes DDL sont **immédiates** et **nécessitent des permissions élevées**
- Toujours **planifier**, **tester** et **documenter** vos modifications DDL
- Le DDL est la **fondation** de votre application : une bonne structure est essentielle

## Prochaines Étapes

Maintenant que vous comprenez le rôle et l'importance du DDL, nous allons entrer dans les détails de chaque commande :

1. **CREATE DATABASE** : Créer votre première base de données
2. **CREATE TABLE** : Définir vos tables et leurs colonnes
3. **ALTER TABLE** : Faire évoluer vos structures
4. **DROP et TRUNCATE** : Gérer la suppression d'objets

Préparez-vous à construire votre première base de données ! 🎯

⏭️ [CREATE DATABASE](/02-definition-et-manipulation-des-donnees/02.1-create-database.md)
