🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 2.1 Les types de données (Data Types)

## Introduction

Les types de données sont l'un des concepts fondamentaux de SQL Server et de toute base de données relationnelle. Ils définissent la nature des informations que vous pouvez stocker dans chaque colonne d'une table : des nombres, du texte, des dates, des valeurs vraies ou fausses, etc.

Comprendre les types de données est essentiel pour créer des bases de données efficaces, performantes et fiables. Un mauvais choix de type peut entraîner des problèmes de stockage, de performance, ou pire, une perte de précision dans vos données.

---

## Qu'est-ce qu'un type de données ?

Un **type de données** (ou **data type**) définit :

1. **La nature des valeurs** qui peuvent être stockées dans une colonne
2. **L'espace de stockage** nécessaire pour ces valeurs
3. **Les opérations possibles** sur ces valeurs
4. **Les contraintes** appliquées automatiquement (plage de valeurs, format, etc.)

### Analogie du monde réel

Imaginez que vous organisiez une bibliothèque :
- Les **romans** vont dans une section spécifique (type "texte long")
- Les **codes ISBN** sont des identifiants numériques (type "nombre")
- Les **dates de publication** sont des dates (type "date")
- L'**état disponible/emprunté** est un indicateur binaire (type "booléen")

Dans une base de données, c'est exactement le même principe : chaque type d'information a son "rayon" spécifique, son type de données.

---

## Pourquoi les types de données sont-ils importants ?

### 1. Intégrité des données

Les types de données garantissent que seules les valeurs valides sont stockées.

**Exemple :**
```sql
CREATE TABLE Employes (
    EmployeID INT,              -- Ne peut contenir que des nombres entiers
    DateNaissance DATE,         -- Ne peut contenir que des dates valides
    Salaire DECIMAL(10, 2)      -- Ne peut contenir que des nombres avec 2 décimales
);
```

Si vous tentez d'insérer `'abc'` dans la colonne `EmployeID`, SQL Server rejettera l'opération avec une erreur, protégeant ainsi l'intégrité de vos données.

### 2. Optimisation du stockage

Chaque type de données occupe un espace spécifique en mémoire. Choisir le bon type permet d'économiser de l'espace disque.

**Exemple :**
```sql
-- ❌ Surdimensionné
Age INT                -- Réserve 4 octets pour une valeur qui tient sur 1

-- ✅ Optimisé
Age TINYINT            -- 1 seul octet (plage 0 à 255, largement suffisante pour un âge)
```

Pour une table de 1 million de lignes, cette seule colonne occupe **4 Mo vs 1 Mo** — et l'écart se cumule sur chaque colonne surdimensionnée.

### 3. Performance des requêtes

Les opérations sur les types appropriés sont plus rapides.

**Exemple :**
```sql
-- Plus lent : comparaison de texte
SELECT * FROM Produits WHERE Prix > '100';  -- Prix stocké en VARCHAR

-- Plus rapide : comparaison numérique
SELECT * FROM Produits WHERE Prix > 100;    -- Prix stocké en DECIMAL
```

SQL Server optimise automatiquement les opérations selon le type de données utilisé.

### 4. Précision des calculs

Certains types garantissent une précision exacte, d'autres sont approximatifs.

**Exemple :**
```sql
-- DECIMAL : précision exacte (pour l'argent)
DECLARE @prix DECIMAL(10, 2) = 19.99;

-- FLOAT : précision approximative (pour les calculs scientifiques)
DECLARE @mesure FLOAT = 19.99;
```

Pour des montants financiers, utiliser `FLOAT` pourrait causer des erreurs d'arrondi catastrophiques !

### 5. Validation automatique

Les types de données valident automatiquement les entrées.

**Exemple :**
```sql
CREATE TABLE Commandes (
    DateCommande DATE,
    Quantite INT
);

-- ❌ Ces insertions échoueront automatiquement
INSERT INTO Commandes VALUES ('32/13/2024', 100);  -- Date invalide
INSERT INTO Commandes VALUES ('2024-11-15', 'abc'); -- Quantité non numérique
```

