🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 5.6 Fonctions Utilisateur (UDF)

## Introduction

Les **fonctions utilisateur** (User Defined Functions - UDF) sont des blocs de code réutilisables que vous créez vous-même pour effectuer des tâches spécifiques dans SQL Server. Contrairement aux fonctions intégrées de SQL Server (comme `SUM()`, `COUNT()`, `GETDATE()`), les UDF sont personnalisées selon vos besoins métier.

**Analogie simple :** Si les fonctions intégrées de SQL Server sont comme les outils standard d'une boîte à outils (marteau, tournevis, clé), les fonctions utilisateur sont comme des outils que vous fabriquez vous-même pour des tâches spécifiques à votre travail. Par exemple, si vous calculez souvent une remise complexe selon des règles métier spécifiques, vous pouvez créer une fonction `CalculerRemiseClient()` plutôt que de réécrire la même logique partout.

---

## Qu'est-ce qu'une fonction utilisateur ?

Une fonction utilisateur (UDF) est un **objet de base de données** qui :
- Accepte **zéro ou plusieurs paramètres** en entrée
- Effectue un **traitement ou calcul** spécifique
- **Retourne un résultat** (une valeur unique ou un ensemble de données)
- Peut être **réutilisée** dans n'importe quelle requête SQL
- Encapsule une **logique métier** pour éviter la duplication de code

**Exemple conceptuel :**
```sql
-- Au lieu d'écrire cette logique partout :
SELECT
    PrixHT * 1.20 AS PrixTTC,
    PrixHT * 0.20 AS MontantTVA
FROM Produits;

-- Vous pouvez créer des fonctions réutilisables :
SELECT
    dbo.CalculerPrixTTC(PrixHT) AS PrixTTC,
    dbo.CalculerMontantTVA(PrixHT) AS MontantTVA
FROM Produits;
```

---

## Les trois types de fonctions utilisateur

SQL Server propose trois types principaux de fonctions utilisateur, chacun avec ses caractéristiques et ses cas d'usage :

### 1. Fonctions Scalaires (Scalar Functions)

Les fonctions scalaires retournent **une seule valeur** d'un type de données spécifique (INT, VARCHAR, DATE, etc.).

**Caractéristiques :**
- Retournent **UNE valeur unique**
- Peuvent être utilisées partout où une expression est attendue (SELECT, WHERE, ORDER BY, etc.)
- Contiennent une logique procédurale (BEGIN...END)
- Similaires aux fonctions mathématiques : une entrée → un résultat

**Exemple conceptuel :**
```sql
-- Fonction qui calcule la TVA
dbo.CalculerTVA(100.00) → Retourne : 20.00

-- Fonction qui formate un nom
dbo.FormaterNom('DUPONT', 'jean') → Retourne : 'Jean Dupont'

-- Fonction qui calcule un âge
dbo.CalculerAge('1990-05-15') → Retourne : 35
```

**Utilisation typique :**
```sql
SELECT
    NomProduit,
    PrixHT,
    dbo.CalculerTVA(PrixHT) AS MontantTVA
FROM Produits;
```

⚠️ **Note importante :** Les fonctions scalaires ont des **problèmes de performance** importants dont nous parlerons en détail dans les sections suivantes.

### 2. Fonctions Table Inline (Inline Table-Valued Functions - TVF)

Les fonctions table inline retournent **une table** (un ensemble de lignes) définie par **une seule requête SELECT**.

**Caractéristiques :**
- Retournent **une table** (plusieurs lignes et colonnes)
- Définies par **une seule instruction SELECT**
- **Très performantes** (optimisées comme des vues)
- Agissent comme des "vues paramétrées"
- Pas de BEGIN...END

**Exemple conceptuel :**
```sql
-- Fonction qui retourne les commandes d'un client
dbo.ObtenirCommandesClient(5) → Retourne : Une table avec toutes les commandes du client 5

-- Fonction qui filtre des produits par prix
dbo.ObtenirProduitsPrix(10, 50) → Retourne : Une table avec tous les produits entre 10€ et 50€
```

