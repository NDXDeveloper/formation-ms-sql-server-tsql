🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 4.6 Manipulation de données avancée

## Introduction

Après avoir maîtrisé les techniques de requêtage fondamentales et les fonctions de fenêtrage, nous abordons maintenant des opérations plus avancées qui permettent de **transformer structurellement** vos données de manières sophistiquées.

Ce chapitre couvre trois outils puissants de T-SQL qui vont au-delà des simples SELECT, INSERT, UPDATE et DELETE :
- **PIVOT et UNPIVOT** : Transformer la structure des données (lignes ↔ colonnes)
- **APPLY** : Appliquer des expressions de table de manière dynamique
- **MERGE** : Synchroniser des données entre sources

Ces techniques sont essentielles pour :
- Préparer des données pour des rapports
- Intégrer des données de sources externes
- Maintenir des entrepôts de données (Data Warehouses)
- Effectuer des transformations ETL (Extract, Transform, Load)
- Réorganiser des structures de données

## Pourquoi "avancé" ?

Ces techniques sont considérées comme avancées pour plusieurs raisons :

### 1. Elles modifient la structure des données

Contrairement aux requêtes SELECT classiques qui **filtrent** ou **agrègent** des données, ces opérations **transforment la structure même** de vos résultats.

**Exemple :**
- Une requête SELECT normale change le **contenu** (quelles lignes, quelles colonnes)
- PIVOT change la **forme** (transforme des lignes en colonnes)

### 2. Elles combinent plusieurs opérations

Ces instructions peuvent effectuer en **une seule passe** ce qui nécessiterait autrement **plusieurs étapes** distinctes.

**Exemple :**
- MERGE peut faire INSERT + UPDATE + DELETE en une seule instruction
- Sans MERGE, vous auriez besoin de trois instructions séparées

### 3. Elles nécessitent une compréhension conceptuelle

Ces techniques demandent de penser différemment :
- Comment les données sont **organisées** (pas seulement leur contenu)
- Comment **transformer** une structure en une autre
- Comment **synchroniser** des ensembles de données

### 4. Elles ont des cas d'usage spécifiques

Vous ne les utiliserez pas tous les jours, mais quand vous en avez besoin, elles sont **irremplaçables**.

## Vue d'ensemble des trois techniques

### PIVOT et UNPIVOT : La transformation structurelle

**Concept :** Réorganiser les données en changeant l'axe d'affichage.

**PIVOT : Lignes → Colonnes**

Imaginez un tableau de ventes avec une ligne par mois :
```
Produit | Mois    | Ventes
Laptop  | Janvier | 10000
Laptop  | Février | 15000
Souris  | Janvier | 2000
Souris  | Février | 2500
```

Avec PIVOT, vous créez un tableau où les mois deviennent des colonnes :
```
Produit | Janvier | Février
Laptop  | 10000   | 15000
Souris  | 2000    | 2500
```

**UNPIVOT : Colonnes → Lignes**

L'opération inverse ! Transforme un tableau large en format long (normalisé).

**Quand utiliser ?**
- Créer des tableaux croisés pour des rapports
- Préparer des données pour des outils de visualisation
- Normaliser des données importées (souvent des fichiers Excel)
- Adapter la structure des données aux besoins de présentation

**Analogie :** C'est comme faire pivoter physiquement un tableau de données de 90 degrés.

### APPLY : L'application dynamique

**Concept :** Appliquer une expression de table (fonction, sous-requête) à **chaque ligne** d'une table source, en utilisant les valeurs de cette ligne.

**Différence avec JOIN :**
- **JOIN classique** : Lie deux tables avec une condition fixe
- **APPLY** : Pour chaque ligne de gauche, exécute une requête qui peut **utiliser les valeurs** de cette ligne

**Deux variantes :**
- **CROSS APPLY** : Comme INNER JOIN (exclut les lignes sans correspondance)
- **OUTER APPLY** : Comme LEFT JOIN (garde toutes les lignes de gauche)

**Exemple typique :** Trouver les 3 commandes les plus récentes **pour chaque client**.

```sql
-- Impossible avec JOIN simple, facile avec APPLY
SELECT C.Client, TopCommandes.*
FROM Clients C
CROSS APPLY (
    SELECT TOP 3 *
    FROM Commandes
    WHERE ClientID = C.ClientID  -- Utilise C.ClientID !
    ORDER BY DateCommande DESC
) AS TopCommandes;
```

