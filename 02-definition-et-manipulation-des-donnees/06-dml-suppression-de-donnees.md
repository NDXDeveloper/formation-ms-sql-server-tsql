🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 2.6 DML : Suppression de données

## Introduction

La suppression de données est la dernière opération fondamentale du DML (Data Manipulation Language) que nous allons étudier. Après avoir appris à créer des structures (DDL), à insérer des données (INSERT), et à les modifier (UPDATE), nous abordons maintenant l'opération la plus **irréversible** et potentiellement la plus **dangereuse** : la suppression.

Dans le cycle de vie d'une donnée, la suppression est souvent l'étape finale. Un client ferme son compte, un produit est retiré du catalogue, des logs anciens doivent être purgés pour libérer de l'espace... La capacité à supprimer des données de manière sûre et efficace est essentielle pour tout développeur SQL.

Cette section est **cruciale** car une erreur de suppression peut avoir des conséquences catastrophiques et souvent irréversibles. Contrairement à UPDATE qui écrase les données, DELETE les fait complètement disparaître.

---

## Qu'est-ce que la suppression de données ?

### Définition

La **suppression de données** consiste à retirer définitivement des lignes d'une table. Ces lignes disparaissent complètement de la base de données et ne peuvent être récupérées que depuis une sauvegarde.

**Analogie du carnet d'adresses :**

Pour rappel de nos opérations :
- **INSERT** = Ajouter un nouveau contact sur une page vierge
- **UPDATE** = Corriger le téléphone d'un contact existant avec une gomme
- **DELETE** = Arracher complètement la page du carnet

### Ce qui est supprimé

Lorsque vous supprimez une ligne, vous supprimez :
- ✅ Toutes les valeurs de toutes les colonnes de cette ligne
- ✅ La ligne entière (pas seulement certaines colonnes)
- ✅ Définitivement (sauf ROLLBACK ou restauration)

**Important :** DELETE supprime des **lignes complètes**, pas des colonnes individuelles.

```sql
-- État initial
ClientID | Nom           | Email                | Telephone
---------|---------------|----------------------|-------------
1        | Marie Dupont  | marie.d@email.fr     | 0612345678
2        | Pierre Martin | pierre.m@email.com   | 0623456789
3        | Julie Leroux  | julie.l@email.fr     | 0634567890

-- DELETE supprime la ligne entière
DELETE FROM Clients WHERE ClientID = 2;

-- Résultat : Pierre Martin a complètement disparu
ClientID | Nom           | Email                | Telephone
---------|---------------|----------------------|-------------
1        | Marie Dupont  | marie.d@email.fr     | 0612345678
3        | Julie Leroux  | julie.l@email.fr     | 0634567890
```

---

## Pourquoi supprimer des données ?

### Cas d'usage légitimes

La suppression de données est nécessaire dans de nombreux scénarios :

#### 1. Respect de la vie privée et du RGPD

```sql
-- Supprimer les données d'un utilisateur qui demande l'effacement
DELETE FROM Utilisateurs WHERE UtilisateurID = 12345;
DELETE FROM HistoriqueNavigations WHERE UtilisateurID = 12345;
DELETE FROM Preferences WHERE UtilisateurID = 12345;
```

**Contexte :** Le droit à l'oubli impose de pouvoir supprimer les données personnelles.

#### 2. Nettoyage de données obsolètes

```sql
-- Supprimer les logs de plus de 90 jours
DELETE FROM LogsSysteme
WHERE DateLog < DATEADD(DAY, -90, GETDATE());

-- Supprimer les sessions expirées
DELETE FROM Sessions
WHERE DateExpiration < GETDATE();
```

**Contexte :** Libérer de l'espace disque et améliorer les performances.

#### 3. Suppression de données de test

```sql
-- Nettoyer les données de test en production
DELETE FROM Commandes WHERE NumeroCommande LIKE 'TEST%';
DELETE FROM Clients WHERE Email LIKE '%@test.com';
```

**Contexte :** Après migration ou tests, nettoyer les données factices.

#### 4. Correction d'erreurs

```sql
-- Supprimer les doublons créés par erreur
DELETE FROM Produits
WHERE ProduitID IN (
    SELECT ProduitID FROM Produits
    GROUP BY CodeProduit
    HAVING COUNT(*) > 1
);
```

