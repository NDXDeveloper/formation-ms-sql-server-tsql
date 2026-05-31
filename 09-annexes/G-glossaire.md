🔝 Retour au [Sommaire](/SOMMAIRE.md)

# Annexe G — Glossaire

> Définitions concises des termes clés de la formation. Le renvoi `(§x)` indique la section où le sujet est approfondi.

---

## A

**ACID** — Les quatre garanties d'une transaction fiable : **A**tomicité, **C**ohérence, **I**solation, **D**urabilité. (§6.1.2)

**Agrégation** — Calcul résumant plusieurs lignes en une valeur (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`). (§3.4)

**Alias** — Nom temporaire donné à une colonne ou une table (`AS`). (§3.1.3)

**AlwaysOn** — Technologie de haute disponibilité par groupes de réplicas. (§8.5)

**Atomicité** — Une transaction s'exécute entièrement ou pas du tout. (§6.1.2)

**Attribut** — Caractéristique d'une entité ; devient une **colonne** en pratique. (§1.1.2)

**Azure SQL Database** — Base de données SQL Server gérée dans le cloud (PaaS). (§8.6)

## B

**Backup (sauvegarde)** — Copie des données permettant la restauration. (§7.8)

**Batch (lot)** — Ensemble d'instructions T-SQL envoyées ensemble, délimité par `GO`. (§5.1.3) Aussi : mode d'exécution par lots du columnstore. (§8.7.3)

**B-Tree (arbre équilibré)** — Structure d'un index non-cluster, permettant des recherches rapides. (§7.1.3)

**BULK_LOGGED** — Modèle de récupération à journalisation minimale des opérations en masse. (§7.8.1)

## C

**Cardinalité** — Nombre de lignes (ou de valeurs distinctes) ; estimée par l'optimiseur. (§7.4)

**Checkpoint** — Écriture des pages modifiées vers le disque. (§7.8.1)

**Clé étrangère (Foreign Key)** — Colonne référençant la clé primaire d'une autre table ; garantit l'intégrité référentielle. (§2.3.2)

**Clé primaire (Primary Key)** — Colonne(s) identifiant de façon unique chaque ligne. (§2.3.1)

**Clustered (index cluster)** — Index qui **est** la table : les données sont triées selon sa clé. (§7.1.2)

**Cohérence** — Une transaction laisse la base dans un état valide (contraintes respectées). (§6.1.2)

**Columnstore** — Index/stockage orienté **colonne**, optimisé pour l'analytique. (§8.7)

**Commit** — Validation définitive d'une transaction. (§6.2.2)

**Concurrence** — Accès simultané de plusieurs transactions aux mêmes données. (§6.3)

**Contrainte** — Règle d'intégrité (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `DEFAULT`, `NOT NULL`). (§2.3)

**CRUD** — Les 4 opérations de base : **C**reate, **R**ead, **U**pdate, **D**elete. (§1.1)

**CTE (Common Table Expression)** — Résultat nommé temporaire (`WITH ... AS`), améliorant la lisibilité ; peut être récursif. (§4.3)

## D

**DCL (Data Control Language)** — Sous-langage de gestion des droits (`GRANT`, `DENY`, `REVOKE`). (§8.4)

**DDL (Data Definition Language)** — Sous-langage de définition des objets (`CREATE`, `ALTER`, `DROP`). (§2.2)

**Deadlock (interblocage)** — Deux transactions s'attendent mutuellement ; SQL Server en annule une. (§6.3.3)

**Différentielle** — Sauvegarde des changements depuis la dernière complète (cumulative). (§7.8.2)

**Dirty read (lecture sale)** — Lecture de données non encore validées par une autre transaction. (§6.3.1)

**DML (Data Manipulation Language)** — Sous-langage de manipulation des données (`INSERT`, `UPDATE`, `DELETE`, `SELECT`). (§2.4–2.6)

**Durabilité** — Après un `COMMIT`, les données survivent même à une panne. (§6.1.2)

## E

**Entité** — Objet/concept du monde réel représenté par une table. (§1.1.2)

**EXISTS** — Prédicat testant l'existence de lignes dans une sous-requête. (§4.2.2)

## F

**FOREIGN KEY** — Voir *Clé étrangère*.

**FULL (recovery)** — Modèle de récupération journalisant tout ; permet le PITR. (§7.8.1)

**Full-Text Search** — Recherche linguistique dans du texte (formes fléchies, pertinence). (§8.8)

## G

**GEOGRAPHY / GEOMETRY** — Types spatiaux (Terre courbe / plan plat). (§8.9)

**GRANT** — Accorder une autorisation. (§8.4.2)

**GROUP BY** — Regrouper les lignes pour les agréger. (§3.5.1)

## H

**HAVING** — Filtrer les groupes après agrégation (vs `WHERE` sur les lignes). (§3.5.2)

**Hash index** — Index de table à mémoire optimisée pour les recherches d'égalité. (§8.10.1)

**Heap (tas)** — Table **sans** index cluster ; lignes non ordonnées. (§7.1.2)

**Hekaton** — Nom de code d'In-Memory OLTP. (§8.10)

**HTAP** — Traitement transactionnel **et** analytique sur les mêmes données. (§8.7.1)

## I

**IDENTITY** — Propriété générant des valeurs auto-incrémentées. (§2.2.2)

**In-Memory OLTP** — Tables en mémoire sans verrou, pour un débit transactionnel extrême. (§8.10)

**Index** — Structure accélérant les recherches (analogie : index d'un livre). (§7.1)

**Instance** — Installation d'un moteur SQL Server hébergeant des bases. (§1.2.2)

**Intégrité référentielle** — Garantie que les clés étrangères pointent vers des lignes existantes. (§2.3.2)

**Isolation** — Degré auquel les transactions concurrentes s'ignorent. (§6.4)

## J

**JOIN (jointure)** — Combinaison de lignes de plusieurs tables (`INNER`, `LEFT`, `RIGHT`, `FULL`, `CROSS`). (§4.1)

**JSON** — Format texte d'échange de données, manipulable nativement. (§8.2)

## K – L

**Key Lookup** — Retour à la table pour récupérer des colonnes absentes d'un index non couvrant. (§7.2.3)

**Latch** — Verrou interne très court protégeant les structures mémoire. (§8.10)

**Lock (verrou)** — Mécanisme empêchant les accès concurrents incompatibles. (§6.3.2)

**LSN (Log Sequence Number)** — Numéro de séquence ordonnant les enregistrements du journal. (§7.8.2)

## M

**MERGE** — Instruction combinant `INSERT`/`UPDATE`/`DELETE` selon correspondance. (§4.6.3)

**Modèle relationnel** — Organisation des données en tables liées par des clés. (§1.1.2)

**MVCC (multi-version)** — Concurrence par versions de lignes, sans verrou (In-Memory, SNAPSHOT). (§8.10.1)

## N

**NORECOVERY** — Option de restauration laissant la base en attente d'autres sauvegardes. (§7.8.4)

**NULL** — Absence de valeur (« inconnu ») ; se teste avec `IS NULL`. (§3.2.5)

## O

**OLAP** — Charge **analytique** (agrégations sur de gros volumes). (§8.7)

**OLTP** — Charge **transactionnelle** (nombreuses petites écritures/lectures). (§8.7)

**OVER()** — Clause définissant la fenêtre d'une fonction de fenêtrage. (§4.5.1)

## P

**PARTITION BY** — Découpe les lignes en groupes pour une fonction de fenêtrage. (§4.5.2)

**Phantom read (lecture fantôme)** — Apparition de nouvelles lignes entre deux lectures d'une même requête. (§6.3.1)

**PITR (Point-in-Time Recovery)** — Restauration à un instant précis. (§7.8.5)

**Plan d'exécution** — Stratégie choisie par l'optimiseur pour exécuter une requête. (§7.3)

**Procédure stockée** — Bloc de code T-SQL nommé et réutilisable, stocké dans la base. (§5.5)

## Q – R

**Query Store** — Magasin historisant requêtes et plans pour analyser les régressions. (§7.5)

**RANK / DENSE_RANK / ROW_NUMBER** — Fonctions de classement de fenêtrage. (§4.5.3)

**RCSI (Read Committed Snapshot)** — Variante de `READ COMMITTED` fondée sur les versions. (§6.4.3)

**RECOVERY** — Option de restauration finalisant et ouvrant la base. (§7.8.4)

**Recovery model (modèle de récupération)** — `SIMPLE`, `FULL` ou `BULK_LOGGED` ; pilote la gestion du journal. (§7.8.1)

**REBUILD / REORGANIZE** — Reconstruire / réorganiser un index fragmenté. (§7.7.2)

**Relation** — Terme théorique pour une **table**. (§1.1.2)

**RESTORE** — Restaurer une base à partir de sauvegardes. (§7.8.4)

**Rollback** — Annulation d'une transaction. (§6.2.3)

**Rowgroup** — Groupe d'environ 1 M de lignes dans un index columnstore. (§8.7)

**RPO (Recovery Point Objective)** — Perte de données maximale acceptable. (§7.8.6)

**RTO (Recovery Time Objective)** — Durée d'indisponibilité maximale acceptable. (§7.8.6)

## S

**SARGability** — Capacité d'un prédicat à utiliser un index (« Search ARGument able »). (§7.6.1)

**Savepoint** — Point de sauvegarde intermédiaire dans une transaction. (§6.2.4)

**Scan** — Parcours de la totalité d'un index ou d'une table. (§7.3.3)

**Schéma** — Conteneur logique regroupant des objets (`dbo`, `Ventes`…). (§1.4.2 / §8.4.1)

**Seek** — Accès ciblé via un index (efficace). (§7.3.3)

**SERIALIZABLE** — Niveau d'isolation le plus strict. (§6.4.5)

**SGBD / SGBDR** — Système de Gestion de Base de Données (Relationnel). (§1.1.3)

**SIMPLE** — Modèle de récupération sans sauvegarde de journal possible. (§7.8.1)

**SNAPSHOT** — Niveau d'isolation par versions, sans blocage. (§6.4.6)

**SQL / T-SQL** — Langage de requête standard / son extension Microsoft (Transact-SQL). (§1.3)

**SSMS** — SQL Server Management Studio, outil client (Windows). (§1.2.3)

**Statistiques** — Données sur la distribution des valeurs, utilisées par l'optimiseur. (§7.4)

**Sous-requête** — Requête imbriquée dans une autre. (§4.2)

## T

**Table** — Structure stockant les données en lignes et colonnes. (§1.4.1)

**TCL (Transaction Control Language)** — `BEGIN`/`COMMIT`/`ROLLBACK`/`SAVE`. (§6.2)

**Tessellation** — Découpage en grille hiérarchique d'un index spatial. (§8.9.2)

**Transaction** — Unité de travail atomique. (§6.1.1)

**Trigger (déclencheur)** — Code exécuté automatiquement lors d'un événement DML/DDL. (§5.7)

**TRUNCATE** — Vidage rapide d'une table (vs `DELETE`). (§2.6.2)

**Tuple** — Terme théorique pour une **ligne**. (§1.1.2)

## U – V – W – X

**UDF (User-Defined Function)** — Fonction définie par l'utilisateur (scalaire ou table). (§5.6)

**UNION / INTERSECT / EXCEPT** — Opérateurs d'ensemble. (§4.4)

**VARCHAR / NVARCHAR** — Types chaîne variable (non-Unicode / Unicode). (§2.1.2)

**View (vue)** — Requête nommée réutilisable comme une table. (§5.4)

**VLF (Virtual Log File)** — Segment interne du journal des transactions. (§7.8.1)

**WAL (Write-Ahead Logging)** — Le journal est écrit avant les données. (§7.8.1)

**WHERE** — Clause de filtrage des lignes. (§3.2.1)

**Window function (fonction de fenêtrage)** — Calcul sur un ensemble de lignes lié à la ligne courante (`OVER`). (§4.5)

**XML** — Format de données hiérarchique, manipulable nativement (XQuery, `FOR XML`). (§8.1)

---

⏭️ [Annexe H — Ressources et bibliographie](/09-annexes/H-ressources.md)
