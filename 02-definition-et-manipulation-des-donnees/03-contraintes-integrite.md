🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 2.3 Contraintes d'intégrité (Constraints)

## Introduction

Imaginez une bibliothèque sans règles : n'importe qui pourrait emprunter 100 livres à la fois, deux personnes pourraient avoir la même carte de lecteur, ou des livres pourraient être enregistrés avec un prix de -50€. Ce serait le chaos !

Les **contraintes d'intégrité** sont les **règles** que vous définissez pour garantir que vos données restent **cohérentes**, **valides** et **fiables**. Elles agissent comme des **gardiens** qui vérifient automatiquement que les données respectent les règles métier avant d'être insérées ou modifiées dans la base de données.

**Analogie :** Les contraintes sont comme les règles d'un jeu de société : elles définissent ce qui est autorisé et ce qui ne l'est pas. Sans ces règles, le jeu (votre base de données) devient ingérable.

## Qu'est-ce que l'Intégrité des Données ?

### Définition

L'**intégrité des données** signifie que les données de votre base sont :
- **Exactes** : elles reflètent la réalité
- **Cohérentes** : elles respectent les règles métier
- **Valides** : elles sont dans des formats et plages acceptables
- **Fiables** : on peut leur faire confiance pour prendre des décisions

### Exemple sans Contraintes (Problématique)

```sql
-- Table SANS contraintes
CREATE TABLE Clients
(
    IdClient INT,
    Nom VARCHAR(100),
    Email VARCHAR(150),
    Age INT,
    Pays VARCHAR(50)
);
```

**Problèmes potentiels :**

```sql
-- ❌ Deux clients avec le même ID
INSERT INTO Clients VALUES (1, 'Dupont', 'dupont@email.com', 25, 'France');
INSERT INTO Clients VALUES (1, 'Martin', 'martin@email.com', 30, 'Belgique');

-- ❌ Email en double
INSERT INTO Clients VALUES (2, 'Bernard', 'dupont@email.com', 28, 'France');

-- ❌ Âge négatif
INSERT INTO Clients VALUES (3, 'Durand', 'durand@email.com', -5, 'France');

-- ❌ Client sans nom
INSERT INTO Clients VALUES (4, NULL, 'anonyme@email.com', 40, 'France');

-- ❌ Âge aberrant
INSERT INTO Clients VALUES (5, 'Lambert', 'lambert@email.com', 250, 'Suisse');
```

**Résultat :** Base de données incohérente et inutilisable !

### Exemple avec Contraintes (Solution)

```sql
-- Table AVEC contraintes
CREATE TABLE Clients
(
    IdClient INT PRIMARY KEY,                    -- Garantit l'unicité de l'ID
    Nom VARCHAR(100) NOT NULL,                   -- Nom obligatoire
    Email VARCHAR(150) NOT NULL UNIQUE,          -- Email obligatoire et unique
    Age INT CHECK (Age BETWEEN 0 AND 120),       -- Âge valide
    Pays VARCHAR(50) DEFAULT 'France',           -- Valeur par défaut
    DateInscription DATE NOT NULL DEFAULT GETDATE()
);
```

**Avantages :**

```sql
-- ❌ REJETÉ : ID en double
INSERT INTO Clients (IdClient, Nom, Email, Age)
VALUES (1, 'Dupont', 'dupont@email.com', 25);

INSERT INTO Clients (IdClient, Nom, Email, Age)
VALUES (1, 'Martin', 'martin@email.com', 30);
-- Erreur : Violation of PRIMARY KEY constraint

-- ❌ REJETÉ : Email en double
INSERT INTO Clients (IdClient, Nom, Email, Age)
VALUES (2, 'Bernard', 'dupont@email.com', 28);
-- Erreur : Violation of UNIQUE KEY constraint

-- ❌ REJETÉ : Âge négatif
INSERT INTO Clients (IdClient, Nom, Email, Age)
VALUES (3, 'Durand', 'durand@email.com', -5);
-- Erreur : Violation of CHECK constraint

-- ✅ ACCEPTÉ : Données valides
INSERT INTO Clients (IdClient, Nom, Email, Age)
VALUES (2, 'Bernard', 'bernard@email.com', 28);
```

