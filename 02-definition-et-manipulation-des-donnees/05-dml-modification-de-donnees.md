🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 2.5 DML : Modification de données

## Introduction

Après avoir appris à créer des structures de données (DDL) et à insérer des informations (INSERT), nous abordons maintenant une opération tout aussi essentielle : la **modification** des données existantes.

Dans le monde réel, les données changent constamment : un client déménage et change d'adresse, un prix de produit est ajusté, un statut de commande évolue, un employé obtient une promotion... La commande **UPDATE** est l'outil qui permet de refléter ces changements dans votre base de données.

Cette section est cruciale car UPDATE est l'une des commandes les plus utilisées au quotidien, mais aussi l'une des plus **dangereuses** si elle est mal utilisée. Une erreur dans un UPDATE peut avoir des conséquences catastrophiques sur vos données.

---

## Qu'est-ce que la modification de données ?

### Définition

La **modification de données** consiste à changer les valeurs existantes dans une ou plusieurs colonnes d'une table, sans ajouter ni supprimer de lignes.

**Analogie du carnet d'adresses :**

Imaginez un carnet d'adresses papier avec les contacts de vos amis :

- **INSERT** = Ajouter un nouveau contact sur une page vierge
- **UPDATE** = Prendre une gomme et corriger le numéro de téléphone d'un contact existant
- **DELETE** = Rayer complètement un contact

Avec UPDATE, vous **modifiez** des informations déjà présentes, vous ne créez pas de nouvelles entrées.

### Différence entre INSERT et UPDATE

```sql
-- État initial de la table Clients
ClientID | Nom           | Email                | Telephone
---------|---------------|----------------------|-------------
1        | Marie Dupont  | marie.d@email.fr     | 0612345678
2        | Pierre Martin | pierre.m@email.com   | NULL

-- INSERT : Ajoute une NOUVELLE ligne
INSERT INTO Clients (ClientID, Nom, Email, Telephone)
VALUES (3, N'Julie Leroux', 'julie.l@email.fr', '0634567890');

-- Résultat : Une ligne de plus
ClientID | Nom           | Email                | Telephone
---------|---------------|----------------------|-------------
1        | Marie Dupont  | marie.d@email.fr     | 0612345678
2        | Pierre Martin | pierre.m@email.com   | NULL
3        | Julie Leroux  | julie.l@email.fr     | 0634567890  ← NOUVELLE ligne

-- UPDATE : Modifie une ligne EXISTANTE
UPDATE Clients
SET Telephone = '0623456789'
WHERE ClientID = 2;

-- Résultat : Même nombre de lignes, mais une valeur modifiée
ClientID | Nom           | Email                | Telephone
---------|---------------|----------------------|-------------
1        | Marie Dupont  | marie.d@email.fr     | 0612345678
2        | Pierre Martin | pierre.m@email.com   | 0623456789  ← MODIFIÉ
3        | Julie Leroux  | julie.l@email.fr     | 0634567890
```

**Points clés :**
- **INSERT** : Nombre de lignes augmente (+1, +2, +N)
- **UPDATE** : Nombre de lignes reste identique (0 changement de lignes)
- **UPDATE** : Seules les valeurs dans les colonnes changent

---

## Pourquoi modifier des données ?

Dans une application réelle, vous aurez constamment besoin de mettre à jour des informations. Voici les cas d'usage les plus courants :

### 1. Correction d'erreurs

```sql
-- Corriger une faute de frappe dans un nom
UPDATE Clients
SET Nom = N'Dupont'  -- au lieu de 'Dupond'
WHERE ClientID = 1;

-- Corriger un prix erroné
UPDATE Produits
SET Prix = 99.99  -- au lieu de 9.99
WHERE ProduitID = 42;
```

### 2. Mise à jour d'informations changeantes

```sql
-- Client qui déménage
UPDATE Clients
SET Adresse = N'15 rue Nouvelle, 75001 Paris',
    Telephone = '0645678901'
WHERE ClientID = 10;

-- Produit qui change de prix
UPDATE Produits
SET Prix = 89.99
WHERE ProduitID = 5;
```

### 3. Changement de statut

```sql
-- Marquer une commande comme expédiée
UPDATE Commandes
SET Statut = N'Expédiée',
    DateExpedition = GETDATE()
WHERE CommandeID = 1234;

-- Activer un compte utilisateur
UPDATE Utilisateurs
SET EstActif = 1,
    DateActivation = GETDATE()
WHERE UtilisateurID = 567;
```

