🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 7.2 Index : Concepts avancés

## Introduction au Chapitre

Félicitations ! Si vous avez terminé le chapitre 7.1, vous maîtrisez maintenant les **concepts fondamentaux** des index :
- Pourquoi les index sont essentiels (7.1.1)
- Les index clustered et la différence avec les Heap (7.1.2)
- Les index non-clustered et la structure B-Tree (7.1.3)
- Les index uniques pour garantir l'intégrité (7.1.4)

Vous savez maintenant **créer des index basiques** et comprendre leur fonctionnement. Mais pour devenir vraiment efficace dans l'optimisation des bases de données, vous devez aller plus loin.

Bienvenue dans le chapitre sur les **concepts avancés des index** !

## Qu'avons-nous vu jusqu'ici ?

### Récapitulatif du chapitre 7.1

Dans le chapitre précédent, nous avons posé les **fondations** :

**Index simple sur une colonne** :
```sql
-- Index de base
CREATE INDEX IX_Clients_Email ON Clients (Email);

-- Index unique
CREATE UNIQUE INDEX IX_Clients_Email ON Clients (Email);
```

**Les types d'index** :
- ✅ Index **clustered** : Détermine l'ordre physique (1 seul par table)
- ✅ Index **non-clustered** : Structure séparée avec pointeurs (jusqu'à 999)
- ✅ Index **unique** : Garantit l'unicité des valeurs

**Les opérations** :
- ✅ **Table Scan** : Parcourir toute la table (lent)
- ✅ **Index Seek** : Recherche directe dans l'index (rapide)
- ✅ **Key Lookup** : Aller-retour entre index et table (coûteux)

**Les structures** :
- ✅ **B-Tree** : Arbre équilibré pour recherches rapides
- ✅ **Heap** : Table sans index clustered

C'est une excellente base ! Mais dans les applications réelles, vous rencontrerez rapidement des situations plus complexes.

## Les Limites des Index Simples

### Problème 1 : Requêtes sur plusieurs colonnes

Dans vos applications réelles, vous allez souvent filtrer sur **plusieurs colonnes** :

```sql
-- Recherche de commandes d'un client pour une période
SELECT * FROM Commandes
WHERE ClientID = 100 AND DateCommande >= '2024-01-01';

-- Recherche de produits dans une catégorie et une marque
SELECT * FROM Produits
WHERE CategorieID = 5 AND MarqueID = 10;

-- Recherche de clients actifs dans une ville
SELECT * FROM Clients
WHERE Ville = 'Paris' AND Statut = 'Actif';
```

**Avec des index simples** :
```sql
CREATE INDEX IX_Commandes_Client ON Commandes (ClientID);
CREATE INDEX IX_Commandes_Date ON Commandes (DateCommande);
```

**Problème** : SQL Server peut utiliser un seul index à la fois (généralement), ou faire une intersection d'index (coûteux).

**Solution** : **Index composites** → Section 7.2.1

### Problème 2 : Données avec beaucoup de NULL ou sous-ensembles

Certaines colonnes contiennent **beaucoup de valeurs NULL** ou vous n'interrogez qu'un **sous-ensemble** des données :

```sql
-- Table Clients : 1 million de lignes
-- Colonne Telephone : 80% de NULL
-- Vous recherchez uniquement les clients avec téléphone

SELECT * FROM Clients WHERE Telephone = '0612345678';
```

**Avec un index standard** :
```sql
CREATE INDEX IX_Clients_Telephone ON Clients (Telephone);
-- Indexe 1 000 000 de lignes (dont 800 000 NULL inutiles)
```

**Problème** : L'index est énorme alors que seules 20% des lignes nous intéressent.

**Solution** : **Index filtrés** → Section 7.2.2

### Problème 3 : Key Lookup coûteux

Vous avez un index, mais SQL Server doit quand même faire des Key Lookups :

```sql
-- Index sur Email
CREATE INDEX IX_Clients_Email ON Clients (Email);

-- Requête demandant d'autres colonnes
SELECT ClientID, Nom, Prenom, Telephone, Ville
FROM Clients
WHERE Email = 'marie@email.com';

-- Opérations :
-- 1. Index Seek sur Email → trouve ClientID
-- 2. Key Lookup → va chercher Nom, Prenom, Telephone, Ville dans la table
```

**Problème** : Le Key Lookup est coûteux, surtout si la requête retourne beaucoup de lignes.

**Solution** : **Colonnes incluses (INCLUDE)** → Section 7.2.3

### Problème 4 : Écritures devenues lentes

Vous avez créé plein d'index pour optimiser vos lectures, mais maintenant vos INSERT, UPDATE et DELETE sont **très lents** :

```sql
-- Table avec 10 index
INSERT INTO Clients (...) VALUES (...);
-- Doit mettre à jour 10 index → Très lent !

UPDATE Clients SET Email = 'nouveau@email.com' WHERE ClientID = 123;
-- Doit mettre à jour tous les index contenant Email → Lent !
```

**Problème** : Trop d'index ralentit les écritures.

**Question** : Comment équilibrer lecture et écriture ? Combien d'index est "trop" ?

**Solution** : Comprendre le **coût des index** → Section 7.2.4

## Vue d'Ensemble des Concepts Avancés

Dans ce chapitre 7.2, nous allons découvrir **quatre techniques avancées** pour optimiser vos index :

### 1. Index Composites : Multi-colonnes (Section 7.2.1)

**Problème résolu** : Requêtes filtrant sur plusieurs colonnes.

**Concept** :
```sql
-- Au lieu de deux index séparés :
CREATE INDEX IX_Clients_Ville ON Clients (Ville);
CREATE INDEX IX_Clients_Statut ON Clients (Statut);

-- Un index composite :
CREATE INDEX IX_Clients_Ville_Statut ON Clients (Ville, Statut);
```

**Ce que vous apprendrez** :
- Comment créer un index sur plusieurs colonnes
- **L'importance cruciale de l'ordre des colonnes**
- La règle du "préfixe de gauche"
- Quand utiliser un index composite vs plusieurs index séparés
- Comment choisir le bon ordre : égalité avant plage, haute sélectivité, etc.

**Analogie** : L'annuaire téléphonique trié par (Nom, Prénom) - l'ordre compte !

**Impact** :
- ⚡ Performances : Très efficace pour requêtes multi-colonnes
- 💾 Espace : Plus économique que plusieurs index séparés
- 🎯 Précision : Doit correspondre exactement à vos patterns de requêtes

### 2. Index Filtrés : Indexer un sous-ensemble (Section 7.2.2)

**Problème résolu** : Index trop volumineux, données avec beaucoup de NULL, sous-ensembles fréquemment interrogés.

**Concept** :
```sql
-- Au lieu d'indexer toutes les lignes :
CREATE INDEX IX_Commandes_Client ON Commandes (ClientID);

-- Indexer seulement un sous-ensemble :
CREATE INDEX IX_Commandes_EnCours_Client
ON Commandes (ClientID)
WHERE Statut = 'En cours';  -- ← Clause WHERE !
```

**Ce que vous apprendrez** :
- Comment créer un index avec une clause WHERE
- Les 5 avantages majeurs (taille, performance, maintenance, statistiques, coût)
- Cas d'usage : NULL, données actives/archivées, statuts spécifiques
- Conditions autorisées et interdites dans le filtre
- Index unique filtré pour gérer plusieurs NULL

**Analogie** : Créer un classeur uniquement pour les documents actifs, pas les archives.

**Impact** :
- 💾 Espace : 50-90% plus petit qu'un index complet
- ⚡ Performances : Plus rapide (moins de données)
- 🔧 Maintenance : Mise à jour seulement si dans le filtre

### 3. Colonnes Incluses : INCLUDE (Section 7.2.3)

**Problème résolu** : Key Lookups coûteux, limite de 900 octets sur les colonnes clés.

**Concept** :
```sql
-- Au lieu d'un index simple :
CREATE INDEX IX_Clients_Email ON Clients (Email);

-- Index avec colonnes incluses :
CREATE INDEX IX_Clients_Email
ON Clients (Email)
INCLUDE (Nom, Prenom, Telephone);  -- ← Colonnes additionnelles !
```

**Ce que vous apprendrez** :
- Qu'est-ce que la clause INCLUDE
- Comment créer un **Covering Index** (index couvrant)
- La différence entre colonnes clés et colonnes incluses
- Structure B-Tree : colonnes INCLUDE uniquement au niveau feuilles
- Quand utiliser INCLUDE (et quand ne pas l'utiliser)
- Comment éviter les Key Lookups

**Analogie** : L'annuaire qui inclut des notes supplémentaires (email, adresse) sans les mettre dans la structure de recherche.

**Impact** :
- ⚡ Performances : Élimine les Key Lookups (peut être 10x plus rapide)
- 💾 Espace : Index plus volumineux
- 🎯 Optimisation ciblée : Pour les requêtes critiques

### 4. Coût des Index : Le revers de la médaille (Section 7.2.4)

**Problème résolu** : Comprendre pourquoi trop d'index ralentit les écritures.

**Concept** : Les index ont un **coût** !

```
Plus d'index = SELECT rapides ⚡
              MAIS
Plus d'index = INSERT/UPDATE/DELETE lents 🐌
```

**Ce que vous apprendrez** :
- Pourquoi les index ralentissent INSERT, UPDATE, DELETE
- Impact chiffré : benchmarks réels
- Le ratio lecture/écriture et votre stratégie
- Différence OLTP (peu d'index) vs OLAP (beaucoup d'index)
- Coûts additionnels : Page Splits, GUID, colonnes larges
- 7 stratégies pour minimiser le coût
- Comment identifier les index inutilisés

**Analogie** : Ajouter un livre dans une bibliothèque : plus vous avez d'index à maintenir, plus c'est long.

**Impact** :
- ⚖️ Équilibre : Trouver le bon nombre d'index
- 📊 Décisions : Basées sur le ratio lecture/écriture
- 🔍 Surveillance : Identifier et supprimer les index coûteux

## Progression Naturelle : Du Simple au Complexe

Ce chapitre suit une **progression logique** :

```
Étape 1 : Index composites
          ↓
     Optimiser les requêtes multi-colonnes

Étape 2 : Index filtrés
          ↓
     Réduire la taille des index

Étape 3 : Colonnes incluses
          ↓
     Éliminer les Key Lookups

Étape 4 : Coût des index
          ↓
     Comprendre les compromis et trouver l'équilibre
```

**Chaque technique se construit sur les précédentes** :

- Vous pouvez créer un **index composite + filtré + avec INCLUDE** :
  ```sql
  CREATE INDEX IX_Commandes_Client_Date
  ON Commandes (ClientID, DateCommande)
  INCLUDE (MontantTotal, Adresse)
  WHERE Statut IN ('En cours', 'En préparation');
  ```

- Mais vous devez toujours considérer le **coût** (section 7.2.4)

## Ce que Vous Serez Capable de Faire

À la fin de ce chapitre 7.2, vous serez capable de :

### ✅ Conception avancée d'index

- Créer des **index composites** optimaux en choisissant le bon ordre des colonnes
- Utiliser des **index filtrés** pour réduire drastiquement la taille
- Implémenter des **covering index** avec INCLUDE pour éliminer les Key Lookups
- Combiner plusieurs techniques dans un seul index

### ✅ Optimisation ciblée

- Analyser une requête lente et identifier le bon type d'index
- Décider entre index composite vs index séparés
- Choisir quand utiliser un index filtré
- Savoir quelles colonnes mettre en INCLUDE

### ✅ Gestion des compromis

- Comprendre le coût des index sur les écritures
- Équilibrer performances de lecture et d'écriture
- Identifier et supprimer les index inutilisés ou coûteux
- Adapter votre stratégie selon le type d'application (OLTP vs OLAP)

### ✅ Prise de décision éclairée

- Évaluer si un index vaut son coût
- Connaître votre ratio lecture/écriture
- Surveiller l'utilisation réelle des index
- Ajuster continuellement votre stratégie d'indexation

## Prérequis et Rappels

Avant de commencer ce chapitre, assurez-vous d'être à l'aise avec :

### Concepts du chapitre 7.1

✅ **Différence clustered vs non-clustered**
```sql
-- Clustered : détermine l'ordre physique (1 seul)
CREATE CLUSTERED INDEX IX_Clients_ClientID ON Clients (ClientID);

-- Non-clustered : structure séparée (jusqu'à 999)
CREATE NONCLUSTERED INDEX IX_Clients_Email ON Clients (Email);
```

✅ **Table Scan vs Index Seek**
- Table Scan : Parcourir toute la table (lent)
- Index Seek : Recherche directe dans l'index (rapide)

✅ **Key Lookup**
- Opération en deux étapes : Index Seek + aller chercher dans la table

✅ **Structure B-Tree**
- Arbre hiérarchique : Racine → Intermédiaire → Feuilles
- Permet des recherches logarithmiques (très rapides)

### Syntaxe de base des index

✅ **Créer un index**
```sql
CREATE INDEX nom_index ON table (colonne);
CREATE UNIQUE INDEX nom_index ON table (colonne);
```

✅ **Supprimer un index**
```sql
DROP INDEX nom_index ON table;
```

✅ **Voir les index d'une table**
```sql
EXEC sp_helpindex 'nom_table';
```

Si ces concepts ne sont pas clairs, nous vous recommandons de réviser le chapitre 7.1 avant de continuer.

## État d'Esprit pour ce Chapitre

### 🎯 Il n'y a pas de "recette magique"

Chaque situation est unique. Les techniques de ce chapitre sont des **outils** dans votre boîte à outils :
- Parfois un index composite est la solution
- Parfois un index filtré est meilleur
- Parfois INCLUDE est nécessaire
- Parfois... aucun index n'est la bonne réponse !

**Votre mission** : Apprendre à choisir le bon outil pour chaque situation.

### 📊 Basez-vous sur des données réelles

Les décisions d'indexation doivent être basées sur :
- ✅ Vos requêtes **réelles** (les plus fréquentes, les plus lentes)
- ✅ Votre **ratio lecture/écriture** réel
- ✅ Les **statistiques d'utilisation** des index
- ❌ PAS sur des suppositions ou des "bonnes pratiques" génériques

### 🔬 Expérimentez et mesurez

L'optimisation d'index est un processus **itératif** :
1. Analysez les performances actuelles
2. Créez un index (composite, filtré, avec INCLUDE)
3. Mesurez l'impact
4. Ajustez si nécessaire
5. Recommencez

**Ne créez pas 20 index d'un coup** - avancez progressivement et mesurez chaque changement.

### ⚖️ Tout est question d'équilibre

Chaque technique a des **avantages** et des **inconvénients** :

```
Index composite    → Rapide pour requêtes multi-colonnes
                    MAIS ordre des colonnes crucial

Index filtré       → Très petit et rapide
                    MAIS ne fonctionne que pour le sous-ensemble filtré

Colonnes INCLUDE   → Élimine les Key Lookups
                    MAIS index plus volumineux

Beaucoup d'index   → Lectures ultra-rapides
                    MAIS écritures très lentes
```

Votre objectif : Trouver le **bon équilibre** pour votre application.

## Structure du Chapitre

Voici comment nous allons progresser :

### Section 7.2.1 - Index Composites
**Durée estimée** : 30-45 minutes de lecture

**Objectifs** :
- Comprendre les index multi-colonnes
- Maîtriser l'ordre des colonnes (critique !)
- Savoir quand utiliser un composite vs plusieurs index

**Difficulté** : ⭐⭐⭐ (Moyenne)

### Section 7.2.2 - Index Filtrés
**Durée estimée** : 25-35 minutes de lecture

**Objectifs** :
- Créer des index sur des sous-ensembles de données
- Connaître les cas d'usage typiques
- Comprendre les restrictions de la clause WHERE

**Difficulté** : ⭐⭐ (Facile à moyenne)

### Section 7.2.3 - Colonnes Incluses (INCLUDE)
**Durée estimée** : 30-40 minutes de lecture

**Objectifs** :
- Créer des covering index
- Éliminer les Key Lookups
- Comprendre la structure avec INCLUDE

**Difficulté** : ⭐⭐⭐ (Moyenne)

### Section 7.2.4 - Coût des Index
**Durée estimée** : 35-45 minutes de lecture

**Objectifs** :
- Comprendre pourquoi les index ralentissent les écritures
- Apprendre à équilibrer lectures et écritures
- Identifier et gérer les index coûteux

**Difficulté** : ⭐⭐⭐⭐ (Moyenne à avancée)

**Temps total estimé** : 2-2.5 heures

## Recommandations pour l'Apprentissage

### Lisez dans l'ordre

Les sections se construisent les unes sur les autres. Ne sautez pas directement à INCLUDE ou au Coût sans avoir compris les composites et les filtrés.

### Pratiquez mentalement

Pour chaque exemple de code, prenez le temps de :
1. Le lire attentivement
2. Visualiser ce qui se passe
3. Vous demander : "Pourquoi cet ordre de colonnes ?"
4. Réfléchir aux alternatives

### Pensez à vos propres applications

Pendant votre lecture, pensez à vos tables réelles :
- Quelles sont vos requêtes les plus fréquentes ?
- Filtrez-vous souvent sur plusieurs colonnes ?
- Avez-vous des colonnes avec beaucoup de NULL ?
- Vos requêtes font-elles beaucoup de Key Lookups ?

### Prenez des notes

Gardez une trace de :
- ✅ Les règles importantes (ex : "égalité avant plage")
- ✅ Les pièges à éviter (ex : "OR interdit dans index filtré")
- ✅ Les idées pour vos propres bases de données

### Revenez-y plus tard

Ces concepts sont riches. Ne vous attendez pas à tout maîtriser en une lecture. Revenez-y après avoir pratiqué, vous comprendrez encore mieux.

## Visualisation : Les Techniques Avancées

Voici une carte conceptuelle des 4 techniques et comment elles s'articulent :

```
                    INDEX AVANCÉS
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
  Optimisation      Optimisation     Optimisation
    Requêtes           Espace         Performance
   Multi-col           Disque           Lecture
        │                │                │
        ▼                ▼                ▼
      INDEX            INDEX           INCLUDE
    COMPOSITES        FILTRÉS         (Covering)
        │                │                │
        └────────────────┼────────────────┘
                         │
                         ▼
                     ÉQUILIBRE
                         │
                         ▼
                   COÛT DES INDEX
                         │
                         ▼
              Lectures vs Écritures
```

## Exemples de Questions Auxquelles Vous Saurez Répondre

Après ce chapitre, vous pourrez répondre à des questions comme :

### Sur les index composites
- ❓ "J'ai une requête WHERE A = ... AND B = ... , dois-je créer un index (A, B) ou (B, A) ?"
- ❓ "Mon index (Ville, Statut) peut-il être utilisé pour WHERE Statut = ... ?"
- ❓ "Vaut-il mieux un index composite ou deux index séparés ?"

### Sur les index filtrés
- ❓ "Ma colonne a 80% de NULL, comment optimiser ?"
- ❓ "Je n'interroge que les données actives (5% de la table), que faire ?"
- ❓ "Puis-je créer un index filtré avec WHERE Status = 'A' OR Status = 'B' ?"

### Sur les colonnes incluses
- ❓ "Mes requêtes font beaucoup de Key Lookups, comment les éviter ?"
- ❓ "J'ai une erreur 'index trop large', quelle est la solution ?"
- ❓ "Quelles colonnes mettre en INCLUDE et lesquelles dans les clés ?"

### Sur le coût
- ❓ "J'ai 15 index sur ma table, c'est trop ?"
- ❓ "Mes INSERT sont devenus très lents depuis que j'ai ajouté des index, pourquoi ?"
- ❓ "Comment savoir si un index est utilisé ou s'il coûte juste cher ?"

## Un Dernier Conseil Avant de Commencer

L'indexation avancée est à la fois :
- 🎨 **Un art** : Intuition, expérience, créativité
- 🔬 **Une science** : Mesures, analyses, optimisations

Ne vous découragez pas si certains concepts semblent complexes au début. Avec la pratique, vous développerez une **intuition** pour savoir quel type d'index créer dans chaque situation.

**Rappelez-vous** : Même les experts en SQL Server continuent d'apprendre sur l'indexation. C'est un domaine riche et en constante évolution.

## Objectifs de Performance

À titre indicatif, voici ce que de bonnes stratégies d'indexation peuvent apporter :

**Sans optimisation avancée** :
- Requêtes : 100-500 ms
- Débit : 1 000 requêtes/seconde
- Espace index : 200% de la taille de la table

**Avec optimisation avancée** (composites + filtrés + INCLUDE) :
- Requêtes : 5-20 ms (10-20x plus rapide)
- Débit : 10 000+ requêtes/seconde
- Espace index : 80-120% de la taille de la table (optimisé)

**Mais attention** : Ces gains ne sont possibles qu'avec une stratégie **réfléchie** qui tient compte du coût.

## Prêt à Passer au Niveau Supérieur ?

Vous avez maintenant :
- ✅ Une vue d'ensemble des 4 techniques avancées
- ✅ Compris les problèmes qu'elles résolvent
- ✅ Une idée de leur impact sur les performances
- ✅ Le bon état d'esprit pour apprendre

**Il est temps de plonger dans les détails !**

Dans la **section 7.2.1**, nous allons explorer les **index composites** et découvrir pourquoi l'ordre des colonnes est si crucial. Vous verrez comment un simple changement d'ordre peut transformer un index inutile en index ultra-performant.

🚀 **Commençons par maîtriser les index multi-colonnes !**

---


⏭️ [Index composites (Multi-colonnes) et importance de l'ordre](/07-optimisation-performance-et-maintenance/02.1-index-composites.md)
