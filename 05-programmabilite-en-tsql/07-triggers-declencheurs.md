🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 5.7 Triggers (Déclencheurs)

## Introduction générale

Bienvenue dans le chapitre sur les **triggers** (déclencheurs en français) ! Les triggers sont l'un des outils les plus puissants et les plus sophistiqués de SQL Server. Ils permettent d'automatiser des actions en réponse à des événements spécifiques dans la base de données.

### Qu'est-ce qu'un trigger ?

Un **trigger** est un type spécial de procédure stockée qui s'exécute **automatiquement** lorsqu'un événement particulier se produit dans la base de données. Contrairement aux procédures stockées classiques que vous appelez explicitement avec `EXEC`, les triggers se déclenchent "tout seuls" en réaction à certaines actions.

### Analogie du monde réel

Pour bien comprendre le concept, imaginez plusieurs situations du quotidien :

**1. Système d'alarme de maison**
- Vous ne déclenchez pas manuellement l'alarme quand un intrus entre
- L'alarme se déclenche automatiquement quand une porte ou fenêtre s'ouvre
- C'est exactement ainsi que fonctionne un trigger : il "surveille" et réagit automatiquement

**2. Détecteur de fumée**
- Personne ne dit au détecteur "vérifie s'il y a de la fumée"
- Le détecteur vérifie constamment et réagit dès qu'il détecte de la fumée
- Un trigger fait la même chose : il surveille en permanence et réagit aux événements

**3. Boîte mail avec règles automatiques**
- Vous configurez une règle : "Si un email arrive de mon patron, le marquer comme important"
- La règle s'applique automatiquement, sans que vous ayez à le faire manuellement
- C'est le même principe qu'un trigger : une fois configuré, il agit automatiquement

### Caractéristique fondamentale : L'automaticité

La caractéristique principale d'un trigger est qu'il s'exécute **sans intervention humaine**. Une fois créé :
- ✅ Il surveille automatiquement la table ou la base de données
- ✅ Il se déclenche instantanément quand l'événement se produit
- ✅ Il exécute son code sans que personne ne l'appelle explicitement
- ✅ Il est invisible pour l'utilisateur qui effectue l'opération

### Exemple simple pour comprendre

Imaginez que vous voulez garder une trace de toutes les modifications de salaire dans votre entreprise. Sans trigger, vous devriez :

```sql
-- À chaque fois qu'on modifie un salaire, il faudrait faire :

-- Étape 1 : Modifier le salaire
UPDATE Employes SET Salaire = 35000 WHERE EmployeID = 1;

-- Étape 2 : Enregistrer manuellement dans l'audit
INSERT INTO Audit_Salaires (EmployeID, AncienSalaire, NouveauSalaire, Date)
VALUES (1, 30000, 35000, GETDATE());
```

**Problèmes de cette approche** :
- ❌ Il faut se rappeler de faire l'étape 2 à chaque fois
- ❌ Si quelqu'un oublie, l'audit est incomplet
- ❌ Il faut connaître l'ancien salaire pour l'enregistrer
- ❌ Duplication de code partout dans l'application

**Avec un trigger**, c'est automatique :

```sql
-- Vous créez le trigger une seule fois :
CREATE TRIGGER trg_Audit_Salaire
ON Employes
AFTER UPDATE
AS
BEGIN
    -- Ce code s'exécutera AUTOMATIQUEMENT à chaque UPDATE
    INSERT INTO Audit_Salaires (EmployeID, AncienSalaire, NouveauSalaire, Date)
    SELECT
        i.EmployeID,
        d.Salaire,  -- Ancien salaire
        i.Salaire,  -- Nouveau salaire
        GETDATE()
    FROM INSERTED i
    INNER JOIN DELETED d ON i.EmployeID = d.EmployeID
    WHERE i.Salaire != d.Salaire;
END;

-- Ensuite, à chaque modification de salaire :
UPDATE Employes SET Salaire = 35000 WHERE EmployeID = 1;
-- Le trigger s'exécute automatiquement !
-- L'audit est enregistré sans que personne n'ait à y penser !
```