**Utilisation typique :**
```sql
-- Utiliser comme une table dans FROM
SELECT *
FROM dbo.ObtenirCommandesClient(5)
WHERE Statut = 'Livré';

-- Joindre avec d'autres tables
SELECT
    c.NomClient,
    cmd.CommandeID,
    cmd.MontantTotal
FROM Clients AS c
CROSS APPLY dbo.ObtenirCommandesClient(c.ClientID) AS cmd;
```

### 3. Fonctions Table Multi-instructions (Multi-Statement Table-Valued Functions - MSTVF)

Les fonctions table multi-instructions retournent également **une table**, mais peuvent contenir **plusieurs instructions** et une logique procédurale complexe.

**Caractéristiques :**
- Retournent **une table** (structure définie explicitement)
- Contiennent **plusieurs instructions** (BEGIN...END)
- Permettent des **variables, boucles, conditions**
- Moins performantes que les inline
- Plus flexibles pour des logiques complexes

**Exemple conceptuel :**
```sql
-- Fonction qui génère un calendrier avec logique complexe
dbo.GenererCalendrier('2025-11-01', '2025-11-30')
→ Retourne : Une table avec toutes les dates du mois avec informations (weekend, jour férié, etc.)

-- Fonction qui analyse et catégorise des données
dbo.AnalyserClient(5)
→ Retourne : Une table avec plusieurs lignes de recommandations basées sur une logique conditionnelle
```

**Utilisation typique :**
```sql
SELECT *
FROM dbo.GenererCalendrier('2025-11-01', '2025-11-30')
WHERE EstWeekend = 0;
```

---

## Comparaison des trois types

| Aspect | Scalaire | Table Inline | Table Multi-instructions |
|--------|----------|--------------|-------------------------|
| **Retour** | Une valeur | Une table | Une table |
| **Syntaxe** | BEGIN...END | AS RETURN (SELECT...) | BEGIN...END |
| **Nombre d'instructions** | Multiple | Une seule SELECT | Multiple |
| **Structure retour** | Type simple | Implicite | Explicite (déclarée) |
| **Performance** | ❌ Faible | ✅ Excellente | ⚠️ Moyenne |
| **Utilisation** | Dans expressions | Dans FROM | Dans FROM |
| **Variables** | ✅ Oui | ❌ Non | ✅ Oui |
| **Boucles/Conditions** | ✅ Oui | ❌ Non | ✅ Oui |

---

## Pourquoi utiliser des fonctions utilisateur ?

### 1. Réutilisabilité du code

Au lieu de réécrire la même logique partout, vous l'écrivez une fois dans une fonction.

**Sans fonction (duplication de code) :**
```sql
-- Dans la requête 1
SELECT PrixHT * 1.20 AS PrixTTC FROM Produits;

-- Dans la requête 2
SELECT PrixHT * 1.20 AS PrixTTC FROM Commandes;

-- Dans la requête 3
SELECT PrixHT * 1.20 AS PrixTTC FROM Factures;

-- Si le taux de TVA change, vous devez modifier 3 requêtes (ou plus !)
```

**Avec fonction (un seul endroit à maintenir) :**
```sql
-- Créer la fonction une fois
CREATE FUNCTION dbo.CalculerPrixTTC(@prixHT DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS BEGIN
    RETURN @prixHT * 1.20;
END;

-- Utiliser partout
SELECT dbo.CalculerPrixTTC(PrixHT) FROM Produits;
SELECT dbo.CalculerPrixTTC(PrixHT) FROM Commandes;
SELECT dbo.CalculerPrixTTC(PrixHT) FROM Factures;

-- Si le taux change : modifier uniquement la fonction !
```

### 2. Encapsulation de la logique métier

Les fonctions permettent de cacher la complexité derrière une interface simple.

**Exemple :**
```sql
-- Logique complexe cachée dans une fonction
SELECT dbo.CategoriserClient(ClientID) AS Categorie
FROM Clients;

-- Au lieu de :
SELECT
    CASE
        WHEN TotalAchats > 10000 AND NombreCommandes > 20 THEN 'VIP'
        WHEN TotalAchats > 5000 AND NombreCommandes > 10 THEN 'Premium'
        WHEN TotalAchats > 1000 AND NombreCommandes > 3 THEN 'Standard'
        WHEN InscritDepuis < DATEADD(MONTH, -6, GETDATE()) THEN 'Inactif'
        ELSE 'Nouveau'
    END AS Categorie
FROM Clients;
```

