🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 8.3 Tables temporelles (Temporal Tables)

## Introduction

Imaginez que vous gérez une base de données pour une boutique en ligne. Un client vous appelle un lundi matin, mécontent : "J'ai commandé un ordinateur vendredi dernier au prix de 750€, mais sur la facture que je viens de recevoir, le prix affiché est 850€ !" Vous consultez votre base de données, et effectivement, le produit coûte actuellement 850€. Mais comment prouver quel était le prix vendredi ? Cette information a disparu lorsque vous avez mis à jour le prix samedi...

Ce scénario illustre un **problème fondamental des bases de données classiques** : lorsque vous modifiez ou supprimez une donnée, **l'ancienne valeur est perdue à jamais**. Les bases de données relationnelles standard ne conservent que l'**état actuel** de vos données, pas leur **histoire**.

## Le besoin d'historisation des données

Dans de nombreux contextes professionnels, conserver l'historique des modifications n'est pas un luxe, c'est une **nécessité** :

### Exigences légales et réglementaires

- **Audit comptable** : Les entreprises doivent souvent conserver 7 à 10 ans d'historique de leurs données financières
- **RGPD** : Pouvoir prouver qu'une donnée personnelle a été supprimée à une date précise
- **Secteur bancaire** : Traçabilité complète de toutes les transactions et modifications de comptes
- **Santé** : Historique complet des dossiers médicaux (qui a consulté quoi et quand ?)
- **SOX Compliance** : Loi américaine exigeant la traçabilité des données financières

### Besoins métier

- **Analyse temporelle** : Comparer les ventes d'un produit avant et après un changement de prix
- **Facturation précise** : Facturer au prix qui était en vigueur à la date de commande
- **Résolution de litiges** : Prouver l'état exact d'un contrat ou d'une transaction à un moment donné
- **Détection de fraudes** : Identifier des modifications suspectes ou non autorisées
- **Récupération d'erreurs** : Restaurer des données supprimées ou modifiées par erreur sans avoir à restaurer toute la base

### Questions métier courantes nécessitant l'historique

Voici des questions que vos utilisateurs métier pourraient vous poser, et auxquelles une base de données classique ne peut pas répondre :

- "Quel était le salaire de cet employé en juin 2023 ?"
- "Combien de produits étaient en stock il y a 3 mois ?"
- "Qui a modifié cette information et quand ?"
- "Quel était l'état de ce dossier client avant la fusion avec l'autre compte ?"
- "Combien de fois ce paramètre de configuration a-t-il changé cette année ?"

Sans historisation, toutes ces questions restent sans réponse.

## Les solutions traditionnelles (et leurs limites)

Avant les tables temporelles, les développeurs utilisaient différentes approches pour conserver l'historique, chacune avec ses inconvénients :

### 1. Tables d'audit manuelles

**Principe** : Créer une table séparée `TableNom_Audit` et écrire des triggers pour copier les anciennes valeurs.

```sql
-- Table principale
CREATE TABLE Produits (
    ProduitID INT PRIMARY KEY,
    Nom NVARCHAR(100),
    Prix DECIMAL(10,2)
);

-- Table d'audit manuelle
CREATE TABLE Produits_Audit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    ProduitID INT,
    Nom NVARCHAR(100),
    Prix DECIMAL(10,2),
    DateModification DATETIME,
    TypeOperation VARCHAR(10)  -- INSERT, UPDATE, DELETE
);

-- Trigger pour capturer les modifications
CREATE TRIGGER TR_Produits_Audit
ON Produits
AFTER UPDATE, DELETE
AS BEGIN
    INSERT INTO Produits_Audit (ProduitID, Nom, Prix, DateModification, TypeOperation)
    SELECT ProduitID, Nom, Prix, GETDATE(), 'UPDATE'
    FROM deleted;
END;
```

**Inconvénients** :
- ❌ Beaucoup de code à écrire et maintenir
- ❌ Risque d'oublier de créer/mettre à jour les triggers
- ❌ Complexité accrue lors de modifications de structure
- ❌ Requêtes d'historique complexes à écrire
- ❌ Bugs potentiels dans le code des triggers
- ❌ Impact sur les performances