**Avantages** :
- ✅ L'audit est garanti à 100% (impossible à oublier)
- ✅ Code centralisé en un seul endroit
- ✅ Pas besoin de connaître l'ancien salaire (le trigger le récupère lui-même)
- ✅ Fonctionne quelle que soit l'application qui modifie les données

## Les grandes familles de triggers

SQL Server propose plusieurs types de triggers, chacun ayant un rôle spécifique. Voici une vue d'ensemble :

### 1. Triggers DML (Data Manipulation Language)

Les triggers DML réagissent aux opérations qui **modifient les données** dans les tables :

**Événements surveillés** :
- **INSERT** : Quand de nouvelles lignes sont ajoutées
- **UPDATE** : Quand des lignes existantes sont modifiées
- **DELETE** : Quand des lignes sont supprimées

**Deux variantes** :
- **AFTER** (ou FOR) : S'exécute après que l'opération a été effectuée
- **INSTEAD OF** : Remplace complètement l'opération

**Exemple d'utilisation** : Auditer les modifications, valider les données, maintenir des totaux calculés

### 2. Triggers DDL (Data Definition Language)

Les triggers DDL réagissent aux opérations qui **modifient la structure** de la base de données :

**Événements surveillés** :
- **CREATE** : Création d'objets (tables, vues, procédures, etc.)
- **ALTER** : Modification d'objets
- **DROP** : Suppression d'objets

**Deux niveaux possibles** :
- **Niveau DATABASE** : Surveille une base de données spécifique
- **Niveau SERVER** : Surveille tout le serveur SQL Server

**Exemple d'utilisation** : Auditer les changements de structure, empêcher la suppression de tables critiques, forcer des standards de nommage

### Tableau récapitulatif

| Type | Cible | Événements | Usage principal |
|------|-------|-----------|-----------------|
| **DML AFTER** | Tables (données) | INSERT, UPDATE, DELETE | Audit, validation après opération |
| **DML INSTEAD OF** | Tables ou Vues (données) | INSERT, UPDATE, DELETE | Remplacement complet de l'opération |
| **DDL DATABASE** | Base de données (structure) | CREATE, ALTER, DROP | Audit de structure, protection |
| **DDL SERVER** | Serveur entier (structure) | CREATE DATABASE, DROP DATABASE, etc. | Audit serveur, gouvernance |

## Concepts clés à comprendre

Avant d'entrer dans les détails techniques, voici quelques concepts fondamentaux sur les triggers :

### Concept 1 : Exécution dans une transaction

Les triggers s'exécutent **dans la même transaction** que l'opération qui les a déclenchés. Cela signifie :

- Si le trigger échoue → L'opération entière est annulée (ROLLBACK)
- Si vous faites un ROLLBACK dans le trigger → L'opération initiale est aussi annulée
- La transaction se termine seulement quand le trigger se termine

**Visualisation** :

```
┌─────────────────── TRANSACTION ───────────────────┐
│                                                   │
│  1. BEGIN TRANSACTION (implicite)                 │
│  2. Exécution de l'opération (INSERT/UPDATE/etc.) │
│  3. Exécution du trigger                          │
│  4. Si tout OK : COMMIT                           │
│  5. Si erreur : ROLLBACK                          │
│                                                   │
└───────────────────────────────────────────────────┘
```

### Concept 2 : Tables virtuelles INSERTED et DELETED

Les triggers DML ont accès à deux tables spéciales et temporaires :

**INSERTED** :
- Contient les nouvelles données
- Présente dans les triggers INSERT (nouvelles lignes) et UPDATE (valeurs après modification)

**DELETED** :
- Contient les anciennes données
- Présente dans les triggers DELETE (lignes supprimées) et UPDATE (valeurs avant modification)

**Important** : Ces tables ont automatiquement la même structure que la table qui déclenche le trigger.

### Concept 3 : Un trigger = Une exécution par instruction

Un point crucial à comprendre : le trigger s'exécute **une seule fois par instruction SQL**, même si cette instruction affecte plusieurs lignes.

```sql
-- Cette instruction insère 3 lignes
INSERT INTO Clients (Nom, Prenom)
VALUES
    ('Dupont', 'Jean'),
    ('Martin', 'Marie'),
    ('Durand', 'Pierre');

-- Le trigger INSERT s'exécute UNE SEULE FOIS
-- et la table INSERTED contient les 3 lignes
```

