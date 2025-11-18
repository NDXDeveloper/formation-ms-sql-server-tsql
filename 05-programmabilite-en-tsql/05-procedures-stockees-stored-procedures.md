🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 5.5 Procédures Stockées (Stored Procedures) - Introduction

## Qu'est-ce qu'une Procédure Stockée ?

Une **procédure stockée** (ou *stored procedure* en anglais) est un programme SQL précompilé et enregistré dans la base de données. C'est l'un des outils les plus puissants et les plus importants de SQL Server pour développer des applications professionnelles robustes et performantes.

### Définition Simple

Une procédure stockée est essentiellement un **ensemble d'instructions SQL regroupées sous un nom** qui peut être exécuté à la demande. Pensez-y comme à une **fonction ou méthode** dans un langage de programmation classique, mais qui vit dans la base de données.

**Différence fondamentale avec une requête SQL simple :**
- Une **requête SQL** est exécutée ponctuellement depuis une application
- Une **procédure stockée** est enregistrée dans la base de données et peut être appelée à tout moment

### Analogie du Monde Réel

Imaginez une **recette de cuisine professionnelle** dans un restaurant :

**Sans procédure stockée (Cuisine maison) :**
- Chaque fois, vous cherchez la recette dans un livre
- Vous suivez les étapes une par une
- Vous devez vous rappeler tous les ingrédients
- Vous risquez d'oublier une étape

**Avec procédure stockée (Cuisine professionnelle) :**
- La recette est **affichée au mur de la cuisine** (stockée dans la base)
- Le chef crie simplement "**Préparez un Bœuf Bourguignon !**" (appelle la procédure)
- Tous les cuisiniers savent exactement quoi faire (instructions préenregistrées)
- La recette est standardisée et toujours exécutée correctement

De la même manière :
- Les **instructions SQL** sont les étapes de la recette
- Le **nom de la procédure** est le nom du plat
- L'**exécution** est l'ordre donné au cuisinier
- Le **résultat** est le plat préparé

---

## Pourquoi les Procédures Stockées sont-elles Essentielles ?

Les procédures stockées résolvent de nombreux problèmes rencontrés dans le développement d'applications avec bases de données.

### Problème 1 : Code SQL Répétitif et Dupliqué

**Sans procédure stockée :**

Imaginez une application de e-commerce où vous devez créer une commande. Voici le code que l'application doit exécuter :

```csharp
// Dans l'application Web (C#)
string sql1 = "INSERT INTO Commandes (ClientID, DateCommande) VALUES (@ClientID, GETDATE())";
// Exécuter la requête...

string sql2 = "SELECT @@IDENTITY";
// Récupérer l'ID...

string sql3 = "INSERT INTO DetailsCommande (CommandeID, ProduitID, Quantite, Prix) VALUES (...)";
// Exécuter pour chaque ligne...

string sql4 = "UPDATE Produits SET Stock = Stock - @Quantite WHERE ProduitID = @ProduitID";
// Exécuter pour chaque produit...

string sql5 = "UPDATE Commandes SET MontantTotal = (SELECT SUM(...) FROM DetailsCommande WHERE ...)";
// Calculer le total...
```

**Problèmes :**
- ✗ Code long et complexe dans l'application
- ✗ Si vous avez aussi une application mobile → **dupliquer** tout ce code
- ✗ Si la logique change → modifier **plusieurs applications**
- ✗ Risque d'erreur ou d'incohérence
- ✗ Nombreux aller-retours réseau (lent)

---

**Avec procédure stockée :**

```sql
-- Dans la base de données (créée une seule fois)
CREATE PROCEDURE SpCreerCommande
    @ClientID INT,
    @Details TableDesDetails READONLY -- Table de détails
AS
BEGIN
    -- Toute la logique ici (5-10 requêtes)
    -- Création commande
    -- Insertion des détails
    -- Mise à jour du stock
    -- Calcul du total
    -- Etc.
END;
```

```csharp
// Dans l'application (Web, Mobile, Desktop - toutes identiques)
SqlCommand cmd = new SqlCommand("SpCreerCommande", conn);
cmd.CommandType = CommandType.StoredProcedure;
cmd.Parameters.AddWithValue("@ClientID", clientId);
cmd.Parameters.AddWithValue("@Details", detailsTable);
cmd.ExecuteNonQuery();
```