**Contexte :** Corriger des erreurs d'import ou de duplication.

#### 5. Désactivation ou fermeture

```sql
-- Supprimer un compte client fermé
DELETE FROM ComptesUtilisateurs WHERE Statut = N'Fermé' AND DateFermeture < '2023-01-01';
```

**Contexte :** Supprimer définitivement les comptes fermés après une période de rétention.

#### 6. Gestion de la performance

```sql
-- Purger les anciennes transactions pour accélérer les requêtes
DELETE FROM Transactions
WHERE DateTransaction < DATEADD(YEAR, -5, GETDATE())
  AND Statut = N'Archivée';
```

**Contexte :** Maintenir une table performante en déplaçant les vieilles données vers un archivage.

---

## Les deux commandes de suppression

SQL Server propose **deux commandes principales** pour supprimer des données :

### 1. DELETE : Suppression sélective

```sql
DELETE FROM nom_table
WHERE condition;
```

**Caractéristiques :**
- ✅ Peut avoir une clause WHERE (suppression ciblée)
- ✅ Fonctionne avec les contraintes de clé étrangère
- ✅ Déclenche les triggers
- ⚠️ Plus lent sur de grosses tables
- ⚠️ Enregistre chaque ligne dans le log

**Usage typique :** Suppression sélective de certaines lignes.

### 2. TRUNCATE : Vidage complet

```sql
TRUNCATE TABLE nom_table;
```

**Caractéristiques :**
- ❌ Pas de clause WHERE possible
- ✅ Très rapide, même sur grosses tables
- ✅ Réinitialise les compteurs IDENTITY
- ⚠️ Ne fonctionne pas si la table est **référencée** par une clé étrangère (table parent)
- ⚠️ Ne déclenche pas les triggers

**Usage typique :** Vider complètement une table (cache, temporaire).

### Comparaison rapide

| Aspect | DELETE | TRUNCATE |
|--------|--------|----------|
| **Clause WHERE** | ✅ Oui | ❌ Non |
| **Vitesse** | Lent | Très rapide |
| **Contraintes FK** | ✅ Compatible | ❌ Bloqué si référencée |
| **Triggers** | ✅ Exécutés | ❌ Ignorés |
| **IDENTITY** | Conservé | Réinitialisé |

**Nous verrons ces différences en détail dans la section 2.6.2.**

---

## Les dangers de la suppression : Avertissement critique

⚠️ **LA SUPPRESSION EST L'OPÉRATION LA PLUS DANGEREUSE EN SQL** ⚠️

### Pourquoi DELETE/TRUNCATE sont dangereux ?

#### 1. Irréversibilité

```sql
-- Une fois committé, c'est PERMANENT
DELETE FROM Clients;
COMMIT;
-- Les clients sont PERDUS définitivement (sauf sauvegarde)
```

**Contrairement à UPDATE :** On ne peut pas récupérer les anciennes valeurs sans sauvegarde.

#### 2. Risque de suppression massive

```sql
-- ❌ CATASTROPHE : Oubli du WHERE
DELETE FROM Commandes;
-- 1 million de commandes supprimées en une seule erreur !
```

**Impact :** Une simple omission de WHERE peut détruire toutes vos données.

#### 3. Effet domino avec les dépendances

```sql
-- Supprimer un client peut affecter plusieurs tables
DELETE FROM Clients WHERE ClientID = 1;
-- Impact :
-- - Commandes orphelines ?
-- - Factures sans client ?
-- - Historique perdu ?
```

**Complexité :** Les données sont souvent liées entre plusieurs tables.

#### 4. Impossible à annuler après COMMIT

```sql
BEGIN TRANSACTION;
    DELETE FROM Produits;
    COMMIT;  -- ← Une fois ici, TROP TARD !

-- Impossible de faire ROLLBACK maintenant
-- Les données sont perdues
```

**Permanent :** Contrairement à UPDATE, on ne peut pas reconstruire les données supprimées.

---

## Témoignages de catastrophes réelles

### Catastrophe 1 : La startup qui a perdu tous ses clients

> "Un stagiaire devait supprimer un client de test. Il a tapé `DELETE FROM Clients;` et a oublié le WHERE. 15 000 clients supprimés. L'entreprise n'avait pas de sauvegarde récente. Perte de 80% de la base client. L'entreprise a fermé 6 mois plus tard."

