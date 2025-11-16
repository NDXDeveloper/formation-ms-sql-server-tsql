🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 2. Définition et Manipulation des Données

## Introduction au chapitre

Bienvenue dans le cœur de SQL Server ! Ce chapitre est fondamental car il couvre deux aspects essentiels de toute base de données :

1. **La définition** : Comment créer et structurer vos données (tables, colonnes, contraintes)
2. **La manipulation** : Comment insérer, modifier et supprimer vos données

Si le chapitre précédent vous a présenté les concepts théoriques des bases de données, ce chapitre vous apprendra à **construire et gérer concrètement** votre base de données. Vous allez apprendre à créer vos propres tables, à y insérer des données, et à les manipuler.

---

## Vue d'ensemble du chapitre

Ce chapitre est organisé en six grandes sections qui vous guideront progressivement :

### 2.1 Les types de données (Data Types)
Les fondations : comprendre quels types d'informations peuvent être stockées (nombres, texte, dates, etc.)

### 2.2 DDL : Création et gestion des objets
Apprendre à créer des bases de données et des tables, et à les modifier

### 2.3 Contraintes d'intégrité
Garantir que vos données restent valides et cohérentes

### 2.4 DML : Insertion de données
Ajouter de nouvelles informations dans vos tables

### 2.5 DML : Modification de données
Mettre à jour les informations existantes

### 2.6 DML : Suppression de données
Retirer des informations de vos tables

---

## DDL vs DML : Deux sous-langages complémentaires

SQL n'est pas un langage monolithique. Il est composé de plusieurs **sous-langages**, chacun ayant un rôle spécifique. Dans ce chapitre, nous allons travailler principalement avec deux d'entre eux :

### DDL : Data Definition Language (Langage de définition des données)

Le **DDL** concerne la **structure** de la base de données. Il permet de créer, modifier ou supprimer les objets de la base de données (tables, colonnes, contraintes, etc.).

**Commandes principales du DDL :**
- `CREATE` : Créer un nouvel objet (base de données, table, etc.)
- `ALTER` : Modifier un objet existant
- `DROP` : Supprimer un objet
- `TRUNCATE` : Vider une table (supprimer toutes les lignes)

**Analogie :** Le DDL, c'est comme un architecte qui dessine les plans d'un bâtiment, décide du nombre de pièces, de leur taille, etc.

**Exemple DDL :**
```sql
-- Créer une nouvelle table
CREATE TABLE Clients (
    ClientID INT,
    Nom NVARCHAR(100),
    Email VARCHAR(255)
);

-- Modifier la table (ajouter une colonne)
ALTER TABLE Clients
ADD DateInscription DATE;

-- Supprimer la table
DROP TABLE Clients;
```

### DML : Data Manipulation Language (Langage de manipulation des données)

Le **DML** concerne les **données** elles-mêmes. Il permet d'insérer, modifier, supprimer ou consulter les données dans les tables existantes.

**Commandes principales du DML :**
- `INSERT` : Ajouter de nouvelles lignes
- `UPDATE` : Modifier des lignes existantes
- `DELETE` : Supprimer des lignes
- `SELECT` : Consulter les données (sera vu dans le chapitre 3)

**Analogie :** Le DML, c'est comme les habitants qui emménagent dans le bâtiment, déménagent des meubles, ou quittent l'immeuble.

**Exemple DML :**
```sql
-- Insérer un nouveau client
INSERT INTO Clients (ClientID, Nom, Email)
VALUES (1, N'Marie Dupont', 'marie.dupont@email.fr');

-- Modifier un client existant
UPDATE Clients
SET Email = 'marie.d@email.fr'
WHERE ClientID = 1;

-- Supprimer un client
DELETE FROM Clients
WHERE ClientID = 1;
```

### Différence visuelle DDL vs DML