### 2. Colonnes de versionnement

**Principe** : Ajouter des colonnes `DateDebut`, `DateFin`, `EstActif` dans la table elle-même.

```sql
CREATE TABLE Produits (
    ProduitID INT,
    VersionID INT,
    Nom NVARCHAR(100),
    Prix DECIMAL(10,2),
    DateDebut DATETIME,
    DateFin DATETIME,
    EstActif BIT,
    PRIMARY KEY (ProduitID, VersionID)
);
```

**Inconvénients** :
- ❌ La table principale devient encombrée avec des données historiques
- ❌ Les requêtes simples deviennent complexes (toujours ajouter `WHERE EstActif = 1`)
- ❌ Gestion manuelle de DateDebut, DateFin, EstActif lors des INSERT/UPDATE
- ❌ Risque d'incohérence des données
- ❌ Performances dégradées (index, scans de table)

### 3. Change Data Capture (CDC)

**Principe** : Fonctionnalité SQL Server qui capture les modifications dans des tables système.

**Inconvénients** :
- ❌ Conçu pour la réplication/ETL, pas pour l'historisation métier
- ❌ Tables système difficiles à interroger
- ❌ Pas de syntaxe SQL simple pour "état à une date donnée"
- ❌ Configuration complexe
- ❌ Impact sur les logs de transaction

### 4. Snapshots/Sauvegardes

**Principe** : Faire des copies complètes de la base à intervalles réguliers.

**Inconvénients** :
- ❌ Énorme consommation d'espace disque
- ❌ Granularité limitée (par exemple, un snapshot par jour seulement)
- ❌ Restauration fastidieuse pour consulter l'historique
- ❌ Pas de traçabilité au niveau de la ligne individuelle

## La solution moderne : Tables temporelles SQL Server

Face à ces limitations, Microsoft a introduit dans **SQL Server 2016** une fonctionnalité native appelée **Tables temporelles** (ou System-Versioned Temporal Tables).

### Qu'est-ce qu'une table temporelle ?

Une table temporelle est une table ordinaire **améliorée** par SQL Server pour :

1. **Conserver automatiquement** toutes les anciennes versions de chaque ligne
2. **Enregistrer les périodes de validité** de chaque version (quand elle était active)
3. **Permettre d'interroger facilement** les données à n'importe quel moment du passé
4. **Gérer tout cela de manière transparente** sans code supplémentaire de votre part

### L'avantage majeur : Transparence totale

Le grand avantage des tables temporelles, c'est que vous continuez à travailler normalement :

```sql
-- Vos requêtes habituelles fonctionnent exactement comme avant
INSERT INTO Produits (ProduitID, Nom, Prix) VALUES (1, 'Ordinateur', 800);
UPDATE Produits SET Prix = 750 WHERE ProduitID = 1;
DELETE FROM Produits WHERE ProduitID = 1;

-- SQL Server gère automatiquement l'historique en arrière-plan !
```

Vous n'avez **aucun trigger à écrire**, **aucune logique complexe à gérer**. SQL Server fait tout pour vous.

### Comment ça fonctionne (vue d'ensemble)

Quand vous activez l'historisation sur une table :

1. **SQL Server ajoute deux colonnes** à votre table pour suivre la période de validité de chaque ligne
2. **SQL Server crée automatiquement une table d'historique** liée à votre table principale
3. **À chaque modification** (UPDATE ou DELETE), l'ancienne version est automatiquement déplacée dans la table d'historique
4. **Vous interrogez les données** avec une syntaxe SQL simple et élégante

**Schéma conceptuel** :

```
Vous travaillez normalement          SQL Server gère l'historique
     avec cette table                    automatiquement
           ↓                                    ↓
┌─────────────────────┐              ┌─────────────────────┐
│   Produits          │              │ Produits_History    │
│   (Table actuelle)  │              │ (Table d'historique)│
├─────────────────────┤              ├─────────────────────┤
│ Données actuelles   │ ──Modif────→ │ Anciennes versions  │
│ (Visible par défaut)│              │ (Automatique)       │
└─────────────────────┘              └─────────────────────┘
```

