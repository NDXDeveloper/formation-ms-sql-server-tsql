🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 8.7 Index Columnstore (analytique et entrepôt de données)

## Introduction

Jusqu'ici, dans ce cours, toutes les tables que nous avons manipulées stockent les données **ligne par ligne** : c'est le stockage « classique », dit *rowstore*. Il est excellent pour le quotidien transactionnel (récupérer une commande, mettre à jour un client). Mais il montre vite ses limites face à une question d'un tout autre genre :

> « Quel est le chiffre d'affaires total par région et par mois, sur les **500 millions** de lignes de ventes des trois dernières années ? »

Sur une table classique, ce type de requête analytique peut prendre **plusieurs minutes**, car SQL Server doit lire d'énormes volumes de données. C'est précisément le problème que les **index columnstore** résolvent — souvent en obtenant des gains de performance de **10× à 100×** sur ce genre de requêtes, avec en prime une **compression spectaculaire** des données.

Introduits avec SQL Server 2012 et largement perfectionnés depuis (2014, 2016, puis 2022), les index columnstore sont la technologie de référence pour l'**analytique** et les **entrepôts de données** sous SQL Server.

---

## OLTP vs OLAP : deux mondes, deux besoins

Pour comprendre l'intérêt du columnstore, il faut distinguer deux types de charges de travail :

| | **OLTP** (transactionnel) | **OLAP** (analytique) |
|---|---|---|
| Exemple | « Enregistrer la commande n°4521 » | « CA par région sur 3 ans » |
| Lignes touchées | Peu (1 à quelques-unes) | Énormément (millions) |
| Colonnes touchées | Beaucoup (toute la ligne) | Peu (2-3 colonnes agrégées) |
| Opérations | INSERT/UPDATE/DELETE fréquents | SELECT massifs, agrégations |
| Stockage idéal | **Rowstore** (par ligne) | **Columnstore** (par colonne) |

> 🧠 Le rowstore est optimisé pour « tout savoir sur **une** ligne ». Le columnstore est optimisé pour « calculer **une** colonne sur des millions de lignes ».

---

## L'idée fondamentale : stocker par colonne

Imaginez une table de ventes avec les colonnes `Date`, `Region`, `Produit`, `Montant`.

**Stockage rowstore** (ce que vous connaissez) — les valeurs d'une même ligne sont contiguës :
```
[2026-01-01, Nord, Stylo, 2.50] [2026-01-01, Sud, Cahier, 4.00] [2026-01-02, Nord, Stylo, 2.50] ...
```

**Stockage columnstore** — les valeurs d'une même **colonne** sont contiguës :
```
Date    : [2026-01-01, 2026-01-01, 2026-01-02, ...]
Region  : [Nord, Sud, Nord, ...]
Produit : [Stylo, Cahier, Stylo, ...]
Montant : [2.50, 4.00, 2.50, ...]
```

Ce simple changement d'organisation a trois conséquences majeures, détaillées dans les sous-sections suivantes :

1. **Compression extrême** : une colonne contient des valeurs **similaires** (mêmes types, beaucoup de répétitions), donc elle se compresse remarquablement bien. On observe couramment des taux de **10×**.
2. **Lecture ciblée** : pour calculer `SUM(Montant)`, SQL Server ne lit **que** la colonne `Montant`, en ignorant totalement les autres. Sur une table de 50 colonnes, c'est colossal.
3. **Mode batch** (*batch mode*) : le moteur traite les lignes par **lots de ~900** au lieu d'une par une, ce qui réduit énormément le coût processeur.

---

## Aperçu du fonctionnement interne

Sans entrer dans tous les détails (couverts en §8.7.2), retenez ce vocabulaire :

- Les lignes sont regroupées en **rowgroups** d'environ **1 million de lignes** (1 048 576 exactement).
- Dans chaque rowgroup, chaque colonne est stockée et compressée séparément : c'est un **segment de colonne**.
- SQL Server conserve les **valeurs min/max** de chaque segment, ce qui lui permet d'**éliminer** des segments entiers sans les lire (*rowgroup elimination*) — par exemple, ignorer tous les segments dont les dates ne concernent pas l'année demandée.