**Avantages :**
- ✅ Code simple dans toutes les applications
- ✅ Logique centralisée dans la base
- ✅ Une seule modification pour toutes les applications
- ✅ Performance optimale (un seul appel réseau)

---

### Problème 2 : Sécurité et Contrôle d'Accès

**Scénario :** Vous avez une table `Salaires` avec des informations sensibles. Les managers doivent pouvoir voir les salaires de leur équipe, mais pas modifier directement la table.

**Sans procédure :** Vous devez donner l'accès SELECT sur la table → risque que quelqu'un voie TOUS les salaires.

**Avec procédure :**

```sql
-- Procédure qui filtre automatiquement
CREATE PROCEDURE SpObtenirSalairesEquipe
    @ManagerID INT
AS
BEGIN
    SELECT EmployeID, Nom, Salaire
    FROM Salaires
    WHERE ManagerID = @ManagerID; -- Filtre automatique
END;

-- Permissions
DENY SELECT ON Salaires TO Manager; -- Pas d'accès direct
GRANT EXECUTE ON SpObtenirSalairesEquipe TO Manager; -- Seulement via la procédure
```

**Résultat :** Le manager peut voir uniquement son équipe, jamais tous les salaires.

---

### Problème 3 : Performance et Optimisation

**Sans procédure :**
- SQL Server doit **analyser, compiler et optimiser** chaque requête à chaque exécution
- Nombreux aller-retours réseau
- Plan d'exécution recréé à chaque fois

**Avec procédure :**
- Le plan d'exécution est **créé une fois et mis en cache**
- Réutilisé à chaque exécution → **plus rapide**
- Un seul appel réseau → **moins de latence**
- Gain de performance : **10-50% selon les cas**

---

## Structure d'une Procédure Stockée

### Composants de Base

```sql
CREATE PROCEDURE nom_procedure
    @parametre1 type,           -- Paramètres d'entrée
    @parametre2 type OUTPUT     -- Paramètres de sortie
AS
BEGIN
    -- Variables locales
    DECLARE @variable type;

    -- Logique métier
    -- SELECT, INSERT, UPDATE, DELETE
    -- IF, WHILE, TRY...CATCH
    -- Appels à d'autres procédures

    -- Retourner un code de statut
    RETURN valeur;
END;
```

### Éléments Clés

1. **Nom** : Identifiant unique de la procédure
2. **Paramètres** : Valeurs d'entrée et de sortie
3. **Corps (BEGIN...END)** : Instructions SQL à exécuter
4. **Variables locales** : Stockage temporaire de données
5. **RETURN** : Code de statut (succès/échec)

---

## Types de Procédures Stockées

### 1. Procédures de Consultation (Lecture)

Retournent des données sans modification.

```sql
CREATE PROCEDURE SpListerClients
AS
BEGIN
    SELECT ClientID, Nom, Prenom, Email
    FROM Clients
    WHERE Actif = 1
    ORDER BY Nom;
END;
```

**Usage :** Rapports, listes, dashboards

---

### 2. Procédures de Modification (Écriture)

Modifient les données (INSERT, UPDATE, DELETE).

```sql
CREATE PROCEDURE SpCreerClient
    @Nom VARCHAR(50),
    @Prenom VARCHAR(50),
    @Email VARCHAR(100)
AS
BEGIN
    INSERT INTO Clients (Nom, Prenom, Email, DateInscription)
    VALUES (@Nom, @Prenom, @Email, GETDATE());

    RETURN SCOPE_IDENTITY(); -- Retourner l'ID créé
END;
```

**Usage :** Création, mise à jour, suppression de données

---

### 3. Procédures de Calcul

Effectuent des calculs complexes.

```sql
CREATE PROCEDURE SpCalculerCommission
    @VendeurID INT,
    @Mois INT,
    @Annee INT,
    @Commission DECIMAL(10,2) OUTPUT
AS
BEGIN
    -- Logique complexe de calcul
    SELECT @Commission = SUM(MontantTotal) * 0.05
    FROM Commandes
    WHERE VendeurID = @VendeurID
      AND MONTH(DateCommande) = @Mois
      AND YEAR(DateCommande) = @Annee;
END;
```