**Quand utiliser ?**
- Top N par groupe
- Appeler des fonctions table avec des paramètres venant de chaque ligne
- Effectuer des calculs complexes ligne par ligne
- Éviter des sous-requêtes corrélées complexes

**Analogie :** C'est comme avoir un assistant personnel pour chaque client qui va chercher ses informations spécifiques.

### MERGE : La synchronisation intelligente

**Concept :** Synchroniser une table cible avec une table source en effectuant INSERT, UPDATE et/ou DELETE en **une seule instruction atomique**.

**Les trois actions possibles :**
- **Ligne dans les deux tables** → UPDATE (ou DELETE)
- **Ligne seulement dans la source** → INSERT
- **Ligne seulement dans la cible** → DELETE (ou UPDATE)

**Exemple :** Mettre à jour un catalogue de produits.

```sql
MERGE INTO Catalogue AS Cible
USING NouveauxProduits AS Source
ON Cible.ProduitID = Source.ProduitID
WHEN MATCHED THEN
    UPDATE SET Cible.Prix = Source.Prix
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ProduitID, Nom, Prix) VALUES (...)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;
```

**Quand utiliser ?**
- Charger des données dans un Data Warehouse
- Synchroniser deux bases de données
- Importer des données externes
- Maintenir des répliques ou caches
- Opérations "UPSERT" (UPDATE ou INSERT)

**Analogie :** C'est comme comparer deux listes et décider automatiquement quoi ajouter, modifier ou supprimer pour qu'elles correspondent.

## Comparaison des trois techniques

| Technique | Objectif principal | Modifie la structure | Opérations multiples | Complexité |
|-----------|-------------------|---------------------|---------------------|------------|
| **PIVOT/UNPIVOT** | Réorganiser l'affichage | ✅ Oui (forme) | ❌ Non | Moyenne |
| **APPLY** | Requêtes dynamiques par ligne | ❌ Non | ❌ Non | Moyenne-Élevée |
| **MERGE** | Synchroniser données | ❌ Non | ✅ Oui (INSERT/UPDATE/DELETE) | Moyenne |

## Différences avec les techniques de base

### SELECT classique vs PIVOT

**SELECT classique :**
```
Affiche les données telles qu'elles sont organisées dans la table
```

**PIVOT :**
```
Réorganise les données : ce qui était en lignes devient des colonnes
```

### JOIN classique vs APPLY

**JOIN :**
```sql
-- Relation fixe entre deux tables
FROM Clients C
INNER JOIN Commandes Cmd ON C.ClientID = Cmd.ClientID
```

**APPLY :**
```sql
-- Relation dynamique, peut utiliser TOP, fonctions, etc.
FROM Clients C
CROSS APPLY (
    SELECT TOP 3 * FROM Commandes WHERE ClientID = C.ClientID
) AS TopCommandes
```

### INSERT/UPDATE/DELETE séparés vs MERGE

**Approche classique :**
```sql
-- Trois instructions séparées
UPDATE ... WHERE EXISTS ...;
INSERT ... WHERE NOT EXISTS ...;
DELETE ... WHERE NOT IN ...;
```

**MERGE :**
```sql
-- Une seule instruction pour tout
MERGE INTO ... USING ...
WHEN MATCHED THEN UPDATE
WHEN NOT MATCHED THEN INSERT
WHEN NOT MATCHED BY SOURCE THEN DELETE;
```

## Quand utiliser ces techniques avancées ?

### ✅ Utilisez PIVOT/UNPIVOT quand :
- Vous devez créer des rapports en tableau croisé
- Vous importez des données d'Excel avec une colonne par mois/année
- Vous devez normaliser ou dénormaliser des structures
- Les outils de visualisation nécessitent un format spécifique

### ✅ Utilisez APPLY quand :
- Vous avez besoin de Top N **par groupe**
- Vous devez appeler une fonction table avec des paramètres différents pour chaque ligne
- Les sous-requêtes corrélées deviennent trop complexes
- Vous voulez appliquer une logique sophistiquée ligne par ligne

### ✅ Utilisez MERGE quand :
- Vous synchronisez des données entre deux sources
- Vous effectuez des chargements ETL
- Vous avez besoin d'une opération "UPSERT" (update or insert)
- Vous voulez garantir l'atomicité d'opérations multiples