### 3. Lisibilité et maintenance

Le code devient plus expressif et facile à comprendre.

**Comparaison :**
```sql
-- ❌ Difficile à lire
SELECT
    ClientID,
    (SELECT SUM(MontantTotal) FROM Commandes WHERE ClientID = c.ClientID) AS Total,
    (SELECT COUNT(*) FROM Commandes WHERE ClientID = c.ClientID) AS NbCommandes,
    (SELECT MAX(DateCommande) FROM Commandes WHERE ClientID = c.ClientID) AS DerniereCommande
FROM Clients AS c;

-- ✅ Plus clair avec une fonction
SELECT
    ClientID,
    s.Total,
    s.NbCommandes,
    s.DerniereCommande
FROM Clients AS c
CROSS APPLY dbo.ObtenirStatsClient(c.ClientID) AS s;
```

### 4. Cohérence des calculs

Tout le monde utilise la même logique, évitant les erreurs et incohérences.

**Exemple :**
```sql
-- Si 5 développeurs calculent la remise différemment, vous aurez 5 résultats différents !
-- Développeur 1 : PrixHT * 0.10
-- Développeur 2 : (PrixHT * 10) / 100
-- Développeur 3 : PrixHT - (PrixHT * 0.90)
-- etc.

-- Avec une fonction, tout le monde utilise le même calcul garanti
SELECT dbo.CalculerRemise(PrixHT) FROM Produits;
```

### 5. Abstraction et sécurité

Les fonctions peuvent masquer des détails d'implémentation sensibles.

**Exemple :**
```sql
-- Les utilisateurs appellent simplement :
SELECT dbo.ObtenirPrixClient(ProduitID, ClientID) FROM ...;

-- Sans savoir que la fonction applique :
-- - Des remises personnalisées selon le type de client
-- - Des tarifs négociés
-- - Des promotions en cours
-- - Des règles métier complexes
```

---

## Anatomie générale d'une fonction

Toutes les fonctions partagent des éléments communs :

### Structure de base

```sql
CREATE FUNCTION nom_schema.nom_fonction
(
    -- Paramètres d'entrée (optionnels)
    @parametre1 type_donnees,
    @parametre2 type_donnees
)
RETURNS type_ou_table_retour  -- Ce qui est retourné
AS
BEGIN  -- Ou directement RETURN pour les inline
    -- Corps de la fonction
    -- Logique, calculs, traitements

    RETURN resultat;
END;
```

### Éléments clés

1. **Nom qualifié** : `schema.nom_fonction` (généralement `dbo.MaFonction`)
2. **Paramètres** : Entre parenthèses, comme pour une procédure stockée
3. **Clause RETURNS** : Définit le type de retour
4. **Corps de la fonction** : La logique à exécuter
5. **Instruction RETURN** : Retourne le résultat

---

## Différences avec les procédures stockées

Les fonctions et les procédures stockées peuvent sembler similaires, mais elles ont des différences importantes :

| Aspect | Fonction | Procédure Stockée |
|--------|----------|-------------------|
| **Objectif** | Calculer et **retourner** un résultat | **Exécuter** des actions |
| **Valeur de retour** | Obligatoire (valeur ou table) | Optionnelle (code de statut) |
| **Utilisation** | Dans des requêtes SELECT, WHERE, etc. | Appelée avec EXECUTE/EXEC |
| **Modifications de données** | ❌ Non autorisées | ✅ Autorisées (INSERT/UPDATE/DELETE) |
| **Transactions** | ❌ Pas de BEGIN TRAN | ✅ Peut gérer des transactions |
| **Paramètres OUTPUT** | ❌ Non | ✅ Oui |
| **Gestion d'erreurs** | Limitée | ✅ TRY...CATCH complet |
| **Appel depuis une fonction** | ✅ Oui (autre fonction) | ❌ Non |

**Exemple de distinction :**