## Les Différents Types de Contraintes

SQL Server propose **six types** de contraintes principales pour garantir l'intégrité de vos données.

### Vue d'Ensemble

| Contrainte | Symbole | Rôle | Exemple |
|------------|---------|------|---------|
| **PRIMARY KEY** | 🔑 | Identifie uniquement chaque ligne | `IdClient INT PRIMARY KEY` |
| **FOREIGN KEY** | 🔗 | Crée des relations entre tables | `IdClient INT FOREIGN KEY REFERENCES Clients` |
| **UNIQUE** | ✨ | Garantit l'unicité d'une valeur | `Email VARCHAR(150) UNIQUE` |
| **CHECK** | ✓ | Valide selon des règles personnalisées | `Age INT CHECK (Age >= 18)` |
| **DEFAULT** | 📝 | Définit une valeur par défaut | `Pays VARCHAR(50) DEFAULT 'France'` |
| **NOT NULL** | ❗ | Rend une colonne obligatoire | `Nom VARCHAR(100) NOT NULL` |

### Hiérarchie d'Importance

```
1. PRIMARY KEY (PK)      ──→ Identifiant unique de chaque ligne
2. FOREIGN KEY (FK)      ──→ Relations et cohérence entre tables
3. NOT NULL              ──→ Données obligatoires
4. UNIQUE                ──→ Unicité sur colonnes non-PK
5. CHECK                 ──→ Règles métier personnalisées
6. DEFAULT               ──→ Valeurs automatiques
```

## Les Contraintes en Détail

### 1. PRIMARY KEY (Clé Primaire) 🔑

**Rôle :** Identifier de manière **unique** chaque ligne d'une table.

**Caractéristiques :**
- Une seule PRIMARY KEY par table
- Valeurs UNIQUE + NOT NULL
- Crée automatiquement un index

```sql
CREATE TABLE Produits
(
    IdProduit INT PRIMARY KEY,
    Nom VARCHAR(150)
);
```

**Pourquoi c'est essentiel :**
- Permet d'identifier précisément chaque enregistrement
- Sert de référence pour les clés étrangères
- Améliore les performances (index automatique)

**Sans PRIMARY KEY :**
```
❌ Comment distinguer deux produits avec le même nom ?
❌ Comment créer des relations avec d'autres tables ?
❌ Comment garantir l'unicité des enregistrements ?
```

### 2. FOREIGN KEY (Clé Étrangère) 🔗

**Rôle :** Créer des **relations** entre tables et garantir l'**intégrité référentielle**.

**Caractéristiques :**
- Référence une PRIMARY KEY d'une autre table
- Plusieurs FOREIGN KEY possibles par table
- Empêche les données orphelines

```sql
CREATE TABLE Commandes
(
    IdCommande INT PRIMARY KEY,
    IdClient INT,
    DateCommande DATE,
    CONSTRAINT FK_Commandes_Clients
        FOREIGN KEY (IdClient) REFERENCES Clients(IdClient)
);
```

**Pourquoi c'est essentiel :**
- Garantit que les relations restent cohérentes
- Empêche la suppression de données référencées
- Documente les relations entre tables

**Sans FOREIGN KEY :**
```
❌ Commande avec un client inexistant (données orphelines)
❌ Suppression accidentelle d'un client ayant des commandes
❌ Incohérence dans les relations
```

### 3. UNIQUE (Unicité) ✨

**Rôle :** Garantir qu'une valeur est **unique** dans toute la table.

**Caractéristiques :**
- Plusieurs contraintes UNIQUE possibles par table
- Autorise NULL (mais généralement une seule fois)
- Crée automatiquement un index

