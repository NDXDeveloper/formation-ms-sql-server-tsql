🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 8.8 Recherche plein texte (Full-Text Search)

## Introduction

Imaginez un site qui stocke des milliers d'articles, de descriptions de produits ou de documents. Un utilisateur tape « chaussures de course imperméables » dans la barre de recherche. Comment retrouver les contenus pertinents, **rapidement**, même si l'auteur a écrit « chaussure imperméable pour courir » ?

Avec les outils vus jusqu'ici, on tenterait :

```sql
SELECT * FROM Articles WHERE Contenu LIKE '%course%';
```

Mais cette approche est **lente** (elle lit toute la table, sans index utilisable) et **limitée** : elle ne comprend ni les variantes (« courir », « course », « coureur »), ni les synonymes, ni la notion de **pertinence**. C'est précisément le problème que résout la **recherche plein texte** (*Full-Text Search*, FTS) de SQL Server.

---

## Le problème avec LIKE

`LIKE '%mot%'` souffre de plusieurs défauts pour la recherche textuelle :

| Limite de `LIKE '%...%'` | Conséquence |
|--------------------------|-------------|
| Ne peut pas utiliser d'index B-tree (joker en tête) | **Balayage complet** de la table → lent |
| Recherche une **sous-chaîne** brute | « courir » ne trouve pas « course » |
| Aucune notion de **pertinence** | Impossible de classer les résultats du plus au moins pertinent |
| Pas de **proximité** ni de **synonymes** | Recherche pauvre |
| Pas de gestion des **mots vides** (le, la, de…) | Bruit |

La recherche plein texte est conçue pour répondre à tout cela.

---

## Qu'est-ce que la recherche plein texte ?

La **recherche plein texte** s'appuie sur un **index de texte intégral** (*full-text index*) : une structure spécialisée qui décompose le texte en **mots** (*tokens*) et permet de les rechercher **linguistiquement**.

> 🧠 **Analogie** : `LIKE` revient à **lire chaque page** d'un livre pour trouver un mot. L'index de texte intégral est l'**index alphabétique en fin de livre** : on va directement aux pages concernées, et on connaît même l'importance relative de chaque occurrence.

### Les capacités linguistiques

L'index de texte intégral apporte une vraie intelligence linguistique :

- **Découpage en mots** (*word breaking*) selon la langue.
- **Racinisation** (*stemming*) : « courir », « course », « courons » se rattachent à la même racine → une recherche sur l'un trouve les autres (formes fléchies).
- **Mots vides** (*stopwords*) : les mots non significatifs (« le », « de », « and »…) sont ignorés.
- **Thésaurus** : gestion des **synonymes** configurables.
- **Pertinence** (*ranking*) : chaque résultat reçoit un **score** permettant de classer du plus pertinent au moins pertinent.

---

## Que peut-on indexer ?

- Des colonnes texte : `CHAR`, `VARCHAR`, `NCHAR`, `NVARCHAR`, `XML`.
- Des **documents binaires** stockés en `VARBINARY(MAX)` (Word, PDF, PowerPoint…) grâce à des composants appelés **iFilters** : SQL Server sait alors en extraire le texte pour l'indexer. La colonne doit être accompagnée d'une colonne indiquant le **type de document** (ex. `.pdf`, `.docx`).

---

## Vue d'ensemble : les briques de la FTS

```
   ┌─────────────────────┐
   │  CATALOGUE          │  conteneur logique des index de texte intégral
   │  full-text          │
   │   ┌───────────────┐ │
   │   │ INDEX full-text│ │  un par table, sur une ou plusieurs colonnes texte
   │   └───────────────┘ │
   └─────────────────────┘
              ▲
              │  interrogé par
              │
   CONTAINS / FREETEXT / CONTAINSTABLE / FREETEXTTABLE
```

- Un **catalogue** de texte intégral regroupe des index.
- Un **index de texte intégral** est associé à une table (un seul par table) et nécessite un **index unique** (souvent la clé primaire) pour identifier les lignes.
- On interroge ensuite avec les prédicats `CONTAINS`/`FREETEXT` ou les fonctions `CONTAINSTABLE`/`FREETEXTTABLE`.

