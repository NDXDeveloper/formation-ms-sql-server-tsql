🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 8.10 In-Memory OLTP (tables à mémoire optimisée)

## Introduction

Certaines applications doivent encaisser un **débit de transactions colossal** : une plateforme de trading, un site qui enregistre des millions de clics, un système d'ingestion de données IoT, un jeu en ligne gérant des sessions par centaines de milliers. Sur ces charges extrêmes, même une base bien indexée finit par buter sur un obstacle invisible : la **contention** — les transactions passent leur temps à **s'attendre les unes les autres** à cause des verrous (*locks*) et des verrous internes (*latches*).

Pour répondre à ce besoin, SQL Server propose depuis la version **2014** une technologie appelée **In-Memory OLTP** (nom de code **Hekaton**). Elle repose sur des **tables à mémoire optimisée** et des **procédures stockées compilées nativement**, capables d'offrir des gains de performance pouvant atteindre **10× à 30×** sur les charges OLTP les plus intenses.

---

## Le problème : la contention des verrous

Sur une table classique très sollicitée, beaucoup de transactions veulent écrire **au même endroit en même temps**. SQL Server protège alors la cohérence avec :

- des **verrous (locks)** sur les lignes/pages (vus au chapitre 6) ;
- des **latches**, des verrous internes très courts sur les structures mémoire (pages).

Quand des milliers de transactions se bousculent, ces protections deviennent elles-mêmes le **goulot d'étranglement** : les transactions font la queue.

> 🧠 **Analogie** : imaginez un supermarché avec une **seule caisse** (le verrou). Peu importe le nombre de clients, ils attendent tous en file. In-Memory OLTP, c'est passer à un système où **chaque client scanne ses articles en parallèle**, sans file d'attente partagée.

---

## La réponse : In-Memory OLTP

In-Memory OLTP repose sur **deux piliers** qui se complètent :

### 1. Les tables à mémoire optimisée (memory-optimized tables)

- Les données résident **entièrement en mémoire vive** (RAM), avec des structures conçues pour l'accès concurrent.
- Elles utilisent un mécanisme **sans verrou ni latch** (*lock-free*), fondé sur le **multi-versioning optimiste** (MVCC) : au lieu de verrouiller, chaque transaction travaille sur sa **propre version** cohérente des données.
- La durabilité est assurée par le journal et des fichiers de points de contrôle (sauf si l'on choisit explicitement de ne pas conserver les données).

### 2. Les procédures stockées compilées nativement (natively compiled)

- Une procédure classique est **interprétée** à chaque exécution. Une procédure compilée nativement est traduite en **code machine** (une DLL) une fois pour toutes.
- Combinée aux tables à mémoire optimisée, elle réduit énormément le nombre d'instructions CPU par transaction.

```
   ┌─────────────────────────────┐      ┌─────────────────────────────┐
   │ Tables à mémoire optimisée  │  +   │ Procédures compilées        │
   │ (RAM, sans verrou, MVCC)    │      │ nativement (code machine)   │
   └─────────────────────────────┘      └─────────────────────────────┘
                       │                                │
                       └───────────────┬────────────────┘
                                       ▼
                         Débit transactionnel extrême
```

---

## Un aperçu concret

```sql
-- 1) La base doit avoir un groupe de fichiers dédié à la mémoire optimisée
ALTER DATABASE Boutique
ADD FILEGROUP fg_memoire CONTAINS MEMORY_OPTIMIZED_DATA;

ALTER DATABASE Boutique
ADD FILE (NAME = 'memoire', FILENAME = 'D:\Data\Boutique_memoire')
TO FILEGROUP fg_memoire;

-- 2) Une table à mémoire optimisée, durable
CREATE TABLE SessionsActives (
    SessionID   UNIQUEIDENTIFIER NOT NULL
        PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 1000000),
    Utilisateur NVARCHAR(100)    NOT NULL,
    DerniereVue DATETIME2        NOT NULL
)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
```

---

## Ce que vous allez apprendre dans cette section

| Sous-section | Sujet |
|--------------|-------|
| **8.10.1** | Tables à mémoire optimisée et concurrence optimiste (MVCC) |
| **8.10.2** | Procédures stockées compilées en mode natif |
| **8.10.3** | Cas d'usage et limites |

---

## Quand l'utiliser (et quand l'éviter)

✅ **Pertinent pour :**
- Les **points chauds** d'écriture : ingestion haute fréquence, compteurs, files d'attente.
- Les tables de **sessions**, de **staging** temporaire (chargement ETL).
- Les goulots de contention identifiés (beaucoup d'attente sur verrous/latches).

❌ **Inutile ou risqué pour :**
- Les bases dont les performances sont déjà satisfaisantes (complexité non justifiée).
- Les très **grandes tables** qui ne tiendraient pas en mémoire.
- Les charges **analytiques** (c'est le rôle du columnstore, voir §8.7).

> 💡 In-Memory OLTP n'est **pas** une optimisation « à activer partout ». C'est un outil de **niche**, à réserver aux véritables goulots de contention, après les avoir mesurés (voir §7.3).

---

## Pièges courants

| Piège | Conséquence | Bon réflexe |
|-------|-------------|-------------|
| Activer In-Memory **partout** | Complexité inutile, peu de gain | Cibler un **point chaud mesuré** de contention |
| L'utiliser pour de l'**analytique** | Mauvais outil | L'analytique, c'est le **columnstore** (§8.7) |
| Table trop grande pour la **RAM** | Échec / pression mémoire | Vérifier que les données tiennent en mémoire |
| Oublier la logique de **retry** | Transactions qui échouent au commit | Gérer les conflits optimistes (erreurs 413xx) |
| Mauvais choix de `DURABILITY` | Perte de données inattendue | `SCHEMA_AND_DATA` si les données doivent survivre |

## Questions fréquentes

**Q : Faut-il l'édition Enterprise ?**
R : Non. In-Memory OLTP est disponible dans **toutes les éditions depuis SQL Server 2016 SP1** (avec une limite de mémoire par base hors Enterprise/Developer).

**Q : Toutes mes données doivent-elles tenir en mémoire ?**
R : Oui, une table à mémoire optimisée réside **entièrement en RAM**. C'est la première contrainte à vérifier.

**Q : Peut-on mélanger tables classiques et tables à mémoire optimisée ?**
R : Oui. Elles cohabitent dans la même base ; on y accède en T-SQL classique (*interop*) ou via des procédures natives.

---

## Résumé

- **In-Memory OLTP** (Hekaton, depuis SQL 2014) vise les charges OLTP à **très fort débit** freinées par la **contention** des verrous.
- Deux piliers : les **tables à mémoire optimisée** (en RAM, sans verrou, multi-version optimiste) et les **procédures compilées nativement** (code machine).
- Gains possibles de **10× à 30×** sur les bons cas d'usage.
- À réserver aux **points chauds** de contention, pas à activer aveuglément ; les données doivent tenir en **mémoire**.

Entrons dans le détail des tables à mémoire optimisée et du modèle de concurrence qui les rend si rapides.

---

⏭️ [Tables à mémoire optimisée et concurrence optimiste (MVCC)](/08-sujets-complementaires-et-ecosysteme/10.1-tables-memoire-optimisee.md)
