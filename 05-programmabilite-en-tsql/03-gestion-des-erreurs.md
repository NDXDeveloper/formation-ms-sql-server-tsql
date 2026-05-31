🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 5.3 Gestion des erreurs

## Introduction générale

Bienvenue dans cette section essentielle consacrée à la **gestion des erreurs** en T-SQL ! Jusqu'à présent, nous avons appris à écrire du code qui fonctionne dans des conditions idéales. Mais dans le monde réel, les choses tournent mal : les utilisateurs saisissent des données invalides, les connexions réseau se coupent, les disques se remplissent, et les contraintes de base de données sont violées.

La **gestion des erreurs** est l'art de :
- **Anticiper** ce qui peut mal tourner
- **Capturer** les erreurs quand elles se produisent
- **Réagir** de manière appropriée et élégante
- **Informer** les utilisateurs de façon claire
- **Logger** les problèmes pour analyse
- **Récupérer** ou échouer gracieusement

Cette section va transformer votre code de "fragile" à **robuste**, de scripts qui plantent mystérieusement à des applications professionnelles qui gèrent les problèmes avec élégance.

---

## Pourquoi la gestion des erreurs est-elle cruciale ?

### Le problème : Code sans gestion d'erreurs

Imaginez ce code simple d'une application bancaire :

```sql
CREATE PROCEDURE TransfererArgent
    @CompteSource INT,
    @CompteDest INT,
    @Montant DECIMAL(10,2)
AS
BEGIN
    -- Débiter le compte source
    UPDATE Comptes SET Solde = Solde - @Montant WHERE CompteID = @CompteSource;

    -- Créditer le compte destination
    UPDATE Comptes SET Solde = Solde + @Montant WHERE CompteID = @CompteDest;

    PRINT 'Transfert effectué';
END
```

**Que se passe-t-il si :**
- Le compte source n'a pas assez d'argent ? ❌ L'argent disparaît !
- Le compte destination n'existe pas ? ❌ L'argent disparaît !
- Une erreur réseau survient entre les deux UPDATE ? ❌ Incohérence totale !
- Le montant est négatif ? ❌ Bug exploitable !

**Résultat :** Catastrophe financière, clients mécontents, problèmes légaux.

### La solution : Gestion robuste des erreurs

```sql
CREATE PROCEDURE TransfererArgent
    @CompteSource INT,
    @CompteDest INT,
    @Montant DECIMAL(10,2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validation
        IF @Montant <= 0
            THROW 50001, 'Le montant doit être positif', 1;

        IF NOT EXISTS (SELECT 1 FROM Comptes WHERE CompteID = @CompteSource)
            THROW 50002, 'Compte source introuvable', 1;

        IF NOT EXISTS (SELECT 1 FROM Comptes WHERE CompteID = @CompteDest)
            THROW 50003, 'Compte destination introuvable', 1;

        DECLARE @Solde DECIMAL(10,2);
        SELECT @Solde = Solde FROM Comptes WHERE CompteID = @CompteSource;

        IF @Solde < @Montant
            THROW 50004, 'Solde insuffisant', 1;

        -- Opérations protégées
        UPDATE Comptes SET Solde = Solde - @Montant WHERE CompteID = @CompteSource;
        UPDATE Comptes SET Solde = Solde + @Montant WHERE CompteID = @CompteDest;

        COMMIT TRANSACTION;
        PRINT 'Transfert effectué avec succès';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Logger l'erreur
        INSERT INTO LogErreurs (Message, Date)
        VALUES (ERROR_MESSAGE(), GETDATE());

        -- Informer l'utilisateur
        PRINT 'Erreur : ' + ERROR_MESSAGE();

        -- Relancer l'erreur
        THROW;
    END CATCH
END
```

**Résultat :** Code sûr, fiable, professionnel.

---

## Analogies pour comprendre

### Analogie 1 : Le parachute

Pensez à la gestion des erreurs comme à un **parachute** :
- **Sans parachute** : Si quelque chose tourne mal en vol, c'est la catastrophe
- **Avec parachute** : En cas de problème, vous avez un plan B qui vous sauve

La gestion des erreurs est votre **parachute de sécurité** en programmation.

### Analogie 2 : Le médecin