### 4. Calculs et recalculs

```sql
-- Décrémenter le stock après une vente
UPDATE Produits
SET Stock = Stock - 1
WHERE ProduitID = 8;

-- Augmenter les prix de 10%
UPDATE Produits
SET Prix = Prix * 1.10
WHERE Categorie = N'Électronique';
```

### 5. Maintenance et nettoyage

```sql
-- Nettoyer les espaces dans les emails
UPDATE Clients
SET Email = TRIM(Email);

-- Mettre en majuscules tous les codes postaux
UPDATE Adresses
SET CodePostal = UPPER(CodePostal);
```

### 6. Enrichissement de données

```sql
-- Ajouter une information calculée
UPDATE Employes
SET NomComplet = Prenom + ' ' + Nom;

-- Calculer l'ancienneté
UPDATE Employes
SET AnneeAnciennete = DATEDIFF(YEAR, DateEmbauche, GETDATE());
```

---

## La commande UPDATE : Vue d'ensemble

### Structure de base

```sql
UPDATE nom_table
SET colonne1 = nouvelle_valeur1,
    colonne2 = nouvelle_valeur2
WHERE condition;
```

**Composants essentiels :**

1. **UPDATE** : Mot-clé qui démarre la commande
2. **nom_table** : La table contenant les données à modifier
3. **SET** : Introduit la liste des colonnes à modifier et leurs nouvelles valeurs
4. **WHERE** : Filtre pour spécifier quelles lignes modifier (⚠️ CRUCIAL)

### Exemple simple

```sql
-- Mettre à jour l'email d'un client spécifique
UPDATE Clients
SET Email = 'marie.dupont@nouveaumail.fr'
WHERE ClientID = 1;
```

**Ce qui se passe :**
1. SQL Server cherche dans la table `Clients`
2. Il filtre pour trouver la ligne où `ClientID = 1`
3. Il modifie la colonne `Email` de cette ligne
4. Les autres lignes et colonnes restent inchangées

---

## Les dangers de UPDATE : Avertissement crucial

⚠️ **ATTENTION : UPDATE est une commande PUISSANTE et DANGEREUSE** ⚠️

### Le risque principal : Oublier WHERE

```sql
-- ❌ CATASTROPHE : Modifier TOUS les clients !
UPDATE Clients
SET Email = 'erreur@email.com';
-- Oublié le WHERE !

-- Résultat : TOUS les clients ont maintenant le même email
```

**Conséquences d'un UPDATE sans WHERE :**
- 🔥 Toutes les lignes de la table sont modifiées
- 💣 Perte potentielle de milliers, voire millions de données
- ⏰ Des heures/jours de récupération
- 💼 Impact métier majeur
- 😱 Possibilité de perte d'emploi dans les cas graves

### Pourquoi UPDATE est-il plus dangereux que INSERT ?

| Opération | Risque | Récupération |
|-----------|--------|--------------|
| **INSERT** | Ajoute des données en trop | Facile : DELETE les lignes ajoutées |
| **UPDATE** | Écrase des données existantes | Difficile : besoin d'une sauvegarde |
| **DELETE** | Supprime des données | Difficile : besoin d'une sauvegarde |

**Exemple :**

```sql
-- INSERT raté : on peut facilement annuler
INSERT INTO Clients VALUES (999, 'Test', 'test@test.com');
-- Oups, erreur ! Pas grave :
DELETE FROM Clients WHERE ClientID = 999;  -- Annulé

-- UPDATE raté : données perdues !
UPDATE Clients SET Email = 'erreur@email.com';
-- Oups ! Impossible de retrouver les anciens emails sans sauvegarde !
```

---

## Les règles d'or de UPDATE

Pour utiliser UPDATE en toute sécurité, suivez ces règles impérativement :

### 1. TOUJOURS tester avec SELECT d'abord

```sql
-- ✅ PROCESSUS SÉCURISÉ

-- Étape 1 : Identifier les lignes avec SELECT
SELECT * FROM Clients WHERE ClientID = 1;

-- Étape 2 : Vérifier que c'est bien ce que vous voulez modifier
-- (1 ligne affichée ? OK. 0 ligne ? Problème. 100 lignes ? Problème !)

-- Étape 3 : Remplacer SELECT par UPDATE avec la MÊME clause WHERE
UPDATE Clients
SET Email = 'nouveau@email.fr'
WHERE ClientID = 1;  -- ← Exactement la même condition que le SELECT
```