| Aspect | DDL | DML |
|--------|-----|-----|
| **Objectif** | Structure de la base | Contenu de la base |
| **Action sur** | Tables, colonnes, contraintes | Lignes de données |
| **Fréquence** | Rare (conception initiale) | Fréquent (opérations quotidiennes) |
| **Réversible** | Difficile (perte potentielle) | Plus facile (transactions) |
| **Exemple** | Créer une table Clients | Ajouter un client dans la table |
| **Commandes** | CREATE, ALTER, DROP | INSERT, UPDATE, DELETE |

---

## Les autres sous-langages SQL (Aperçu)

Bien que ce chapitre se concentre sur DDL et DML, il est utile de connaître les autres sous-langages de SQL :

### DCL : Data Control Language
Gestion des permissions et de la sécurité
- `GRANT` : Accorder des permissions
- `DENY` : Refuser des permissions
- `REVOKE` : Retirer des permissions

### TCL : Transaction Control Language
Gestion des transactions (sera vu au chapitre 6)
- `BEGIN TRANSACTION` : Démarrer une transaction
- `COMMIT` : Valider une transaction
- `ROLLBACK` : Annuler une transaction

### DQL : Data Query Language
Interrogation des données (parfois considéré comme partie du DML)
- `SELECT` : Consulter les données (chapitre 3 entier)

---

## Le cycle de vie d'une base de données

Pour mieux comprendre comment DDL et DML s'articulent, voici le cycle de vie typique d'une base de données :

### Phase 1 : Conception et création (DDL)

```sql
-- 1. Créer la base de données
CREATE DATABASE MaBoutique;

-- 2. Créer les tables
CREATE TABLE Produits (
    ProduitID INT PRIMARY KEY,
    Nom NVARCHAR(200),
    Prix DECIMAL(10, 2),
    Stock INT
);

CREATE TABLE Clients (
    ClientID INT PRIMARY KEY,
    Nom NVARCHAR(100),
    Email VARCHAR(255)
);

CREATE TABLE Commandes (
    CommandeID INT PRIMARY KEY,
    ClientID INT,
    DateCommande DATE,
    MontantTotal DECIMAL(10, 2)
);
```

**Cette phase se fait généralement une seule fois**, lors de la création initiale de la base de données.

### Phase 2 : Utilisation quotidienne (DML)

```sql
-- Ajouter des produits
INSERT INTO Produits VALUES (1, N'Ordinateur portable', 899.99, 10);
INSERT INTO Produits VALUES (2, N'Souris sans fil', 29.99, 50);

-- Enregistrer une commande
INSERT INTO Commandes VALUES (1, 100, '2024-11-15', 899.99);

-- Mettre à jour le stock après une vente
UPDATE Produits
SET Stock = Stock - 1
WHERE ProduitID = 1;

-- Supprimer un produit obsolète
DELETE FROM Produits WHERE ProduitID = 2;
```

**Cette phase se répète continuellement**, au fur et à mesure de l'utilisation de l'application.

### Phase 3 : Évolution (DDL)

```sql
-- Ajouter une nouvelle colonne
ALTER TABLE Produits
ADD Description NVARCHAR(MAX);

-- Ajouter une contrainte
ALTER TABLE Commandes
ADD CONSTRAINT FK_Commandes_Clients
FOREIGN KEY (ClientID) REFERENCES Clients(ClientID);
```

**Cette phase intervient ponctuellement**, quand les besoins métier évoluent.

---

## L'importance de l'ordre : Structure avant données

**Règle fondamentale :** Vous devez d'abord définir la structure (DDL) avant de pouvoir manipuler les données (DML).

### Séquence correcte ✅

```sql
-- 1. D'abord : créer la table (DDL)
CREATE TABLE Employes (
    EmployeID INT,
    Nom NVARCHAR(100),
    Salaire DECIMAL(10, 2)
);

-- 2. Ensuite : insérer des données (DML)
INSERT INTO Employes VALUES (1, N'Marie Dupont', 45000.00);
```

### Séquence incorrecte ❌

```sql
-- ❌ Ceci échouera : la table n'existe pas encore !
INSERT INTO Employes VALUES (1, N'Marie Dupont', 45000.00);

-- Ensuite créer la table ne résout pas le problème
CREATE TABLE Employes (
    EmployeID INT,
    Nom NVARCHAR(100),
    Salaire DECIMAL(10, 2)
);
```