**Usage :** Calculs métier, statistiques, analyses

---

### 4. Procédures de Validation

Vérifient des règles métier.

```sql
CREATE PROCEDURE SpValiderCommande
    @CommandeID INT
AS
BEGIN
    -- Vérifications multiples
    IF NOT EXISTS (SELECT 1 FROM Commandes WHERE CommandeID = @CommandeID)
        RETURN -1; -- Commande inexistante

    IF (SELECT MontantTotal FROM Commandes WHERE CommandeID = @CommandeID) <= 0
        RETURN -2; -- Montant invalide

    -- Autres validations...

    RETURN 1; -- Validation OK
END;
```

**Usage :** Validation de données, règles métier

---

### 5. Procédures Utilitaires

Effectuent des tâches de maintenance ou d'administration.

```sql
CREATE PROCEDURE SpNettoyer​LogsAnciens
    @JoursConservation INT = 90
AS
BEGIN
    DELETE FROM Logs
    WHERE DateLog < DATEADD(DAY, -@JoursConservation, GETDATE());

    PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' logs supprimés';
END;
```

**Usage :** Maintenance, nettoyage, administration

---

## Concepts Clés à Comprendre

### Concept 1 : Précompilation

Les procédures stockées sont **compilées** lors de leur première exécution. Le plan d'exécution est mis en cache et réutilisé.

**Avantage :** Exécutions suivantes beaucoup plus rapides.

**Analogie :** C'est comme un GPS qui calcule l'itinéraire une fois, puis vous le fait suivre à chaque trajet identique.

---

### Concept 2 : Encapsulation

Les procédures **cachent** la complexité et la structure de la base de données.

**Avantage :** Les applications n'ont pas besoin de connaître les détails internes.

**Analogie :** Quand vous appelez un taxi, vous dites "Emmenez-moi à la gare". Vous ne donnez pas les instructions rue par rue.

---

### Concept 3 : Paramétrage

Les procédures acceptent des **paramètres** pour être flexibles et réutilisables.

**Analogie :** Une recette de gâteau où vous pouvez choisir la saveur (chocolat, vanille, fraise) en changeant un ingrédient.

---

### Concept 4 : Modularité

Les procédures peuvent **s'appeler entre elles**, créant des modules réutilisables.

```sql
-- Procédure A appelle Procédure B
CREATE PROCEDURE SpCreerClient
AS
BEGIN
    -- Logique de création

    -- Appeler une autre procédure
    EXEC SpEnvoyerEmailBienvenue @Email;
END;
```

---

## Cycle de Vie d'une Procédure Stockée

```
1. CRÉATION (CREATE PROCEDURE)
   ↓
   La procédure est enregistrée dans la base de données
   ↓

2. PREMIÈRE EXÉCUTION (EXEC)
   ↓
   - SQL Server compile la procédure
   - Crée le plan d'exécution
   - Met en cache le plan
   - Exécute les instructions
   ↓

3. EXÉCUTIONS SUIVANTES
   ↓
   - SQL Server réutilise le plan en cache
   - Exécution plus rapide
   ↓

4. MODIFICATION (ALTER PROCEDURE)
   ↓
   La procédure est mise à jour
   Le plan en cache est invalidé
   ↓

5. SUPPRESSION (DROP PROCEDURE)
   ↓
   La procédure est supprimée de la base
```

---

## Cas d'Usage Typiques

### 1. Applications Web et Mobile

```sql
-- API de l'application
CREATE PROCEDURE SpAuthentifier
    @Email VARCHAR(100),
    @MotDePasse VARCHAR(100),
    @UtilisateurID INT OUTPUT
AS
BEGIN
    -- Logique d'authentification
    -- Validation
    -- Retour de l'ID utilisateur
END;
```

**Usage :** Backend de l'application appelle cette procédure pour connecter un utilisateur.

---

### 2. Traitements par Lots (Batch)

