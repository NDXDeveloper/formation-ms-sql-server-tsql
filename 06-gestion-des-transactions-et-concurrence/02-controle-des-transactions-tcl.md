🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 6.2 Contrôle des Transactions (TCL) - Introduction

## Bienvenue dans le Contrôle des Transactions

Vous avez maintenant compris ce qu'est une transaction et pourquoi les propriétés ACID sont essentielles pour garantir la fiabilité de vos données. Il est temps de passer à la pratique et d'apprendre à **contrôler** vos transactions en T-SQL.

Dans cette section, nous allons découvrir le **TCL (Transaction Control Language)**, c'est-à-dire l'ensemble des commandes qui vous permettent de gérer explicitement vos transactions.

---

## Qu'est-ce que le TCL ?

Le **TCL (Transaction Control Language)** est l'un des sous-langages du SQL. Pour rappel, SQL est divisé en plusieurs catégories :

- **DDL** (Data Definition Language) : CREATE, ALTER, DROP
- **DML** (Data Manipulation Language) : SELECT, INSERT, UPDATE, DELETE
- **DCL** (Data Control Language) : GRANT, REVOKE, DENY
- **TCL** (Transaction Control Language) : **BEGIN TRANSACTION, COMMIT, ROLLBACK, SAVE TRANSACTION**

Le TCL regroupe toutes les commandes qui vous permettent de **contrôler le début, la fin, et le comportement** de vos transactions.

### Analogie : Les Commandes d'un Magnétoscope

Imaginez que votre transaction est comme un enregistrement vidéo :

```
┌─────────────────────────────────────────┐
│   TCL = Contrôles du Magnétoscope       │
├─────────────────────────────────────────┤
│                                         │
│  BEGIN TRANSACTION  →  ⏺️ REC           │
│  (Démarrer l'enregistrement)            │
│                                         │
│  COMMIT             →  ⏹️ STOP + SAVE   │
│  (Arrêter et sauvegarder)               │
│                                         │
│  ROLLBACK           →  ⏹️ STOP + DELETE │
│  (Arrêter et effacer)                   │
│                                         │
│  SAVE TRANSACTION   →  📌 BOOKMARK      │
│  (Marquer un point)                     │
│                                         │
└─────────────────────────────────────────┘
```

---

## Les Quatre Commandes Principales du TCL

### 1. BEGIN TRANSACTION - Démarrer une Transaction

**Rôle** : Marquer le **début** d'une transaction explicite.

```sql
BEGIN TRANSACTION;
-- À partir d'ici, tout fait partie de la transaction
```

**Analogie** : Ouvrir un document en mode "Brouillon" où vous pouvez travailler sans que les changements soient définitifs immédiatement.

### 2. COMMIT TRANSACTION - Valider une Transaction

**Rôle** : **Valider** toutes les modifications et les rendre **permanentes**.

```sql
COMMIT TRANSACTION;
-- Toutes les modifications sont enregistrées définitivement
```

**Analogie** : Cliquer sur "Enregistrer" pour sauvegarder définitivement votre document.

### 3. ROLLBACK TRANSACTION - Annuler une Transaction

**Rôle** : **Annuler** toutes les modifications et retourner à l'état initial.

```sql
ROLLBACK TRANSACTION;
-- Toutes les modifications sont annulées
```

**Analogie** : Cliquer sur "Annuler" ou fermer le document sans enregistrer, en perdant tous les changements.

### 4. SAVE TRANSACTION - Créer un Point de Sauvegarde

**Rôle** : Créer un **point de sauvegarde** à l'intérieur d'une transaction pour pouvoir revenir à ce point précis.

```sql
SAVE TRANSACTION nom_point;
-- Marquer un point de retour possible
```

**Analogie** : Créer un "checkpoint" dans un jeu vidéo, vous permettant de revenir à ce point sans recommencer depuis le début.

---

## Le Cycle de Vie d'une Transaction Contrôlée

Voici comment ces commandes s'articulent dans le cycle de vie d'une transaction :