**Erreur générée :** `Invalid object name 'Employes'.`

---

## Comprendre les tables : Le cœur de la base de données relationnelle

Avant d'aller plus loin, assurons-nous de bien comprendre ce qu'est une table.

### Qu'est-ce qu'une table ?

Une **table** est une structure de stockage qui organise les données en **lignes** et **colonnes**, comme un tableau Excel.

**Composants d'une table :**
- **Nom de la table** : identifie la table (ex: "Clients", "Produits")
- **Colonnes** : définissent les attributs (ex: Nom, Email, DateNaissance)
- **Lignes** : contiennent les données réelles (ex: un client spécifique)
- **Cellules** : intersection d'une ligne et d'une colonne (une valeur)

### Représentation visuelle

```
Table : Clients
┌──────────┬────────────────┬──────────────────────┬──────────────┐
│ ClientID │ Nom            │ Email                │ DateInscr.   │
├──────────┼────────────────┼──────────────────────┼──────────────┤
│ 1        │ Marie Dupont   │ marie.d@email.fr     │ 2024-01-15   │
│ 2        │ Pierre Martin  │ pierre.m@email.com   │ 2024-02-20   │
│ 3        │ Julie Leroux   │ julie.l@email.fr     │ 2024-03-10   │
└──────────┴────────────────┴──────────────────────┴──────────────┘
    ↑            ↑                  ↑                      ↑
  Colonne    Colonne            Colonne              Colonne

  ←────────────────── Ligne (enregistrement) ─────────────────→
```

### Terminologie : Ligne vs Enregistrement

Les termes suivants sont **synonymes** et utilisés de manière interchangeable :
- **Ligne** = **Enregistrement** = **Row** (anglais) = **Tuple** (mathématique)
- **Colonne** = **Attribut** = **Champ** = **Field** (anglais)

**Exemple :** "La table Clients contient 3 lignes" = "La table Clients contient 3 enregistrements"

---

## Schémas : Organisation logique des tables

Dans SQL Server, les tables sont organisées en **schémas** (schemas). Un schéma est comme un dossier qui regroupe logiquement des tables liées.

### Schéma par défaut : dbo

Par défaut, SQL Server utilise le schéma `dbo` (database owner).

```sql
-- Ces deux syntaxes sont équivalentes
CREATE TABLE Clients (...);
CREATE TABLE dbo.Clients (...);  -- Explicit schema
```

### Pourquoi utiliser des schémas ?

Les schémas permettent d'organiser logiquement les tables :

```sql
-- Schéma pour les ventes
CREATE SCHEMA Ventes;
CREATE TABLE Ventes.Commandes (...);
CREATE TABLE Ventes.Factures (...);

-- Schéma pour les ressources humaines
CREATE SCHEMA RH;
CREATE TABLE RH.Employes (...);
CREATE TABLE RH.Salaires (...);

-- Schéma pour la production
CREATE SCHEMA Production;
CREATE TABLE Production.Produits (...);
CREATE TABLE Production.Stock (...);
```

**Avantages :**
- ✅ Organisation claire et logique
- ✅ Séparation des responsabilités
- ✅ Gestion des permissions plus fine
- ✅ Évite les conflits de noms

---

## Conventions de nommage (Best Practices)

Adopter de bonnes conventions de nommage dès le début facilite la maintenance à long terme.

### Noms de tables

```sql
-- ✅ Bonnes pratiques
CREATE TABLE Clients (...);          -- Pluriel, PascalCase
CREATE TABLE CommandesLignes (...);  -- Clair et descriptif
CREATE TABLE HistoriquesPrix (...);

-- ❌ À éviter
CREATE TABLE client (...);           -- Minuscule
CREATE TABLE tbl_clients (...);      -- Préfixe inutile
CREATE TABLE C (...);                -- Trop court, pas clair
CREATE TABLE Clients_Base (...);     -- Suffixe inutile
```