```sql
-- Traitement quotidien automatisé
CREATE PROCEDURE SpTraitementFacturesQuotidien
AS
BEGIN
    -- Générer les factures du jour
    -- Envoyer les emails
    -- Mettre à jour les statuts
    -- Logger les opérations
END;
```

**Usage :** Job SQL Agent qui s'exécute chaque nuit à 2h du matin.

---

### 3. Rapports et Business Intelligence

```sql
-- Rapport de ventes mensuel
CREATE PROCEDURE SpRapportVentesMensuel
    @Mois INT,
    @Annee INT
AS
BEGIN
    -- Calculs complexes
    -- Agrégations
    -- Jointures multiples
    SELECT ... -- Résultats formatés
END;
```

**Usage :** Power BI ou Tableau se connecte et appelle cette procédure pour générer les rapports.

---

### 4. Intégration de Systèmes

```sql
-- Synchronisation avec un système externe
CREATE PROCEDURE SpImporterCommandesERP
    @FichierXML XML
AS
BEGIN
    -- Parser le XML
    -- Valider les données
    -- Insérer dans les tables
    -- Logger les erreurs
END;
```

**Usage :** Import de données depuis un système ERP externe.

---

### 5. Workflows Complexes

```sql
-- Processus de validation de commande
CREATE PROCEDURE SpValiderEtTraiterCommande
    @CommandeID INT
AS
BEGIN
    -- 1. Valider la commande
    EXEC SpValiderCommande @CommandeID;

    -- 2. Vérifier le stock
    EXEC SpVerifierStock @CommandeID;

    -- 3. Calculer les frais
    EXEC SpCalculerFraisLivraison @CommandeID;

    -- 4. Générer la facture
    EXEC SpGenererFacture @CommandeID;

    -- 5. Notifier le client
    EXEC SpEnvoyerEmailConfirmation @CommandeID;
END;
```

**Usage :** Orchestration d'un processus métier complexe.

---

## Vue d'Ensemble de cette Section

Dans les sous-sections suivantes, nous allons explorer en profondeur tous les aspects des procédures stockées :

### 5.5.1 CREATE PROCEDURE (ou PROC)
- Syntaxe complète de création
- Exemples de procédures simples à complexes
- Conventions de nommage
- Bonnes pratiques de structure

### 5.5.2 Paramètres d'Entrée (Input) et de Sortie (OUTPUT)
- Paramètres obligatoires et optionnels
- Paramètres avec valeurs par défaut
- Paramètres OUTPUT pour retourner des valeurs
- Différences entre INPUT et OUTPUT

### 5.5.3 Valeurs de Retour (RETURN)
- Codes de statut (succès/échec)
- Conventions de codes de retour
- Différence entre RETURN et OUTPUT
- Quand utiliser chaque méthode

### 5.5.4 Exécution (EXECUTE ou EXEC)
- Différentes façons d'exécuter une procédure
- Passage de paramètres (par position vs par nom)
- Capture des valeurs de retour
- Exécution depuis une application

### 5.5.5 Avantages (Performance, Sécurité, Réutilisabilité)
- Gains de performance mesurables
- Sécurité accrue et contrôle d'accès
- Maintenance centralisée
- Réutilisabilité du code

---

## Comparaison : Approches Alternatives

### Procédures Stockées vs Requêtes Ad-hoc

| Aspect | Requêtes Ad-hoc | Procédures Stockées |
|--------|----------------|---------------------|
| **Stockage** | Dans l'application | Dans la base de données |
| **Compilation** | À chaque exécution | Une fois (puis cache) |
| **Modification** | Redéployer l'application | Modifier la procédure uniquement |
| **Réutilisabilité** | Duplication dans chaque app | Une seule définition |
| **Performance** | Bonne | Excellente (10-50% plus rapide) |
| **Sécurité** | Moins granulaire | Très granulaire |
| **Maintenance** | Difficile (code dispersé) | Facile (code centralisé) |

---

### Procédures Stockées vs ORM (Entity Framework, Hibernate)