## Avantages des tables temporelles

### 1. Simplicité d'utilisation ✨

- Aucun code complexe à écrire
- Aucun trigger à maintenir
- Les requêtes normales fonctionnent exactement comme avant
- Syntaxe SQL intuitive pour interroger l'historique

### 2. Fiabilité 🛡️

- Gestion par SQL Server (pas de bugs dans votre code)
- Garantie de cohérence des données
- Impossible d'oublier d'enregistrer une modification

### 3. Performance ⚡

- Optimisé par Microsoft
- La table principale reste légère (historique séparé)
- Impact minimal sur les opérations INSERT/UPDATE/DELETE

### 4. Conformité réglementaire 📋

- Audit complet et automatique
- Traçabilité totale des modifications
- Preuve de l'état des données à tout moment

### 5. Analyse métier 📊

- Comparer les données entre différentes périodes
- Identifier des tendances temporelles
- Prendre des décisions basées sur l'évolution historique

## Ce que nous allons apprendre

Cette section sur les tables temporelles est divisée en trois parties :

### 8.3.1 Concept d'historisation automatique des données

Nous explorerons en profondeur :
- Comment SQL Server gère l'historique en coulisses
- Le rôle des colonnes de validité (ValidFrom, ValidTo)
- Le cycle de vie d'une ligne à travers ses versions
- Les différences avec d'autres méthodes d'historisation

### 8.3.2 Syntaxe SYSTEM_VERSIONING

Nous apprendrons la syntaxe concrète pour :
- Créer une nouvelle table temporelle
- Ajouter l'historisation à une table existante
- Configurer les options (rétention, compression, etc.)
- Désactiver/réactiver l'historisation
- Gérer la table d'historique

### 8.3.3 Interrogation à un instant T (AS OF)

Nous maîtriserons les requêtes temporelles pour :
- Voir les données telles qu'elles étaient à une date précise (AS OF)
- Interroger les versions actives pendant une période (FROM...TO, BETWEEN...AND)
- Obtenir l'historique complet d'une ligne (ALL)
- Comparer les données entre différentes périodes
- Optimiser les performances des requêtes temporelles

## Quand utiliser les tables temporelles ?

### Scénarios idéaux ✅

Les tables temporelles sont particulièrement adaptées pour :

- **Données maîtres** : Clients, Produits, Employés, Fournisseurs
- **Données de configuration** : Paramètres d'application, tarifs, règles métier
- **Données contractuelles** : Contrats, polices d'assurance, conditions commerciales
- **Données financières** : Comptes, transactions, soldes
- **Données réglementées** : Tout ce qui nécessite un audit ou une conformité

### Scénarios à éviter ⚠️

Les tables temporelles ne sont **pas recommandées** pour :

- **Tables de logs déjà temporelles** : Les logs sont déjà historiques par nature
- **Tables très volumineuses avec modifications fréquentes** : L'historique deviendra énorme
- **Tables temporaires ou de staging** : Pas besoin d'historique sur des données temporaires
- **Données en temps réel** : Capteurs IoT, télémétrie (trop de modifications par seconde)

### Considérations

Avant d'activer l'historisation, réfléchissez à :

1. **Espace disque** : L'historique occupe de l'espace. Définissez une politique de rétention.
2. **Performance des écritures** : Les UPDATE/DELETE sont légèrement plus lents (écriture dans deux tables).
3. **Conformité RGPD** : Pour supprimer définitivement des données personnelles, vous devrez désactiver temporairement l'historisation.
4. **Besoin réel** : Ai-je vraiment besoin de l'historique complet, ou juste d'un audit ?

## Compatibilité et versions

Les tables temporelles sont disponibles dans :

- ✅ SQL Server 2016 et versions ultérieures
- ✅ Azure SQL Database
- ✅ Azure SQL Managed Instance