---

## Les grandes catégories de types de données

SQL Server propose de nombreux types de données, regroupés en plusieurs catégories :

### 1. Types numériques

Pour stocker des nombres entiers ou décimaux.

**Exemples :**
- `INT` : nombres entiers (-2 milliards à +2 milliards)
- `BIGINT` : très grands nombres entiers
- `DECIMAL(p, s)` : nombres avec décimales et précision exacte
- `FLOAT` : nombres avec décimales et précision approximative

**Cas d'usage :**
- Identifiants, quantités → `INT`
- Montants monétaires → `DECIMAL(18, 2)`
- Mesures scientifiques → `FLOAT`

### 2. Types de chaînes de caractères

Pour stocker du texte.

**Exemples :**
- `CHAR(n)` : texte de longueur fixe
- `VARCHAR(n)` : texte de longueur variable
- `NVARCHAR(n)` : texte de longueur variable avec support Unicode (accents, autres alphabets)

**Cas d'usage :**
- Noms, prénoms → `NVARCHAR(100)`
- Codes postaux, codes pays → `CHAR(2)` ou `VARCHAR(10)`
- Descriptions longues → `NVARCHAR(MAX)`

### 3. Types de date et heure

Pour stocker des informations temporelles.

**Exemples :**
- `DATE` : date uniquement (année, mois, jour)
- `TIME` : heure uniquement (heure, minute, seconde)
- `DATETIME2` : date et heure combinées (type moderne recommandé)

**Cas d'usage :**
- Date de naissance → `DATE`
- Horaires d'ouverture → `TIME`
- Horodatage de transaction → `DATETIME2(3)`

### 4. Types booléens et spéciaux

Pour des cas d'usage spécifiques.

**Exemples :**
- `BIT` : valeur booléenne (0/1, vrai/faux)
- `UNIQUEIDENTIFIER` : identifiant unique global (GUID)
- `BINARY/VARBINARY` : données binaires brutes

**Cas d'usage :**
- Drapeaux actif/inactif → `BIT`
- Identifiants d'API → `UNIQUEIDENTIFIER`
- Hash de mots de passe → `VARBINARY`

### 5. Types avancés

Pour des besoins spécialisés.

**Exemples :**
- `XML` : documents XML structurés
- `JSON` : stocké en `NVARCHAR` avec fonctions spéciales
- `GEOGRAPHY` : coordonnées géographiques
- `HIERARCHYID` : structures hiérarchiques

---

## Comment choisir le bon type de données ?

### Questions à se poser

Lorsque vous définissez une colonne, posez-vous ces questions :

#### 1. Quelle est la nature de l'information ?
- **Nombre** → Types numériques
- **Texte** → Types de chaînes
- **Date/heure** → Types temporels
- **Vrai/Faux** → BIT

#### 2. Quelle est la plage de valeurs ?
- **0 à 255** → TINYINT
- **-2 milliards à +2 milliards** → INT
- **Plus grand** → BIGINT

#### 3. Ai-je besoin de décimales ?
- **Non** → INT, BIGINT
- **Oui, précision exacte** → DECIMAL
- **Oui, précision approximative acceptable** → FLOAT

#### 4. Quelle est la longueur maximale du texte ?
- **Longueur fixe** (ex: codes pays) → CHAR(n)
- **Longueur variable** → VARCHAR(n) ou NVARCHAR(n)
- **Très long ou variable** → VARCHAR(MAX) ou NVARCHAR(MAX)

#### 5. Ai-je besoin de caractères internationaux ?
- **Oui** (accents, autres alphabets) → NVARCHAR, NCHAR
- **Non** (uniquement ASCII) → VARCHAR, CHAR

### Exemple de choix guidé

**Scénario :** Vous créez une table de clients.