### 2. Utiliser des transactions pour les opérations critiques

```sql
-- Démarrer une transaction (mode "brouillon")
BEGIN TRANSACTION;

    -- Faire l'UPDATE
    UPDATE Clients
    SET Email = 'nouveau@email.fr'
    WHERE ClientID = 1;

    -- Vérifier le résultat
    SELECT * FROM Clients WHERE ClientID = 1;

    -- Si OK : valider définitivement
    COMMIT;

    -- Si problème : annuler
    -- ROLLBACK;
```

**Tant que vous n'avez pas fait COMMIT, rien n'est permanent !**

### 3. Vérifier le nombre de lignes modifiées

```sql
-- Faire l'UPDATE
UPDATE Clients
SET Email = 'nouveau@email.fr'
WHERE ClientID = 1;

-- Vérifier immédiatement combien de lignes ont été modifiées
SELECT @@ROWCOUNT AS LignesModifiees;
-- Devrait afficher 1

-- Si le nombre est inattendu : ALERTE !
```

### 4. Faire des sauvegardes avant les mises à jour importantes

```sql
-- Créer une copie de sécurité de la table
SELECT * INTO Clients_Backup_20241115 FROM Clients;

-- Maintenant vous pouvez faire votre UPDATE en toute sécurité
UPDATE Clients
SET Email = LOWER(Email);  -- Mettre tous les emails en minuscules

-- Si problème, restaurer :
-- DELETE FROM Clients;
-- INSERT INTO Clients SELECT * FROM Clients_Backup_20241115;
```

### 5. Ne JAMAIS travailler directement en production sans tests

```sql
-- ❌ MAUVAISE pratique
-- Écrire l'UPDATE directement en production et exécuter

-- ✅ BONNE pratique
-- 1. Tester en développement
-- 2. Tester en préproduction
-- 3. Créer une sauvegarde
-- 4. Exécuter en production dans une transaction
-- 5. Vérifier immédiatement
-- 6. COMMIT si OK
```

---

## Ce que vous apprendrez dans cette section

Cette section est divisée en deux parties essentielles :

### 2.5.1 Syntaxe UPDATE ... SET ... WHERE

Vous apprendrez :
- La syntaxe complète de UPDATE
- Comment modifier une ou plusieurs colonnes
- Les différents opérateurs dans WHERE
- Comment utiliser des calculs dans SET
- Comment mettre à jour à partir d'autres tables
- Des exemples pratiques concrets

### 2.5.2 L'importance cruciale de la clause WHERE

Vous découvrirez :
- Pourquoi WHERE est absolument essentiel
- Des exemples réels de catastrophes causées par l'oubli de WHERE
- Comment se protéger contre les erreurs
- Des stratégies de sécurité et bonnes pratiques
- Comment récupérer en cas d'erreur

---

## Types de modifications possibles

UPDATE permet plusieurs types de modifications :

### 1. Modification avec valeur fixe

```sql
-- Assigner une valeur constante
UPDATE Produits
SET Prix = 99.99
WHERE ProduitID = 1;
```

### 2. Modification avec calcul

```sql
-- Calculer la nouvelle valeur à partir de l'ancienne
UPDATE Produits
SET Prix = Prix * 1.10  -- Augmentation de 10%
WHERE Categorie = N'Électronique';
```

### 3. Modification avec fonction

```sql
-- Utiliser une fonction SQL
UPDATE Clients
SET Email = LOWER(Email),  -- Mettre en minuscules
    DateModification = GETDATE()  -- Date actuelle
WHERE EstActif = 1;
```

### 4. Modification conditionnelle (CASE)

```sql
-- Différentes valeurs selon des conditions
UPDATE Commandes
SET Priorite = CASE
    WHEN MontantTotal > 1000 THEN N'Haute'
    WHEN MontantTotal > 500 THEN N'Moyenne'
    ELSE N'Normale'
END;
```

### 5. Modification depuis une autre table (JOIN)

```sql
-- Utiliser des données d'une autre table
UPDATE Employes
SET NomDepartement = D.NomDepartement
FROM Employes E
INNER JOIN Departements D ON E.DepartementID = D.DepartementID;
```

---

## UPDATE et les contraintes

