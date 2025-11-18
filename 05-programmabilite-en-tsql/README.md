🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 5. Programmabilité en T-SQL

## Introduction générale

Bienvenue dans la **section la plus transformative** de ce cours ! Jusqu'à présent, vous avez appris à interroger des données avec SELECT, à les modifier avec INSERT/UPDATE/DELETE, et à structurer vos bases de données. Vous avez utilisé T-SQL comme un **outil de requêtage**.

Maintenant, vous allez franchir une étape décisive : transformer T-SQL d'un simple langage de requêtes en un **véritable langage de programmation**. Vous allez apprendre à créer des **programmes**, pas seulement des requêtes.

Cette section couvre la **programmabilité** : l'ensemble des fonctionnalités qui permettent de :
- **Stocker de la logique** dans la base de données
- **Automatiser des tâches** répétitives
- **Réutiliser du code** à travers des procédures et fonctions
- **Encapsuler la complexité** pour simplifier l'utilisation
- **Protéger les données** avec une logique métier centralisée
- **Réagir automatiquement** aux modifications de données

C'est le passage du statut de **"manipulateur de données"** à celui de **"développeur de base de données"**.

---

## Le grand tournant : De l'utilisateur au programmeur

### Avant : T-SQL comme outil de requêtage

```sql
-- Requête simple
SELECT * FROM Employes WHERE Departement = 'IT';

-- Modification simple
UPDATE Employes SET Salaire = Salaire * 1.10 WHERE Departement = 'IT';

-- Vous êtes limité à des opérations simples et répétitives
```

**Limitations :**
- Chaque opération doit être tapée manuellement
- Pas de réutilisation du code
- Pas de logique conditionnelle complexe
- Pas d'automatisation
- Pas de validation centralisée

### Après : T-SQL comme langage de programmation

```sql
-- Procédure stockée réutilisable
CREATE PROCEDURE AugmenterSalaires
    @Departement VARCHAR(50),
    @Pourcentage DECIMAL(5,2)
AS
BEGIN
    BEGIN TRY
        -- Validation
        IF @Pourcentage < 0 OR @Pourcentage > 50
            THROW 50001, 'Pourcentage invalide (0-50%)', 1;

        IF NOT EXISTS (SELECT 1 FROM Departements WHERE Nom = @Departement)
            THROW 50002, 'Département introuvable', 1;

        -- Transaction protégée
        BEGIN TRANSACTION;

        UPDATE Employes
        SET Salaire = Salaire * (1 + @Pourcentage / 100)
        WHERE Departement = @Departement;

        -- Logging automatique
        INSERT INTO HistoriqueAugmentations (Departement, Pourcentage, Date)
        VALUES (@Departement, @Pourcentage, GETDATE());

        COMMIT TRANSACTION;

        PRINT 'Augmentation appliquée : ' + CAST(@@ROWCOUNT AS VARCHAR) + ' employés';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Utilisation simple et sûre
EXEC AugmenterSalaires @Departement = 'IT', @Pourcentage = 10;
```

**Avantages :**
- Code réutilisable et centralisé
- Validation et gestion d'erreurs intégrées
- Transaction automatique
- Logging automatique
- Sécurité et contrôle d'accès
- Maintenance simplifiée

---

## Qu'est-ce que la programmabilité ?

### Définition

La **programmabilité** désigne l'ensemble des fonctionnalités qui permettent d'écrire de la **logique applicative** directement dans la base de données, plutôt que uniquement dans l'application cliente.

### Les huit piliers de la programmabilité T-SQL

Cette section massive couvre huit domaines fondamentaux :