```sql
CREATE TABLE Clients (
    -- Identifiant : nombre entier séquentiel
    ClientID INT,

    -- Nom/Prénom : texte variable, peut contenir des accents
    Nom NVARCHAR(100),
    Prenom NVARCHAR(100),

    -- Email : texte variable, uniquement ASCII
    Email VARCHAR(255),

    -- Date de naissance : date seule, pas d'heure
    DateNaissance DATE,

    -- Compte actif : vrai ou faux
    EstActif BIT,

    -- Date d'inscription : date + heure précise
    DateInscription DATETIME2(3),

    -- Solde compte : montant avec 2 décimales
    Solde DECIMAL(18, 2)
);
```

**Justification des choix :**
- `ClientID INT` : Les identifiants sont des nombres entiers
- `Nom/Prenom NVARCHAR(100)` : Noms variables, peuvent contenir des accents (François, José, Müller)
- `Email VARCHAR(255)` : Les emails sont en ASCII, longueur variable
- `DateNaissance DATE` : On ne s'intéresse qu'au jour, pas à l'heure de naissance
- `EstActif BIT` : Indicateur simple vrai/faux
- `DateInscription DATETIME2(3)` : Date et heure précise à la milliseconde
- `Solde DECIMAL(18, 2)` : Montant monétaire avec précision exacte (2 décimales)

---

## Erreurs courantes à éviter

### 1. Utiliser VARCHAR pour des nombres

```sql
-- ❌ ERREUR : stocker des nombres en texte
CREATE TABLE Produits (
    Prix VARCHAR(10)    -- "19.99" stocké comme texte
);

-- Problèmes :
-- - Impossible de faire des calculs directs
-- - Tri alphabétique au lieu de numérique ("100" < "20")
-- - Gaspillage d'espace

-- ✅ CORRECT
CREATE TABLE Produits (
    Prix DECIMAL(10, 2)  -- 19.99 stocké comme nombre
);
```

### 2. Types trop grands "par sécurité"

```sql
-- ❌ ERREUR : surdimensionnement systématique
CREATE TABLE Employes (
    Age VARCHAR(1000),           -- Un âge ne dépassera jamais 1000 caractères !
    Nom NVARCHAR(MAX)            -- Inutilement grand pour un nom
);

-- ✅ CORRECT : dimensionnement raisonnable
CREATE TABLE Employes (
    Age TINYINT,                 -- 0 à 255, largement suffisant
    Nom NVARCHAR(100)            -- 100 caractères suffisent
);
```

### 3. Oublier le support Unicode

```sql
-- ❌ ERREUR : ne pas prévoir les caractères accentués
CREATE TABLE Utilisateurs (
    Nom VARCHAR(100)    -- "François" deviendra "Francois"
);

-- ✅ CORRECT
CREATE TABLE Utilisateurs (
    Nom NVARCHAR(100)   -- Supporte "François", "José", "李明"
);
```

### 4. Utiliser FLOAT pour l'argent

```sql
-- ❌ ERREUR : FLOAT pour des montants monétaires
CREATE TABLE Commandes (
    MontantTotal FLOAT  -- Risque d'arrondi : 19.99 peut devenir 19.990000000001
);

-- ✅ CORRECT
CREATE TABLE Commandes (
    MontantTotal DECIMAL(18, 2)  -- Précision exacte garantie
);
```

### 5. Stocker des dates en texte

```sql
-- ❌ ERREUR : dates en format texte
CREATE TABLE Evenements (
    DateEvenement VARCHAR(20)    -- "15/11/2024" ou "11/15/2024" ? Ambiguïté !
);

-- ✅ CORRECT
CREATE TABLE Evenements (
    DateEvenement DATE           -- Format interne, pas d'ambiguïté
);
```

---

## Impact des types de données sur la base de données

### Impact sur l'espace disque

**Exemple concret : table de 1 million d'utilisateurs**

```sql
-- Version inefficace
CREATE TABLE UtilisateursInef (
    UserID VARCHAR(50),           -- 50 octets
    Age VARCHAR(10),              -- 10 octets
    Email VARCHAR(500),           -- 500 octets
    EstActif VARCHAR(10)          -- 10 octets
);
-- Total par ligne : ~570 octets
-- Pour 1 million d'utilisateurs : ~570 Mo

-- Version optimisée
CREATE TABLE UtilisateursOpt (
    UserID INT,                   -- 4 octets
    Age TINYINT,                  -- 1 octet
    Email VARCHAR(255),           -- ~20 octets en moyenne
    EstActif BIT                  -- 1 bit (0.125 octet)
);
-- Total par ligne : ~25 octets
-- Pour 1 million d'utilisateurs : ~25 Mo

-- Gain : 95% d'espace économisé !
```