```sql
CREATE TABLE Utilisateurs
(
    IdUtilisateur INT PRIMARY KEY,
    NomUtilisateur VARCHAR(50) UNIQUE,
    Email VARCHAR(150) UNIQUE
);
```

**Pourquoi c'est utile :**
- Empêche les doublons sur des colonnes importantes
- Garantit l'unicité sans être une PRIMARY KEY
- Idéal pour emails, noms d'utilisateur, codes produits

**Sans UNIQUE :**
```
❌ Deux utilisateurs avec le même email
❌ Deux produits avec le même code-barre
❌ Confusion et doublons dans les données
```

### 4. CHECK (Validation) ✓

**Rôle :** Valider les données selon des **règles métier personnalisées**.

**Caractéristiques :**
- Plusieurs contraintes CHECK possibles par table
- Peut valider une ou plusieurs colonnes
- Rejette les données invalides

```sql
CREATE TABLE Employes
(
    IdEmploye INT PRIMARY KEY,
    Age INT CHECK (Age BETWEEN 18 AND 70),
    Salaire DECIMAL(10,2) CHECK (Salaire > 0),
    Statut VARCHAR(20) CHECK (Statut IN ('Actif', 'Inactif', 'Retraité'))
);
```

**Pourquoi c'est puissant :**
- Applique les règles métier au niveau base de données
- Empêche les données aberrantes ou invalides
- Centralise la validation (une seule source de vérité)

**Sans CHECK :**
```
❌ Âge négatif ou aberrant (250 ans)
❌ Prix négatif (-50€)
❌ Statut invalide ('EnVacances' au lieu de 'Actif')
```

### 5. DEFAULT (Valeur par Défaut) 📝

**Rôle :** Définir une valeur **automatique** si aucune valeur n'est fournie.

**Caractéristiques :**
- Simplifie les insertions
- Garantit une valeur cohérente
- Peut utiliser des fonctions (GETDATE(), NEWID())

```sql
CREATE TABLE Articles
(
    IdArticle INT PRIMARY KEY,
    Titre VARCHAR(200),
    DatePublication DATE DEFAULT GETDATE(),
    EstPublie BIT DEFAULT 0,
    Langue VARCHAR(10) DEFAULT 'FR'
);
```

**Pourquoi c'est pratique :**
- Réduit les erreurs d'oubli
- Simplifie le code d'insertion
- Documente les valeurs standards

**Sans DEFAULT :**
```
❌ Oubli de spécifier la date → NULL
❌ Code d'insertion plus long et répétitif
❌ Risque d'incohérence dans les valeurs
```

### 6. NOT NULL (Obligatoire) ❗

**Rôle :** Rendre une colonne **obligatoire** (interdire NULL).

**Caractéristiques :**
- Empêche les valeurs vides/manquantes
- Garantit la présence d'information
- Souvent combiné avec DEFAULT

```sql
CREATE TABLE Clients
(
    IdClient INT PRIMARY KEY,
    Nom VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    Telephone VARCHAR(20)  -- Optionnel (NULL autorisé)
);
```

**Pourquoi c'est important :**
- Garantit que les données essentielles sont présentes
- Évite les bugs liés aux valeurs NULL
- Documente les champs obligatoires

**Sans NOT NULL :**
```
❌ Client sans nom ou sans email
❌ Données incomplètes difficiles à exploiter
❌ Calculs et traitements compliqués par les NULL
```

## Relations entre Contraintes

Les contraintes fonctionnent souvent ensemble pour garantir l'intégrité complète :

### Exemple Complet : Système E-commerce