Un bon médecin ne se contente pas de dire "Vous êtes malade" :
1. Il **identifie** le problème (diagnostic)
2. Il **comprend** la cause (analyse)
3. Il **prescrit** un traitement (action corrective)
4. Il **documente** dans votre dossier (logging)
5. Il **suit** votre évolution (monitoring)

La gestion des erreurs suit le même processus médical pour vos applications.

### Analogie 3 : Le pilote d'avion

Un pilote professionnel :
- **Anticipe** les problèmes potentiels (validation préventive)
- **Surveille** constamment les instruments (détection)
- **Réagit** calmement aux alarmes (gestion)
- **Communique** avec la tour de contrôle (logging/alertes)
- **Atterrit** en sécurité même en cas de problème (récupération)

Votre code doit être comme un pilote expérimenté.

---

## Les trois piliers de la gestion des erreurs

Cette section couvre trois aspects complémentaires et essentiels :

### 1. Capturer les erreurs : TRY ... CATCH

**Ce que vous apprendrez :**
- La structure TRY ... CATCH pour intercepter les erreurs
- Comment protéger votre code contre les pannes
- La différence entre erreurs capturables et non capturables
- Les transactions et leur annulation en cas d'erreur
- Les blocs TRY ... CATCH imbriqués

**Analogie :** C'est le **filet de sécurité** qui attrape les problèmes avant qu'ils ne deviennent catastrophiques.

**Exemple de ce que vous saurez faire :**
```sql
BEGIN TRY
    -- Code potentiellement risqué
    INSERT INTO Employes (EmployeID, Nom) VALUES (1, 'Dupont');
END TRY
BEGIN CATCH
    -- Gérer l'erreur élégamment
    PRINT 'Erreur : ' + ERROR_MESSAGE();
END CATCH
```

### 2. Analyser les erreurs : Fonctions d'erreur

**Ce que vous apprendrez :**
- ERROR_NUMBER() : Identifier le type d'erreur
- ERROR_MESSAGE() : Comprendre ce qui s'est passé
- ERROR_SEVERITY() : Évaluer la gravité
- ERROR_STATE() : Obtenir le contexte interne
- ERROR_LINE() : Localiser exactement où ça a planté
- ERROR_PROCEDURE() : Identifier quelle procédure a échoué

**Analogie :** Ce sont vos **outils de diagnostic** pour comprendre exactement ce qui s'est mal passé.

**Exemple de ce que vous saurez faire :**
```sql
BEGIN CATCH
    PRINT 'Type d''erreur : ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Description   : ' + ERROR_MESSAGE();
    PRINT 'Ligne         : ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Gravité       : ' + CAST(ERROR_SEVERITY() AS VARCHAR);
END CATCH
```

### 3. Générer des erreurs : RAISERROR vs THROW

**Ce que vous apprendrez :**
- Comment créer vos propres erreurs personnalisées
- RAISERROR : la méthode historique avec formatage
- THROW : la méthode moderne et simple
- Quand utiliser l'une ou l'autre
- Créer un système de codes d'erreur cohérent
- Valider les données et rejeter ce qui est invalide

**Analogie :** C'est votre **système d'alarme** qui signale activement les problèmes que vous détectez.

**Exemple de ce que vous saurez faire :**
```sql
IF @Age < 18
    THROW 50001, 'L''utilisateur doit avoir au moins 18 ans', 1;

IF NOT EXISTS (SELECT 1 FROM Clients WHERE ClientID = @ClientID)
    THROW 50002, 'Client introuvable', 1;
```

---

## Le cycle complet de gestion des erreurs

Voici comment ces trois éléments fonctionnent ensemble :

```
┌─────────────────────────────────────────────────────────────┐
│                    VOTRE APPLICATION                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. VALIDATION (Générer des erreurs - THROW/RAISERROR)      │
│     ↓                                                       │
│     IF données invalides → THROW 50001, 'Erreur', 1         │
│                                                             │
│  2. EXÉCUTION PROTÉGÉE (Capturer - TRY...CATCH)             │
│     ↓                                                       │
│     BEGIN TRY                                               │
│         -- Opérations risquées                              │
│     END TRY                                                 │
│                                                             │
│  3. GESTION D'ERREUR (Analyser - Fonctions d'erreur)        │
│     ↓                                                       │
│     BEGIN CATCH                                             │
│         • ERROR_NUMBER()  → Identifier                      │
│         • ERROR_MESSAGE() → Comprendre                      │
│         • ERROR_LINE()    → Localiser                       │
│         • Logging         → Documenter                      │
│         • ROLLBACK        → Annuler                         │
│         • THROW           → Remonter                        │
│     END CATCH                                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Types d'erreurs que vous rencontrerez

### 1. Erreurs de validation (que vous générez)

```sql
-- Données invalides détectées
IF @Email NOT LIKE '%@%'
    THROW 50001, 'Format email invalide', 1;