**Leçon :** Toujours avoir des sauvegardes et TOUJOURS tester avec SELECT.

### Catastrophe 2 : La banque et les transactions

> "Un développeur devait supprimer les transactions de test en préproduction. Il s'est trompé de serveur et a exécuté le script en production. 2 millions de transactions bancaires supprimées. Restauration depuis sauvegarde : 18 heures d'arrêt. Perte estimée : 5 millions d'euros."

**Leçon :** Toujours vérifier sur quel serveur vous êtes connecté.

### Catastrophe 3 : Le e-commerce et les commandes

> "Un script automatique de nettoyage avait un bug. Au lieu de supprimer les commandes annulées de plus de 2 ans, il a supprimé TOUTES les commandes de plus de 2 ans. Perte de l'historique complet. Impact sur la comptabilité, les statistiques, la relation client."

**Leçon :** Tester TOUS les scripts automatiques en développement d'abord.

---

## Les règles d'or de la suppression

Pour supprimer des données en toute sécurité, suivez **impérativement** ces règles :

### 1. TOUJOURS tester avec SELECT d'abord

```sql
-- ✅ PROCESSUS SÉCURISÉ

-- Étape 1 : Voir ce qui sera supprimé
SELECT * FROM Clients
WHERE EstActif = 0 AND DerniereConnexion < '2023-01-01';

-- Étape 2 : Compter
SELECT COUNT(*) FROM Clients
WHERE EstActif = 0 AND DerniereConnexion < '2023-01-01';
-- Résultat : 127 clients

-- Étape 3 : Remplacer SELECT par DELETE avec la MÊME clause WHERE
DELETE FROM Clients
WHERE EstActif = 0 AND DerniereConnexion < '2023-01-01';
```

**Cette étape simple évite 95% des catastrophes !**

### 2. Utiliser des transactions

```sql
-- Démarrer une transaction
BEGIN TRANSACTION;

    -- Faire la suppression
    DELETE FROM Clients
    WHERE EstActif = 0;

    -- Vérifier le résultat
    SELECT @@ROWCOUNT AS LignesSupprimees;

    -- Vérifier qu'il reste bien des clients actifs
    SELECT COUNT(*) FROM Clients;

    -- Si tout est OK : valider
    COMMIT;

    -- Si problème : annuler
    -- ROLLBACK;
```

**Sécurité :** Tant que vous n'avez pas fait COMMIT, vous pouvez annuler.

### 3. Faire des sauvegardes avant suppression importante

```sql
-- Créer une table de sauvegarde
SELECT * INTO Clients_Backup_20241115
FROM Clients
WHERE EstActif = 0;

-- Vérifier la sauvegarde
SELECT COUNT(*) FROM Clients_Backup_20241115;
-- 127 lignes sauvegardées

-- Maintenant, supprimer en toute sécurité
DELETE FROM Clients WHERE EstActif = 0;

-- En cas de problème, restaurer :
-- INSERT INTO Clients SELECT * FROM Clients_Backup_20241115;
```

### 4. Vérifier @@ROWCOUNT après la suppression

```sql
-- Supprimer
DELETE FROM Logs
WHERE DateLog < DATEADD(DAY, -90, GETDATE());

-- Vérifier immédiatement
DECLARE @NbSupprimes INT = @@ROWCOUNT;

IF @NbSupprimes > 100000
BEGIN
    PRINT 'ALERTE : ' + CAST(@NbSupprimes AS VARCHAR) + ' lignes supprimées !';
    PRINT 'Vérifiez si c''est normal avant de COMMIT';
END
ELSE
    PRINT CAST(@NbSupprimes AS VARCHAR) + ' lignes supprimées';
```

### 5. Comprendre les dépendances

```sql
-- Avant de supprimer un client, vérifier les dépendances
SELECT
    (SELECT COUNT(*) FROM Commandes WHERE ClientID = 1) AS NbCommandes,
    (SELECT COUNT(*) FROM Factures WHERE ClientID = 1) AS NbFactures,
    (SELECT COUNT(*) FROM Adresses WHERE ClientID = 1) AS NbAdresses;

-- Si des dépendances existent, décider de la stratégie :
-- 1. Supprimer en cascade (enfants puis parent)
-- 2. Archiver au lieu de supprimer
-- 3. Annuler l'opération
```