```sql
-- Table Clients
CREATE TABLE Clients
(
    IdClient INT IDENTITY(1,1) PRIMARY KEY,              -- 🔑 Identifiant unique
    Email VARCHAR(150) NOT NULL UNIQUE,                   -- ❗✨ Obligatoire et unique
    Nom VARCHAR(100) NOT NULL,                            -- ❗ Obligatoire
    Prenom VARCHAR(50) NOT NULL,                          -- ❗ Obligatoire
    DateInscription DATE NOT NULL DEFAULT GETDATE(),      -- ❗📝 Obligatoire avec défaut
    EstActif BIT NOT NULL DEFAULT 1                       -- ❗📝 Obligatoire avec défaut
);

-- Table Produits
CREATE TABLE Produits
(
    IdProduit INT IDENTITY(1,1) PRIMARY KEY,              -- 🔑 Identifiant unique
    CodeProduit VARCHAR(20) NOT NULL UNIQUE,              -- ❗✨ Obligatoire et unique
    Nom VARCHAR(150) NOT NULL,                            -- ❗ Obligatoire
    Prix DECIMAL(10,2) NOT NULL CHECK (Prix > 0),         -- ❗✓ Obligatoire et positif
    Stock INT NOT NULL DEFAULT 0 CHECK (Stock >= 0),      -- ❗📝✓ Obligatoire, défaut, positif
    EstDisponible BIT NOT NULL DEFAULT 1                  -- ❗📝 Obligatoire avec défaut
);

-- Table Commandes
CREATE TABLE Commandes
(
    IdCommande INT IDENTITY(1,1) PRIMARY KEY,             -- 🔑 Identifiant unique
    NumeroCommande VARCHAR(30) NOT NULL UNIQUE,           -- ❗✨ Obligatoire et unique
    IdClient INT NOT NULL,                                -- ❗ Obligatoire
    DateCommande DATETIME2 NOT NULL DEFAULT GETDATE(),    -- ❗📝 Obligatoire avec défaut
    MontantTotal DECIMAL(10,2) NOT NULL CHECK (MontantTotal >= 0), -- ❗✓ Obligatoire et positif
    Statut VARCHAR(20) NOT NULL DEFAULT 'En attente'      -- ❗📝 Obligatoire avec défaut
        CHECK (Statut IN ('En attente', 'Payée', 'Expédiée', 'Livrée', 'Annulée')), -- ✓ Liste fermée
    CONSTRAINT FK_Commandes_Clients                       -- 🔗 Relation avec Clients
        FOREIGN KEY (IdClient) REFERENCES Clients(IdClient)
);

-- Table LignesCommande (relation N-N entre Commandes et Produits)
CREATE TABLE LignesCommande
(
    IdLigne INT IDENTITY(1,1) PRIMARY KEY,                -- 🔑 Identifiant unique
    IdCommande INT NOT NULL,                              -- ❗ Obligatoire
    IdProduit INT NOT NULL,                               -- ❗ Obligatoire
    Quantite INT NOT NULL CHECK (Quantite > 0),           -- ❗✓ Obligatoire et positif
    PrixUnitaire DECIMAL(10,2) NOT NULL CHECK (PrixUnitaire > 0), -- ❗✓ Obligatoire et positif
    CONSTRAINT FK_Lignes_Commandes                        -- 🔗 Relation avec Commandes
        FOREIGN KEY (IdCommande) REFERENCES Commandes(IdCommande),
    CONSTRAINT FK_Lignes_Produits                         -- 🔗 Relation avec Produits
        FOREIGN KEY (IdProduit) REFERENCES Produits(IdProduit)
);
```

**Ce système garantit :**
- ✅ Chaque client, produit et commande a un identifiant unique
- ✅ Les emails sont uniques (pas de comptes en double)
- ✅ Les relations sont cohérentes (pas de commandes orphelines)
- ✅ Les prix et quantités sont valides (positifs)
- ✅ Les statuts sont dans une liste prédéfinie
- ✅ Les dates et statuts ont des valeurs par défaut sensées

## Pourquoi les Contraintes sont-elles Essentielles ?

### 1. Qualité des Données

Les contraintes empêchent l'insertion de données **invalides** ou **incohérentes**.

