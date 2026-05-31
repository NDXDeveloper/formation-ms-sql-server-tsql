🔝 Retour au [Sommaire](/SOMMAIRE.md)

# Annexe B — Base de données d'exemple

## Introduction

Pour apprendre, rien ne vaut la **pratique sur des données**. Cette annexe vous fournit deux bases d'exemple :

1. La **base « maison » `Boutique`** : légère, simple, **cohérente avec les exemples du cours** (Clients, Commandes, Produits…). Idéale pour les **chapitres 1 à 5** et la plupart des exercices.
2. **WideWorldImporters** : la base d'exemple **officielle de Microsoft**, plus riche et moderne. Idéale pour les **chapitres 7 et 8** (index, columnstore, JSON, tables temporelles…).

---

## La base « maison » Boutique

### Pourquoi une base maison ?

- 🎯 **Simple** : 6 tables, faciles à appréhender d'un coup d'œil.
- 🔗 **Cohérente avec le cours** : on retrouve les entités vues dès le §1.1.2 (modèle relationnel).
- 🧪 **Idéale pour s'exercer** : assez riche pour pratiquer jointures, agrégations, sous-requêtes, fonctions de fenêtrage, transactions…

### Le modèle de données

```
┌────────────┐         ┌──────────────┐
│ Categories │         │   Clients    │
└─────┬──────┘         └──────┬───────┘
      │ 1                     │ 1
      │                       │
      │ N                     │ N
┌─────▼──────┐         ┌──────▼───────┐        ┌────────────┐
│  Produits  │         │  Commandes   │◀───────│  Employes  │
└─────┬──────┘         └──────┬───────┘ N    1 └─────┬──────┘
      │ 1                     │ 1                    │ (self-join
      │                       │                      │  ManagerID)
      │ N                     │ N                    ▼
      │              ┌────────▼─────────┐         (hiérarchie)
      └─────────────▶│  LignesCommande  │
                  N  └──────────────────┘
```

| Table | Rôle | Concepts illustrés |
|-------|------|--------------------|
| `Categories` | Catégories de produits | Relation 1:N |
| `Produits` | Catalogue | FK, CHECK, DEFAULT |
| `Clients` | Clients de la boutique | UNIQUE (email), DATE |
| `Employes` | Personnel | **Self-join** (ManagerID), hiérarchie |
| `Commandes` | Commandes passées | FK multiples, CHECK (statut) |
| `LignesCommande` | Détail des commandes | Table de jonction (N:M résolu) |

### Installation

1. Connectez-vous à votre instance (voir [annexe A](/09-annexes/A-guide-installation.md)).
2. Ouvrez et exécutez le script **[`boutique-creation.sql`](/09-annexes/B-base-exemple/boutique-creation.sql)**.
3. Le script crée la base `Boutique`, ses tables, ses contraintes, et insère un jeu de données cohérent.

```sql
-- En ligne de commande (sqlcmd) :
-- sqlcmd -S localhost -U sa -P "MotDePasse!" -i boutique-creation.sql
```

### Vérification

```sql
USE Boutique;
GO
SELECT 'Clients' AS Table_, COUNT(*) AS Lignes FROM Clients
UNION ALL SELECT 'Produits', COUNT(*) FROM Produits
UNION ALL SELECT 'Commandes', COUNT(*) FROM Commandes
UNION ALL SELECT 'LignesCommande', COUNT(*) FROM LignesCommande
UNION ALL SELECT 'Employes', COUNT(*) FROM Employes
UNION ALL SELECT 'Categories', COUNT(*) FROM Categories;
```

> 💡 Le script est **ré-exécutable** : il supprime puis recrée la base `Boutique`. Ne l'exécutez donc pas sur une vraie base de ce nom !

---

## WideWorldImporters (base officielle Microsoft)

Pour les chapitres avancés, WideWorldImporters (WWI) offre un schéma réaliste exploitant des fonctionnalités modernes : **tables temporelles**, **JSON**, **columnstore**, partitionnement…

### Téléchargement et restauration

1. Téléchargez le fichier de sauvegarde **`WideWorldImporters-Full.bak`** depuis le dépôt officiel Microsoft (« sql-server-samples » sur GitHub, section *releases*).
2. Restaurez-le (voir §7.8.4 sur la restauration) :

```sql
RESTORE DATABASE WideWorldImporters
FROM DISK = 'C:\Backups\WideWorldImporters-Full.bak'
WITH
    MOVE 'WWI_Primary'   TO 'C:\Data\WideWorldImporters.mdf',
    MOVE 'WWI_UserData'  TO 'C:\Data\WideWorldImporters_UserData.ndf',
    MOVE 'WWI_Log'       TO 'C:\Data\WideWorldImporters.ldf',
    MOVE 'WWI_InMemory_Data_1' TO 'C:\Data\WideWorldImporters_InMemory_Data_1',
    RECOVERY, REPLACE;
```

> 💡 Les **noms logiques** exacts s'obtiennent avec `RESTORE FILELISTONLY FROM DISK = '...'` (voir §7.8.3). Adaptez les chemins `MOVE` à votre installation.

> ⚠️ WWI contient un groupe de fichiers **In-Memory OLTP** (voir §8.10). Si votre édition ne le supporte pas, utilisez la version « Standard » de la sauvegarde, sans In-Memory.

### Quand utiliser WWI plutôt que Boutique ?

| Chapitre / sujet | Base conseillée |
|------------------|-----------------|
| Ch. 1 à 5 (fondamentaux, DML, SELECT, programmabilité) | **Boutique** (maison) |
| Ch. 6 (transactions) | Boutique ou WWI |
| Ch. 7 (index, perf), §8.7 columnstore | **WideWorldImporters** (gros volumes) |
| §8.1-8.3 (XML, JSON, temporel) | **WideWorldImporters** (exemples intégrés) |

---

## Résumé

- La base **`Boutique`** (maison, 6 tables) est légère et cohérente avec le cours : idéale pour les fondamentaux et les exercices (chapitres 1 à 5).
- Le script **`boutique-creation.sql`** crée tout (tables, contraintes, données) et est ré-exécutable.
- **WideWorldImporters** (officielle Microsoft) sert aux chapitres avancés (volumes, fonctionnalités modernes) ; on la met en place par **restauration** d'une sauvegarde.

Une fois votre base en place, place à la pratique avec les exercices !

---

⏭️ [Annexe C — Exercices et TP corrigés](/09-annexes/C-exercices/README.md)
