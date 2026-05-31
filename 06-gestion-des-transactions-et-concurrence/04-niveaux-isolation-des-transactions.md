🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 6.4 Niveaux d'isolation des transactions

## Introduction

Dans les sections précédentes (6.3), nous avons découvert les problématiques de concurrence (Dirty Reads, Non-Repeatable Reads, Phantom Reads) ainsi que les mécanismes de verrouillage et de blocage que SQL Server utilise pour gérer l'accès concurrent aux données. Maintenant, une question fondamentale se pose :

**Comment contrôler quelles anomalies de concurrence sont autorisées ou bloquées ?**

La réponse : les **niveaux d'isolation des transactions**.

Les niveaux d'isolation sont comme des **paramètres** que vous pouvez ajuster pour trouver le bon équilibre entre la **cohérence des données** (empêcher les anomalies) et les **performances** (permettre plus de concurrence). SQL Server propose **cinq niveaux d'isolation** (du moins restrictif au plus strict), auxquels s'ajoute une configuration apparentée — **RCSI** — qui n'est pas un niveau en soi mais une option de base de données (nous y revenons en détail plus bas).

---

## Qu'est-ce qu'un niveau d'isolation ?

### Définition

Un **niveau d'isolation** est un paramètre qui détermine :
1. **Quelles anomalies de concurrence** sont autorisées ou bloquées
2. **Comment SQL Server utilise les verrous** (ou le versioning) pour gérer la concurrence
3. **Le degré d'isolation** d'une transaction par rapport aux autres transactions

### Analogie : Les niveaux de sécurité d'un immeuble

Imaginez un immeuble avec différents niveaux de sécurité :

**Niveau 1 - Accès libre (READ UNCOMMITTED)**
- Les portes sont toujours ouvertes
- Vous pouvez entrer n'importe où, même dans les pièces où travaillent d'autres personnes
- **Avantage** : Circulation fluide, aucune attente
- **Inconvénient** : Vous pouvez voir des travaux en cours qui seront annulés

**Niveau 2 - Accès normal (READ COMMITTED)**
- Les portes se verrouillent temporairement quand quelqu'un travaille
- Vous attendez qu'ils finissent, puis vous pouvez entrer
- **Avantage** : Bon équilibre entre fluidité et sécurité
- **Inconvénient** : Si vous revenez plus tard, la pièce peut avoir changé

**Niveau 3 - Réservation stricte (REPEATABLE READ)**
- Quand vous entrez dans une pièce, elle est réservée pour vous
- Personne ne peut la modifier tant que vous n'avez pas fini
- **Avantage** : La pièce reste identique pendant votre visite
- **Inconvénient** : D'autres personnes doivent attendre longtemps

**Niveau 4 - Accès exclusif (SERIALIZABLE)**
- Quand vous entrez, tout l'étage est réservé pour vous
- Personne ne peut rien modifier, ni même ajouter de nouvelles pièces
- **Avantage** : Contrôle total et isolation maximale
- **Inconvénient** : Tout l'immeuble est ralenti

**Niveau 5 - Photographie (SNAPSHOT)**
- Vous recevez une photo de tout l'étage au moment où vous entrez
- Vous travaillez avec cette photo, pendant que les autres modifient l'original
- **Avantage** : Pas d'attente, vue cohérente
- **Inconvénient** : Nécessite de l'espace pour stocker les photos

C'est exactement ainsi que fonctionnent les niveaux d'isolation : chacun offre un compromis différent entre sécurité (cohérence) et fluidité (performance).

---

## Le compromis fondamental : Cohérence vs Performance

### Le dilemme

Il existe un **conflit inhérent** entre deux objectifs :

**Cohérence des données (Isolation)**
- Garantir que les données sont exactes et fiables
- Empêcher les anomalies de concurrence
- S'assurer que les transactions ne s'interfèrent pas

**Performance (Concurrence)**
- Permettre à de nombreuses transactions de s'exécuter simultanément
- Minimiser les temps d'attente (blocages)
- Maximiser le débit du système

### Le spectre des niveaux d'isolation