```sql
-- Sans contraintes : Catastrophe !
INSERT INTO Produits VALUES (-5, 'Ordinateur', -899.99, -10, 'Oui');
-- Prix négatif, stock négatif, EstDisponible = texte au lieu de booléen

-- Avec contraintes : Protection !
-- Toutes ces valeurs invalides seraient rejetées automatiquement
```

### 2. Cohérence Globale

Les contraintes garantissent que les **relations** entre tables restent cohérentes.

```sql
-- Sans FOREIGN KEY : Problème !
DELETE FROM Clients WHERE IdClient = 1;
-- Le client est supprimé mais ses commandes restent orphelines

-- Avec FOREIGN KEY : Protection !
-- La suppression est refusée car le client a des commandes
-- Ou les commandes sont supprimées en cascade (si configuré)
```

### 3. Documentation Automatique

Les contraintes **documentent** les règles métier directement dans la structure.

```sql
-- En lisant cette table, on comprend immédiatement les règles :
CREATE TABLE Employes
(
    IdEmploye INT PRIMARY KEY,                       -- Identifiant unique
    Age INT CHECK (Age BETWEEN 18 AND 70),          -- Âge entre 18 et 70
    Salaire DECIMAL(10,2) CHECK (Salaire >= 1800),  -- Salaire minimum 1800€
    Departement VARCHAR(50) DEFAULT 'Non assigné'    -- Département par défaut
);
```

### 4. Sécurité et Fiabilité

Les contraintes protègent contre les **erreurs humaines** et les **bugs applicatifs**.

```sql
-- Bug dans l'application : oubli de validation
-- Mais la base de données refuse les données invalides !
INSERT INTO Produits (Prix) VALUES (-100);  -- Rejeté par CHECK
```

### 5. Performances

Certaines contraintes créent des **index automatiques** qui améliorent les performances.

```sql
-- PRIMARY KEY et UNIQUE créent automatiquement des index
CREATE TABLE Clients
(
    IdClient INT PRIMARY KEY,        -- Index automatique
    Email VARCHAR(150) UNIQUE        -- Index automatique
);

-- Recherches rapides grâce aux index
SELECT * FROM Clients WHERE IdClient = 1234;      -- Très rapide
SELECT * FROM Clients WHERE Email = 'test@email.com';  -- Très rapide
```

## Comment Définir des Contraintes ?

### Lors de la Création de la Table

**Syntaxe Inline (Simple) :**

```sql
CREATE TABLE Exemple
(
    Id INT PRIMARY KEY,
    Email VARCHAR(150) UNIQUE,
    Age INT CHECK (Age >= 18),
    Pays VARCHAR(50) DEFAULT 'France',
    Nom VARCHAR(100) NOT NULL
);
```

**Syntaxe avec Noms de Contraintes (Recommandé) :**

```sql
CREATE TABLE Exemple
(
    Id INT,
    Email VARCHAR(150),
    Age INT,
    Pays VARCHAR(50),
    Nom VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Exemple PRIMARY KEY (Id),
    CONSTRAINT UQ_Exemple_Email UNIQUE (Email),
    CONSTRAINT CHK_Exemple_Age CHECK (Age >= 18),
    CONSTRAINT DF_Exemple_Pays DEFAULT 'France' FOR Pays
);
```

**Avantages de nommer les contraintes :**
- Facilite la suppression/modification
- Rend les messages d'erreur plus clairs
- Améliore la documentation

### Après la Création de la Table

```sql
-- D'abord créer la table
CREATE TABLE Exemple
(
    Id INT,
    Email VARCHAR(150),
    Age INT
);

-- Ensuite ajouter les contraintes
ALTER TABLE Exemple
ADD CONSTRAINT PK_Exemple PRIMARY KEY (Id);

ALTER TABLE Exemple
ADD CONSTRAINT UQ_Exemple_Email UNIQUE (Email);

ALTER TABLE Exemple
ADD CONSTRAINT CHK_Exemple_Age CHECK (Age >= 18);
```