### 6. Ne JAMAIS travailler directement en production sans tests

```sql
-- ❌ DANGER : Taper une requête directement en production
-- ✅ SÉCURITÉ : Processus en 5 étapes

-- 1. Écrire la requête en développement
-- 2. Tester avec SELECT
-- 3. Tester le DELETE en développement
-- 4. Valider par un collègue/lead dev
-- 5. Exécuter en production dans une transaction
```

---

## Suppression vs Archivage

Souvent, au lieu de supprimer définitivement, il est préférable d'**archiver** les données.

### Suppression définitive

```sql
-- Les données sont PERDUES
DELETE FROM Commandes
WHERE DateCommande < DATEADD(YEAR, -5, GETDATE());
```

**Problèmes :**
- ❌ Impossible de récupérer pour analyse historique
- ❌ Perte pour les audits
- ❌ Perte pour les statistiques à long terme

### Archivage puis suppression

```sql
-- Option 1 : Table d'archive
INSERT INTO CommandesArchive
SELECT * FROM Commandes
WHERE DateCommande < DATEADD(YEAR, -5, GETDATE());

DELETE FROM Commandes
WHERE DateCommande < DATEADD(YEAR, -5, GETDATE());

-- Option 2 : Flag "supprimé" (soft delete)
ALTER TABLE Commandes ADD EstSupprimee BIT DEFAULT 0;

UPDATE Commandes
SET EstSupprimee = 1
WHERE DateCommande < DATEADD(YEAR, -5, GETDATE());

-- Les requêtes normales filtrent :
SELECT * FROM Commandes WHERE EstSupprimee = 0;
```

**Avantages :**
- ✅ Possibilité de récupération
- ✅ Conservation pour audit
- ✅ Analyses historiques possibles

---

## Soft Delete vs Hard Delete

### Hard Delete (Suppression physique)

```sql
-- Suppression définitive de la base de données
DELETE FROM Clients WHERE ClientID = 1;
```