```
┌──────────────────────────────────────────────────────────────────┐
│                    PROGRAMMABILITÉ T-SQL                         │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. VARIABLES & BATCHES                                          │
│     Stocker des valeurs, organiser le code                       │
│                                                                  │
│  2. STRUCTURES DE CONTRÔLE                                       │
│     Prendre des décisions (IF), répéter (WHILE), transformer     │
│                                                                  │
│  3. GESTION DES ERREURS                                          │
│     Capturer, analyser, gérer les problèmes                      │
│                                                                  │
│  4. VUES (VIEWS)                                                 │
│     Simplifier les requêtes complexes, abstraction des données   │
│                                                                  │
│  5. PROCÉDURES STOCKÉES                                          │
│     Programmes réutilisables, logique métier centralisée         │
│                                                                  │
│  6. FONCTIONS UTILISATEUR                                        │
│     Calculs personnalisés, transformations réutilisables         │
│                                                                  │
│  7. TRIGGERS (DÉCLENCHEURS)                                      │
│     Réactions automatiques aux modifications de données          │
│                                                                  │
│  8. SQL DYNAMIQUE                                                │
│     Génération et exécution de code à la volée                   │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Vue d'ensemble des huit piliers

### 5.1 Variables et Lots (Batches)

**Le fondement de tout le reste.**

Vous apprendrez à :
- Déclarer et utiliser des variables pour stocker des valeurs temporaires
- Comprendre la différence entre variables locales (@) et globales (@@)
- Organiser votre code en batches avec le séparateur GO
- Gérer la portée des variables

**Analogie :** Les variables sont comme des **boîtes étiquetées** où vous rangez temporairement des informations.

**Exemple :**
```sql
DECLARE @Salaire DECIMAL(10,2) = 3500;
DECLARE @Prime DECIMAL(10,2) = @Salaire * 0.15;
PRINT 'Prime : ' + CAST(@Prime AS VARCHAR);
```

**Durée estimée :** 1-2 heures

---

### 5.2 Structures de contrôle

**Donner de l'intelligence à votre code.**

Vous apprendrez à :
- Grouper des instructions avec BEGIN ... END
- Prendre des décisions avec IF ... ELSE
- Répéter des actions avec WHILE (et BREAK, CONTINUE)
- Transformer des valeurs avec CASE

**Analogie :** Les structures de contrôle sont comme les **aiguillages** et **boucles** d'un circuit de train qui dirigent le flux.

**Exemple :**
```sql
IF @Salaire < 2000
    PRINT 'Salaire bas';
ELSE IF @Salaire < 4000
    PRINT 'Salaire moyen';
ELSE
    PRINT 'Salaire élevé';
```

**Durée estimée :** 3-4 heures

---

### 5.3 Gestion des erreurs

**Rendre votre code robuste et fiable.**

Vous apprendrez à :
- Capturer les erreurs avec TRY ... CATCH
- Analyser les erreurs avec les fonctions ERROR_*
- Générer vos propres erreurs avec THROW et RAISERROR
- Logger les erreurs pour diagnostic

**Analogie :** La gestion d'erreurs est votre **filet de sécurité** et votre **système d'alarme**.

**Exemple :**
```sql
BEGIN TRY
    UPDATE Comptes SET Solde = Solde - 1000 WHERE CompteID = @ID;
END TRY
BEGIN CATCH
    PRINT 'Erreur : ' + ERROR_MESSAGE();
    ROLLBACK TRANSACTION;
END CATCH
```

**Durée estimée :** 2-3 heures

---

### 5.4 Vues (Views)

**Simplifier et sécuriser l'accès aux données.**

Vous apprendrez à :
- Créer des vues pour encapsuler des requêtes complexes
- Utiliser les vues pour la sécurité (masquer certaines colonnes)
- Comprendre les limitations des vues
- Découvrir les vues indexées pour la performance

**Analogie :** Une vue est comme une **fenêtre** qui montre une perspective spécifique sur vos données.

**Exemple :**
```sql
CREATE VIEW vw_EmployesActifs AS
SELECT EmployeID, Nom, Prenom, Departement
FROM Employes
WHERE EstActif = 1;

-- Utilisation simple
SELECT * FROM vw_EmployesActifs;
```

**Durée estimée :** 1-2 heures

---

### 5.5 Procédures stockées

**Le cœur de la programmabilité.**

Vous apprendrez à :
- Créer des procédures réutilisables
- Utiliser des paramètres d'entrée et de sortie
- Retourner des valeurs et des codes de statut
- Gérer la sécurité et les permissions
- Optimiser les performances

**Analogie :** Une procédure stockée est comme une **recette de cuisine** : des instructions réutilisables avec des ingrédients (paramètres).

**Exemple :**
```sql
CREATE PROCEDURE ObtenirEmploye
    @EmployeID INT,
    @NomComplet VARCHAR(100) OUTPUT