| Aspect | ORM | Procédures Stockées |
|--------|-----|---------------------|
| **Courbe d'apprentissage** | ⭐⭐⭐ Moyenne | ⭐⭐⭐⭐ Plus difficile |
| **Rapidité développement** | ⭐⭐⭐⭐⭐ Très rapide | ⭐⭐⭐ Moyenne |
| **Performance** | ⭐⭐⭐ Bonne | ⭐⭐⭐⭐⭐ Excellente |
| **Complexité supportée** | ⭐⭐⭐ Limitée | ⭐⭐⭐⭐⭐ Illimitée |
| **Portabilité** | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐ Faible (spécifique DB) |
| **Contrôle précis** | ⭐⭐ Limité | ⭐⭐⭐⭐⭐ Total |

**Meilleure pratique :** Approche **hybride**
- ORM pour le CRUD simple (Create, Read, Update, Delete)
- Procédures stockées pour la logique métier complexe

---

### Procédures Stockées vs Vues

| Aspect | Vues | Procédures Stockées |
|--------|------|---------------------|
| **Type d'opération** | SELECT uniquement | Toutes (SELECT, INSERT, UPDATE, DELETE) |
| **Paramètres** | ❌ Non | ✅ Oui |
| **Logique complexe** | ❌ Limitée | ✅ Complète (IF, WHILE, etc.) |
| **Modification de données** | ⚠️ Limitée | ✅ Oui |
| **Variables** | ❌ Non | ✅ Oui |
| **Gestion d'erreurs** | ❌ Non | ✅ Oui (TRY...CATCH) |

**Complémentarité :** Les vues et les procédures se complètent
- **Vues** : Simplifier les consultations, masquer la complexité
- **Procédures** : Logique métier, modifications, workflows

---

## Vocabulaire et Terminologie

Pour bien comprendre les procédures stockées, voici les termes importants à connaître :

| Terme | Définition |
|-------|------------|
| **Procédure stockée** | Programme SQL enregistré dans la base de données |
| **Paramètre d'entrée** | Valeur passée à la procédure (INPUT) |
| **Paramètre de sortie** | Valeur retournée par la procédure (OUTPUT) |
| **Code de retour** | Valeur entière retournée par RETURN (succès/échec) |
| **Plan d'exécution** | Stratégie optimale pour exécuter la procédure |
| **Compilation** | Transformation du T-SQL en instructions exécutables |
| **Cache de plan** | Mémoire où sont stockés les plans d'exécution |
| **Batch** | Ensemble d'instructions séparées par GO |
| **Encapsulation** | Masquer la complexité interne |

---

## Prérequis pour Créer et Utiliser des Procédures

### Connaissances Requises

Avant de créer des procédures stockées, vous devriez maîtriser :

- ✅ Les requêtes SELECT de base
- ✅ Les opérations DML (INSERT, UPDATE, DELETE)
- ✅ Les jointures (INNER JOIN, LEFT JOIN, etc.)
- ✅ Les fonctions d'agrégation (COUNT, SUM, AVG, etc.)
- ✅ Les structures de base (IF, WHILE, CASE)
- ✅ Les variables (DECLARE, SET, SELECT)

### Permissions Nécessaires

Pour créer une procédure :
- ✅ Permission `CREATE PROCEDURE` dans la base de données
- ✅ Permission `ALTER SCHEMA` (pour créer dans un schéma)
- ✅ Appartenance au rôle `db_ddladmin` ou `db_owner`

Pour exécuter une procédure :
- ✅ Permission `EXECUTE` sur la procédure
- ✅ Permissions sur les tables sous-jacentes (si elles sont requises)

---

## Bonnes Pratiques Générales

### ✅ À FAIRE

1. **Utiliser des noms explicites et cohérents**
   - Préfixe : `Sp` ou `usp` (user stored procedure)
   - Verbe d'action : `SpCreer`, `SpModifier`, `SpSupprimer`

2. **Toujours utiliser SET NOCOUNT ON**
   - Réduit le trafic réseau
   - Améliore les performances

3. **Documenter avec des commentaires**
   - En-tête avec description, paramètres, codes de retour
   - Commentaires dans le code pour la logique complexe

4. **Valider tous les paramètres d'entrée**
   - Vérifier les valeurs NULL
   - Vérifier les plages de valeurs
   - Retourner des codes d'erreur explicites