IF @Prix < 0
    THROW 50002, 'Le prix ne peut pas être négatif', 1;
```

**Responsabilité :** Votre code doit détecter et signaler ces problèmes.

### 2. Erreurs de contrainte (générées par SQL Server)

```sql
-- Violation de PRIMARY KEY
INSERT INTO Clients (ClientID, Nom) VALUES (1, 'Dupont');
INSERT INTO Clients (ClientID, Nom) VALUES (1, 'Martin');  -- ERREUR !

-- Violation de FOREIGN KEY
INSERT INTO Commandes (ClientID) VALUES (999);  -- Client inexistant
```

**Responsabilité :** Votre code doit capturer et gérer ces erreurs.

### 3. Erreurs système (générées par SQL Server)

```sql
-- Division par zéro
DECLARE @Resultat INT = 100 / 0;  -- ERREUR !

-- Conversion impossible
DECLARE @Date DATE = CAST('pas une date' AS DATE);  -- ERREUR !

-- Mémoire insuffisante, disque plein, etc.
```

**Responsabilité :** Votre code doit capturer, logger, et réagir appropriément.

---

## Niveaux de gestion des erreurs

### Niveau 1 : Le minimum (débutant)

```sql
BEGIN TRY
    -- Votre code
END TRY
BEGIN CATCH
    PRINT 'Une erreur est survenue';
END CATCH
```

**Problème :** Trop vague, pas de détails, pas de logging.

### Niveau 2 : Informatif (intermédiaire)

```sql
BEGIN TRY
    -- Votre code
END TRY
BEGIN CATCH
    PRINT 'Erreur : ' + ERROR_MESSAGE();
    PRINT 'Ligne : ' + CAST(ERROR_LINE() AS VARCHAR);
END CATCH
```

**Mieux :** L'utilisateur comprend le problème.

### Niveau 3 : Professionnel (avancé)

```sql
BEGIN TRY
    BEGIN TRANSACTION;
    -- Votre code
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    -- Logger dans une table
    INSERT INTO LogErreurs (
        NumeroErreur, Message, Ligne, NomProcedure, Date
    )
    VALUES (
        ERROR_NUMBER(), ERROR_MESSAGE(), ERROR_LINE(),
        ERROR_PROCEDURE(), GETDATE()
    );

    -- Message utilisateur clair
    PRINT 'Erreur #' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Description : ' + ERROR_MESSAGE();

    -- Relancer si erreur critique
    IF ERROR_SEVERITY() >= 16
        THROW;
END CATCH
```

**Objectif :** C'est ce niveau que nous visons dans cette section.

---

## Stratégies de gestion des erreurs

### Stratégie 1 : Fail Fast (Échouer rapidement)

```sql
-- Valider AVANT de faire quoi que ce soit
IF @Parametre IS NULL
    THROW 50001, 'Paramètre obligatoire', 1;

IF @Quantite <= 0
    THROW 50002, 'Quantité invalide', 1;

-- Si on arrive ici, tout est valide
-- On peut procéder en toute confiance
```

**Principe :** Rejeter les données invalides immédiatement.

### Stratégie 2 : Try-Retry (Réessayer)

```sql
DECLARE @Tentative INT = 1;
DECLARE @Succes BIT = 0;

WHILE @Tentative <= 3 AND @Succes = 0
BEGIN
    BEGIN TRY
        -- Opération qui peut échouer temporairement
        EXEC OperationReseau;
        SET @Succes = 1;
    END TRY
    BEGIN CATCH
        PRINT 'Échec tentative ' + CAST(@Tentative AS VARCHAR);
        WAITFOR DELAY '00:00:02';  -- Attendre 2 secondes
    END CATCH

    SET @Tentative = @Tentative + 1;