### Noms de colonnes

```sql
-- ✅ Bonnes pratiques
ClientID INT                         -- PascalCase, suffixe ID pour clés
Nom NVARCHAR(100)                    -- Clair et descriptif
DateNaissance DATE                   -- Préfixe 'Date' pour les dates
EstActif BIT                         -- Préfixe 'Est' pour les booléens
MontantTTC DECIMAL(10, 2)            -- Inclut l'unité dans le nom

-- ❌ À éviter
client_id INT                        -- Snake_case (moins lisible en T-SQL)
n NVARCHAR(100)                      -- Trop court
DateDeNaissanceDuClient DATE         -- Trop long
actif BIT                            -- Minuscule
montant DECIMAL(10, 2)               -- Pas d'indication d'unité
```

### Règles générales

1. **Utilisez PascalCase** : `ClientID`, `DateCommande`, `MontantTotal`
2. **Soyez descriptif** : `DateNaissance` plutôt que `DN`
3. **Évitez les mots réservés** : `ORDER`, `SELECT`, `TABLE` comme noms
4. **Pas de caractères spéciaux** : évitez espaces et accents dans les noms
5. **Cohérence** : choisissez une convention et respectez-la partout

```sql
-- ✅ Exemple cohérent et professionnel
CREATE TABLE Commandes (
    CommandeID INT PRIMARY KEY,
    ClientID INT,
    DateCommande DATETIME2(3),
    MontantHT DECIMAL(10, 2),
    MontantTTC DECIMAL(10, 2),
    EstPayee BIT,
    EstLivree BIT
);
```

---

## NULL : Le concept de valeur manquante

Un concept fondamental à comprendre avant de manipuler des données est **NULL**.

### Qu'est-ce que NULL ?

**NULL** représente **l'absence de valeur**. Ce n'est pas zéro, ce n'est pas une chaîne vide, c'est littéralement "pas de valeur" ou "inconnu".

**Analogie :** Si quelqu'un vous demande "Quelle est la couleur de ta voiture ?", et que vous n'avez pas de voiture, la réponse est NULL (pas de réponse applicable), pas "transparent" ou "aucune couleur".

### NULL vs 0 vs '' (chaîne vide)

```sql
-- Trois valeurs très différentes
DECLARE @nombre INT = NULL;        -- Valeur inconnue/absente
DECLARE @zero INT = 0;             -- Valeur connue : zéro
DECLARE @texte VARCHAR(10) = '';   -- Chaîne vide (différent de NULL)

-- Comparaison
SELECT
    CASE WHEN @nombre IS NULL THEN 'NULL' ELSE 'Valeur' END,
    CASE WHEN @zero = 0 THEN 'Zéro' ELSE 'Autre' END,
    CASE WHEN @texte = '' THEN 'Vide' ELSE 'Texte' END;
```

### Exemples concrets de NULL

```sql
CREATE TABLE Employes (
    EmployeID INT,
    Nom NVARCHAR(100),
    Telephone VARCHAR(20),      -- Peut être NULL (optionnel)
    Email VARCHAR(255),         -- Peut être NULL (optionnel)
    DateDemission DATE          -- NULL si toujours employé
);

-- Insertion avec des valeurs NULL
INSERT INTO Employes VALUES
    (1, N'Marie Dupont', '0612345678', 'marie@email.fr', NULL),  -- Toujours employée
    (2, N'Pierre Martin', NULL, 'pierre@email.fr', NULL),        -- Pas de téléphone
    (3, N'Julie Leroux', NULL, NULL, '2023-12-31');              -- A démissionné
```

### Opérations avec NULL

**Important :** NULL se comporte de manière spéciale dans les opérations.

```sql
-- Arithmétique avec NULL
SELECT 10 + NULL;           -- Résultat : NULL
SELECT 100 * NULL;          -- Résultat : NULL
SELECT NULL / 5;            -- Résultat : NULL

-- Comparaisons avec NULL (ne fonctionnent PAS normalement !)
SELECT * FROM Employes WHERE Telephone = NULL;      -- ❌ Ne trouve rien !
SELECT * FROM Employes WHERE Telephone IS NULL;     -- ✅ Correct !

-- Concaténation avec NULL
SELECT 'Bonjour ' + NULL;   -- Résultat : NULL
```