**Niveau de compatibilité requis** : Base de données en mode de compatibilité 130 ou supérieur (SQL Server 2016+).

Vérifier la compatibilité :

```sql
-- Vérifier le niveau de compatibilité de votre base
SELECT name, compatibility_level
FROM sys.databases
WHERE name = 'VotreBaseDeDonnees';

-- 130 = SQL Server 2016
-- 140 = SQL Server 2017
-- 150 = SQL Server 2019
-- 160 = SQL Server 2022
```

## Terminologie importante

Avant de plonger dans les détails, familiarisons-nous avec les termes clés :

| Terme | Signification |
|-------|---------------|
| **Table temporelle** | Table principale avec historisation activée |
| **Table d'historique** | Table automatique contenant les anciennes versions |
| **System-Versioning** | Le mécanisme d'historisation automatique de SQL Server |
| **ValidFrom** | Colonne indiquant quand une version devient valide |
| **ValidTo** | Colonne indiquant quand une version cesse d'être valide |
| **PERIOD FOR SYSTEM_TIME** | Contrainte définissant les colonnes de validité |
| **FOR SYSTEM_TIME** | Clause SQL pour interroger l'historique |
| **AS OF** | Voir les données à une date précise |
| **GENERATED ALWAYS** | Colonnes gérées automatiquement par SQL Server |

## Exemple introductif rapide

Avant d'entrer dans les détails, voici un aperçu de ce que vous pourrez faire :

### Créer une table temporelle

```sql
CREATE TABLE Produits
(
    ProduitID INT PRIMARY KEY,
    Nom NVARCHAR(100) NOT NULL,
    Prix DECIMAL(10, 2) NOT NULL,

    -- Colonnes temporelles (gérées automatiquement)
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Produits_History));
```

### Utiliser la table normalement

```sql
-- Insertion (comme d'habitude)
INSERT INTO Produits (ProduitID, Nom, Prix)
VALUES (1, 'Ordinateur', 800);

-- Modification (comme d'habitude)
UPDATE Produits SET Prix = 750 WHERE ProduitID = 1;
UPDATE Produits SET Prix = 700 WHERE ProduitID = 1;

-- SQL Server a automatiquement conservé les anciennes valeurs (800€, 750€) !
```

### Interroger l'historique

```sql
-- Prix actuel (requête normale)
SELECT Nom, Prix FROM Produits WHERE ProduitID = 1;
-- Résultat : Ordinateur, 700€

-- Prix tel qu'il était le 15 juin 2024 (requête temporelle)
SELECT Nom, Prix
FROM Produits FOR SYSTEM_TIME AS OF '2024-06-15'
WHERE ProduitID = 1;
-- Résultat : Ordinateur, 800€ (si c'était le prix à cette date)

-- Historique complet
SELECT Nom, Prix, ValidFrom, ValidTo
FROM Produits FOR SYSTEM_TIME ALL
WHERE ProduitID = 1
ORDER BY ValidFrom;
-- Résultat : Toutes les versions avec leurs périodes de validité
```

Impressionnant, n'est-ce pas ? Et tout cela **sans aucun trigger ni code complexe** !

## Comparaison : Avant / Après les tables temporelles

### Avant (solution manuelle avec triggers)

```sql
-- Vous deviez écrire tout ce code :

-- 1. Créer la table d'historique
CREATE TABLE Produits_Historique (...);

-- 2. Créer un trigger INSERT
CREATE TRIGGER TR_Produits_Insert ON Produits AFTER INSERT AS ...

-- 3. Créer un trigger UPDATE
CREATE TRIGGER TR_Produits_Update ON Produits AFTER UPDATE AS ...

-- 4. Créer un trigger DELETE
CREATE TRIGGER TR_Produits_Delete ON Produits AFTER DELETE AS ...

-- 5. Écrire des requêtes complexes pour interroger l'historique
SELECT * FROM Produits_Historique
WHERE ProduitID = 1
  AND @DateRecherchee BETWEEN DateDebut AND DateFin
UNION ALL
SELECT * FROM Produits
WHERE ProduitID = 1
  AND EstActif = 1;

-- Total : ~100-200 lignes de code à maintenir par table !
```