**Conséquence importante** : Votre code de trigger doit toujours être capable de traiter plusieurs lignes, pas seulement une !

### Concept 4 : Invisibilité pour l'utilisateur

Quand un trigger s'exécute, l'utilisateur qui a lancé l'opération ne le voit pas :

```sql
-- L'utilisateur écrit simplement :
INSERT INTO Clients (Nom, Prenom) VALUES ('Dupont', 'Jean');

-- Il voit le message : "1 ligne affectée"

-- Mais en coulisse, le trigger peut avoir :
-- - Inséré une ligne dans une table d'audit
-- - Mis à jour des statistiques
-- - Envoyé une notification
-- - Vérifié des règles métier
-- L'utilisateur ne voit rien de tout cela !
```

C'est à la fois :
- ✅ **Un avantage** : Centralisation, automatisation garantie
- ⚠️ **Un risque** : Comportements cachés, difficulté de débogage

### Concept 5 : Ordre d'exécution

Si vous avez plusieurs triggers sur la même table pour le même événement, SQL Server les exécute dans un ordre que vous pouvez contrôler (avec `sp_settriggerorder`), mais en général :
- Tous les triggers AFTER s'exécutent les uns après les autres
- L'ordre n'est pas garanti sauf si vous le spécifiez explicitement

## Structure d'un trigger

Bien que nous verrons la syntaxe détaillée dans les sections suivantes, voici la structure générale d'un trigger :

```sql
CREATE TRIGGER nom_du_trigger
ON nom_de_la_table_ou_vue
{AFTER | INSTEAD OF} {INSERT | UPDATE | DELETE}
AS
BEGIN
    -- Votre code T-SQL ici

    -- Accès aux données via INSERTED et DELETED (pour triggers DML)
    -- Accès aux informations via EVENTDATA() (pour triggers DDL)

    -- Vous pouvez :
    -- - Faire des SELECT, INSERT, UPDATE, DELETE sur d'autres tables
    -- - Valider des conditions
    -- - Faire des ROLLBACK pour annuler l'opération
    -- - Enregistrer des audits
    -- - Etc.
END;
```

## Avantages des triggers

### ✅ Garantie d'exécution
Une fois créé, un trigger s'exécute toujours. Impossible à oublier ou à contourner (sauf à le désactiver explicitement).

### ✅ Centralisation de la logique
Au lieu d'avoir du code répété dans 10 applications différentes, la logique est centralisée dans la base de données.

### ✅ Indépendance de l'application
Peu importe quelle application modifie les données (application web, script, import manuel), le trigger s'exécute.

### ✅ Protection des données
Les triggers peuvent valider et empêcher des modifications dangereuses.

### ✅ Audit complet
Vous pouvez tracer toutes les modifications sans dépendre de la bonne volonté des développeurs.

## Inconvénients et risques des triggers

### ⚠️ Complexité cachée
Le code s'exécute "en coulisse". Les développeurs peuvent ne pas savoir qu'un trigger existe.

### ⚠️ Difficultés de débogage
Quand quelque chose ne fonctionne pas comme prévu, il peut être difficile de trouver que c'est à cause d'un trigger.

### ⚠️ Impact sur les performances
Chaque trigger ajoute du temps de traitement. Des triggers mal écrits peuvent sérieusement ralentir la base de données.

### ⚠️ Cascades incontrôlables
Un trigger sur la table A peut modifier la table B, ce qui déclenche un trigger sur B, qui modifie C... Cela peut devenir ingérable.

### ⚠️ Effets de bord inattendus
Une simple insertion peut avoir des effets secondaires non documentés si des triggers complexes sont présents.

## Quand et pourquoi utiliser des triggers ?

Cette question sera détaillée dans la section 5.7.1, mais voici un aperçu :

### Cas d'usage appropriés

**Audit et traçabilité** - ⭐ Usage recommandé
```
Enregistrer qui a modifié quoi et quand
```