5. **Utiliser la gestion d'erreurs**
   - Blocs TRY...CATCH pour les opérations critiques
   - Messages d'erreur clairs

6. **Limiter la complexité**
   - Maximum 200-300 lignes par procédure
   - Décomposer en procédures plus petites si nécessaire

### ❌ À ÉVITER

1. **Ne pas utiliser SELECT * dans les procédures**
   - Toujours spécifier les colonnes explicitement

2. **Éviter le préfixe 'sp_' (réservé au système)**
   - Utilisez `Sp` ou `usp` à la place

3. **Ne pas négliger la gestion d'erreurs**
   - Les erreurs non gérées peuvent corrompre les données

4. **Éviter le SQL dynamique non paramétré**
   - Risque d'injection SQL

5. **Ne pas créer de procédures "Dieu"**
   - Une procédure ne doit pas tout faire

---

## Workflow Typique avec les Procédures Stockées

```
1. ANALYSE DU BESOIN
   ↓
   Identifier l'opération métier à automatiser
   ↓

2. CONCEPTION
   ↓
   - Définir les paramètres d'entrée/sortie
   - Déterminer la logique métier
   - Identifier les validations nécessaires
   ↓

3. DÉVELOPPEMENT
   ↓
   CREATE PROCEDURE ...
   ↓

4. TESTS
   ↓
   - Tester avec données valides
   - Tester avec données invalides
   - Tester les cas limites
   - Vérifier les performances
   ↓

5. DOCUMENTATION
   ↓
   Ajouter commentaires et documentation
   ↓

6. DÉPLOIEMENT
   ↓
   Déployer en production
   ↓

7. ATTRIBUTION DES PERMISSIONS
   ↓
   GRANT EXECUTE aux utilisateurs/rôles appropriés
   ↓

8. UTILISATION
   ↓
   Les applications appellent la procédure
   ↓

9. MAINTENANCE
   ↓
   ALTER PROCEDURE pour modifications
   ↓

10. MONITORING
    ↓
    Surveiller les performances et l'utilisation
```

---

## Exemples Introductifs

Pour vous donner un avant-goût, voici quelques exemples simples :

### Exemple 1 : Procédure la plus simple

```sql
-- Afficher un message
CREATE PROCEDURE SpDireBonjour
AS
BEGIN
    PRINT 'Bonjour, bienvenue dans SQL Server !';
END;

-- Exécution
EXEC SpDireBonjour;
```

---

### Exemple 2 : Procédure avec paramètre

```sql
-- Obtenir un client par ID
CREATE PROCEDURE SpObtenirClient
    @ClientID INT
AS
BEGIN
    SELECT ClientID, Nom, Prenom, Email
    FROM Clients
    WHERE ClientID = @ClientID;
END;

-- Exécution
EXEC SpObtenirClient @ClientID = 5;
```

---

### Exemple 3 : Procédure avec validation

```sql
-- Créer un client avec validation
CREATE PROCEDURE SpCreerClient
    @Nom VARCHAR(50),
    @Email VARCHAR(100)
AS
BEGIN
    -- Validation
    IF EXISTS (SELECT 1 FROM Clients WHERE Email = @Email)
    BEGIN
        PRINT 'Erreur : Email déjà utilisé';
        RETURN -1;
    END

    -- Insertion
    INSERT INTO Clients (Nom, Email, DateInscription)
    VALUES (@Nom, @Email, GETDATE());

    RETURN 1; -- Succès
END;
```

---

### Exemple 4 : Procédure complexe

```sql
-- Traiter une commande complète
CREATE PROCEDURE SpTraiterCommande
    @CommandeID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. Valider la commande
        -- 2. Réserver le stock
        -- 3. Calculer les frais
        -- 4. Générer la facture
        -- 5. Envoyer notification

        COMMIT TRANSACTION;
        RETURN 1;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN -1;
    END CATCH
END;
```

**Note :** Ces exemples seront approfondis dans les sections suivantes.

---

## Préparation de l'Environnement

Avant de commencer à créer des procédures stockées, assurez-vous d'avoir :