## Conventions de Nommage

Il est important d'avoir des conventions de nommage cohérentes pour vos contraintes :

| Type | Préfixe | Format | Exemple |
|------|---------|--------|---------|
| PRIMARY KEY | PK_ | PK_NomTable | `PK_Clients` |
| FOREIGN KEY | FK_ | FK_TableEnfant_TableParent | `FK_Commandes_Clients` |
| UNIQUE | UQ_ ou UK_ | UQ_NomTable_NomColonne | `UQ_Clients_Email` |
| CHECK | CHK_ ou CK_ | CHK_NomTable_NomColonne | `CHK_Produits_Prix` |
| DEFAULT | DF_ ou DEF_ | DF_NomTable_NomColonne | `DF_Clients_Pays` |

**Exemple complet avec nommage cohérent :**

```sql
CREATE TABLE Produits
(
    IdProduit INT,
    CodeProduit VARCHAR(20),
    Nom VARCHAR(150) NOT NULL,
    Prix DECIMAL(10,2),
    Stock INT,
    IdCategorie INT,
    CONSTRAINT PK_Produits PRIMARY KEY (IdProduit),
    CONSTRAINT UQ_Produits_CodeProduit UNIQUE (CodeProduit),
    CONSTRAINT CHK_Produits_Prix CHECK (Prix > 0),
    CONSTRAINT CHK_Produits_Stock CHECK (Stock >= 0),
    CONSTRAINT DF_Produits_Stock DEFAULT 0 FOR Stock,
    CONSTRAINT FK_Produits_Categories FOREIGN KEY (IdCategorie)
        REFERENCES Categories(IdCategorie)
);
```

## Ordre de Création

Certaines contraintes dépendent d'autres. Voici l'ordre logique :

### 1. Tables sans Dépendances

```sql
-- D'abord les tables "parent" (référencées par d'autres)
CREATE TABLE Clients (...);
CREATE TABLE Produits (...);
CREATE TABLE Categories (...);
```

### 2. Tables avec Clés Étrangères

```sql
-- Ensuite les tables "enfant" (qui référencent d'autres tables)
CREATE TABLE Commandes
(
    IdCommande INT PRIMARY KEY,
    IdClient INT,
    CONSTRAINT FK_Commandes_Clients FOREIGN KEY (IdClient) REFERENCES Clients(IdClient)
);
```

### 3. Tables de Liaison

```sql
-- Enfin les tables de liaison (qui référencent plusieurs tables)
CREATE TABLE LignesCommande
(
    IdLigne INT PRIMARY KEY,
    IdCommande INT,
    IdProduit INT,
    CONSTRAINT FK_Lignes_Commandes FOREIGN KEY (IdCommande) REFERENCES Commandes(IdCommande),
    CONSTRAINT FK_Lignes_Produits FOREIGN KEY (IdProduit) REFERENCES Produits(IdProduit)
);
```

## Gestion des Contraintes

### Voir les Contraintes Existantes

```sql
-- Via INFORMATION_SCHEMA
SELECT
    tc.CONSTRAINT_NAME,
    tc.CONSTRAINT_TYPE,
    tc.TABLE_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
WHERE tc.TABLE_NAME = 'Clients'
ORDER BY tc.CONSTRAINT_TYPE;

-- Via sp_help
EXEC sp_help 'Clients';
```

### Supprimer une Contrainte

```sql
ALTER TABLE Produits
DROP CONSTRAINT CHK_Produits_Prix;

ALTER TABLE Commandes
DROP CONSTRAINT FK_Commandes_Clients;
```

### Désactiver Temporairement (Maintenance)

```sql
-- Désactiver une contrainte
ALTER TABLE Commandes
NOCHECK CONSTRAINT FK_Commandes_Clients;

-- Effectuer les opérations de maintenance...

-- Réactiver la contrainte
ALTER TABLE Commandes
CHECK CONSTRAINT FK_Commandes_Clients;
```