**Intégrité référentielle complexe** - ⭐ Usage recommandé
```
Règles métier qui dépassent les contraintes FOREIGN KEY standards
```

**Dénormalisation contrôlée** - ✅ Usage acceptable
```
Maintenir des totaux calculés pour améliorer les performances
```

**Validation de données complexe** - ✅ Usage acceptable
```
Règles qui dépassent ce que peut faire une contrainte CHECK
```

### Cas d'usage déconseillés

**Logique métier applicative** - ❌ À éviter
```
Les règles métier complexes devraient rester dans l'application
```

**Opérations longues** - ❌ À éviter
```
Envoi d'emails, appels API, calculs lourds
```

**Compenser une mauvaise conception** - ❌ À éviter
```
Si vous avez besoin d'un trigger pour "réparer" votre modèle,
repensez plutôt votre modèle
```

## Règles d'or pour les triggers

Avant de plonger dans les détails techniques, gardez ces principes en tête :

### 1. 🎯 Simplicité
Plus un trigger est simple, plus il est facile à comprendre, maintenir et déboguer.

### 2. 📖 Documentation
Documentez abondamment chaque trigger : que fait-il, pourquoi existe-t-il, quelles tables modifie-t-il.

### 3. ⚡ Performance
Gardez vos triggers rapides. Ils s'exécutent dans la transaction de l'utilisateur et la bloquent.

### 4. 🔍 Visibilité
Communiquez l'existence des triggers à l'équipe. Ne les laissez pas être des "surprises".

### 5. 🧪 Tests
Testez toujours vos triggers avec plusieurs lignes, pas juste une seule.

### 6. 🛡️ Gestion d'erreur
Utilisez TRY...CATCH pour gérer les erreurs proprement.

### 7. 📊 Audit des triggers
Gardez une trace des triggers eux-mêmes : quand ont-ils été créés, modifiés, par qui.

## Conventions de nommage recommandées

Une bonne convention de nommage aide à identifier rapidement les triggers :

### Format suggéré

```
trg_[NomTable]_[TypeOperation]_[Description]
```

### Exemples

```sql
-- Triggers DML
trg_Clients_Insert_Audit          -- Audit des insertions de clients
trg_Employes_Update_Salaire       -- Gestion des mises à jour de salaire
trg_Commandes_Delete_Prevention   -- Empêche la suppression de commandes
trg_Produits_Update_Stock         -- Met à jour les stocks

-- Triggers DDL
trg_Audit_DDL_Complete            -- Audit complet des opérations DDL
trg_Prevent_Drop_Tables           -- Empêche la suppression de tables
trg_Enforce_Naming_Standards      -- Force les standards de nommage
```

### Préfixes alternatifs

Certaines équipes utilisent d'autres préfixes :
- `trigger_` : Plus explicite mais plus long
- `tr_` : Plus court
- `t_` : Très court mais moins clair

**Recommandation** : Choisissez une convention et respectez-la systématiquement dans toute votre base de données !

## Outils pour gérer les triggers

### Voir tous les triggers d'une table

```sql
-- Liste des triggers sur une table spécifique
SELECT
    name AS NomTrigger,
    is_disabled AS EstDesactive,
    create_date AS DateCreation,
    modify_date AS DateModification
FROM sys.triggers
WHERE parent_id = OBJECT_ID('Clients');
```

### Voir tous les triggers de la base de données

```sql
-- Tous les triggers DML
SELECT
    OBJECT_NAME(parent_id) AS NomTable,
    name AS NomTrigger,
    type_desc AS TypeTrigger,
    is_disabled AS EstDesactive
FROM sys.triggers
WHERE parent_class = 1  -- 1 = table ou vue
ORDER BY OBJECT_NAME(parent_id), name;
```

### Voir le code source d'un trigger

```sql
-- Afficher le code d'un trigger
SELECT OBJECT_DEFINITION(OBJECT_ID('trg_Clients_Audit_Insert'));

-- Ou utiliser sp_helptext
EXEC sp_helptext 'trg_Clients_Audit_Insert';
```

### Désactiver/Réactiver un trigger