```
┌──────────────── Rowgroup 1 (≈ 1 M lignes) ────────────────┐
│  Segment Date  │ Segment Region │ Segment Montant │ ...    │
│  (compressé)   │  (compressé)   │  (compressé)    │        │
└────────────────────────────────────────────────────────────┘
┌──────────────── Rowgroup 2 (≈ 1 M lignes) ────────────────┐
│  ...           │  ...           │  ...            │        │
└────────────────────────────────────────────────────────────┘
```

---

## Ce que vous allez apprendre dans cette section

| Sous-section | Sujet |
|--------------|-------|
| **8.7.1** | Le stockage en colonnes vs en lignes (le « pourquoi » en profondeur) |
| **8.7.2** | Columnstore *clustered* (CCI) et *non-clustered* (NCCI) |
| **8.7.3** | Cas d'usage, mode batch et limites à connaître |

---

## Quand utiliser le columnstore (et quand l'éviter)

✅ **Idéal pour :**
- Les **entrepôts de données** et tables de faits volumineuses.
- Les requêtes d'**agrégation** sur de grands volumes (`SUM`, `COUNT`, `AVG`, `GROUP BY`).
- Les tables de **plusieurs millions de lignes** ou plus.

❌ **À éviter (ou avec prudence) pour :**
- Les petites tables (le gain est nul, voire négatif).
- Les charges purement **OLTP** avec beaucoup de recherches d'une seule ligne (`WHERE id = ...`).
- Les tables très fortement mises à jour ligne par ligne (bien que SQL Server 2016+ gère cela nettement mieux).

> 💡 **HTAP** : depuis SQL Server 2016, on peut combiner un index columnstore *non-clustered* avec une table rowstore OLTP pour faire de l'analytique en temps réel sur des données transactionnelles — c'est l'approche *Hybrid Transactional/Analytical Processing*.

---

## Pièges courants

| Piège | Conséquence | Bon réflexe |
|-------|-------------|-------------|
| Columnstore sur une **petite table** | Aucun gain (tout reste en delta store) | Réserver aux tables de centaines de milliers / millions de lignes |
| Columnstore pour de l'**OLTP pur** | Recherches d'une ligne plus lentes | Garder le rowstore + index B-tree pour l'OLTP |
| Insérer **ligne par ligne** | Delta store encombré, compression médiocre | Charger par **gros lots** (≥ 100 000 lignes) |
| Oublier que le **CCI remplace** l'index cluster | Conception incohérente | Choisir : CCI **ou** index cluster rowstore (+ index NC possibles) |
| Croire que columnstore accélère **tout** | Déception sur l'OLTP | Il accélère l'**analytique**, pas les recherches ponctuelles |

## Questions fréquentes

**Q : Le columnstore remplace-t-il mes index classiques ?**
R : Non, il les **complète**. On garde des index B-tree pour les recherches ponctuelles et on ajoute du columnstore pour l'analytique (approche HTAP).

**Q : À partir de quelle taille de table est-ce rentable ?**
R : En pratique, à partir de **centaines de milliers à quelques millions de lignes**. En dessous, le gain est nul.

**Q : Faut-il une édition spécifique de SQL Server ?**
R : Le columnstore est disponible dans **toutes les éditions depuis SQL Server 2016** (Enterprise, Standard, et Express dans les limites de ressources de cette édition).

**Q : Est-ce compatible avec le partitionnement de tables ?**
R : Oui, et c'est même très complémentaire sur les grands historiques (voir §8.7.3).

---

## Résumé

- Le **columnstore** stocke les données **par colonne** au lieu de **par ligne**.
- Il est conçu pour l'**analytique** (OLAP) sur de grands volumes, pas pour le transactionnel fin (OLTP).
- Trois forces : **compression** élevée, **lecture ciblée** des seules colonnes utiles, **mode batch**.
- Les données sont organisées en **rowgroups** (~1 M lignes) et **segments de colonne**, avec élimination des segments inutiles.
- À réserver aux **grandes tables** et aux requêtes d'**agrégation** ; inutile sur les petites tables.

Entrons maintenant dans le détail du « pourquoi » : en quoi le stockage en colonnes change-t-il tout ?

---

⏭️ [Stockage en colonnes vs stockage en lignes](/08-sujets-complementaires-et-ecosysteme/07.1-stockage-colonnes-vs-lignes.md)