**Règle d'or :** Pour vérifier NULL, utilisez toujours `IS NULL` ou `IS NOT NULL`, jamais `= NULL`.

---

## Les contraintes : Gardiens de l'intégrité

Les **contraintes** sont des règles que vous définissez sur vos tables pour garantir la qualité et la cohérence des données.

### Vue d'ensemble des contraintes

| Contrainte | Rôle | Exemple |
|------------|------|---------|
| **PRIMARY KEY** | Identifie uniquement chaque ligne | ClientID |
| **FOREIGN KEY** | Lien entre tables | CommandeID → Commandes |
| **UNIQUE** | Empêche les doublons | Email unique |
| **CHECK** | Validation personnalisée | Age > 0 |
| **DEFAULT** | Valeur par défaut | DateCreation = Aujourd'hui |
| **NOT NULL** | Valeur obligatoire | Nom ne peut pas être NULL |

### Pourquoi utiliser des contraintes ?

**Sans contraintes :**
```sql
CREATE TABLE Produits (
    ProduitID INT,
    Nom NVARCHAR(200),
    Prix DECIMAL(10, 2)
);

-- Problèmes possibles :
INSERT INTO Produits VALUES (1, N'Laptop', -100);     -- Prix négatif !
INSERT INTO Produits VALUES (1, N'Mouse', 25);        -- ID dupliqué !
INSERT INTO Produits VALUES (NULL, NULL, NULL);       -- Données vides !
```

**Avec contraintes :**
```sql
CREATE TABLE Produits (
    ProduitID INT PRIMARY KEY,              -- Unique et NOT NULL
    Nom NVARCHAR(200) NOT NULL,             -- Obligatoire
    Prix DECIMAL(10, 2) CHECK (Prix > 0),   -- Doit être positif
    DateCreation DATE DEFAULT GETDATE()     -- Valeur par défaut
);

-- Ces insertions invalides seront REJETÉES automatiquement
INSERT INTO Produits VALUES (1, N'Laptop', -100);     -- ❌ Prix négatif
INSERT INTO Produits VALUES (1, N'Mouse', 25);        -- ❌ ID dupliqué
INSERT INTO Produits VALUES (NULL, NULL, 5);          -- ❌ ProduitID NULL
```

Les contraintes seront détaillées dans la section 2.3.

---

## Transactions : Le concept de base

Bien que les transactions soient couvertes en détail au chapitre 6, il est important d'en comprendre le principe de base.

### Qu'est-ce qu'une transaction ?

Une **transaction** est un groupe d'opérations qui doivent réussir **toutes ensemble** ou **échouer ensemble**. C'est le principe du "tout ou rien".

**Analogie :** Un virement bancaire entre deux comptes :
1. Débiter le compte A de 100€
2. Créditer le compte B de 100€

Si l'étape 1 réussit mais l'étape 2 échoue, vous perdez 100€ ! Une transaction garantit que soit les deux réussissent, soit aucune ne se fait.

### Exemple simple

```sql
-- Début de la transaction
BEGIN TRANSACTION;

    -- Opération 1 : Débiter le stock
    UPDATE Produits
    SET Stock = Stock - 1
    WHERE ProduitID = 1;

    -- Opération 2 : Créer la commande
    INSERT INTO Commandes (CommandeID, ClientID, MontantTotal)
    VALUES (100, 42, 899.99);

-- Si tout va bien : valider
COMMIT;

-- Si erreur : annuler tout
-- ROLLBACK;
```

**Le concept important :** Les modifications DML (INSERT, UPDATE, DELETE) peuvent être validées ou annulées.

---

## Feuille de route du chapitre

Maintenant que vous comprenez les concepts de base, voici comment nous allons progresser :