```
┌────────────────────────────────────────────────────────────────────────┐
│                SPECTRE DES NIVEAUX D'ISOLATION                         │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  READ UNCOMMITTED ←→ READ COMMITTED ←→ REPEATABLE READ ←→ SERIALIZABLE │
│                              ↑                                         │
│                          RCSI & SNAPSHOT                               │
│                                                                        │
│  ⭐⭐⭐⭐⭐ Performance                Performance ⭐⭐               │
│  ⭐ Cohérence                        Cohérence ⭐⭐⭐⭐⭐             │
│                                                                        │
│  ← Plus de concurrence     Moins de concurrence →                      │
│  ← Moins de blocages       Plus de blocages →                          │
│  ← Moins de cohérence      Plus de cohérence →                         │
└────────────────────────────────────────────────────────────────────────┘
```

### Le paradoxe

**Vous ne pouvez pas avoir les deux à la fois !**

- **Plus d'isolation** = Plus de verrous = Moins de concurrence = Moins de performance
- **Plus de concurrence** = Moins de verrous = Moins d'isolation = Risque d'anomalies

L'art du développeur SQL Server est de choisir le **bon niveau** pour chaque situation.

---

## Les niveaux d'isolation de SQL Server

### Vue d'ensemble

Le tableau ci-dessous récapitule les **cinq niveaux d'isolation** de SQL Server, auxquels s'ajoute l'option **RCSI** (sur une ligne distincte), chacun avec ses caractéristiques propres :

| Niveau | Dirty Reads | Non-Rep. Reads | Phantom Reads | Mécanisme | Performance |
|--------|-------------|----------------|---------------|-----------|-------------|
| **READ UNCOMMITTED** | ✅ Autorisées | ✅ Autorisées | ✅ Autorisées | Aucun verrou | ⭐⭐⭐⭐⭐ |
| **READ COMMITTED** | ❌ Bloquées | ✅ Autorisées | ✅ Autorisées | Verrous temp. | ⭐⭐⭐⭐ |
| **RCSI** | ❌ Bloquées | ✅ Autorisées | ✅ Autorisées | Versioning | ⭐⭐⭐⭐⭐ |
| **REPEATABLE READ** | ❌ Bloquées | ❌ Bloquées | ✅ Autorisées | Verrous maintenus | ⭐⭐⭐ |
| **SERIALIZABLE** | ❌ Bloquées | ❌ Bloquées | ❌ Bloquées | Verrous + range | ⭐⭐ |
| **SNAPSHOT** | ❌ Bloquées | ❌ Bloquées | ❌ Bloquées | Versioning | ⭐⭐⭐⭐ |

> 📌 **Précision importante** : à proprement parler, `SET TRANSACTION ISOLATION LEVEL` ne propose que **cinq** niveaux — READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SNAPSHOT et SERIALIZABLE. **RCSI** n'est pas un niveau que l'on sélectionne ainsi : c'est une **option de base de données** (`READ_COMMITTED_SNAPSHOT ON`) qui fait fonctionner READ COMMITTED en mode *versioning*. Il figure sur une ligne distincte de ce tableau parce que son comportement, très utile en pratique, mérite d'être étudié à part (section 6.4.3).

### Description succincte de chaque niveau

#### 1. READ UNCOMMITTED (Le moins restrictif)
- **Principe** : Aucun verrou, lecture de tout y compris les données non validées
- **Usage** : Rapports approximatifs, monitoring non critique
- **Avantage** : Performance maximale
- **Inconvénient** : Peut lire des données qui seront annulées

#### 2. READ COMMITTED (Le défaut)
- **Principe** : Lit uniquement les données validées, verrous temporaires
- **Usage** : Usage général (80-90% des applications)
- **Avantage** : Bon équilibre cohérence/performance
- **Inconvénient** : Les mêmes lectures peuvent donner des résultats différents

#### 3. READ COMMITTED SNAPSHOT - RCSI (Variante moderne)
- **Principe** : Comme READ COMMITTED mais avec versioning au lieu de verrous
- **Usage** : Applications web modernes, haute concurrence
- **Avantage** : Pas de blocage en lecture
- **Inconvénient** : Utilise tempdb

#### 4. REPEATABLE READ (Plus strict)
- **Principe** : Les données lues ne peuvent pas changer pendant la transaction
- **Usage** : Rapports nécessitant cohérence stricte
- **Avantage** : Garantit que les relectures donnent le même résultat
- **Inconvénient** : Plus de blocages, risque de deadlock élevé

#### 5. SERIALIZABLE (Le plus strict - verrous)
- **Principe** : Isolation totale, comme si les transactions s'exécutaient en série
- **Usage** : Opérations critiques très rares
- **Avantage** : Aucune anomalie possible
- **Inconvénient** : Performance très faible, blocages massifs