### 1. Un Environnement de Test

```sql
-- Créer une base de données de test
CREATE DATABASE TestProcedures;
GO

USE TestProcedures;
GO
```

### 2. Des Tables d'Exemple

```sql
-- Table Clients
CREATE TABLE Clients (
    ClientID INT PRIMARY KEY IDENTITY(1,1),
    Nom VARCHAR(50) NOT NULL,
    Prenom VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Telephone VARCHAR(20),
    Ville VARCHAR(50),
    Actif BIT DEFAULT 1,
    DateInscription DATETIME DEFAULT GETDATE()
);

-- Table Produits
CREATE TABLE Produits (
    ProduitID INT PRIMARY KEY IDENTITY(1,1),
    NomProduit VARCHAR(100) NOT NULL,
    Prix DECIMAL(10,2) NOT NULL,
    StockDisponible INT DEFAULT 0,
    Categorie VARCHAR(50)
);

-- Table Commandes
CREATE TABLE Commandes (
    CommandeID INT PRIMARY KEY IDENTITY(1,1),
    ClientID INT FOREIGN KEY REFERENCES Clients(ClientID),
    DateCommande DATETIME DEFAULT GETDATE(),
    MontantTotal DECIMAL(10,2),
    Statut VARCHAR(20) DEFAULT 'En attente'
);

-- Table DetailsCommande
CREATE TABLE DetailsCommande (
    DetailID INT PRIMARY KEY IDENTITY(1,1),
    CommandeID INT FOREIGN KEY REFERENCES Commandes(CommandeID),
    ProduitID INT FOREIGN KEY REFERENCES Produits(ProduitID),
    Quantite INT NOT NULL,
    PrixUnitaire DECIMAL(10,2) NOT NULL
);

-- Insérer quelques données de test
INSERT INTO Clients (Nom, Prenom, Email, Ville)
VALUES
    ('Martin', 'Jean', 'jean.martin@email.com', 'Paris'),
    ('Dubois', 'Marie', 'marie.dubois@email.com', 'Lyon'),
    ('Durand', 'Pierre', 'pierre.durand@email.com', 'Marseille');

INSERT INTO Produits (NomProduit, Prix, StockDisponible, Categorie)
VALUES
    ('Ordinateur Portable', 899.99, 15, 'Électronique'),
    ('Souris Sans Fil', 29.99, 50, 'Électronique'),
    ('Clavier Mécanique', 119.99, 25, 'Électronique');
```

Vous êtes maintenant prêt à explorer le monde des procédures stockées !

---

## Résumé de l'Introduction

**Points clés à retenir :**

- 📦 Une procédure stockée est un **programme SQL enregistré** dans la base de données
- 🚀 Les procédures améliorent la **performance** (plan d'exécution caché)
- 🔒 Elles renforcent la **sécurité** (encapsulation, contrôle d'accès granulaire)
- ♻️ Elles favorisent la **réutilisabilité** (code centralisé, maintenance facilitée)
- 🎯 Elles acceptent des **paramètres** (entrée/sortie) pour la flexibilité
- 🔄 Elles peuvent contenir de la **logique complexe** (IF, WHILE, TRY...CATCH)
- 📊 Elles peuvent retourner des **données** (SELECT) ou des **codes de statut** (RETURN)

**Types principaux :**
- Consultation (SELECT)
- Modification (INSERT, UPDATE, DELETE)
- Calcul (logique métier complexe)
- Validation (règles métier)
- Utilitaires (maintenance)

**Dans les prochaines sections, vous apprendrez :**
- Comment créer des procédures avec syntaxe complète
- Comment utiliser les paramètres d'entrée et de sortie
- Comment retourner des codes de statut
- Comment exécuter et appeler les procédures
- Tous les avantages mesurables en détail

**Philosophie :** Les procédures stockées transforment votre base de données en une **API puissante** qui centralise la logique métier et simplifie vos applications.

Commençons maintenant par apprendre à créer des procédures stockées avec la section 5.5.1 !

⏭️ [CREATE PROCEDURE (ou PROC)](/05-programmabilite-en-tsql/05.1-create-procedure.md)