### Après (avec tables temporelles)

```sql
-- Vous écrivez simplement :

CREATE TABLE Produits
(
    ProduitID INT PRIMARY KEY,
    Nom NVARCHAR(100),
    Prix DECIMAL(10, 2),
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON);

-- Et pour interroger l'historique :
SELECT * FROM Produits FOR SYSTEM_TIME AS OF @DateRecherchee;

-- Total : ~10 lignes de code, aucune maintenance !
```

**La différence est spectaculaire** : vous déléguez toute la complexité à SQL Server.

## Architecture conceptuelle

Voici comment s'organise une table temporelle dans SQL Server :

```
┌─────────────────────────────────────────────────────────────┐
│                    BASE DE DONNÉES                          │
│                                                             │
│  ┌──────────────────────────┐   ┌───────────────────────┐   │
│  │  Produits                │   │  Produits_History     │   │
│  │  (Table actuelle)        │   │  (Table historique)   │   │
│  ├──────────────────────────┤   ├───────────────────────┤   │
│  │ ProduitID | Nom  | Prix  │   │ ProduitID | Nom       │   │
│  │ ValidFrom | ValidTo      │   │ Prix | ValidFrom      │   │
│  │                          │   │      | ValidTo        │   │
│  │ 1 | Ordi | 700€          │   │ 1 | Ordi | 800€       │   │
│  │ 2024-11-01 | 9999-12-31  │   │ 2024-01-01|2024-06-01 │   │
│  │                          │   │ 1 | Ordi | 750€       │   │
│  │ (VERSION ACTUELLE)       │   │ 2024-06-01|2024-11-01 │   │
│  │                          │   │                       │   │
│  │                          │   │ (ANCIENNES VERSIONS)  │   │
│  └──────────────────────────┘   └───────────────────────┘   │
│              ↑                              ↑               │
│              │                              │               │
│              └──────── Liées ───────────────┘               │
│                  (SYSTEM_VERSIONING)                        │
└─────────────────────────────────────────────────────────────┘

         VOS REQUÊTES NORMALES        REQUÊTES TEMPORELLES
                  ↓                            ↓
          SELECT * FROM Produits      SELECT * FROM Produits
                                      FOR SYSTEM_TIME AS OF...
                  ↓                            ↓
           Table actuelle              Table actuelle
              seulement                + Table historique
```

## Prêt à commencer ?

Maintenant que vous comprenez **pourquoi** les tables temporelles existent et **ce qu'elles apportent**, nous allons explorer dans les sections suivantes :

1. **Comment elles fonctionnent en détail** (8.3.1) - Le mécanisme interne
2. **Comment les créer et les configurer** (8.3.2) - La syntaxe pratique
3. **Comment interroger l'historique** (8.3.3) - Les requêtes temporelles

Les tables temporelles représentent une **avancée majeure** dans SQL Server. Elles transforment un problème complexe (l'historisation) en une fonctionnalité simple et élégante. Une fois que vous aurez maîtrisé cette fonctionnalité, vous vous demanderez comment vous avez pu vous en passer !

---

**Points clés à retenir** :
- Les bases de données classiques ne conservent que l'état actuel, pas l'historique
- Avant SQL Server 2016, l'historisation nécessitait des solutions complexes (triggers, tables d'audit)
- Les tables temporelles automatisent complètement l'historisation
- Vous travaillez normalement, SQL Server gère l'historique en arrière-plan
- Syntaxe SQL simple pour interroger les données à n'importe quel moment du passé
- Idéal pour l'audit, la conformité, l'analyse temporelle
- Disponible depuis SQL Server 2016, Azure SQL Database, et Azure SQL Managed Instance

Passons maintenant aux détails techniques ! 🚀

⏭️ [Concept d'historisation automatique des données](/08-sujets-complementaires-et-ecosysteme/03.1-concept-historisation-automatique.md)