```sql
-- ✅ FONCTION : Calcule et retourne
CREATE FUNCTION dbo.CalculerTotal(@clientID INT)
RETURNS DECIMAL(10,2)
AS BEGIN
    DECLARE @total DECIMAL(10,2);
    SELECT @total = SUM(MontantTotal) FROM Commandes WHERE ClientID = @clientID;
    RETURN @total;
END;

-- Utilisation dans une requête
SELECT ClientID, dbo.CalculerTotal(ClientID) FROM Clients;

-- ✅ PROCÉDURE : Effectue des actions
CREATE PROCEDURE dbo.TraiterCommande
    @commandeID INT
AS
BEGIN
    -- Peut modifier des données
    UPDATE Commandes SET Statut = 'Traité' WHERE CommandeID = @commandeID;
    INSERT INTO Historique (CommandeID, Action) VALUES (@commandeID, 'Traitement');

    -- Peut avoir une logique complexe avec transactions
    BEGIN TRANSACTION;
    -- ...
    COMMIT;
END;

-- Utilisation
EXEC dbo.TraiterCommande 123;
```

**Règle simple :**
- **Fonction** : Quand vous voulez **calculer et retourner** quelque chose
- **Procédure** : Quand vous voulez **faire des actions** (modifier des données, gérer des processus)

---

## Contraintes et limitations des fonctions

### Restrictions communes à TOUTES les fonctions

Les fonctions ont des limitations importantes pour garantir qu'elles restent **déterministes** et **prévisibles** :

#### 1. Pas de modification de données