```sql
-- Désactiver temporairement
DISABLE TRIGGER trg_Clients_Audit_Insert ON Clients;

-- Réactiver
ENABLE TRIGGER trg_Clients_Audit_Insert ON Clients;

-- Désactiver TOUS les triggers d'une table
DISABLE TRIGGER ALL ON Clients;

-- Réactiver TOUS les triggers d'une table
ENABLE TRIGGER ALL ON Clients;
```

## Organisation de ce chapitre

Dans les sections suivantes, nous allons explorer en détail :

### 5.7.1 - Concepts : Quand les utiliser (et quand ne pas les utiliser)
Nous approfondirons les cas d'usage appropriés et les pièges à éviter. Cette section vous aidera à décider si un trigger est la bonne solution pour votre problème.

### 5.7.2 - Triggers DML (AFTER / FOR)
Nous verrons comment créer des triggers qui s'exécutent **après** les opérations INSERT, UPDATE et DELETE. C'est le type de trigger le plus couramment utilisé.

### 5.7.3 - Les tables virtuelles INSERTED et DELETED
Une plongée profonde dans ces tables spéciales qui contiennent les données modifiées. Comprendre ces tables est crucial pour écrire des triggers efficaces.

### 5.7.4 - Triggers INSTEAD OF
Nous explorerons les triggers qui **remplacent** complètement l'opération initiale. Très utiles pour rendre des vues complexes modifiables.

### 5.7.5 - Triggers DDL (Niveau serveur ou base de données)
Enfin, nous verrons comment surveiller et contrôler les changements de structure de votre base de données avec les triggers DDL.

## Prérequis pour bien comprendre ce chapitre

Avant de continuer, assurez-vous d'être à l'aise avec :

- ✅ **Les opérations DML** : INSERT, UPDATE, DELETE
- ✅ **Les procédures stockées** : Structure de base, BEGIN/END
- ✅ **Les transactions** : COMMIT, ROLLBACK, concept de transaction
- ✅ **La gestion d'erreur** : TRY...CATCH
- ✅ **Les jointures** : INNER JOIN, nécessaire pour utiliser INSERTED/DELETED
- ✅ **Le XML de base** : Pour les triggers DDL qui utilisent EVENTDATA()

Si vous n'êtes pas sûr de certains concepts, il peut être utile de réviser les chapitres correspondants avant de continuer.

## Environnement de test

Avant de créer des triggers en production, il est fortement recommandé de les tester dans un environnement de développement ou de test. Voici comment créer un environnement simple pour expérimenter :

```sql
-- Créer une base de données de test
CREATE DATABASE TestTriggers;
GO

USE TestTriggers;
GO

-- Créer des tables simples pour tester
CREATE TABLE Clients (
    ClientID INT IDENTITY(1,1) PRIMARY KEY,
    Nom VARCHAR(50),
    Prenom VARCHAR(50),
    Email VARCHAR(100),
    DateInscription DATE DEFAULT GETDATE()
);

CREATE TABLE Audit_Clients (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    ClientID INT,
    Action VARCHAR(20),
    DateAction DATETIME DEFAULT GETDATE(),
    Utilisateur VARCHAR(100) DEFAULT SYSTEM_USER
);

-- Maintenant vous pouvez créer et tester des triggers sur ces tables
```

## Mot de la fin de l'introduction

Les triggers sont des outils puissants qui, utilisés correctement, peuvent grandement améliorer l'intégrité, la sécurité et la traçabilité de vos bases de données. Cependant, ils doivent être utilisés avec parcimonie et intelligence.

**Principe directeur** :
> "Un trigger devrait être comme un agent de sécurité discret : toujours vigilant, qui intervient seulement quand nécessaire, et dont l'action est rapide et efficace."

N'oubliez jamais :
- 🎯 Gardez-les simples
- 📖 Documentez-les abondamment
- 🧪 Testez-les minutieusement
- 💬 Communiquez leur existence à votre équipe

Prêt à plonger dans le monde des triggers ? Commençons par la section suivante qui vous aidera à déterminer quand (et quand ne pas) utiliser des triggers !

---


⏭️ [Concepts : Quand les utiliser (et quand ne pas les utiliser)](/05-programmabilite-en-tsql/07.1-concepts-quand-utiliser-triggers.md)