AS
BEGIN
    SELECT @NomComplet = Prenom + ' ' + Nom
    FROM Employes
    WHERE EmployeID = @EmployeID;
END
```

**Durée estimée :** 3-4 heures

---

### 5.6 Fonctions utilisateur

**Créer vos propres calculs personnalisés.**

Vous apprendrez à :
- Créer des fonctions scalaires (retournent une valeur)
- Créer des fonctions table (retournent des lignes)
- Comprendre les différences avec les procédures stockées
- Connaître les limitations de performance

**Analogie :** Une fonction est comme une **calculatrice personnalisée** que vous pouvez réutiliser partout.

**Exemple :**
```sql
CREATE FUNCTION dbo.CalculerTVA
    (@MontantHT DECIMAL(10,2), @TauxTVA DECIMAL(5,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @MontantHT * (@TauxTVA / 100);
END

-- Utilisation
SELECT Prix, dbo.CalculerTVA(Prix, 20) AS TVA FROM Produits;
```

**Durée estimée :** 2-3 heures

---

### 5.7 Triggers (Déclencheurs)

**Automatiser les réactions aux modifications.**

Vous apprendrez à :
- Créer des triggers DML (AFTER, INSTEAD OF)
- Utiliser les tables INSERTED et DELETED
- Implémenter l'audit automatique
- Comprendre quand NE PAS utiliser les triggers
- Gérer les triggers DDL

**Analogie :** Un trigger est comme un **gardien** qui surveille et réagit automatiquement aux changements.

**Exemple :**
```sql
CREATE TRIGGER trg_AuditEmployes
ON Employes
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditLog (Table, Action, Date)
    SELECT 'Employes', 'UPDATE', GETDATE()
    FROM INSERTED;
END
```

**Durée estimée :** 2-3 heures

---

### 5.8 SQL dynamique

**Générer et exécuter du code à la volée.**

Vous apprendrez à :
- Construire des requêtes dynamiquement
- Exécuter du SQL dynamique avec EXEC et sp_executesql
- Comprendre les risques d'injection SQL
- Sécuriser le SQL dynamique avec des paramètres

**Analogie :** Le SQL dynamique est comme un **robot** qui écrit et exécute du code selon vos instructions.

**Exemple :**
```sql
DECLARE @TableName VARCHAR(50) = 'Employes';
DECLARE @SQL NVARCHAR(MAX);

SET @SQL = 'SELECT * FROM ' + QUOTENAME(@TableName);
EXEC sp_executesql @SQL;
```

**Durée estimée :** 2-3 heures

---

## Progression recommandée

Cette section suit une progression **logique et pédagogique** :

```
5.1 Variables & Batches (FONDATIONS)
    ↓
    └─→ Nécessaire pour tout le reste

5.2 Structures de contrôle (LOGIQUE)
    ↓
    └─→ Utilise les variables, ajoute la logique

5.3 Gestion des erreurs (ROBUSTESSE)
    ↓
    └─→ Utilise les structures de contrôle, ajoute la fiabilité

5.4 Vues (SIMPLIFICATION)
    ↓
    └─→ Prépare pour les procédures et fonctions

5.5 Procédures stockées (PROGRAMMES)
    ↓
    └─→ Combine tout ce qui précède

5.6 Fonctions utilisateur (CALCULS)
    ↓
    └─→ Alternative aux procédures pour certains cas

5.7 Triggers (AUTOMATISATION)
    ↓
    └─→ Réactions automatiques avancées

5.8 SQL dynamique (FLEXIBILITÉ ULTIME)
    ↓
    └─→ Technique avancée pour cas spéciaux
```

**Recommandation forte :** Suivez cet ordre ! Chaque section s'appuie sur les précédentes.

---

## Pourquoi la programmabilité est-elle importante ?

### 1. Performance

**Avant (application → base de données) :**
```
Application                      Base de données
    ↓                                  ↓
1. SELECT tous les employés ─────→ Retourne 10,000 lignes
2. Filtrer en mémoire
3. Calculer en mémoire
4. Formater les résultats
    ↓
Lent, consomme beaucoup de bande passante
```

**Après (logique dans la base) :**
```
Application                      Base de données
    ↓                                  ↓
EXEC Procédure  ──────────────→  • Filtre (SQL)
                                  • Calcule (SQL)
                                  • Formate (SQL)
                              Retourne 10 lignes
Rapide, efficace
```

### 2. Sécurité

```sql
-- Sans procédure : l'application a accès direct aux tables
-- Risque : injection SQL, accès non contrôlé

-- Avec procédure : l'application appelle seulement la procédure
GRANT EXECUTE ON CreerCommande TO ApplicationUser;
DENY SELECT, INSERT, UPDATE, DELETE ON Commandes TO ApplicationUser;

-- L'application ne peut QUE appeler la procédure
-- Toute la logique de sécurité est centralisée
```

### 3. Maintenabilité

**Sans programmabilité :**
- Logique métier éparpillée dans 10 applications différentes
- Un changement = modifier 10 applications
- Risque d'incohérences

**Avec programmabilité :**
- Logique centralisée dans la base de données
- Un changement = modifier une procédure
- Cohérence garantie

### 4. Réutilisabilité

```sql
-- Créez une fois
CREATE PROCEDURE CalculerCommission @VenteID INT AS ...

-- Utilisez partout
EXEC CalculerCommission @VenteID = 123;  -- Application web
EXEC CalculerCommission @VenteID = 456;  -- Application mobile
EXEC CalculerCommission @VenteID = 789;  -- Rapport Excel
EXEC CalculerCommission @VenteID = 101;  -- Script batch
```

### 5. Intégrité des données

```sql
-- Trigger qui garantit automatiquement la cohérence
CREATE TRIGGER trg_StockCheck
ON Commandes
AFTER INSERT
AS
BEGIN
    -- Si stock insuffisant, annuler
    IF EXISTS (
        SELECT 1 FROM INSERTED i
        JOIN Produits p ON i.ProduitID = p.ProduitID
        WHERE p.Stock < i.Quantite
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, 'Stock insuffisant', 1;
    END
END
```

---

## Le changement de mentalité

### Avant : Mentalité "requête"

- "Comment récupérer ces données ?"
- "Comment modifier cette valeur ?"
- Pensée ponctuelle, ad-hoc

### Après : Mentalité "programme"

- "Comment automatiser ce processus ?"
- "Comment rendre ce code réutilisable ?"
- "Comment gérer les erreurs ?"
- "Comment protéger l'intégrité des données ?"
- Pensée systémique, architecturale

---

## Exemples concrets de transformation

### Exemple 1 : Gestion de commandes

**Avant (script manuel) :**
```sql
-- À faire manuellement à chaque commande
BEGIN TRANSACTION;
INSERT INTO Commandes (ClientID, Date) VALUES (123, GETDATE());
DECLARE @CommandeID INT = SCOPE_IDENTITY();
INSERT INTO Details (CommandeID, ProduitID, Quantite) VALUES (@CommandeID, 5, 2);
UPDATE Produits SET Stock = Stock - 2 WHERE ProduitID = 5;
INSERT INTO Factures (CommandeID, Montant) VALUES (@CommandeID, 99.99);
COMMIT;
-- Pas de validation, pas de gestion d'erreurs, pas d'audit
```

**Après (procédure stockée) :**
```sql
EXEC CreerCommande
    @ClientID = 123,
    @ProduitID = 5,
    @Quantite = 2;

-- La procédure fait TOUT :
-- ✓ Validation des données
-- ✓ Vérification du stock
-- ✓ Transaction sécurisée
-- ✓ Gestion d'erreurs
-- ✓ Audit automatique
-- ✓ Calcul de facturation
-- ✓ Mise à jour du stock
-- ✓ Notification si besoin
```

### Exemple 2 : Rapports complexes

**Avant (requête monstrueuse) :**
```sql
SELECT
    e.Nom,
    d.NomDepartement,
    (SELECT AVG(Salaire) FROM Employes WHERE DepartementID = e.DepartementID) AS SalaireMoyen,
    -- ... 50 lignes de plus de requête complexe
FROM Employes e
JOIN Departements d ON e.DepartementID = d.DepartementID
-- ... jointures multiples, sous-requêtes partout
```

**Après (vue) :**
```sql
CREATE VIEW vw_RapportEmployes AS
-- Toute la complexité encapsulée
SELECT ... -- requête propre et optimisée

-- Utilisation simple
SELECT * FROM vw_RapportEmployes WHERE Departement = 'IT';
```

### Exemple 3 : Audit automatique

**Avant (manuel, souvent oublié) :**
```sql
UPDATE Employes SET Salaire = 4000 WHERE EmployeID = 123;
-- Oups, j'ai oublié de logger le changement !
```

**Après (trigger automatique) :**
```sql
UPDATE Employes SET Salaire = 4000 WHERE EmployeID = 123;
-- Le trigger s'exécute AUTOMATIQUEMENT et enregistre :
-- - Qui a fait la modification
-- - Quand
-- - Ancienne valeur
-- - Nouvelle valeur
-- Impossible d'oublier !
```

---

## Ce que vous saurez faire à la fin de cette section

### Niveau débutant → intermédiaire

- ✓ Écrire des scripts avec variables et logique conditionnelle
- ✓ Créer des vues pour simplifier les requêtes
- ✓ Gérer les erreurs proprement
- ✓ Créer des procédures stockées de base

### Niveau intermédiaire → avancé

- ✓ Créer des systèmes complets de gestion d'erreurs
- ✓ Développer des bibliothèques de fonctions réutilisables
- ✓ Implémenter l'audit automatique avec triggers
- ✓ Utiliser le SQL dynamique de manière sécurisée

### Niveau avancé → expert

- ✓ Architecturer des systèmes de base de données complexes
- ✓ Optimiser les performances avec des stratégies avancées
- ✓ Créer des frameworks réutilisables
- ✓ Écrire du code T-SQL de qualité production

---

## Prérequis pour cette section

Avant de commencer, vous devriez maîtriser :

✅ **Les bases du SQL :**
- SELECT, FROM, WHERE, JOIN
- INSERT, UPDATE, DELETE
- Agrégations (SUM, COUNT, AVG)
- GROUP BY, HAVING, ORDER BY

✅ **La structure des bases de données :**
- Tables, colonnes, types de données
- Clés primaires et étrangères
- Contraintes (UNIQUE, CHECK, etc.)

✅ **Concepts de base :**
- Transactions (BEGIN, COMMIT, ROLLBACK)
- Compréhension de ce qu'est une base de données relationnelle

Si ces concepts ne sont pas clairs, revoyez les sections 1-4 avant de continuer.

---

## Temps total estimé

Cette section est la **plus longue et la plus importante** du cours :

| Sous-section | Durée estimée |
|--------------|---------------|
| 5.1 Variables et Batches | 1-2 heures |
| 5.2 Structures de contrôle | 3-4 heures |
| 5.3 Gestion des erreurs | 2-3 heures |
| 5.4 Vues | 1-2 heures |
| 5.5 Procédures stockées | 3-4 heures |
| 5.6 Fonctions utilisateur | 2-3 heures |
| 5.7 Triggers | 2-3 heures |
| 5.8 SQL dynamique | 2-3 heures |
| **TOTAL** | **16-24 heures** |

**Recommandation :** Ne vous précipitez pas. Prenez le temps de :
- Lire attentivement
- Taper tous les exemples
- Expérimenter avec vos propres variantes
- Revenir sur les concepts difficiles

---

## Conseils pour réussir cette section

### 1. Créez un environnement de test dédié

```sql
-- Base de données pour vos expérimentations
CREATE DATABASE FormationTSQL;
USE FormationTSQL;

-- Tables de test
CREATE TABLE Employes (...);
CREATE TABLE Departements (...);
CREATE TABLE LogErreurs (...);
```

### 2. Expérimentez sans crainte

Cette section nécessite de **pratiquer activement** :
- Modifiez les exemples
- Cassez le code volontairement pour voir ce qui se passe
- Créez vos propres scénarios
- Testez les limites

### 3. Construisez progressivement

Ne sautez pas d'étapes :
- Maîtrisez les variables avant les structures de contrôle
- Maîtrisez les structures avant les procédures
- Chaque concept s'appuie sur le précédent

### 4. Documentez votre code

Prenez l'habitude de commenter :
```sql
-- Procédure : AugmenterSalaire
-- Objectif : Augmente le salaire d'un employé avec validation
-- Paramètres : @EmployeID (ID de l'employé), @Pourcentage (%)
-- Retour : 0 = succès, -1 = erreur
CREATE PROCEDURE AugmenterSalaire
    @EmployeID INT,
    @Pourcentage DECIMAL(5,2)
AS
BEGIN
    -- Code ici
END
```

### 5. Gardez une bibliothèque d'exemples

Créez un dossier avec vos scripts organisés :
```
/FormationTSQL
    /5.1_Variables
        - exemples_variables.sql
        - exercices_variables.sql
    /5.2_Structures
        - if_else.sql
        - while.sql
        - case.sql
    /5.3_Erreurs
        - try_catch.sql
        - exemples_logging.sql
    ...
```

---

## Les pièges courants à éviter

### Piège 1 : Vouloir tout comprendre d'un coup

**❌ Mauvaise approche :**
"Je vais lire toute la section 5 en une journée"

**✅ Bonne approche :**
"Je vais maîtriser une sous-section par jour"

### Piège 2 : Lire sans pratiquer

**❌ Mauvaise approche :**
Lire tous les exemples sans les taper

**✅ Bonne approche :**
Taper chaque exemple, l'exécuter, le modifier, comprendre

### Piège 3 : Négliger les bases

**❌ Mauvaise approche :**
Sauter 5.1 et 5.2 pour aller directement aux procédures stockées

**✅ Bonne approche :**
Suivre l'ordre, chaque section est fondamentale

### Piège 4 : Ne pas gérer les erreurs

**❌ Mauvaise approche :**
Écrire des procédures sans TRY...CATCH

**✅ Bonne approche :**
Toujours inclure la gestion d'erreurs dès le début

---

## Ce qui vous attend

### Difficulté croissante

```
5.1 Variables        ★☆☆☆☆ Facile
5.2 Structures       ★★☆☆☆ Facile-Moyen
5.3 Erreurs          ★★☆☆☆ Moyen
5.4 Vues             ★★☆☆☆ Moyen
5.5 Procédures       ★★★☆☆ Moyen-Avancé
5.6 Fonctions        ★★★☆☆ Moyen-Avancé
5.7 Triggers         ★★★★☆ Avancé
5.8 SQL Dynamique    ★★★★☆ Avancé
```

### Satisfaction croissante

Au fur et à mesure, vous allez :
- 📈 Voir votre code devenir plus professionnel
- 🎯 Résoudre des problèmes plus complexes
- 💡 Comprendre comment fonctionnent les applications professionnelles
- 🚀 Gagner en confiance et en autonomie
- ⭐ Créer des solutions dont vous serez fier

---

## Un dernier mot avant de commencer

La section 5 est le **cœur de ce cours**. C'est ici que vous allez vraiment devenir un **développeur de base de données**. Les concepts que vous allez apprendre sont utilisés **tous les jours** par les professionnels du monde entier.

Cette transformation ne se fera pas en un jour. Cela demande :
- Du **temps** : 16-24 heures de travail concentré
- De la **pratique** : Taper, expérimenter, tester
- De la **patience** : Certains concepts sont nouveaux et complexes
- De la **persévérance** : Continuez même si c'est difficile

Mais le résultat en vaut largement la peine. À la fin de cette section, vous aurez les compétences pour :
- Créer des applications de base de données complètes
- Écrire du code robuste et maintenable
- Automatiser des processus complexes
- Protéger et valider vos données
- Optimiser les performances
- Travailler comme un professionnel

**Vous êtes prêt pour ce voyage ?**

---

## Prêt à commencer ?

La programmabilité en T-SQL est un univers fascinant qui va complètement changer votre relation avec les bases de données. De simple utilisateur de données, vous allez devenir **architecte de systèmes**.

C'est un long chemin, mais chaque étape vous rapprochera de la maîtrise.

Commençons par les fondations : les **variables et batches** ! 🚀

---


⏭️ [Variables et Lots (Batches)](/05-programmabilite-en-tsql/01-variables-et-lots-batches.md)