### ❌ N'utilisez PAS ces techniques quand :
- Une solution plus simple existe (principe KISS : Keep It Simple)
- Vous ne maîtrisez pas encore bien les bases (SELECT, JOIN, GROUP BY)
- La maintenance du code devient difficile pour votre équipe
- Les performances ne sont pas meilleures que des approches classiques

## Prérequis pour ce chapitre

Avant d'aborder ces techniques avancées, assurez-vous de bien maîtriser :

### ✅ Indispensables
- SELECT avec WHERE, ORDER BY
- Jointures (INNER, LEFT, RIGHT, FULL)
- Sous-requêtes de base
- Fonctions d'agrégation (SUM, COUNT, AVG)
- GROUP BY et HAVING
- Concepts des clés primaires et étrangères

### ✅ Recommandés
- Fonctions de fenêtrage (chapitre 4.5)
- CTE (Common Table Expressions)
- Transactions de base (BEGIN, COMMIT, ROLLBACK)
- Concepts d'indexation

### ✅ Utiles mais pas obligatoires
- Plans d'exécution
- SQL dynamique
- Fonctions table

Si ces concepts ne sont pas totalement clairs, n'hésitez pas à y revenir avant de continuer. Les techniques avancées s'appuient sur ces fondations.

## Contexte : Transformation vs Manipulation

Il est important de comprendre la nuance entre **manipulation** et **transformation** de données :

### Manipulation classique
```
INSERT : Ajouter des données
UPDATE : Modifier des données existantes
DELETE : Supprimer des données
```
→ Change le **contenu** mais pas la **structure**

### Transformation avancée
```
PIVOT : Change la forme d'affichage
APPLY : Applique des opérations contextuelles
MERGE : Combine plusieurs manipulations
```
→ Change la **structure** ou **combine des opérations**

## Cas d'usage dans le monde réel

### Reporting et Business Intelligence
- **PIVOT** : Créer des tableaux de bord avec ventes par mois en colonnes
- **APPLY** : Calculer les KPI personnalisés pour chaque division
- **MERGE** : Mettre à jour les tables de faits dans un Data Warehouse

### Intégration de données
- **UNPIVOT** : Normaliser des fichiers Excel importés
- **APPLY** : Enrichir des données avec des informations externes
- **MERGE** : Synchroniser avec des systèmes tiers

### Maintenance de systèmes
- **PIVOT** : Analyser les performances par période
- **APPLY** : Appliquer des règles métier complexes
- **MERGE** : Maintenir des répliques de bases de données

### Développement d'applications
- **PIVOT/UNPIVOT** : Adapter les structures pour différentes vues
- **APPLY** : Implémentation de logique métier complexe
- **MERGE** : Opérations UPSERT dans les API

## Organisation de ce chapitre

Ce chapitre est organisé en trois sections indépendantes :

### **4.6.1 - PIVOT et UNPIVOT**
Vous apprendrez à transformer des lignes en colonnes et vice-versa. Nous verrons :
- Comment créer des tableaux croisés
- Comment normaliser des données "larges"
- Les alternatives aux opérateurs PIVOT/UNPIVOT
- Les pièges et limitations

### **4.6.2 - La clause APPLY (CROSS APPLY, OUTER APPLY)**
Vous découvrirez comment appliquer des expressions de table dynamiquement. Nous couvrirons :
- La différence entre CROSS et OUTER APPLY
- Les cas d'usage typiques (Top N par groupe)
- L'utilisation avec des fonctions table
- Comparaison avec les jointures classiques

### **4.6.3 - L'instruction MERGE**
Vous maîtriserez la synchronisation de données. Nous explorerons :
- Les trois clauses WHEN (MATCHED, NOT MATCHED)
- Les opérations de synchronisation
- L'utilisation de OUTPUT pour la traçabilité
- Les cas d'usage ETL et Data Warehouse

Chaque section est **indépendante** : vous pouvez les aborder dans l'ordre que vous souhaitez selon vos besoins.

## Conseils pour l'apprentissage

### 1. Commencez par des exemples simples
Ne cherchez pas à maîtriser toutes les subtilités d'un coup. Commencez avec des cas d'usage basiques sur de petits jeux de données.

### 2. Comparez avec les alternatives
Pour chaque technique, demandez-vous : "Comment ferais-je cela autrement ?" Cela vous aidera à comprendre la valeur ajoutée.

### 3. Visualisez les transformations
Pour PIVOT/UNPIVOT en particulier, dessinez ou imaginez mentalement comment les données se réorganisent.