#### 6. SNAPSHOT (Le plus strict - versioning)
- **Principe** : Vue cohérente figée de toute la base au début de la transaction
- **Usage** : Alternative moderne à SERIALIZABLE
- **Avantage** : Isolation maximale sans blocage
- **Inconvénient** : Utilise beaucoup tempdb

---

## Comment les niveaux d'isolation résolvent les problématiques

### Rappel des anomalies (vues en section 6.3.1)

**Dirty Read (Lecture sale)**
- Lire des données non validées qui peuvent être annulées
- Exemple : Voir un prix temporaire de 50€ qui sera annulé

**Non-Repeatable Read (Lecture non répétable)**
- Relire une donnée et obtenir une valeur différente
- Exemple : Lire Prix = 100€, puis relire Prix = 120€

**Phantom Read (Lecture fantôme)**
- De nouvelles lignes apparaissent entre deux lectures
- Exemple : Compter 10 employés, puis recompter 11 employés

### Comment chaque niveau gère ces anomalies

```
                        Dirty    Non-Rep.   Phantom
                        Reads    Reads      Reads
                        ─────    ────────   ───────
READ UNCOMMITTED        Permet   Permet     Permet
                          ↓        ↓          ↓
READ COMMITTED          Bloque   Permet     Permet
RCSI                    Bloque   Permet     Permet
                                   ↓          ↓
REPEATABLE READ         Bloque   Bloque     Permet
                                              ↓
SERIALIZABLE            Bloque   Bloque     Bloque
SNAPSHOT                Bloque   Bloque     Bloque

← Moins strict                    Plus strict →
← Plus rapide                     Plus lent →
```

---

## Deux approches : Verrous vs Versioning

Ces deux familles portent un nom standard que vous rencontrerez partout :
- l'approche par **verrous** est dite **pessimiste** : on bloque *par précaution*, en supposant qu'un conflit risque de survenir ;
- l'approche par **versioning** est dite **optimiste** : on laisse lectures et écritures progresser sans bloquer, en supposant que les conflits sont rares — et on les détecte (puis on les gère) seulement s'ils surviennent réellement.

### Approche traditionnelle : Les verrous

**Niveaux concernés :** READ COMMITTED, REPEATABLE READ, SERIALIZABLE

**Principe :**
- Utilise des **verrous** (shared, exclusive, range locks)
- Les lecteurs et les écrivains **peuvent se bloquer mutuellement**
- Plus le niveau est strict, plus les verrous sont maintenus longtemps

**Avantages :**
- Pas d'overhead sur tempdb
- Mécanisme éprouvé et fiable

**Inconvénients :**
- Risque de blocage et de deadlock
- Impact sur la concurrence

### Approche moderne : Le versioning

**Niveaux concernés :** RCSI, SNAPSHOT

**Principe :**
- Utilise le **versioning de lignes** (row versioning)
- Les anciennes versions sont stockées dans **tempdb**
- Les lecteurs ne bloquent **jamais** les écrivains

**Avantages :**
- Aucun blocage en lecture
- Meilleures performances en lecture
- Meilleure expérience utilisateur

**Inconvénients :**
- Utilise de l'espace dans tempdb
- Overhead sur les opérations d'écriture
- Nécessite configuration au niveau base de données

---

## Le lien avec les propriétés ACID

### Rappel : ACID

Les transactions doivent respecter les propriétés **ACID** :
- **A**tomicité : Tout ou rien
- **C**ohérence : Données toujours valides
- **I**solation : Les transactions ne s'interfèrent pas
- **D**urabilité : Les données validées sont permanentes

### L'isolation (le "I" de ACID)

Les niveaux d'isolation contrôlent directement la propriété **I**solation :

**Isolation faible (READ UNCOMMITTED)**
```
Transaction A ←→ Transaction B
Forte interaction, peu d'isolation
Peuvent se "voir" mutuellement même sans validation
```

**Isolation moyenne (READ COMMITTED, REPEATABLE READ)**
```
Transaction A ↔ Transaction B
Interaction contrôlée, isolation partielle
Se voient uniquement après validation (READ COMMITTED)
ou pas du tout pour les données lues (REPEATABLE READ)
```

**Isolation maximale (SERIALIZABLE, SNAPSHOT)**
```
Transaction A | Transaction B
Aucune interaction, isolation totale
Chaque transaction voit la base comme si elle était seule
```

### Niveaux standard et spécificités SQL Server