## Impact des Contraintes sur les Performances

### Avantages

- ✅ **Index automatiques** (PRIMARY KEY, UNIQUE) : accélèrent les recherches
- ✅ **Validation précoce** : évite le traitement de données invalides
- ✅ **Moins de vérifications applicatives** : la base fait le travail

### Coûts

- ⚠️ **Vérifications à l'insertion/modification** : léger surcoût
- ⚠️ **Complexité accrue** : plus de contraintes = plus de vérifications
- ⚠️ **Blocages potentiels** : les FK peuvent créer des locks

### Bonnes Pratiques

1. **Utilisez des contraintes**, le bénéfice dépasse largement le coût
2. **Nommez vos contraintes** pour faciliter la maintenance
3. **Testez les contraintes** après leur création
4. **Documentez les règles métier** complexes
5. **Indexez les clés étrangères** pour améliorer les performances

## Résumé Visuel

```
┌─────────────────────────────────────────────────┐
│           CONTRAINTES D'INTÉGRITÉ               │
└─────────────────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   🔑 PRIMARY      🔗 FOREIGN      ✨ UNIQUE
     KEY             KEY
        │              │              │
   Identifiant    Relations      Unicité
    unique       entre tables    colonnes
        │              │              │
   ─────┴──────────────┴──────────────┴────
        │              │              │
   ✓ CHECK        📝 DEFAULT      ❗ NOT NULL
        │              │              │
   Validation     Valeurs         Colonnes
  personnalisée  automatiques   obligatoires
```

## Points Clés à Retenir

1. ✅ Les contraintes **garantissent la qualité** et la cohérence des données
2. 🔑 **PRIMARY KEY** : identifie uniquement chaque ligne (obligatoire)
3. 🔗 **FOREIGN KEY** : crée et maintient les relations entre tables
4. ✨ **UNIQUE** : empêche les doublons sur des colonnes importantes
5. ✓ **CHECK** : valide selon des règles métier personnalisées
6. 📝 **DEFAULT** : simplifie les insertions avec des valeurs automatiques
7. ❗ **NOT NULL** : rend les colonnes obligatoires
8. 📝 **Nommez vos contraintes** pour faciliter la maintenance
9. 🎯 Les contraintes se combinent pour une protection complète
10. ⚡ Certaines contraintes créent des index automatiques (performance)

## Ce que Nous Allons Apprendre

Dans les sections suivantes, nous allons explorer en détail chaque type de contrainte :

### 2.3.1 PRIMARY KEY (Clé primaire)
Comment créer et gérer les identifiants uniques, l'auto-incrémentation avec IDENTITY, les clés simples vs composites.

### 2.3.2 FOREIGN KEY (Clé étrangère)
Comment créer des relations entre tables, l'intégrité référentielle, les actions CASCADE, ON DELETE, ON UPDATE.

### 2.3.3 UNIQUE (Contrainte d'unicité)
Comment garantir l'unicité sur des colonnes non-PK, la gestion des NULL, les contraintes composites.

### 2.3.4 CHECK (Validation de données)
Comment valider des plages, des listes, des patterns, des relations entre colonnes avec des règles personnalisées.

### 2.3.5 DEFAULT (Valeur par défaut)
Comment définir des valeurs automatiques, utiliser des fonctions système (GETDATE, NEWID), combiner avec NOT NULL.

### 2.3.6 NOT NULL vs NULL
Comprendre la différence, le comportement de NULL dans les opérations, les fonctions de gestion (ISNULL, COALESCE).

## Exemple Complet : Mise en Pratique

Voici un exemple complet montrant toutes les contraintes en action :