### 4. Pratiquez sur des données réelles
Ces techniques prennent tout leur sens avec des problèmes réels. Essayez de les appliquer à vos propres données.

### 5. Vérifiez les performances
Ces opérations peuvent être coûteuses. Comparez toujours les plans d'exécution avec des approches alternatives.

### 6. Ne sur-utilisez pas
Ce n'est pas parce qu'une technique est avancée qu'elle est toujours meilleure. Privilégiez la simplicité quand c'est possible.

## Quand revenir aux bases ?

Si pendant ce chapitre vous rencontrez des difficultés, c'est peut-être le signe qu'il faut renforcer certains concepts de base :

**Difficulté avec PIVOT ?** → Révisez GROUP BY et les agrégations

**Difficulté avec APPLY ?** → Révisez les jointures et les sous-requêtes

**Difficulté avec MERGE ?** → Révisez INSERT, UPDATE, DELETE et les jointures

Il n'y a aucune honte à revenir en arrière. Ces techniques avancées reposent sur une base solide.

## Note sur la compatibilité

Toutes les techniques de ce chapitre sont disponibles dans SQL Server depuis plusieurs versions :
- **PIVOT/UNPIVOT** : SQL Server 2005+
- **APPLY** : SQL Server 2005+
- **MERGE** : SQL Server 2008+

Si vous utilisez une version récente de SQL Server (2012+), vous avez accès à toutes ces fonctionnalités.

## Avertissement sur la complexité

Ces techniques sont puissantes, mais elles peuvent rendre le code moins lisible si elles sont mal utilisées :

### ✅ Code clair et justifié
```sql
-- MERGE pour synchroniser un catalogue produit
MERGE INTO Catalogue AS C
USING NouveauxProduits AS N
ON C.ProduitID = N.ProduitID
WHEN MATCHED THEN UPDATE ...
WHEN NOT MATCHED THEN INSERT ...;
```
→ **Intention claire** : synchronisation de données

### ❌ Code complexe sans justification
```sql
-- PIVOT imbriqué dans APPLY avec MERGE...
-- Probablement trop complexe !
```
→ **Refactorisation nécessaire** : divisez en étapes plus simples

**Règle d'or :** Si vous ne pouvez pas expliquer simplement ce que fait votre requête, elle est probablement trop complexe.

## Objectifs d'apprentissage

À la fin de ce chapitre, vous serez capable de :

1. **Transformer** des structures de données avec PIVOT et UNPIVOT
2. **Comprendre** quand utiliser APPLY au lieu de JOIN
3. **Synchroniser** des données efficacement avec MERGE
4. **Choisir** la technique appropriée selon le contexte
5. **Éviter** les pièges courants de ces opérations avancées
6. **Optimiser** les performances de ces requêtes complexes

## Ressources complémentaires

Une fois que vous aurez maîtrisé ces techniques de base, vous pourrez approfondir avec :
- Les stratégies d'optimisation spécifiques à chaque opération
- L'intégration dans des processus ETL complexes
- Les patterns avancés de Data Warehousing
- Les techniques de debugging pour requêtes complexes

Mais pour l'instant, concentrons-nous sur la compréhension des concepts fondamentaux de chaque technique.

## Prêt à commencer ?

Les techniques de manipulation avancée de données vont enrichir considérablement votre boîte à outils SQL. Elles vous permettront de résoudre des problèmes qui seraient autrement très complexes ou impossibles à gérer efficacement.

Chaque technique a sa place et son utilité. L'objectif n'est pas de toutes les utiliser systématiquement, mais de savoir **quand et comment** les utiliser à bon escient.

Dans la section suivante, nous allons commencer par **PIVOT et UNPIVOT**, qui permettent de réorganiser la structure de vos données de manières spectaculaires.

Prenez votre temps, expérimentez avec les exemples, et n'hésitez pas à revenir sur les concepts de base si nécessaire.

Bonne découverte de ces techniques avancées ! 🚀

---

**Note :** Ces techniques sont souvent considérées comme "avancées" non pas parce qu'elles sont difficiles en soi, mais parce qu'elles nécessitent de penser différemment à la structure des données. Avec de la pratique, elles deviendront des outils naturels dans votre arsenal SQL.

⏭️ [PIVOT et UNPIVOT](/04-techniques-de-requetage-avancees/06.1-pivot-et-unpivot.md)
