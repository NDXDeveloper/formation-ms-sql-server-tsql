🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 2.4 DML : Insertion de données

## Introduction

Félicitations ! Vous avez appris à créer la structure de vos bases de données et de vos tables avec le DDL (Data Definition Language). Vous savez maintenant définir des tables, des colonnes, et des contraintes d'intégrité. Mais une base de données vide n'a aucune utilité ! Il est temps de la **remplir avec des données réelles**.

C'est ici qu'intervient le **DML** (Data Manipulation Language), le sous-langage SQL qui vous permet de manipuler les données elles-mêmes.

---

## Qu'est-ce que le DML ?

### Définition

Le **DML** (Data Manipulation Language) est l'ensemble des commandes SQL qui permettent de :

- **Insérer** de nouvelles données (INSERT)
- **Modifier** des données existantes (UPDATE)
- **Supprimer** des données (DELETE)
- **Interroger** et récupérer des données (SELECT)

> **Note** : Certains experts classent SELECT dans une catégorie à part appelée DQL (Data Query Language), mais traditionnellement, SELECT fait partie du DML.

### Différence entre DDL et DML

Pour bien comprendre, voici une analogie simple :

| DDL (Data Definition Language) | DML (Data Manipulation Language) |
|--------------------------------|----------------------------------|
| **Construction** de la maison | **Utilisation** de la maison |
| Créer les murs, les pièces | Placer les meubles, y vivre |
| CREATE TABLE, ALTER TABLE | INSERT, UPDATE, DELETE, SELECT |
| Définit la **structure** | Manipule les **données** |

**Exemple concret** :

```sql
-- DDL : Créer la structure de la table
CREATE TABLE Clients (
    ClientID INT PRIMARY KEY,
    Nom VARCHAR(100),
    Email VARCHAR(100)
);

-- DML : Ajouter des données dans la table
INSERT INTO Clients (ClientID, Nom, Email)
VALUES (1, 'Jean Dupont', 'jean.dupont@example.com');
```

---

## Pourquoi l'insertion de données est-elle importante ?

### Le cœur d'une application

Une base de données n'a de valeur que par les **données qu'elle contient**. Sans données :

- ❌ Impossible de générer des rapports
- ❌ Impossible d'afficher des informations aux utilisateurs
- ❌ Impossible de prendre des décisions basées sur des analyses
- ❌ Votre application ne peut pas fonctionner

L'insertion de données est donc la **première étape** pour rendre votre base de données utile.

### Cycle de vie des données

Dans un système réel, les données suivent un cycle :

1. **Création (INSERT)** : Les données sont ajoutées pour la première fois
2. **Lecture (SELECT)** : Les données sont consultées et affichées
3. **Modification (UPDATE)** : Les données sont mises à jour au fil du temps
4. **Suppression (DELETE)** : Les données obsolètes sont supprimées

Nous nous concentrons ici sur la **première étape : l'insertion**.

---

## Les trois façons d'insérer des données

SQL Server et T-SQL offrent **trois méthodes principales** pour insérer des données dans une table. Chaque méthode a ses propres cas d'usage et avantages.

### 1. INSERT INTO ... VALUES

**Description** : Insérer des valeurs **spécifiques** que vous tapez manuellement.

**Quand l'utiliser ?**
- Ajouter quelques lignes de données
- Créer des données de test
- Insérer des enregistrements uniques

**Exemple simple** :
```sql
INSERT INTO Clients (ClientID, Nom, Email)
VALUES (1, 'Marie Dubois', 'marie.dubois@example.com');
```

**Avantages** :
- ✅ Simple et direct
- ✅ Parfait pour de petites quantités de données
- ✅ Facile à comprendre pour les débutants

**Inconvénients** :
- ❌ Fastidieux pour de grandes quantités de données
- ❌ Nécessite de connaître les valeurs à l'avance

---

### 2. Insertion de lignes multiples

**Description** : Insérer **plusieurs lignes** en une seule instruction.

**Quand l'utiliser ?**
- Ajouter plusieurs enregistrements d'un coup
- Initialiser des données de référence (pays, catégories, etc.)
- Importer des données depuis un fichier ou un script