Les fonctions **ne peuvent pas** :
- Insérer, modifier ou supprimer des données (pas d'INSERT, UPDATE, DELETE sur des tables permanentes)
- Créer ou modifier des objets de base de données (pas de CREATE, ALTER, DROP)

```sql
-- ❌ INTERDIT dans une fonction
CREATE FUNCTION dbo.ExempleMauvais()
RETURNS INT
AS BEGIN
    -- ERREUR : Impossible de modifier des données
    INSERT INTO Log (Message) VALUES ('Test');
    UPDATE Produits SET Prix = Prix * 1.10;
    DELETE FROM TempData WHERE Date < GETDATE();

    RETURN 1;
END;
```

#### 2. Pas de transactions explicites

Les fonctions ne peuvent pas utiliser :
- BEGIN TRANSACTION
- COMMIT TRANSACTION
- ROLLBACK TRANSACTION

```sql
-- ❌ INTERDIT dans une fonction
CREATE FUNCTION dbo.ExempleMauvais2()
RETURNS INT
AS BEGIN
    BEGIN TRANSACTION;  -- ERREUR !
    -- ...
    COMMIT;
    RETURN 1;
END;
```

#### 3. Pas d'effets de bord non-déterministes

Les fonctions ne doivent pas avoir d'effets de bord imprévisibles :
- Pas d'envoi d'emails
- Pas d'appels à des services externes
- Pas d'interactions avec le système de fichiers

#### 4. Limitations sur les instructions

Les fonctions ne peuvent pas :
- Appeler des procédures stockées
- Utiliser PRINT (dans la plupart des cas)
- Utiliser certaines commandes système

### Pourquoi ces limitations ?

Ces restrictions existent pour garantir que :
1. **Déterminisme** : Mêmes entrées → Mêmes sorties
2. **Sécurité transactionnelle** : Pas d'effets de bord imprévisibles
3. **Optimisation** : L'optimiseur peut faire des hypothèses sur le comportement
4. **Intégrité** : Les fonctions ne cassent pas l'intégrité des données

---

## Conventions de nommage

### Bonnes pratiques de nommage

1. **Préfixe descriptif** selon le type :
   ```sql
   -- Fonctions scalaires : verbe d'action
   dbo.CalculerRemise
   dbo.FormaterTelephone
   dbo.ObtenirAge
   dbo.ConvertirDevise

   -- Fonctions table : nom ou action
   dbo.ObtenirCommandesClient
   dbo.RechercherProduits
   dbo.CommandesParPeriode
   ```

2. **Nommage clair et explicite** :
   ```sql
   -- ✅ BON
   dbo.CalculerPrixTTC
   dbo.ObtenirDerniereCommande
   dbo.ValiderCodePostal

   -- ❌ MAUVAIS
   dbo.Calc
   dbo.GetData
   dbo.Function1
   ```

3. **Utiliser le schéma approprié** :
   ```sql
   -- Pour les fonctions métier générales
   dbo.CalculerTVA

   -- Pour des fonctions spécifiques à un domaine
   ventes.CalculerCommission
   rh.CalculerAnciennete
   ```

4. **Éviter les préfixes de type** :
   ```sql
   -- ❌ Éviter
   fn_CalculerTotal
   udf_GetClient

   -- ✅ Préférer
   dbo.CalculerTotal
   dbo.ObtenirClient
   ```

---

## Déterminisme des fonctions

Le **déterminisme** est un concept important pour les fonctions.

### Fonction déterministe

Une fonction est **déterministe** si elle retourne toujours le **même résultat** pour les mêmes paramètres d'entrée.

**Exemples déterministes :**
```sql
-- Toujours le même résultat pour les mêmes entrées
dbo.CalculerCarre(5)          → Toujours 25
dbo.ConcatenerNom('Jean', 'Dupont') → Toujours 'Jean Dupont'
ABS(-10)                      → Toujours 10
UPPER('hello')                → Toujours 'HELLO'
```

### Fonction non-déterministe

Une fonction est **non-déterministe** si elle peut retourner des résultats **différents** pour les mêmes entrées.

**Exemples non-déterministes :**
```sql
GETDATE()                     → Différent à chaque appel
NEWID()                       → GUID différent à chaque fois
RAND()                        → Nombre aléatoire
```

### Pourquoi c'est important ?

1. **Colonnes calculées** : Seules les fonctions déterministes peuvent être utilisées dans des colonnes calculées persistées
2. **Index** : Seules les fonctions déterministes permettent l'indexation
3. **Optimisation** : Les fonctions déterministes peuvent être optimisées (résultat mis en cache)

```sql
-- ✅ Possible : Fonction déterministe
ALTER TABLE Produits
ADD PrixTTC AS (PrixHT * 1.20) PERSISTED;

-- ❌ Impossible : Fonction non-déterministe
ALTER TABLE Commandes
ADD DateCreation AS (GETDATE());  -- ERREUR !
```

---

## Visibilité et permissions

### Schémas

Les fonctions appartiennent à un **schéma** (généralement `dbo`) :

```sql
-- Créer dans le schéma par défaut (dbo)
CREATE FUNCTION dbo.MaFonction() ...

-- Créer dans un schéma personnalisé
CREATE FUNCTION ventes.CalculerCommission() ...

-- Appeler une fonction
SELECT dbo.MaFonction();
SELECT ventes.CalculerCommission();
```

### Permissions

Pour utiliser une fonction, l'utilisateur doit avoir les permissions appropriées :

```sql
-- Donner le droit d'exécuter une fonction
GRANT EXECUTE ON dbo.CalculerRemise TO MonUtilisateur;

-- Donner le droit sur toutes les fonctions d'un schéma
GRANT EXECUTE ON SCHEMA::dbo TO MonUtilisateur;

-- Révoquer le droit
REVOKE EXECUTE ON dbo.CalculerRemise FROM MonUtilisateur;
```

---

## Bonnes pratiques générales

### ✅ À faire

1. **Documenter vos fonctions**
   ```sql
   /*
   Fonction : dbo.CalculerRemise
   Description : Calcule la remise applicable selon le montant
   Paramètres : @montant - Montant HT de la commande
   Retour : Montant de la remise en euros
   Auteur : Jean Dupont
   Date : 2025-11-18
   */
   CREATE FUNCTION dbo.CalculerRemise(@montant DECIMAL(10,2))
   RETURNS DECIMAL(10,2)
   AS BEGIN
       ...
   END;
   ```

2. **Nommer clairement les paramètres**
   ```sql
   -- ✅ BON
   CREATE FUNCTION dbo.CalculerAge(@dateNaissance DATE)

   -- ❌ MAUVAIS
   CREATE FUNCTION dbo.CalculerAge(@d DATE)
   ```

3. **Valider les entrées**
   ```sql
   CREATE FUNCTION dbo.DiviserNombres(@a INT, @b INT)
   RETURNS DECIMAL(10,2)
   AS BEGIN
       -- Éviter la division par zéro
       IF @b = 0
           RETURN NULL;

       RETURN CAST(@a AS DECIMAL(10,2)) / @b;
   END;
   ```

4. **Choisir le bon type de fonction**
   - Calcul simple → Expression directe (pas de fonction)
   - Calcul complexe réutilisable → Fonction scalaire (avec prudence)
   - Ensemble de données → Fonction table inline
   - Logique procédurale complexe → Fonction multi-instructions

### ❌ À éviter

1. **Ne pas créer de fonctions pour tout**
   ```sql
   -- ❌ Inutile
   CREATE FUNCTION dbo.Multiplier(@a INT, @b INT)
   RETURNS INT AS BEGIN RETURN @a * @b; END;

   -- ✅ Utilisez directement
   SELECT Quantite * Prix FROM Produits;
   ```

2. **Attention aux performances** (surtout avec les fonctions scalaires)
   ```sql
   -- ⚠️ Peut être TRÈS lent sur de grosses tables
   SELECT dbo.MaFonctionScalaire(Colonne) FROM GrosseTable;
   ```

3. **Ne pas imbriquer trop de fonctions**
   ```sql
   -- ❌ Difficile à lire et à déboguer
   SELECT dbo.Fonction1(dbo.Fonction2(dbo.Fonction3(Colonne)))
   FROM Table;
   ```

---

## Outils de gestion des fonctions

### Créer une fonction

```sql
CREATE FUNCTION dbo.MaFonction (...)
RETURNS ...
AS
BEGIN
    ...
END;
```

### Modifier une fonction existante

```sql
ALTER FUNCTION dbo.MaFonction (...)
RETURNS ...
AS
BEGIN
    ...
END;
```

### Supprimer une fonction

```sql
-- Supprimer (génère une erreur si elle n'existe pas)
DROP FUNCTION dbo.MaFonction;

-- Supprimer seulement si elle existe
DROP FUNCTION IF EXISTS dbo.MaFonction;
```

### Afficher le code d'une fonction

```sql
-- Voir la définition
EXEC sp_helptext 'dbo.MaFonction';

-- Ou dans SSMS : clic droit > Script Function as > CREATE To
```

### Lister toutes les fonctions

```sql
-- Lister les fonctions utilisateur
SELECT
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS FunctionName,
    type_desc AS FunctionType,
    create_date,
    modify_date
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF')  -- FN=Scalar, IF=Inline Table, TF=Multi-statement Table
ORDER BY name;
```

---

## Résumé

Les **fonctions utilisateur** (UDF) en T-SQL sont des outils puissants pour :
- **Encapsuler** la logique métier réutilisable
- **Simplifier** les requêtes complexes
- **Garantir** la cohérence des calculs
- **Améliorer** la lisibilité du code

**Les trois types de fonctions :**
1. **Scalaires** : Retournent une valeur unique (⚠️ problèmes de performance)
2. **Table inline** : Retournent une table avec une seule SELECT (✅ performant)
3. **Table multi-instructions** : Retournent une table avec logique complexe (⚠️ performance moyenne)

**Points clés à retenir :**
- Les fonctions **ne peuvent pas modifier** les données
- Elles doivent être **déterministes** autant que possible
- Le choix du type de fonction impacte **fortement** les performances
- À utiliser avec **discernement** (ne pas en abuser)

**Différence avec les procédures stockées :**
- **Fonctions** : Calculent et retournent (utilisables dans SELECT)
- **Procédures** : Exécutent des actions (appelées avec EXEC)

Dans les sections suivantes, nous explorerons en détail chaque type de fonction avec des exemples concrets et des conseils de performance.

---

**Sections suivantes :**
- 5.6.1 : Fonctions scalaires en détail
- 5.6.2 : Fonctions table inline en détail
- 5.6.3 : Fonctions table multi-instructions en détail
- 5.6.4 : Limitations de performance et optimisation

⏭️ [Fonctions scalaires (Retournent une seule valeur)](/05-programmabilite-en-tsql/06.1-fonctions-scalaires.md)