> 📝 **Précision importante** — Un type `VARCHAR(n)` ne réserve **pas** `n` octets : il ne stocke que la longueur réellement utilisée (plus 2 octets d'en-tête). Les chiffres ci-dessus sont donc un **majorant** (pire cas). Le gain le plus sûr vient des types **à taille fixe** bien dimensionnés (`INT` → `TINYINT`, ou un `BIT` au lieu d'un texte « oui »/« non »).

### Impact sur la vitesse

Les types appropriés permettent des requêtes plus rapides :

```sql
-- Recherche sur un INT (index B-Tree efficace)
SELECT * FROM Clients WHERE ClientID = 12345;  -- Très rapide

-- vs

-- Recherche sur un VARCHAR non indexé
SELECT * FROM Clients WHERE ClientID = '12345';  -- Plus lent
```

### Impact sur l'intégrité

Les types valident automatiquement les données :

```sql
CREATE TABLE Commandes (
    Quantite INT,
    DateCommande DATE
);

-- SQL Server rejette automatiquement ces insertions invalides
INSERT INTO Commandes VALUES ('abc', '2024-11-15');     -- 'abc' n'est pas un INT
INSERT INTO Commandes VALUES (10, '32/13/2024');       -- Date invalide
INSERT INTO Commandes VALUES (10, 'hier');             -- Pas une date
```

---

## Règles d'or pour choisir les types de données

### ✅ Les bonnes pratiques

1. **Choisissez le type le plus spécifique** pour vos données
   - Pas de `VARCHAR` pour des nombres
   - Pas de `NVARCHAR(MAX)` si `NVARCHAR(100)` suffit

2. **Prévoyez une marge raisonnable**, mais sans exagérer
   - `NVARCHAR(100)` pour un nom (pas 10, pas 1000)
   - `INT` pour un compteur (pas BIGINT sauf besoin réel)

3. **Utilisez NVARCHAR par défaut pour le texte** (sauf cas spécifique)
   - Évite les problèmes d'encodage
   - Support international

4. **Pour l'argent, utilisez DECIMAL**
   - Jamais FLOAT pour des montants monétaires
   - `DECIMAL(18, 2)` est un bon standard

5. **Utilisez les types modernes**
   - `DATETIME2` au lieu de `DATETIME`
   - `VARCHAR(MAX)` au lieu de `TEXT` (obsolète)

6. **Pensez aux performances**
   - Types plus petits = index plus rapides
   - Types appropriés = meilleure optimisation des requêtes

### ❌ Les pièges à éviter

1. Ne pas stocker des données formatées (dates en texte, nombres en VARCHAR)
2. Ne pas surdimensionner systématiquement "par sécurité"
3. Ne pas oublier le support Unicode (NVARCHAR vs VARCHAR)
4. Ne pas utiliser FLOAT pour des calculs financiers
5. Ne pas ignorer NULL (prévoir si la colonne peut être NULL ou non)

---

## Vue d'ensemble des types disponibles

Voici un aperçu rapide des types que nous allons étudier en détail :

### Types numériques
- **Entiers** : TINYINT, SMALLINT, INT, BIGINT
- **Décimaux exacts** : DECIMAL, NUMERIC
- **Décimaux approximatifs** : FLOAT, REAL
- **Monétaires** : MONEY, SMALLMONEY

### Types de chaînes
- **Sans Unicode** : CHAR, VARCHAR
- **Avec Unicode** : NCHAR, NVARCHAR
- **Texte long** : VARCHAR(MAX), NVARCHAR(MAX)

### Types temporels
- **Date seule** : DATE
- **Heure seule** : TIME
- **Date + Heure** : DATETIME2, DATETIME, SMALLDATETIME
- **Avec fuseau horaire** : DATETIMEOFFSET

