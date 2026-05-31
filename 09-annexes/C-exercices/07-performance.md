🔝 Retour au [Sommaire](/SOMMAIRE.md)

# C.7 — Exercices du chapitre 7 : Optimisation, performance et maintenance

Index, SARGability, plans d'exécution et sauvegarde/restauration, sur la base `Boutique`.

---

## Exercice 7.1 ⭐ — Créer un index non-cluster

📝 **Énoncé** : Les requêtes filtrent souvent les commandes par `ClientID`. Créez un index adapté.

✅ **Corrigé** :
```sql
CREATE NONCLUSTERED INDEX IX_Commandes_ClientID
ON Commandes (ClientID);
```

🧠 **Explication** : un index non-cluster sur la colonne de filtre permet un **Index Seek** au lieu d'un balayage de table (voir §7.1.3).

---

## Exercice 7.2 ⭐⭐ — Index composite et ordre des colonnes

📝 **Énoncé** : Les requêtes filtrent par `CategorieID` puis trient par `PrixUnitaire`. Proposez un index composite, et expliquez l'importance de l'ordre des colonnes.

✅ **Corrigé** :
```sql
CREATE NONCLUSTERED INDEX IX_Produits_Cat_Prix
ON Produits (CategorieID, PrixUnitaire);
```

🧠 **Explication** : l'ordre compte ! La colonne d'**égalité** (`CategorieID`) doit précéder la colonne de **tri/plage** (`PrixUnitaire`). Cet index sert un `WHERE CategorieID = ... ORDER BY PrixUnitaire` mais **pas** un filtre sur `PrixUnitaire` seul. Voir §7.2.1.

---

## Exercice 7.3 ⭐⭐⭐ — SARGability

📝 **Énoncé** : La requête suivante n'utilise pas l'index sur `DateCommande`. Pourquoi ? Réécrivez-la pour la rendre « SARGable ».

```sql
SELECT * FROM Commandes WHERE YEAR(DateCommande) = 2025;
```

✅ **Corrigé** :
```sql
SELECT * FROM Commandes
WHERE DateCommande >= '2025-01-01' AND DateCommande < '2026-01-01';
```

🧠 **Explication** : appliquer une **fonction** (`YEAR(...)`) sur la colonne empêche l'usage de l'index (la colonne n'est plus « recherchable »). En réécrivant avec une **plage de dates**, la colonne reste utilisable par l'index → Index Seek. Voir §7.6.1 et §7.6.2.

---

## Exercice 7.4 ⭐⭐ — Index couvrant (INCLUDE)

📝 **Énoncé** : Pour la requête `SELECT NomProduit, PrixUnitaire FROM Produits WHERE CategorieID = 1`, proposez un index **couvrant**.

✅ **Corrigé** :
```sql
CREATE NONCLUSTERED INDEX IX_Produits_Cat_Couvrant
ON Produits (CategorieID)
INCLUDE (NomProduit, PrixUnitaire);
```

🧠 **Explication** : avec `INCLUDE`, l'index contient toutes les colonnes du `SELECT` : SQL Server répond **sans retourner à la table** (pas de *key lookup*). C'est un index **couvrant**. Voir §7.2.3.

---

## Exercice 7.5 ⭐⭐ — Seek vs Scan (conceptuel)

📝 **Énoncé** : Dans un plan d'exécution, quelle différence entre un **Index Seek** et un **Index Scan** ? Lequel est généralement préférable ?

✅ **Corrigé** :
- **Index Seek** : SQL Server navigue directement vers les lignes pertinentes (ciblé, efficace).
- **Index Scan** : SQL Server parcourt **tout** l'index (ou la table).
- Un **Seek** est généralement préférable sur de gros volumes filtrés ; un **Scan** peut être normal si la requête ramène une grande partie de la table.

🧠 **Explication** : voir §7.3.3. Un Scan inattendu sur une requête sélective signale souvent un index manquant ou un prédicat non-SARGable.

---

## Exercice 7.6 ⭐⭐ — Éviter SELECT *

📝 **Énoncé** : Pourquoi `SELECT *` est-il déconseillé en production ? Donnez deux raisons.

✅ **Corrigé** :
- Il transfère des colonnes **inutiles** (réseau, mémoire) et empêche souvent un index **couvrant**.
- Il rend le code **fragile** : si la table change (colonnes ajoutées/réordonnées), les résultats et les applications peuvent casser.

🧠 **Explication** : on nomme explicitement les colonnes nécessaires (voir §7.6.3).

---

## Exercice 7.7 ⭐⭐ — Sauvegarde complète

📝 **Énoncé** : Écrivez la commande pour faire une sauvegarde complète **compressée et vérifiée** de la base `Boutique`.

✅ **Corrigé** :
```sql
BACKUP DATABASE Boutique
TO DISK = 'C:\Backups\Boutique_FULL.bak'
WITH INIT, COMPRESSION, CHECKSUM, STATS = 10;
```

🧠 **Explication** : `COMPRESSION` réduit la taille, `CHECKSUM` vérifie l'intégrité, `INIT` écrase le fichier existant. Voir §7.8.3. *(Sur Express, retirez `COMPRESSION`.)*

---

## Exercice 7.8 ⭐⭐⭐ — Séquence de restauration

📝 **Énoncé** : On veut restaurer `Boutique` à partir d'une complète puis d'une sauvegarde de journal. Donnez la séquence correcte des commandes (avec les bonnes options).

✅ **Corrigé** :
```sql
RESTORE DATABASE Boutique FROM DISK = 'C:\Backups\Boutique_FULL.bak'
WITH NORECOVERY, REPLACE;

RESTORE LOG Boutique FROM DISK = 'C:\Backups\Boutique_LOG.trn'
WITH RECOVERY;
```

🧠 **Explication** : `NORECOVERY` sur toutes les étapes sauf la **dernière**, qui prend `RECOVERY` pour ouvrir la base. Voir §7.8.4.

---

## Exercice 7.9 ⭐⭐ — Modèle de récupération (conceptuel)

📝 **Énoncé** : Une base de production a un journal qui grossit sans cesse jusqu'à saturer le disque. Elle est en modèle `FULL`. Quelle est la cause probable et la solution ?

✅ **Corrigé** :
- Cause : **aucune sauvegarde de journal** n'est planifiée (en `FULL`, le journal n'est tronqué que par `BACKUP LOG`).
- Solution : planifier des **`BACKUP LOG`** réguliers (si le PITR est nécessaire) **ou** passer la base en `SIMPLE` (si le PITR n'est pas requis).

🧠 **Explication** : ne jamais « régler » cela par des `SHRINK` répétés ; traiter la **cause**. Voir §7.8.1.

---

⏭️ [C.8 — Exercices du chapitre 8](/09-annexes/C-exercices/08-sujets-complementaires.md)