UPDATE doit respecter toutes les contraintes définies sur la table :

### Contraintes qui s'appliquent à UPDATE

```sql
CREATE TABLE Produits (
    ProduitID INT PRIMARY KEY,
    Nom NVARCHAR(200) NOT NULL,
    Prix DECIMAL(10, 2) CHECK (Prix > 0),
    Stock INT DEFAULT 0,
    CategorieID INT FOREIGN KEY REFERENCES Categories(CategorieID)
);

-- ❌ Violation de NOT NULL
UPDATE Produits
SET Nom = NULL
WHERE ProduitID = 1;
-- Erreur : La colonne Nom n'accepte pas NULL

-- ❌ Violation de CHECK
UPDATE Produits
SET Prix = -10
WHERE ProduitID = 1;
-- Erreur : Prix doit être > 0

-- ❌ Violation de FOREIGN KEY
UPDATE Produits
SET CategorieID = 999
WHERE ProduitID = 1;
-- Erreur si la catégorie 999 n'existe pas

-- ✅ UPDATE valide
UPDATE Produits
SET Prix = 99.99,
    Stock = 50
WHERE ProduitID = 1;
```

---

## UPDATE et les performances

### Impact sur les performances

La vitesse d'un UPDATE dépend de plusieurs facteurs :

**1. Nombre de lignes à modifier**
```sql
-- Rapide : 1 ligne
UPDATE Clients SET Email = 'new@email.com' WHERE ClientID = 1;

-- Lent : 1 million de lignes
UPDATE Clients SET Email = LOWER(Email);
```

**2. Présence d'index**
```sql
-- Rapide si ClientID est indexé
UPDATE Clients SET Nom = 'Nouveau' WHERE ClientID = 1;

-- Plus lent si Email n'est pas indexé
UPDATE Clients SET Nom = 'Nouveau' WHERE Email = 'test@email.com';
```

**3. Complexité du SET**
```sql
-- Rapide : valeur simple
UPDATE Produits SET Prix = 99.99 WHERE ProduitID = 1;

-- Plus lent : calculs complexes
UPDATE Produits
SET Prix = (SELECT AVG(Prix) FROM Produits WHERE Categorie = P.Categorie) * 1.1
FROM Produits P;
```

### Optimisation pour les grosses tables

```sql
-- Pour une très grosse table, mettre à jour par lots
DECLARE @BatchSize INT = 1000;

WHILE 1 = 1
BEGIN
    UPDATE TOP (@BatchSize) Produits
    SET DateModification = GETDATE()
    WHERE DateModification IS NULL;

    IF @@ROWCOUNT = 0 BREAK;  -- Plus rien à mettre à jour

    WAITFOR DELAY '00:00:01';  -- Pause de 1 seconde entre chaque lot
END
```

---

## UPDATE et les triggers

Si des triggers sont définis sur la table, ils seront déclenchés par UPDATE :

```sql
-- Exemple de trigger (sera vu en détail plus tard)
CREATE TRIGGER TR_Produits_Update
ON Produits
AFTER UPDATE
AS
BEGIN
    -- Ce code s'exécute automatiquement après chaque UPDATE
    INSERT INTO HistoriquePrix (ProduitID, AncienPrix, NouveauPrix, DateModification)
    SELECT
        d.ProduitID,
        d.Prix AS AncienPrix,
        i.Prix AS NouveauPrix,
        GETDATE()
    FROM DELETED d
    INNER JOIN INSERTED i ON d.ProduitID = i.ProduitID
    WHERE d.Prix != i.Prix;
END
```

**Impact :** Chaque UPDATE peut déclencher du code supplémentaire, ce qui peut :
- ✅ Automatiser des tâches (audit, historique)
- ⚠️ Ralentir les performances
- ⚠️ Causer des effets de bord inattendus

---

## Différences UPDATE vs MERGE

SQL Server propose aussi l'instruction **MERGE** pour des scénarios complexes :

```sql
-- UPDATE : Simple, pour un seul type d'action
UPDATE Clients
SET Telephone = '0612345678'
WHERE ClientID = 1;

-- MERGE : Complexe, plusieurs actions selon les conditions
MERGE INTO Clients AS Target
USING SourceTable AS Source ON Target.ClientID = Source.ClientID
WHEN MATCHED THEN
    UPDATE SET Telephone = Source.Telephone
WHEN NOT MATCHED THEN
    INSERT (ClientID, Nom, Telephone) VALUES (Source.ClientID, Source.Nom, Source.Telephone);
```