```
┌─────────────────────────────────────────────────────┐
│           CYCLE COMPLET D'UNE TRANSACTION           │
└─────────────────────────────────────────────────────┘

📍 Point de départ : Aucune transaction active

         │
         ▼
    ┌─────────────────────┐
    │ BEGIN TRANSACTION   │  ──► Démarre la transaction
    └─────────────────────┘      @@TRANCOUNT = 1
         │                       🔒 Verrous posés
         │
         ▼
    ┌─────────────────────┐
    │  Opérations SQL     │
    │  (INSERT, UPDATE,   │  ──► Modifications temporaires
    │   DELETE, etc.)     │      en mémoire
    └─────────────────────┘
         │
         │
         ▼
   ┌──────────────┐
   │ Tout s'est   │
   │ bien passé ? │
   └──────┬───────┘
          │
    ┌─────┴────────┐
    │              │
 OUI│              │NON
    │              │
    ▼              ▼
┌────────┐     ┌────────┐
│ COMMIT │     │ROLLBACK│
└────────┘     └────────┘
    │              │
    ▼              ▼
 Valide         Annule
 ✅ Permanent    ⏪ Retour état initial
 💾 Sur disque   🗑️ Supprimé
 👁️ Visible      @@TRANCOUNT = 0
 @@TRANCOUNT=0

📍 Point final : Transaction terminée
```

---

## Pourquoi Avons-Nous Besoin du TCL ?

### Sans Contrôle des Transactions

Imaginons un transfert bancaire sans contrôle transactionnel :

```sql
-- ⚠️ DANGEREUX : Sans transaction explicite

-- Débiter le compte A
UPDATE Comptes SET Solde = Solde - 500 WHERE NumCompte = 'A123';

-- 💥 Si le serveur plante ici...

-- Créditer le compte B
UPDATE Comptes SET Solde = Solde + 500 WHERE NumCompte = 'B456';
```

**Problèmes potentiels :**
- Si une erreur survient entre les deux UPDATE → 500€ disparus
- Si le serveur crash → État incohérent
- Si la seconde ligne échoue → Première ligne déjà validée
- Aucun moyen d'annuler en bloc

### Avec Contrôle des Transactions

```sql
-- ✅ SÉCURISÉ : Avec transaction explicite

BEGIN TRANSACTION;

    -- Débiter le compte A
    UPDATE Comptes SET Solde = Solde - 500 WHERE NumCompte = 'A123';

    -- Créditer le compte B
    UPDATE Comptes SET Solde = Solde + 500 WHERE NumCompte = 'B456';

COMMIT; -- Les deux réussissent ensemble
-- ou
ROLLBACK; -- Les deux échouent ensemble
```

**Avantages :**
- ✅ Les deux opérations forment une unité
- ✅ En cas d'erreur, tout est annulé automatiquement
- ✅ En cas de crash, SQL Server annule automatiquement au redémarrage
- ✅ État toujours cohérent

---

## Les Situations Nécessitant le Contrôle des Transactions

### 1. Opérations Multiples Interdépendantes

Quand plusieurs opérations doivent **toutes** réussir ou **toutes** échouer :

```sql
BEGIN TRANSACTION;
    -- Créer la commande
    INSERT INTO Commandes (ClientID, Date) VALUES (123, GETDATE());

    -- Ajouter les articles
    INSERT INTO LignesCommande (CommandeID, Produit) VALUES (@ID, 'Laptop');

    -- Mettre à jour le stock
    UPDATE Produits SET Stock = Stock - 1 WHERE Nom = 'Laptop';
COMMIT;
```

### 2. Validations Métier Complexes

Quand vous devez vérifier des conditions avant de valider :

```sql
BEGIN TRANSACTION;
    UPDATE Stock SET Quantite = Quantite - 10 WHERE ProduitID = 123;

    -- Vérifier si le stock n'est pas négatif
    IF (SELECT Quantite FROM Stock WHERE ProduitID = 123) < 0
    BEGIN
        ROLLBACK; -- Annuler si stock insuffisant
    END
    ELSE
    BEGIN
        COMMIT; -- Valider si OK
    END
```

### 3. Gestion d'Erreurs