**Caractéristiques :**
- ✅ Libère vraiment l'espace disque
- ✅ Respecte le RGPD (droit à l'oubli)
- ❌ Irréversible
- ❌ Perte d'historique

### Soft Delete (Suppression logique)

```sql
-- Ajout d'une colonne "supprimé"
ALTER TABLE Clients ADD EstSupprime BIT DEFAULT 0;
ALTER TABLE Clients ADD DateSuppression DATETIME2(3) NULL;

-- "Supprimer" un client (logiquement)
UPDATE Clients
SET EstSupprime = 1,
    DateSuppression = GETDATE()
WHERE ClientID = 1;

-- Les requêtes normales ignorent les supprimés
SELECT * FROM Clients WHERE EstSupprime = 0;

-- Mais on peut toujours consulter l'historique
SELECT * FROM Clients WHERE EstSupprime = 1;
```

**Caractéristiques :**
- ✅ Réversible facilement
- ✅ Conserve l'historique
- ✅ Permet l'audit
- ❌ N'économise pas d'espace disque
- ❌ Complique les requêtes (toujours filtrer EstSupprime)

### Stratégie hybride

```sql
-- Soft delete immédiat
UPDATE Clients
SET EstSupprime = 1, DateSuppression = GETDATE()
WHERE ClientID = 1;

-- Hard delete après période de rétention
DELETE FROM Clients
WHERE EstSupprime = 1
  AND DateSuppression < DATEADD(MONTH, -6, GETDATE());
```

**Meilleur des deux mondes :** Sécurité à court terme, nettoyage à long terme.

---

## Ordre de suppression avec les clés étrangères

Lorsque des tables sont liées par des clés étrangères, l'ordre de suppression est crucial.

### Règle : Enfants avant parents

```sql
-- Structure parent-enfant
CREATE TABLE Clients (
    ClientID INT PRIMARY KEY,
    Nom NVARCHAR(100)
);

CREATE TABLE Commandes (
    CommandeID INT PRIMARY KEY,
    ClientID INT FOREIGN KEY REFERENCES Clients(ClientID)
);

CREATE TABLE LignesCommande (
    LigneID INT PRIMARY KEY,
    CommandeID INT FOREIGN KEY REFERENCES Commandes(CommandeID)
);

-- ❌ ERREUR : Supprimer le parent en premier
DELETE FROM Clients WHERE ClientID = 1;
-- Erreur : violation de contrainte FOREIGN KEY

-- ✅ CORRECT : Supprimer dans le bon ordre
-- Étape 1 : Petits-enfants
DELETE FROM LignesCommande
WHERE CommandeID IN (SELECT CommandeID FROM Commandes WHERE ClientID = 1);

-- Étape 2 : Enfants
DELETE FROM Commandes WHERE ClientID = 1;

-- Étape 3 : Parent
DELETE FROM Clients WHERE ClientID = 1;
```

### Suppression en cascade (CASCADE DELETE)

```sql
-- Définir la cascade à la création
CREATE TABLE Commandes (
    CommandeID INT PRIMARY KEY,
    ClientID INT,
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID)
        ON DELETE CASCADE  -- ← Suppression automatique des enfants
);

-- Maintenant, supprimer le parent supprime automatiquement les enfants
DELETE FROM Clients WHERE ClientID = 1;
-- Les commandes du client 1 sont automatiquement supprimées
```

**⚠️ Attention :** CASCADE DELETE est pratique mais peut supprimer plus que prévu !

---

## Ce que vous apprendrez dans cette section

Cette section est divisée en deux parties complémentaires :

### 2.6.1 Syntaxe DELETE FROM ... WHERE

Vous apprendrez :
- La syntaxe complète de DELETE
- Comment utiliser tous les opérateurs dans WHERE
- Comment supprimer avec des JOIN
- Comment utiliser TOP pour limiter les suppressions
- Comment vérifier avec @@ROWCOUNT
- Des exemples pratiques de tous types
- Les pièges courants et comment les éviter

### 2.6.2 Différence entre DELETE et TRUNCATE

Vous découvrirez :
- Les différences fondamentales entre DELETE et TRUNCATE
- Quand utiliser l'un ou l'autre
- Impact sur les performances
- Impact sur IDENTITY, triggers, contraintes
- Comparaisons détaillées avec exemples
- Stratégies de choix selon le contexte

---

## Checklist avant toute suppression

Avant d'exécuter **TOUTE** suppression en production, vérifiez :

### ✅ Préparation

- [ ] **J'ai identifié exactement** quelles lignes doivent être supprimées
- [ ] **J'ai testé avec SELECT** avec la même clause WHERE
- [ ] **J'ai compté** le nombre de lignes qui seront supprimées
- [ ] **J'ai vérifié** qu'il reste des données importantes après suppression

### ✅ Sécurité

- [ ] **J'ai une sauvegarde récente** de la base de données
- [ ] **J'ai créé une table de backup** des données à supprimer
- [ ] **Je suis dans une transaction** (BEGIN TRANSACTION)
- [ ] **J'ai vérifié les dépendances** (clés étrangères, autres tables)

### ✅ Validation

- [ ] **Ma clause WHERE est correcte** (testé avec SELECT)
- [ ] **L'ordre de suppression respecte** les contraintes FK
- [ ] **Je sais comment annuler** en cas de problème
- [ ] **Un collègue a validé** pour les suppressions critiques

### ✅ Après suppression

- [ ] **J'ai vérifié @@ROWCOUNT** immédiatement
- [ ] **Le nombre correspond** aux attentes
- [ ] **J'ai vérifié** qu'il ne reste pas de données orphelines
- [ ] **Je peux COMMIT** en toute sécurité

---

## Stratégies de suppression sécurisées

### Pour petites suppressions (< 1000 lignes)

```sql
BEGIN TRANSACTION;
    -- Voir ce qui sera supprimé
    SELECT * FROM Clients WHERE EstActif = 0;

    -- Compter
    SELECT COUNT(*) FROM Clients WHERE EstActif = 0;

    -- Supprimer
    DELETE FROM Clients WHERE EstActif = 0;

    -- Vérifier
    SELECT @@ROWCOUNT;

COMMIT;  -- Ou ROLLBACK si problème
```

### Pour grosses suppressions (> 100 000 lignes)

```sql
-- Supprimer par lots pour éviter de bloquer la table
DECLARE @BatchSize INT = 10000;
DECLARE @TotalDeleted INT = 0;

WHILE 1 = 1
BEGIN
    DELETE TOP (@BatchSize) FROM LogsSysteme
    WHERE DateLog < DATEADD(DAY, -90, GETDATE());

    SET @TotalDeleted = @TotalDeleted + @@ROWCOUNT;

    IF @@ROWCOUNT = 0 BREAK;

    PRINT CAST(@TotalDeleted AS VARCHAR) + ' lignes supprimées...';
    WAITFOR DELAY '00:00:01';  -- Pause de 1 seconde
END

PRINT 'Total supprimé : ' + CAST(@TotalDeleted AS VARCHAR);
```

### Pour suppressions critiques

```sql
-- Processus ultra-sécurisé
-- Étape 1 : Sauvegarde complète de la base
BACKUP DATABASE MaBase TO DISK = 'C:\Backup\MaBase_PreSuppression.bak';

-- Étape 2 : Copie des données à supprimer
SELECT * INTO ClientsASupprimer_20241115
FROM Clients
WHERE EstActif = 0;

-- Étape 3 : Vérifications multiples
SELECT COUNT(*) AS NbASupprimer FROM ClientsASupprimer_20241115;
SELECT COUNT(*) AS NbRestants FROM Clients WHERE EstActif = 1;

-- Étape 4 : Suppression dans transaction
BEGIN TRANSACTION;
    DELETE FROM Clients WHERE EstActif = 0;

    -- Validation par un humain
    SELECT @@ROWCOUNT AS Supprimées;
    SELECT COUNT(*) FROM Clients;

    -- Attendre confirmation manuelle avant COMMIT
    -- COMMIT;
ROLLBACK;  -- Sécurité : ROLLBACK par défaut
```

---

## Points clés à retenir

✅ **La suppression est IRRÉVERSIBLE** une fois committée

✅ **TOUJOURS tester avec SELECT** avant DELETE

✅ **Utiliser des transactions** pour pouvoir annuler

✅ **Faire des sauvegardes** avant les suppressions importantes

✅ **Vérifier @@ROWCOUNT** après chaque suppression

✅ **Respecter l'ordre** : enfants avant parents (FK)

✅ **Considérer l'archivage** au lieu de la suppression pure

✅ **DELETE** pour suppression sélective, **TRUNCATE** pour vider une table

⚠️ **WHERE est CRUCIAL** (comme pour UPDATE)

⚠️ **Pas de CTRL+Z** après COMMIT

⚠️ **Vérifier les dépendances** avant de supprimer

---

## Message crucial

> **La suppression est l'opération la plus dangereuse en SQL.**
>
> Contrairement à UPDATE qui écrase les données (on perd les anciennes valeurs),  
> DELETE fait disparaître les lignes complètement.
>
> Il n'y a **aucun moyen** de récupérer des données supprimées sans sauvegarde.
>
> **Trois règles sacrées :**  
> 1. Testez TOUJOURS avec SELECT d'abord  
> 2. Utilisez TOUJOURS des transactions  
> 3. Ayez TOUJOURS une sauvegarde
>
> **5 minutes de précaution valent mieux que des jours de reconstruction de données.**

---

## Prochaines étapes

Dans les sections suivantes, nous allons explorer en détail :

1. **Section 2.6.1** : La syntaxe complète de DELETE, tous les cas d'usage, et comment supprimer en toute sécurité
2. **Section 2.6.2** : Les différences entre DELETE et TRUNCATE, quand utiliser l'un ou l'autre

Ces deux sections vous donneront toutes les compétences et connaissances nécessaires pour supprimer des données de manière professionnelle et sécurisée.

**Attention :** Cette section requiert votre concentration maximale. Les erreurs de suppression sont les plus coûteuses en base de données. Prenez votre temps, suivez les bonnes pratiques, et n'hésitez jamais à demander une validation avant une suppression importante.

**Prêt à apprendre à supprimer vos données en toute sécurité ? Allons-y avec prudence ! ⚠️🛡️**

⏭️ [Syntaxe DELETE FROM ... WHERE](/02-definition-et-manipulation-des-donnees/06.1-syntaxe-delete-from-where.md)