**Quand utiliser quoi ?**
- **UPDATE** : 99% des cas, modifications simples
- **MERGE** : Synchronisation complexe de données entre tables

---

## Exemples de scénarios réels

### Scénario 1 : E-commerce

```sql
-- Après une vente : décrémenter le stock
UPDATE Produits
SET Stock = Stock - 1,
    DateDerniereVente = GETDATE()
WHERE ProduitID = 42;

-- Lancer une promotion
UPDATE Produits
SET PrixPromo = Prix * 0.80,
    EnPromotion = 1
WHERE Categorie = N'Électronique';
```

### Scénario 2 : Gestion d'utilisateurs

```sql
-- Enregistrer une connexion
UPDATE Utilisateurs
SET DerniereConnexion = GETDATE(),
    NombreConnexions = NombreConnexions + 1
WHERE UtilisateurID = 123;

-- Désactiver les comptes inactifs
UPDATE Utilisateurs
SET EstActif = 0
WHERE DerniereConnexion < DATEADD(DAY, -90, GETDATE());
```

### Scénario 3 : Gestion de commandes

```sql
-- Passer une commande à "Expédiée"
UPDATE Commandes
SET Statut = N'Expédiée',
    DateExpedition = GETDATE(),
    NumeroSuivi = 'FR123456789'
WHERE CommandeID = 5678;
```

---

## Checklist avant de faire un UPDATE

Avant d'exécuter **tout** UPDATE, vérifiez :

**Préparation :**
- [ ] J'ai identifié exactement quelles lignes doivent être modifiées
- [ ] J'ai testé ma clause WHERE avec un SELECT
- [ ] J'ai vérifié que le nombre de lignes retournées est correct
- [ ] J'ai une sauvegarde récente (pour les opérations critiques)

**Sécurité :**
- [ ] Ma clause WHERE est présente (sauf si modification globale volontaire)
- [ ] Je suis dans une transaction (BEGIN TRANSACTION)
- [ ] J'ai prévu de vérifier @@ROWCOUNT après exécution

**Validation :**
- [ ] Les nouvelles valeurs respectent les contraintes
- [ ] Les types de données sont corrects
- [ ] La logique métier est respectée

---

## Points clés à retenir

✅ **UPDATE** modifie des données existantes (ne crée pas de nouvelles lignes)

✅ **WHERE** est CRUCIAL pour cibler les bonnes lignes

✅ **SELECT d'abord** : toujours tester avec SELECT avant UPDATE

✅ **Transactions** : utilisez BEGIN TRANSACTION pour pouvoir annuler

✅ **@@ROWCOUNT** : vérifiez le nombre de lignes modifiées

✅ **Sauvegardes** : faites des copies avant les mises à jour importantes

⚠️ **UPDATE sans WHERE** = modification de TOUTES les lignes (dangereux !)

⚠️ **Pas de CTRL+Z** : une fois COMMIT, c'est permanent

⚠️ **Contraintes** : UPDATE doit les respecter

---

## Message important

> **UPDATE est une commande extraordinairement utile mais potentiellement catastrophique.**
>
> La différence entre un UPDATE bien fait et un UPDATE raté, c'est souvent une simple clause WHERE.
>
> Prenez TOUJOURS le temps de :
> 1. Réfléchir à ce que vous voulez modifier
> 2. Tester avec SELECT
> 3. Utiliser une transaction
> 4. Vérifier le résultat
>
> **5 minutes de précaution valent mieux que 5 heures de récupération.**

---

## Prochaines étapes

Dans les sections suivantes, nous allons :

1. **Section 2.5.1** : Apprendre la syntaxe complète de UPDATE avec de nombreux exemples pratiques
2. **Section 2.5.2** : Comprendre en profondeur pourquoi la clause WHERE est si cruciale, avec des exemples réels de catastrophes et comment s'en protéger

Ces deux sections sont **essentielles** pour tout développeur travaillant avec SQL Server. Elles vous donneront les compétences ET les bonnes pratiques pour modifier vos données en toute sécurité.

**Prêt à apprendre à modifier vos données comme un professionnel ? C'est parti ! 🚀**

⏭️ [Syntaxe UPDATE ... SET ... WHERE](/02-definition-et-manipulation-des-donnees/05.1-syntaxe-update-set-where.md)