La norme SQL définit 4 niveaux standards, du moins strict au plus strict :
1. READ UNCOMMITTED
2. READ COMMITTED (défaut dans SQL Server)
3. REPEATABLE READ
4. SERIALIZABLE

**SQL Server y ajoute le *row versioning***, ce qui donne deux configurations supplémentaires :

5. **SNAPSHOT** : un **véritable niveau d'isolation à part entière**, que l'on sélectionne avec `SET TRANSACTION ISOLATION LEVEL SNAPSHOT` (après avoir activé l'option de base `ALLOW_SNAPSHOT_ISOLATION ON`). Il repose sur le versioning, **pas** sur les verrous — ce n'est donc **pas** une simple « variante de SERIALIZABLE » : sa sémantique diffère (sous SNAPSHOT, certaines anomalies comme le *write skew* restent possibles, contrairement à SERIALIZABLE — voir 6.4.6).
6. **READ COMMITTED SNAPSHOT (RCSI)** : ce n'est **pas** un niveau que l'on choisit avec `SET TRANSACTION ISOLATION LEVEL`. C'est une **option de base de données** (`ALTER DATABASE … SET READ_COMMITTED_SNAPSHOT ON`) qui change le *comportement* du niveau READ COMMITTED : ses lectures se font alors par versioning plutôt que par verrous.

> 📌 **À retenir** : au sens strict, `SET TRANSACTION ISOLATION LEVEL` accepte **cinq** niveaux (READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SNAPSHOT, SERIALIZABLE). RCSI n'est pas un sixième niveau, mais une bascule qui transforme READ COMMITTED en sa version « snapshot ». Ce cours lui consacre tout de même une section dédiée (6.4.3) tant son impact pratique est important.

---

## Comment choisir le bon niveau d'isolation ?

### Questions à se poser

Pour choisir le niveau approprié, demandez-vous :

**1. Quel type d'opération ?**
- Lecture simple → READ COMMITTED ou RCSI
- Rapport complexe → REPEATABLE READ ou SNAPSHOT
- Opération critique → SERIALIZABLE ou SNAPSHOT

**2. Quelle est la fréquence ?**
- Très fréquent (milliers/seconde) → READ COMMITTED ou RCSI
- Occasionnel (quelques/minute) → REPEATABLE READ
- Rare (une fois/jour) → SERIALIZABLE acceptable

**3. Quelle cohérence est nécessaire ?**
- Approximative → READ UNCOMMITTED
- Normale → READ COMMITTED
- Stricte → REPEATABLE READ ou SNAPSHOT
- Absolue → SERIALIZABLE ou SNAPSHOT

**4. Quel est le niveau de concurrence ?**
- Haute concurrence → READ COMMITTED, RCSI, SNAPSHOT
- Moyenne concurrence → READ COMMITTED, REPEATABLE READ
- Faible concurrence → Tous niveaux acceptables

**5. Peut-on utiliser tempdb ?**
- OUI → Considérer RCSI ou SNAPSHOT
- NON → Limité aux niveaux basés sur verrous

### Arbre de décision simplifié

```
Début
  │
  ├─ Lecture approximative acceptable ?
  │  └─ OUI → READ UNCOMMITTED
  │
  ├─ Besoin d'empêcher toutes les anomalies ?
  │  │
  │  ├─ OUI → tempdb disponible ?
  │  │  ├─ OUI → SNAPSHOT
  │  │  └─ NON → SERIALIZABLE
  │  │
  │  └─ NON → Besoin d'empêcher Non-Repeatable Reads ?
  │     ├─ OUI → REPEATABLE READ
  │     └─ NON → READ COMMITTED ou RCSI (défaut)
  │
  └─ Pas sûr ? → READ COMMITTED (défaut)
```

---

## Règles générales et recommandations

### La règle des 90%

```
90% des applications peuvent utiliser : READ COMMITTED (ou RCSI)
5% nécessitent : REPEATABLE READ ou SNAPSHOT
4% peuvent utiliser : READ UNCOMMITTED (rapports non critiques)
1% nécessitent vraiment : SERIALIZABLE
```

### Recommandations par type d'application

**Application web / mobile**
```
✅ READ COMMITTED (défaut)
✅ RCSI (si activé)
❌ Éviter SERIALIZABLE (trop restrictif)
```

**Système transactionnel (banque, e-commerce)**
```
✅ READ COMMITTED pour opérations courantes
✅ SNAPSHOT pour rapports
⚠️ SERIALIZABLE uniquement pour opérations très critiques
```

**Data warehouse / Reporting**
```
✅ SNAPSHOT pour rapports complexes
✅ READ UNCOMMITTED pour monitoring approximatif
⚠️ REPEATABLE READ si besoin de cohérence sans versioning
```

**Application temps réel (IoT, capteurs)**
```
✅ READ UNCOMMITTED (performance prioritaire)
⚠️ READ COMMITTED si intégrité importante
```

### Bonnes pratiques générales

**1. Commencer avec le défaut**
```sql
-- Par défaut, SQL Server utilise READ COMMITTED
-- C'est un excellent point de départ pour 90% des cas
BEGIN TRANSACTION;
SELECT * FROM Produits;
COMMIT;
```

**2. N'augmenter l'isolation que si nécessaire**
```sql
-- ❌ MAUVAIS : Utiliser SERIALIZABLE par défaut "au cas où"
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- ✅ BON : Utiliser le minimum nécessaire
-- READ COMMITTED pour la plupart des cas
-- SNAPSHOT pour les rapports complexes uniquement
```

**3. Limiter la portée des niveaux stricts**
```sql
-- ❌ MAUVAIS : Toute la session en REPEATABLE READ
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- ✅ BON : Uniquement pour la transaction critique
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- Opération critique...
COMMIT;

-- Retour au défaut
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

**4. Considérer les alternatives modernes**
```sql
-- Au lieu de :
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;  -- Blocage massif

-- Considérer :
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;       -- Isolation forte par versioning, sans blocage
```

**5. Garder les transactions courtes**
```
Niveau strict + Transaction longue = Catastrophe

✅ SERIALIZABLE pendant 1 seconde : OK
❌ SERIALIZABLE pendant 10 minutes : Désastre
```

---

## Configuration et syntaxe de base

### Définir le niveau d'isolation

**Au niveau de la session**
```sql
-- Affecte toutes les transactions suivantes dans la session
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
```

**Au niveau de la transaction**
```sql
-- Le niveau d'isolation doit être défini AVANT le BEGIN TRANSACTION
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRANSACTION;
-- Opérations...
COMMIT;
```

> ⚠️ Pour le niveau **SNAPSHOT** en particulier, le `SET TRANSACTION ISOLATION LEVEL SNAPSHOT` doit impérativement être exécuté **avant** le `BEGIN TRANSACTION`. Tenter de basculer en SNAPSHOT alors qu'une transaction est déjà ouverte échoue avec l'erreur **Msg 3951**.

### Vérifier le niveau actuel

```sql
-- Méthode 1 : DBCC USEROPTIONS
DBCC USEROPTIONS;

-- Méthode 2 : DMV système
SELECT
    CASE transaction_isolation_level
        WHEN 0 THEN 'Unspecified'
        WHEN 1 THEN 'ReadUncommitted'
        WHEN 2 THEN 'ReadCommitted'
        WHEN 3 THEN 'Repeatable'
        WHEN 4 THEN 'Serializable'
        WHEN 5 THEN 'Snapshot'
    END AS IsolationLevel
FROM sys.dm_exec_sessions
WHERE session_id = @@SPID;
```

### Configuration au niveau base de données (RCSI et SNAPSHOT)

```sql
-- Activer RCSI (variante de READ COMMITTED)
ALTER DATABASE MaBase SET READ_COMMITTED_SNAPSHOT ON;

-- Activer SNAPSHOT ISOLATION
ALTER DATABASE MaBase SET ALLOW_SNAPSHOT_ISOLATION ON;
```

**Note :** Ces deux niveaux nécessitent une activation explicite au niveau de la base de données, contrairement aux autres niveaux qui sont disponibles par défaut.

---

## Vue d'ensemble de ce chapitre

Dans les sections suivantes, nous allons explorer chaque niveau d'isolation en détail :

### 6.4.1 READ UNCOMMITTED
- Le niveau le moins restrictif
- Performances maximales, cohérence minimale
- Autorise toutes les anomalies de concurrence
- Idéal pour les rapports approximatifs

### 6.4.2 READ COMMITTED (Défaut)
- Le niveau par défaut de SQL Server
- Bon équilibre entre performance et cohérence
- Bloque les Dirty Reads
- Usage général recommandé

### 6.4.3 READ COMMITTED SNAPSHOT (RCSI)
- Variante moderne de READ COMMITTED
- Utilise le versioning au lieu des verrous
- Aucun blocage en lecture
- Excellent pour les applications web

### 6.4.4 REPEATABLE READ
- Empêche les Non-Repeatable Reads
- Maintient les verrous jusqu'au COMMIT
- Pour les rapports nécessitant cohérence stricte
- Risque de blocage élevé

### 6.4.5 SERIALIZABLE
- Le niveau le plus strict (approche verrous)
- Empêche toutes les anomalies de concurrence
- Isolation totale
- Performances très faibles, à utiliser rarement

### 6.4.6 SNAPSHOT ISOLATION
- L'approche moderne de l'isolation forte, **sans blocage en lecture**
- Bloque les trois anomalies classiques (dirty, non-repeatable, phantom)
- **Proche** de SERIALIZABLE, mais avec une sémantique différente : le *write skew* y reste possible
- Utilise le versioning (tempdb)

---

## Concepts clés à retenir

Avant de plonger dans les détails de chaque niveau, gardez en tête ces principes fondamentaux :

### 1. Le compromis est inévitable

Il n'existe **pas de niveau parfait**. Chaque niveau est un compromis :
- Plus de cohérence = Moins de performance
- Plus de concurrence = Plus de risque d'anomalies

### 2. Le défaut est souvent suffisant

**READ COMMITTED** (le défaut) convient à la majorité des applications. Ne changez que si vous avez une **raison spécifique**.

### 3. Les niveaux modernes sont préférables

Quand possible, préférez les niveaux basés sur le **versioning** (RCSI, SNAPSHOT) aux niveaux basés uniquement sur les **verrous** :
- RCSI : lectures sans blocage, là où READ COMMITTED classique pose des verrous
- SNAPSHOT : vue cohérente sans blocage, là où SERIALIZABLE bloque massivement (tout en gardant à l'esprit leurs différences de sémantique)

### 4. La transaction courte est essentielle

Quel que soit le niveau d'isolation :
```
Transaction courte + Niveau strict = Acceptable
Transaction longue + Niveau strict = Problématique
```

### 5. Testez avec votre charge réelle

Les performances varient selon :
- Le nombre d'utilisateurs simultanés
- Le ratio lectures/écritures
- La structure de vos données
- Vos patterns d'accès

**Testez** dans des conditions réalistes avant de choisir !

---

## Analogie finale : Le thermostat

Les niveaux d'isolation sont comme un **thermostat** :

```
❄️ Froid (READ UNCOMMITTED)
   └─ Performance maximale
   └─ Cohérence minimale
   └─ "Rapide mais risqué"

🌡️ Tempéré (READ COMMITTED, RCSI)
   └─ Bon équilibre
   └─ Usage quotidien
   └─ "Confortable et fiable"

🔥 Chaud (REPEATABLE READ, SERIALIZABLE, SNAPSHOT)
   └─ Cohérence maximale
   └─ Performance réduite
   └─ "Sûr mais coûteux"
```

Comme pour un thermostat :
- La plupart du temps, la **température moyenne** (READ COMMITTED) est parfaite
- Parfois, vous avez besoin de **plus de chaleur** (SNAPSHOT) pour une situation spéciale
- Rarement, vous avez besoin de **chaleur maximale** (SERIALIZABLE) pour des cas critiques
- Occasionnellement, le **froid** (READ UNCOMMITTED) suffit pour des besoins simples

---

## Préparation pour les sections suivantes

Pour tirer le meilleur parti des sections suivantes, gardez à l'esprit ces questions :

1. **Quelles anomalies** mon application peut-elle tolérer ?
2. **Quelle est la criticité** des données manipulées ?
3. **Quel est le niveau de concurrence** attendu ?
4. **Puis-je utiliser tempdb** (pour RCSI et SNAPSHOT) ?
5. **Quelle est la durée** typique de mes transactions ?

Ces questions vous guideront dans le choix du niveau d'isolation approprié pour chaque situation.

---

**Prochaine étape :** Dans la section 6.4.1, nous commencerons par explorer **READ UNCOMMITTED**, le niveau d'isolation le moins restrictif qui offre les meilleures performances au prix d'aucune garantie de cohérence. Nous verrons en détail comment il fonctionne, quand l'utiliser (et surtout quand ne pas l'utiliser), et ses implications pratiques.

⏭️ [READ UNCOMMITTED](/06-gestion-des-transactions-et-concurrence/04.1-read-uncommitted.md)