### Étape 1 : Les fondations (Section 2.1)
**Objectif :** Comprendre les types de données disponibles
- Quels types pour quelles données ?
- Comment choisir le bon type ?
- Impact sur le stockage et les performances

### Étape 2 : Créer la structure (Section 2.2)
**Objectif :** Apprendre à créer et modifier des objets
- Créer une base de données
- Créer des tables
- Modifier des tables existantes
- Supprimer des objets

### Étape 3 : Garantir l'intégrité (Section 2.3)
**Objectif :** Ajouter des règles de validation
- Clés primaires et étrangères
- Contraintes d'unicité
- Validations personnalisées
- Valeurs par défaut

### Étape 4 : Ajouter des données (Section 2.4)
**Objectif :** Remplir les tables
- Insérer une ligne
- Insérer plusieurs lignes
- Insérer depuis une autre table

### Étape 5 : Modifier des données (Section 2.5)
**Objectif :** Mettre à jour les informations
- Modifier une ou plusieurs lignes
- Utiliser WHERE correctement
- Éviter les erreurs courantes

### Étape 6 : Supprimer des données (Section 2.6)
**Objectif :** Retirer des informations
- Supprimer des lignes spécifiques
- Vider une table
- Différence entre DELETE et TRUNCATE

---

## Conseils pour progresser efficacement

### 1. Pratiquez dans l'ordre
Les sections s'appuient les unes sur les autres. Ne sautez pas d'étapes !

### 2. Expérimentez
Créez vos propres exemples, testez, faites des erreurs (dans un environnement de test !).

### 3. Comprenez avant de mémoriser
Il est plus important de comprendre **pourquoi** que de mémoriser **comment**.

### 4. Prenez des notes
Documentez les concepts qui vous semblent importants ou difficiles.

### 5. Créez des exemples concrets
Utilisez des cas d'usage qui vous parlent (gestion de bibliothèque, collection de films, etc.).

---

## Environnement de pratique

Pour suivre ce chapitre, vous aurez besoin d'un environnement SQL Server. Voici quelques options :

### Option 1 : SQL Server Express (gratuit)
- Installation locale
- Complet et gratuit
- Idéal pour l'apprentissage

### Option 2 : Azure Data Studio
- Outil moderne et léger
- Cross-platform (Windows, Mac, Linux)
- Gratuit

### Option 3 : SQL Server Management Studio (SSMS)
- Outil traditionnel Microsoft
- Windows uniquement
- Gratuit et très complet

### Créer une base de données de test

```sql
-- Créer une base de données pour vos exercices
CREATE DATABASE FormationSQL;

-- L'utiliser
USE FormationSQL;

-- Vous êtes prêt à créer vos tables !
```

---

## Points clés à retenir

- ✅ **DDL** définit la structure (CREATE, ALTER, DROP)
- ✅ **DML** manipule les données (INSERT, UPDATE, DELETE)
- ✅ **Structure avant données** : créez les tables avant d'insérer
- ✅ **Tables = lignes + colonnes** : organisation tabulaire
- ✅ **NULL** = absence de valeur (pas zéro, pas vide)
- ✅ **Contraintes** = règles pour garantir l'intégrité
- ✅ **Nommage cohérent** = maintenance facilitée

---

## Prochaine étape

Maintenant que vous comprenez l'architecture générale et les concepts de base, nous allons commencer par les fondations : **les types de données**.

Dans la section 2.1, vous découvrirez :
- Les types numériques (INT, DECIMAL, FLOAT)
- Les types de chaînes (VARCHAR, NVARCHAR)
- Les types de date et heure (DATE, DATETIME2)
- Les types spéciaux (BIT, UNIQUEIDENTIFIER, etc.)

Chaque type a ses spécificités, ses avantages, et ses cas d'usage. Maîtriser les types de données est la première étape pour créer des bases de données robustes et performantes.

**C'est parti ! 🚀**

⏭️ [Les types de données (Data Types)](/02-definition-et-manipulation-des-donnees/01-les-types-de-donnees.md)