**Exemple simple** :
```sql
INSERT INTO Clients (ClientID, Nom, Email)
VALUES
    (1, 'Marie Dubois', 'marie.dubois@example.com'),
    (2, 'Pierre Martin', 'pierre.martin@example.com'),
    (3, 'Sophie Leroy', 'sophie.leroy@example.com');
```

**Avantages** :
- ✅ Beaucoup plus rapide que plusieurs INSERT individuels
- ✅ Réduit le nombre de transactions
- ✅ Code plus concis et lisible

**Inconvénients** :
- ❌ Toujours fastidieux pour des centaines de lignes
- ❌ Tout est annulé si une seule ligne est invalide

---

### 3. INSERT INTO ... SELECT

**Description** : Insérer des données **provenant d'une requête** sur une ou plusieurs tables existantes.

**Quand l'utiliser ?**
- Copier des données d'une table vers une autre
- Archiver des données historiques
- Créer des tables de rapports ou d'agrégation
- Transformer et consolider des données

**Exemple simple** :
```sql
INSERT INTO ClientsArchive (ClientID, Nom, Email)
SELECT ClientID, Nom, Email
FROM Clients
WHERE DateInscription < '2020-01-01';
```

**Avantages** :
- ✅ Extrêmement puissant et flexible
- ✅ Peut traiter des milliers ou millions de lignes
- ✅ Permet des transformations complexes
- ✅ Combine des données de plusieurs tables

**Inconvénients** :
- ❌ Plus complexe à maîtriser
- ❌ Nécessite de bien comprendre les requêtes SELECT

---

## Comparaison des trois méthodes

| Méthode | Nombre de lignes | Complexité | Performance | Cas d'usage typique |
|---------|------------------|------------|-------------|---------------------|
| **INSERT ... VALUES** | 1 ligne | ⭐ Facile | Moyenne | Ajout ponctuel |
| **Insertion multiple** | 2-100 lignes | ⭐⭐ Moyenne | Bonne | Initialisation, import manuel |
| **INSERT ... SELECT** | 1-∞ lignes | ⭐⭐⭐ Avancée | Excellente | Copie, archivage, rapports |

---

## Concepts fondamentaux avant de commencer

### 1. Respect de la structure de la table

Lorsque vous insérez des données, vous devez **respecter la structure** définie lors de la création de la table :

- **Types de données** : Une colonne INT ne peut recevoir que des nombres entiers
- **Contraintes** : Les règles (PRIMARY KEY, FOREIGN KEY, CHECK, etc.) doivent être respectées
- **NOT NULL** : Les colonnes obligatoires doivent recevoir une valeur

**Exemple** :
```sql
CREATE TABLE Produits (
    ProduitID INT PRIMARY KEY,        -- Doit être unique et non NULL
    Nom VARCHAR(100) NOT NULL,        -- Obligatoire
    Prix DECIMAL(10, 2) CHECK (Prix > 0),  -- Doit être positif
    Stock INT DEFAULT 0               -- Facultatif (valeur par défaut = 0)
);
```

Si vous tentez d'insérer un produit avec un prix négatif, SQL Server **rejettera** l'insertion.

### 2. Ordre des colonnes

Lorsque vous spécifiez les colonnes dans votre instruction INSERT, l'**ordre est important** :

```sql
-- Les valeurs doivent correspondre à l'ordre des colonnes
INSERT INTO Produits (ProduitID, Nom, Prix)
VALUES (1, 'Ordinateur', 899.99);
--      ↓   ↓            ↓
--      1   'Ordinateur' 899.99
```

Si vous inversez l'ordre, vous risquez d'obtenir des erreurs ou des résultats incorrects.

### 3. Gestion des valeurs NULL

Une valeur **NULL** signifie "absence de valeur" ou "valeur inconnue". Elle est différente de :
- Une chaîne vide `''`
- Le nombre zéro `0`
- Une date par défaut

**Exemple** :
```sql
INSERT INTO Employes (EmployeID, Nom, Email)
VALUES (1, 'Jean Dupont', NULL);  -- Email inconnu ou non fourni
```

### 4. Valeurs par défaut (DEFAULT)

Si une colonne a une valeur par défaut définie, vous pouvez :
- Ne pas spécifier la colonne dans l'INSERT (elle prendra sa valeur par défaut)
- Utiliser le mot-clé `DEFAULT` explicitement