Ces éléments sont détaillés en §8.8.1, et les requêtes en §8.8.2.

---

## Full-Text Search vs LIKE : comparaison

| Critère | `LIKE '%...%'` | Full-Text Search |
|---------|----------------|------------------|
| Performance sur gros volumes | ❌ Lente (scan) | ✅ Rapide (index dédié) |
| Formes fléchies (courir/course) | ❌ Non | ✅ Oui (`FORMSOF INFLECTIONAL`) |
| Synonymes | ❌ Non | ✅ Oui (thésaurus) |
| Proximité de mots | ❌ Non | ✅ Oui (`NEAR`) |
| Pertinence / classement | ❌ Non | ✅ Oui (`RANK`) |
| Documents (PDF, Word) | ❌ Non | ✅ Oui (iFilters) |
| Simplicité | ✅ Très simple | ⚠️ Nécessite une configuration |

---

## Quand l'utiliser (et ses alternatives)

✅ **Idéal pour** : moteurs de recherche internes, recherche dans des descriptions/articles/documents, recherche multilingue avec pertinence.

⚠️ **À savoir** : pour des besoins de recherche très avancés à grande échelle (facettes, scoring très fin, autocomplétion sophistiquée), des moteurs spécialisés comme **Elasticsearch** ou **Azure AI Search** vont plus loin. L'atout de la FTS de SQL Server est d'être **intégrée** : pas de système externe à maintenir, et on combine librement recherche textuelle et requêtes SQL classiques (jointures, filtres).

> 💡 **Prérequis d'installation** : la recherche plein texte est un **composant optionnel** de SQL Server (« Full-Text and Semantic Extractions for Search »). Il doit être installé sur l'instance (voir l'annexe A sur l'installation).

---

## Pièges courants

| Piège | Conséquence | Bon réflexe |
|-------|-------------|-------------|
| Confondre `LIKE '%mot%'` et FTS | Lenteur et recherche pauvre | FTS pour la recherche linguistique sur de gros volumes |
| **Composant non installé** | `CREATE FULLTEXT...` échoue | Installer « Full-Text Search » sur l'instance (annexe A) |
| Rechercher un **mot vide** (« le », « de ») | Aucun résultat | Les mots vides sont ignorés par conception |
| Mauvaise **langue** d'index | Racinisation / mots vides incorrects | Déclarer la bonne `LANGUAGE` par colonne |
| Interroger un index **non peuplé** | Résultats vides | Attendre la fin du peuplement (*population*) |

## Questions fréquentes

**Q : La FTS remplace-t-elle un moteur comme Elasticsearch ?**
R : Pour une recherche intégrée à SQL Server (combinée à des filtres SQL), elle suffit souvent. Pour des besoins très avancés à grande échelle, un moteur dédié va plus loin.

**Q : Puis-je gérer plusieurs langues dans la même table ?**
R : Oui, la clause `LANGUAGE` se définit **par colonne** indexée.

**Q : Quelle différence avec `PATINDEX` / `LIKE` ?**
R : Ces fonctions manipulent des chaînes brutes ; elles n'offrent ni index linguistique, ni racinisation, ni pertinence. La FTS est conçue pour la recherche.

---

## Résumé

- La **recherche plein texte** indexe le **texte par mots** et permet une recherche **linguistique** (formes fléchies, synonymes, mots vides) avec **pertinence**.
- Elle dépasse de loin `LIKE '%...%'`, à la fois en **performance** et en **richesse**.
- Elle s'appuie sur un **catalogue** et un **index de texte intégral** (un par table, nécessite un index unique).
- On peut indexer des colonnes texte **et** des documents binaires (PDF, Word…) via les **iFilters**.
- C'est un **composant optionnel** à installer ; intégré au SQL, il évite un moteur de recherche externe.

Voyons comment mettre en place concrètement un catalogue et un index de texte intégral.

---

⏭️ [Catalogues et index de texte intégral](/08-sujets-complementaires-et-ecosysteme/08.1-catalogues-et-index-texte-integral.md)