### Types spéciaux
- **Booléen** : BIT
- **Identifiant unique** : UNIQUEIDENTIFIER
- **Binaire** : BINARY, VARBINARY
- **XML** : XML
- **Spatial** : GEOGRAPHY, GEOMETRY
- **Hiérarchique** : HIERARCHYID

---

## Exemple récapitulatif complet

Voici un exemple de table bien conçue utilisant les types appropriés :

```sql
CREATE TABLE Commandes (
    -- Identifiant auto-incrémenté
    CommandeID INT IDENTITY(1,1) PRIMARY KEY,

    -- Identifiant unique pour API externe
    CommandeGUID UNIQUEIDENTIFIER DEFAULT NEWID(),

    -- Référence client
    ClientID INT NOT NULL,

    -- Numéro de commande visible (format texte)
    NumeroCommande VARCHAR(20) NOT NULL,

    -- Date et heure de la commande
    DateCommande DATETIME2(3) DEFAULT SYSDATETIME(),

    -- Statut de la commande
    Statut NVARCHAR(50) NOT NULL,

    -- Montants (précision exacte)
    MontantHT DECIMAL(18, 2) NOT NULL,
    TauxTVA DECIMAL(5, 4) NOT NULL,
    MontantTTC DECIMAL(18, 2) NOT NULL,

    -- Indicateurs
    EstPayee BIT DEFAULT 0,
    EstLivree BIT DEFAULT 0,
    EstAnnulee BIT DEFAULT 0,

    -- Adresse de livraison (peut contenir accents)
    AdresseLivraison NVARCHAR(500),

    -- Commentaires optionnels
    Commentaires NVARCHAR(MAX),

    -- Audit : qui et quand
    DateCreation DATETIME2(3) DEFAULT SYSDATETIME(),
    DateModification DATETIME2(3),
    UtilisateurModification NVARCHAR(100)
);
```

**Pourquoi ces choix ?**
- `INT IDENTITY` : identifiant interne efficace
- `UNIQUEIDENTIFIER` : pour exposer en API sans révéler les IDs séquentiels
- `VARCHAR(20)` : numéro de commande en format texte standardisé
- `DATETIME2(3)` : précision à la milliseconde pour les timestamps
- `DECIMAL(18, 2)` : montants avec 2 décimales
- `BIT` : indicateurs booléens
- `NVARCHAR` : texte pouvant contenir des accents
- `NVARCHAR(MAX)` : commentaires de longueur variable

---

## Prochaines étapes

Maintenant que vous comprenez l'importance des types de données et leur impact, nous allons explorer en détail chaque catégorie :

1. **Types numériques** : INT, DECIMAL, FLOAT et leurs variantes
2. **Types de chaînes** : CHAR, VARCHAR, NCHAR, NVARCHAR
3. **Types temporels** : DATE, TIME, DATETIME2
4. **Autres types** : BIT, UNIQUEIDENTIFIER, BINARY, XML, etc.

Chaque section approfondira les spécificités, les cas d'usage, et les bonnes pratiques pour chaque type.

---

## Conclusion

Les types de données sont la fondation de toute base de données bien conçue. Ils garantissent :

- ✅ **L'intégrité** : seules les données valides sont acceptées
- ✅ **La performance** : opérations optimisées selon le type
- ✅ **L'espace** : stockage efficace des informations
- ✅ **La précision** : calculs exacts quand nécessaire
- ✅ **La clarté** : intention explicite du concepteur

**Règle d'or** : Prenez le temps de choisir le bon type dès le départ. Changer le type d'une colonne sur une table contenant des millions de lignes est coûteux et risqué !

Dans les sections suivantes, nous allons approfondir chaque catégorie de types pour que vous puissiez faire les meilleurs choix pour vos bases de données SQL Server.

⏭️ [Types numériques (INT, DECIMAL, NUMERIC, FLOAT)](/02-definition-et-manipulation-des-donnees/01.1-types-numeriques.md)