END
```

**Principe :** Réessayer les opérations qui peuvent échouer temporairement.

### Stratégie 3 : Graceful Degradation (Dégradation élégante)

```sql
BEGIN TRY
    -- Essayer l'opération optimale
    EXEC OperationComplexe;
END TRY
BEGIN CATCH
    -- Si ça échoue, utiliser une méthode alternative plus simple
    EXEC OperationSimpleAlternative;
    PRINT 'Avertissement : Mode dégradé activé';
END CATCH
```

**Principe :** Continuer avec une fonctionnalité réduite plutôt que d'échouer complètement.

### Stratégie 4 : Transaction Rollback (Annulation complète)

```sql
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TableA SET Valeur = 100;
    UPDATE TableB SET Valeur = 200;
    UPDATE TableC SET Valeur = 300;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;  -- Tout annuler si une erreur

    THROW;
END CATCH
```

**Principe :** Tout ou rien, maintenir la cohérence des données.

---

## Prérequis

Avant de commencer cette section, vous devriez maîtriser :

- ✅ Les structures de contrôle (IF, WHILE, CASE) - Section 5.2
- ✅ Les blocs BEGIN ... END
- ✅ Les transactions (BEGIN TRANSACTION, COMMIT, ROLLBACK) - Concepts de base
- ✅ Les procédures stockées (création et exécution)
- ✅ Les variables (locales et globales comme @@TRANCOUNT)

Si ces concepts ne sont pas clairs, revoyez les sections précédentes.

---

## Compétences que vous allez acquérir

À la fin de cette section, vous serez capable de :

### Compétences fondamentales
- ✓ Protéger votre code avec des blocs TRY ... CATCH
- ✓ Capturer et analyser les erreurs avec les fonctions d'erreur
- ✓ Générer vos propres erreurs avec THROW et RAISERROR
- ✓ Créer des messages d'erreur clairs et informatifs

### Compétences avancées
- ✓ Implémenter un système de logging complet
- ✓ Gérer les transactions avec annulation automatique
- ✓ Créer un système de codes d'erreur cohérent
- ✓ Relancer les erreurs de manière appropriée
- ✓ Différencier les types d'erreurs et réagir en conséquence

### Compétences professionnelles
- ✓ Écrire du code robuste et fiable
- ✓ Créer des applications qui échouent gracieusement
- ✓ Déboguer efficacement grâce au logging
- ✓ Protéger l'intégrité des données
- ✓ Fournir des retours utilisateur clairs

---

## Ce qui distingue un code amateur d'un code professionnel

### Code amateur

```sql
CREATE PROCEDURE AjouterProduit
    @Nom VARCHAR(100),
    @Prix DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Produits (Nom, Prix) VALUES (@Nom, @Prix);
    PRINT 'Produit ajouté';
END
```

**Problèmes :**
- Aucune validation
- Aucune gestion d'erreur
- Pas de logging
- Pas de transaction
- Messages vagues

### Code professionnel

```sql
CREATE PROCEDURE AjouterProduit
    @Nom VARCHAR(100),
    @Prix DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validation
        IF @Nom IS NULL OR LEN(@Nom) = 0
            THROW 50001, 'Le nom du produit est obligatoire', 1;

        IF @Prix <= 0
            THROW 50002, 'Le prix doit être positif', 1;

        IF EXISTS (SELECT 1 FROM Produits WHERE Nom = @Nom)
            THROW 50003, 'Ce produit existe déjà', 1;

        -- Transaction
        BEGIN TRANSACTION;

        INSERT INTO Produits (Nom, Prix, DateCreation)
        VALUES (@Nom, @Prix, GETDATE());

        -- Audit
        INSERT INTO AuditLog (Action, Detail, Date)
        VALUES ('PRODUIT_AJOUTE', 'Nom: ' + @Nom, GETDATE());

        COMMIT TRANSACTION;

        PRINT 'Produit "' + @Nom + '" ajouté avec succès';
        RETURN 0;  -- Code de succès

    END TRY
    BEGIN CATCH
        -- Annuler la transaction
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Logger l'erreur
        INSERT INTO LogErreurs (
            NumeroErreur, MessageErreur, NomProcedure, Ligne, DateErreur
        )
        VALUES (
            ERROR_NUMBER(), ERROR_MESSAGE(),
            'AjouterProduit', ERROR_LINE(), GETDATE()
        );

        -- Message utilisateur
        PRINT 'Erreur lors de l''ajout du produit';
        PRINT 'Code: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Détail: ' + ERROR_MESSAGE();

        RETURN -1;  -- Code d'erreur
    END CATCH