**Exemple** :
```sql
CREATE TABLE Commandes (
    CommandeID INT PRIMARY KEY,
    DateCommande DATE DEFAULT GETDATE(),  -- Date du jour par défaut
    Statut VARCHAR(20) DEFAULT 'En attente'
);

-- La date et le statut prendront leurs valeurs par défaut
INSERT INTO Commandes (CommandeID)
VALUES (1001);
```

### 5. Colonnes auto-incrémentées (IDENTITY)

SQL Server peut générer automatiquement des valeurs pour certaines colonnes, typiquement les clés primaires :

```sql
CREATE TABLE Clients (
    ClientID INT PRIMARY KEY IDENTITY(1,1),  -- Auto-incrémenté
    Nom VARCHAR(100)
);

-- Pas besoin de fournir ClientID
INSERT INTO Clients (Nom)
VALUES ('Marie Dubois');  -- ClientID sera automatiquement 1

INSERT INTO Clients (Nom)
VALUES ('Pierre Martin'); -- ClientID sera automatiquement 2
```

> **Important** : Vous ne devez **jamais** insérer manuellement une valeur dans une colonne IDENTITY (sauf cas particuliers avec `SET IDENTITY_INSERT ON`).

---

## Vérification de l'intégrité des données

Avant d'insérer des données, posez-vous ces questions :

### ✅ Checklist pré-insertion

1. **Les types de données sont-ils corrects ?**
   - Nombres pour les colonnes numériques
   - Chaînes pour les colonnes textuelles
   - Dates au bon format pour les colonnes temporelles

2. **Les contraintes sont-elles respectées ?**
   - PRIMARY KEY : Valeur unique ?
   - FOREIGN KEY : La valeur référencée existe-t-elle dans la table parent ?
   - CHECK : Les conditions sont-elles satisfaites ?
   - UNIQUE : La valeur est-elle unique ?

3. **Les colonnes obligatoires ont-elles des valeurs ?**
   - Toutes les colonnes NOT NULL doivent recevoir une valeur

4. **Les valeurs sont-elles dans la bonne plage ?**
   - Un âge ne peut pas être négatif
   - Une date de naissance ne peut pas être dans le futur
   - Un prix ne peut pas être négatif (généralement)

---

## Erreurs courantes lors de l'insertion

### 1. Violation de contrainte PRIMARY KEY

**Erreur** : Tentative d'insérer une valeur de clé primaire qui existe déjà.

```sql
-- ❌ Si ClientID = 1 existe déjà
INSERT INTO Clients (ClientID, Nom)
VALUES (1, 'Nouveau Client');
```

**Message d'erreur** : "Violation de contrainte PRIMARY KEY. Impossible d'insérer une clé dupliquée."

### 2. Violation de contrainte FOREIGN KEY

**Erreur** : Tentative de référencer une valeur qui n'existe pas dans la table parent.

```sql
-- ❌ Si aucun client avec ClientID = 999 n'existe
INSERT INTO Commandes (CommandeID, ClientID, Montant)
VALUES (1, 999, 150.00);
```

**Message d'erreur** : "Instruction INSERT en conflit avec la contrainte FOREIGN KEY."

### 3. Type de données incompatible

**Erreur** : Tentative d'insérer une valeur d'un type incompatible.

```sql
-- ❌ 'ABC' ne peut pas être converti en INT
INSERT INTO Produits (ProduitID, Nom, Prix)
VALUES ('ABC', 'Produit', 100.00);
```

**Message d'erreur** : "Erreur de conversion du type de données varchar en int."

### 4. Valeur NULL dans une colonne NOT NULL

**Erreur** : Omission d'une colonne obligatoire.

```sql
-- ❌ Nom est NOT NULL mais n'est pas fourni
INSERT INTO Clients (ClientID, Email)
VALUES (1, 'client@example.com');
```

**Message d'erreur** : "Impossible d'insérer la valeur NULL dans la colonne 'Nom'."

---

## Bonnes pratiques générales

### ✅ À faire