```sql
-- =========================================
-- SYSTÈME DE GESTION D'UNE BIBLIOTHÈQUE
-- =========================================

-- Table Auteurs
CREATE TABLE Auteurs
(
    IdAuteur INT IDENTITY(1,1),                          -- Auto-incrémentation
    Nom VARCHAR(100) NOT NULL,                           -- Obligatoire
    Prenom VARCHAR(100) NOT NULL,                        -- Obligatoire
    Nationalite VARCHAR(50) DEFAULT 'Inconnue',          -- Valeur par défaut
    DateNaissance DATE CHECK (DateNaissance < GETDATE()), -- Validation
    CONSTRAINT PK_Auteurs PRIMARY KEY (IdAuteur)         -- Clé primaire
);

-- Table Livres
CREATE TABLE Livres
(
    IdLivre INT IDENTITY(1,1),
    ISBN VARCHAR(13) NOT NULL UNIQUE,                    -- Obligatoire et unique
    Titre VARCHAR(200) NOT NULL,
    IdAuteur INT NOT NULL,
    AnneePublication INT CHECK (AnneePublication BETWEEN 1450 AND 2100),
    NombrePages INT CHECK (NombrePages > 0),
    Prix DECIMAL(8,2) CHECK (Prix >= 0),
    Stock INT NOT NULL DEFAULT 0 CHECK (Stock >= 0),
    EstDisponible BIT NOT NULL DEFAULT 1,
    DateAjout DATE NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_Livres PRIMARY KEY (IdLivre),
    CONSTRAINT FK_Livres_Auteurs
        FOREIGN KEY (IdAuteur) REFERENCES Auteurs(IdAuteur)
);

-- Table Membres
CREATE TABLE Membres
(
    IdMembre INT IDENTITY(1,1),
    NumeroMembre VARCHAR(20) NOT NULL UNIQUE,
    Email VARCHAR(150) NOT NULL UNIQUE,
    Nom VARCHAR(100) NOT NULL,
    Prenom VARCHAR(50) NOT NULL,
    DateInscription DATE NOT NULL DEFAULT GETDATE(),
    EstActif BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Membres PRIMARY KEY (IdMembre)
);

-- Table Emprunts
CREATE TABLE Emprunts
(
    IdEmprunt INT IDENTITY(1,1),
    IdMembre INT NOT NULL,
    IdLivre INT NOT NULL,
    DateEmprunt DATE NOT NULL DEFAULT GETDATE(),
    DateRetourPrevue DATE NOT NULL,
    DateRetourEffective DATE,
    Statut VARCHAR(20) NOT NULL DEFAULT 'En cours'
        CHECK (Statut IN ('En cours', 'Rendu', 'En retard')),
    CONSTRAINT PK_Emprunts PRIMARY KEY (IdEmprunt),
    CONSTRAINT FK_Emprunts_Membres
        FOREIGN KEY (IdMembre) REFERENCES Membres(IdMembre),
    CONSTRAINT FK_Emprunts_Livres
        FOREIGN KEY (IdLivre) REFERENCES Livres(IdLivre),
    CONSTRAINT CHK_Emprunts_Dates
        CHECK (DateRetourPrevue > DateEmprunt)
);
```

**Ce système garantit :**
- ✅ Chaque auteur, livre, membre et emprunt a un ID unique
- ✅ Les ISBN et emails sont uniques
- ✅ Les relations sont cohérentes (pas d'emprunts orphelins)
- ✅ Les années, pages, prix et stocks sont valides
- ✅ Les statuts sont dans une liste prédéfinie
- ✅ Les dates sont cohérentes (retour après emprunt)
- ✅ Les valeurs par défaut simplifient les insertions

## Prochaines Étapes

Maintenant que vous comprenez l'importance et les types de contraintes, nous allons explorer chacune en détail. Commençons par la plus fondamentale : la **PRIMARY KEY** (clé primaire), qui est le pilier de l'intégrité des données.

Préparez-vous à maîtriser les contraintes d'intégrité - elles sont essentielles pour créer des bases de données robustes et fiables ! 🎯

⏭️ [PRIMARY KEY (Clé primaire)](/02-definition-et-manipulation-des-donnees/03.1-primary-key.md)