END
```

**C'est cette transformation que cette section va opérer dans votre code.**

---

## À quoi s'attendre

### Niveau de difficulté

Cette section est de niveau **intermédiaire**. Les concepts sont nouveaux mais essentiels. Avec de la pratique, ils deviendront naturels.

### Approche pédagogique

Pour chaque concept, nous suivrons :
1. **Le problème** : Pourquoi c'est important
2. **La solution** : Comment ça marche
3. **Des exemples** : Du simple au complexe
4. **Les pièges** : Erreurs courantes à éviter
5. **Les bonnes pratiques** : Comment faire professionnellement

### Temps estimé

Prévoyez environ **2 à 3 heures** pour cette section :
- TRY ... CATCH : 45 minutes
- Fonctions d'erreur : 45 minutes
- RAISERROR vs THROW : 45 minutes
- Pratique et expérimentation : 30-45 minutes

---

## Conseils pour bien apprendre

### 1. Cassez intentionnellement votre code

Pour apprendre la gestion des erreurs, vous devez **provoquer des erreurs** :
```sql
-- Essayez ces erreurs volontaires
SELECT 1 / 0;  -- Division par zéro
DECLARE @Date DATE = CAST('abc' AS DATE);  -- Conversion impossible
INSERT INTO Employes VALUES (1, 'Test'), (1, 'Test2');  -- Clé dupliquée
```

### 2. Créez un environnement de test

```sql
-- Table pour vos tests
CREATE TABLE TestErreurs (
    ID INT PRIMARY KEY,
    Valeur VARCHAR(50)
);

-- Testez différents scénarios
BEGIN TRY
    INSERT INTO TestErreurs VALUES (1, 'Test');
    INSERT INTO TestErreurs VALUES (1, 'Doublon');  -- Erreur !
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH
```

### 3. Construisez une bibliothèque d'exemples

Gardez des exemples de code pour chaque type d'erreur :
- Erreur de validation
- Erreur de contrainte
- Erreur de conversion
- Erreur de transaction

### 4. Loggez TOUT

Créez une table de log dès le début :
```sql
CREATE TABLE LogErreurs (
    LogID INT IDENTITY PRIMARY KEY,
    DateErreur DATETIME DEFAULT GETDATE(),
    NumeroErreur INT,
    MessageErreur NVARCHAR(4000),
    NomProcedure NVARCHAR(128),
    Ligne INT
);
```

---

## Les erreurs sont vos amies

Paradoxalement, dans cette section, les erreurs sont **bénéfiques** :
- Chaque erreur rencontrée est une **leçon**
- Chaque erreur capturée est une **victoire**
- Chaque erreur loggée est une **amélioration**

Ne craignez pas les erreurs, apprenez à les **maîtriser**.

---

## Un dernier mot avant de commencer

La gestion des erreurs est ce qui sépare les **scripts amateurs** des **applications professionnelles**. C'est la différence entre :
- Du code qui "marche" vs du code **fiable**
- Des bugs mystérieux vs des problèmes **diagnosticables**
- Des pannes catastrophiques vs des défaillances **gracieuses**
- Des utilisateurs frustrés vs des utilisateurs **informés**

Investir du temps dans la gestion des erreurs, c'est investir dans :
- La **qualité** de votre code
- La **confiance** de vos utilisateurs
- La **maintenabilité** de vos applications
- Votre **réputation** de développeur professionnel

---

## Prêt à commencer ?

Vous avez maintenant une vision claire de l'importance et de l'étendue de la gestion des erreurs. Il est temps de plonger dans le vif du sujet et d'apprendre à créer du code véritablement robuste.

Commençons par le fondement de tout système de gestion d'erreurs : les blocs **TRY ... CATCH** ! 🛡️

---


⏭️ [Blocs TRY ... CATCH](/05-programmabilite-en-tsql/03.1-blocs-try-catch.md)