Quand vous voulez gérer proprement les erreurs :

```sql
BEGIN TRANSACTION;
BEGIN TRY
    -- Opérations risquées
    INSERT INTO ...
    UPDATE ...
    DELETE ...

    COMMIT; -- Tout s'est bien passé
END TRY
BEGIN CATCH
    ROLLBACK; -- Une erreur s'est produite, tout annuler
    PRINT ERROR_MESSAGE();
END CATCH;
```

### 4. Opérations Critiques

Quand vous manipulez des données sensibles où l'intégrité est cruciale :

```sql
BEGIN TRANSACTION;
    -- Opérations financières, médicales, légales...
    -- qui nécessitent une cohérence absolue
COMMIT;
```

---

## TCL et les Propriétés ACID

Les commandes TCL sont directement liées aux propriétés ACID que nous avons vues précédemment :

### Atomicité (A)

**BEGIN TRANSACTION** et **COMMIT**/**ROLLBACK** garantissent que toutes les opérations réussissent ou échouent ensemble.

```sql
BEGIN TRANSACTION;        -- Début de l'unité atomique
    Operation 1
    Operation 2
    Operation 3
COMMIT/ROLLBACK;         -- Fin de l'unité atomique
```

### Cohérence (C)

Les transactions permettent de vérifier les règles métier avant de **COMMIT** :

```sql
BEGIN TRANSACTION;
    -- Opérations...
    IF [règle métier violée]
        ROLLBACK;
    ELSE
        COMMIT;
```

### Isolation (I)

Les transactions contrôlées isolent vos modifications des autres utilisateurs jusqu'au **COMMIT** :

```sql
BEGIN TRANSACTION;
    UPDATE ... -- 🔒 Verrous posés, autres utilisateurs isolés
    -- Modifications visibles uniquement pour cette transaction
COMMIT;        -- ✅ Modifications maintenant visibles à tous
```

### Durabilité (D)

**COMMIT** garantit que les modifications sont écrites sur disque de manière permanente :

```sql
COMMIT; -- 💾 Écriture garantie sur disque, survit aux pannes
```

---

## Ce que Vous Allez Apprendre

Dans les sections suivantes de ce chapitre, nous allons explorer en détail chacune des commandes TCL :

### Section 6.2.1 : BEGIN TRANSACTION
Vous apprendrez à :
- Démarrer une transaction explicite
- Comprendre les différentes syntaxes
- Nommer vos transactions pour faciliter le débogage
- Utiliser @@TRANCOUNT pour vérifier l'état

### Section 6.2.2 : COMMIT TRANSACTION
Vous apprendrez à :
- Valider vos transactions
- Comprendre ce qui se passe lors d'un COMMIT
- Identifier le bon moment pour valider
- Gérer les transactions imbriquées

### Section 6.2.3 : ROLLBACK TRANSACTION
Vous apprendrez à :
- Annuler vos transactions
- Gérer les erreurs proprement
- Différencier ROLLBACK complet vs partiel
- Restaurer l'état initial de la base

### Section 6.2.4 : SAVE TRANSACTION
Vous apprendrez à :
- Créer des points de sauvegarde
- Faire des ROLLBACK partiels
- Gérer des transactions complexes avec plusieurs étapes
- Utiliser les savepoints efficacement

### Section 6.2.5 : Transactions Implicites vs Explicites
Vous apprendrez à :
- Comprendre les différents modes transactionnels
- Choisir entre auto-commit et transactions explicites
- Connaître les avantages et inconvénients de chaque mode
- Éviter les pièges courants

---

## Le Pattern de Base

Avant de plonger dans les détails, voici le **pattern de base** que vous utiliserez dans la majorité des cas :

```sql
-- Pattern standard d'une transaction
BEGIN TRANSACTION;

BEGIN TRY
    -- ========================================
    -- VOS OPÉRATIONS SQL ICI
    -- ========================================

    INSERT INTO ...;
    UPDATE ...;
    DELETE ...;

    -- ========================================
    -- SI TOUT EST OK : COMMIT
    -- ========================================

    COMMIT;
    PRINT '✓ Transaction validée';

END TRY
BEGIN CATCH
    -- ========================================
    -- EN CAS D'ERREUR : ROLLBACK
    -- ========================================

    IF @@TRANCOUNT > 0
        ROLLBACK;

    PRINT '✗ Erreur : Transaction annulée';
    PRINT ERROR_MESSAGE();

    -- Optionnel : Relancer l'erreur
    -- THROW;

END CATCH;
```

**Ce pattern garantit :**
- ✅ Démarrage explicite avec BEGIN TRANSACTION
- ✅ Validation automatique en cas de succès
- ✅ Annulation automatique en cas d'erreur
- ✅ Gestion propre des erreurs
- ✅ Logging pour le débogage

---

## Principes Fondamentaux à Retenir

Avant de commencer les sections détaillées, gardez en tête ces principes :

### 1. Toute Transaction Doit se Terminer

```sql
BEGIN TRANSACTION;
    -- Opérations...
-- ⚠️ Il FAUT terminer avec COMMIT ou ROLLBACK
```

**Règle d'or** : Chaque BEGIN TRANSACTION doit avoir un COMMIT ou un ROLLBACK correspondant.

### 2. Les Transactions Courtes sont Meilleures

```sql
-- ✓ BON : Transaction courte
BEGIN TRANSACTION;
    UPDATE MaTable SET Col = 'Valeur';
COMMIT;

-- ✗ MAUVAIS : Transaction trop longue
BEGIN TRANSACTION;
    UPDATE MaTable SET Col = 'Valeur';
    WAITFOR DELAY '00:05:00'; -- Attend 5 minutes !
COMMIT;
```

Plus une transaction est longue, plus elle bloque les autres utilisateurs.

### 3. Utilisez TRY...CATCH Systématiquement

```sql
-- ✓ BON : Gestion d'erreur
BEGIN TRANSACTION;
BEGIN TRY
    -- Opérations...
    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
END CATCH;

-- ✗ MAUVAIS : Pas de gestion d'erreur
BEGIN TRANSACTION;
    -- Opérations...
COMMIT; -- Et si une erreur survient ?
```

TRY...CATCH garantit le ROLLBACK automatique en cas d'erreur.

### 4. Surveillez @@TRANCOUNT

```sql
-- Avant toute opération critique
IF @@TRANCOUNT = 0
    PRINT 'Aucune transaction active';
ELSE
    PRINT 'Transaction(s) active(s) : ' + CAST(@@TRANCOUNT AS VARCHAR);
```

@@TRANCOUNT vous indique combien de transactions sont actives.

### 5. Documentez Vos Transactions

```sql
-- Transaction nécessaire car :
-- - La commande et les lignes doivent être créées ensemble
-- - Le stock doit être cohérent avec la commande
-- - En cas d'erreur, rien ne doit être enregistré
BEGIN TRANSACTION;
    -- Code...
COMMIT;
```

Des commentaires clairs aident à comprendre **pourquoi** une transaction est nécessaire.

---

## Comparaison : Avec et Sans TCL

### Sans TCL (Risqué)

```sql
-- Chaque instruction est une transaction séparée
INSERT INTO Commandes (ClientID, Date) VALUES (123, GETDATE());
-- ✅ Validée automatiquement

-- Si cette ligne échoue, l'INSERT précédent reste !
INSERT INTO LignesCommande (CommandeID, Produit) VALUES (@ID, 'Laptop');
-- ❌ Échec

-- Résultat : Commande sans lignes → Incohérent
```

### Avec TCL (Sécurisé)

```sql
BEGIN TRANSACTION;

    INSERT INTO Commandes (ClientID, Date) VALUES (123, GETDATE());
    INSERT INTO LignesCommande (CommandeID, Produit) VALUES (@ID, 'Laptop');

    -- Si une ligne échoue, TOUTES sont annulées

COMMIT;

-- Résultat : Soit commande complète, soit rien → Cohérent
```

---

## Visualisation : Le Contrôle que Vous Obtenez

```
SANS TCL (Auto-commit) :
────────────────────────────────────────
Instruction 1 → [Exec → ✅ ou ❌] → Permanent
Instruction 2 → [Exec → ✅ ou ❌] → Permanent
Instruction 3 → [Exec → ✅ ou ❌] → Permanent

❌ Pas de contrôle entre les instructions
❌ Pas de ROLLBACK global possible


AVEC TCL (Transaction explicite) :
────────────────────────────────────────
BEGIN TRANSACTION ──────┐
                        │
Instruction 1 ──────────┤
Instruction 2 ──────────┼─► Toutes temporaires
Instruction 3 ──────────┤
                        │
Décision ? ─────────────┘
    │
    ├─► ✅ Tout OK ? → COMMIT → Tout permanent
    │
    └─► ❌ Erreur ? → ROLLBACK → Tout annulé

✅ Contrôle total
✅ ROLLBACK global possible
✅ Atomicité garantie
```

---

## Erreurs à Éviter Dès le Début

### ❌ Oublier de Terminer une Transaction

```sql
BEGIN TRANSACTION;
    UPDATE MaTable SET Col = 'Valeur';
-- ⚠️ Pas de COMMIT ni ROLLBACK
-- Transaction reste ouverte → Problèmes de performance
```

### ❌ COMMIT sans BEGIN TRANSACTION

```sql
-- Aucune transaction active
UPDATE MaTable SET Col = 'Valeur';
COMMIT; -- ⚠️ Inutile mais pas d'erreur
```

### ❌ Transactions Trop Longues

```sql
BEGIN TRANSACTION;
    -- Traitement de 3 heures...
    -- 🔒 Bloque tous les autres utilisateurs pendant 3 heures !
COMMIT;
```

### ❌ Ignorer les Erreurs

```sql
BEGIN TRANSACTION;
    UPDATE Table1 ...;
    UPDATE Table2 ...; -- ❌ Échoue
    -- Mais le script continue !
COMMIT; -- ⚠️ Valide même avec l'erreur
```

**Solution** : Toujours utiliser TRY...CATCH

---

## Prêt à Commencer ?

Vous avez maintenant une vue d'ensemble du TCL et de son importance. Les commandes de contrôle des transactions sont vos outils pour garantir l'intégrité et la cohérence de vos données.

**Dans les sections suivantes**, nous explorerons chaque commande en détail :
- Comment les utiliser correctement
- Quand les utiliser
- Les pièges à éviter
- Les bonnes pratiques

Chaque section contiendra de nombreux exemples pratiques et concrets pour vous aider à maîtriser le contrôle des transactions.

**N'oubliez pas** : Le contrôle des transactions n'est pas optionnel dans une application professionnelle. C'est une compétence fondamentale que tout développeur de bases de données doit maîtriser.

---

## Points Clés de cette Introduction

### ✅ TCL = Transaction Control Language

Les commandes pour contrôler le début, la fin, et le comportement des transactions.

### ✅ Quatre commandes principales

BEGIN TRANSACTION, COMMIT, ROLLBACK, SAVE TRANSACTION.

### ✅ Le pattern de base

BEGIN TRANSACTION + TRY...CATCH + COMMIT/ROLLBACK est votre structure standard.

### ✅ Toute transaction doit se terminer

Chaque BEGIN TRANSACTION doit avoir un COMMIT ou ROLLBACK correspondant.

### ✅ Les transactions protègent l'intégrité

Elles garantissent que les opérations liées réussissent ou échouent ensemble.

### ✅ Gardez les transactions courtes

Plus elles sont courtes, moins elles bloquent les autres utilisateurs.

### ✅ TRY...CATCH est essentiel

Pour gérer proprement les erreurs et garantir le ROLLBACK automatique.

### ✅ Documentez vos transactions

Expliquez pourquoi une transaction est nécessaire.

---

## Allons-y ! 🚀

Vous êtes maintenant prêt à plonger dans les détails de chaque commande TCL. Commençons par la première et la plus importante : **BEGIN TRANSACTION**.

---


⏭️ [BEGIN TRANSACTION](/06-gestion-des-transactions-et-concurrence/02.1-begin-transaction.md)