1. **Toujours spécifier les colonnes** explicitement dans votre instruction INSERT
2. **Respecter les types de données** définis dans la table
3. **Vérifier les contraintes** avant l'insertion
4. **Utiliser des transactions** pour les insertions importantes (pour pouvoir annuler si nécessaire)
5. **Tester avec un petit échantillon** avant d'insérer de grandes quantités de données
6. **Documenter votre code** : expliquez pourquoi vous insérez ces données

### ❌ À éviter

1. Ne pas spécifier les colonnes (INSERT INTO table VALUES ...)
2. Insérer des données sans valider leur format
3. Ignorer les messages d'erreur de contraintes
4. Insérer massivement sans sauvegarde préalable
5. Utiliser SELECT * pour les insertions

---

## L'importance des transactions

Lors de l'insertion de données, il est souvent judicieux d'utiliser des **transactions** pour garantir l'intégrité :

```sql
BEGIN TRANSACTION;

    INSERT INTO Clients (ClientID, Nom, Email)
    VALUES (1, 'Jean Dupont', 'jean@example.com');

    INSERT INTO Commandes (CommandeID, ClientID, Montant)
    VALUES (1001, 1, 250.00);

    -- Si tout va bien
    COMMIT TRANSACTION;

-- Si une erreur survient, on peut annuler avec ROLLBACK TRANSACTION
```

> **Note** : Nous étudierons les transactions en détail dans le chapitre 6.

---

## Outils pour l'insertion de données

### 1. SQL Server Management Studio (SSMS)

L'outil graphique principal pour exécuter vos instructions INSERT.

**Avantages** :
- Interface graphique intuitive
- Coloration syntaxique
- Aide à l'auto-complétion
- Affichage des erreurs clairs

### 2. Scripts SQL

Vous pouvez écrire vos instructions INSERT dans des fichiers `.sql` pour :
- Les réutiliser facilement
- Les versionner (Git, SVN, etc.)
- Les partager avec d'autres développeurs
- Automatiser l'initialisation de bases de données

### 3. Applications et interfaces

Dans le monde réel, les données sont souvent insérées via :
- **Applications web** : Formulaires d'inscription, de commande, etc.
- **Applications mobiles** : Création de profils, ajout de contenus
- **APIs** : Services REST qui reçoivent des données JSON/XML
- **Scripts d'import** : Pour migrer des données depuis d'autres systèmes

---

## Structure de cette section

Cette section 2.4 est divisée en trois parties :

### 2.4.1 - Syntaxe INSERT INTO ... VALUES
Vous apprendrez à insérer **une seule ligne** avec des valeurs spécifiques. C'est la base de l'insertion de données.

### 2.4.2 - Insertion de lignes multiples
Vous découvrirez comment insérer **plusieurs lignes en une seule instruction** pour améliorer la performance et la lisibilité.

### 2.4.3 - INSERT INTO ... SELECT
Vous maîtriserez l'insertion de données **provenant d'une requête**, permettant de copier, transformer et consolider des données entre tables.

---

## Ce que vous allez apprendre

À la fin de cette section, vous serez capable de :

- ✅ Insérer une ou plusieurs lignes de données avec des valeurs spécifiques
- ✅ Comprendre et respecter les types de données et les contraintes
- ✅ Gérer les valeurs NULL et les valeurs par défaut
- ✅ Insérer des données de manière efficace avec l'insertion multiple
- ✅ Copier et transformer des données entre tables avec INSERT ... SELECT
- ✅ Identifier et corriger les erreurs courantes d'insertion
- ✅ Appliquer les bonnes pratiques pour des insertions fiables

---

## Résumé

L'insertion de données est la **première étape** pour donner vie à votre base de données. Le DML, et plus particulièrement l'instruction INSERT, vous permet de :

- Ajouter de nouvelles données dans vos tables
- Respecter la structure et les contraintes définies
- Utiliser différentes méthodes selon vos besoins (VALUES, multiple, SELECT)

Avec une bonne maîtrise de l'insertion, vous pourrez construire des bases de données riches et exploitables pour vos applications.

---

**Prêt à commencer ?** Direction la section **2.4.1** pour découvrir en détail la syntaxe de base `INSERT INTO ... VALUES` !

⏭️ [Syntaxe INSERT INTO ... VALUES](/02-definition-et-manipulation-des-donnees/04.1-syntaxe-insert-into-values.md)
