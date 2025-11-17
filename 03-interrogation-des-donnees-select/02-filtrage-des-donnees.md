🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 3.2 Filtrage des données - Introduction

## Bienvenue dans l'art du filtrage !

Vous avez appris à afficher des données avec `SELECT` et `FROM`, mais jusqu'à présent, vos requêtes retournent **toutes** les lignes d'une table. Dans le monde réel, c'est rarement ce que vous voulez !

Imaginez une table `Clients` contenant **1 million** de clients. Voudriez-vous vraiment afficher tous les clients à chaque fois ? Bien sûr que non ! Vous voulez être **sélectif** et ne récupérer que les données qui vous intéressent.

**C'est exactement le rôle du filtrage.**

---

## Le problème : Trop de données !

### Sans filtrage

```sql
SELECT Prenom, Nom, Ville, Age
FROM Clients
```

**Résultat** : 1 000 000 de lignes !

| Prenom | Nom | Ville | Age |
|--------|-----|-------|-----|
| Sophie | Martin | Paris | 28 |
| Pierre | Dubois | Lyon | 35 |
| Marie | Leroy | Paris | 42 |
| ... | ... | ... | ... |
| (999 997 lignes de plus) |

**Problèmes** :
- ⏱️ Temps de chargement très long
- 💾 Consommation excessive de mémoire
- 🖥️ Interface utilisateur surchargée
- 😵 Information impossible à analyser

### Avec filtrage

```sql
SELECT Prenom, Nom, Ville, Age
FROM Clients
WHERE Ville = 'Paris' AND Age >= 30
```

**Résultat** : 150 lignes pertinentes

| Prenom | Nom | Ville | Age |
|--------|-----|-------|-----|
| Marie | Leroy | Paris | 42 |
| Jean | Moreau | Paris | 35 |
| ... | ... | ... | ... |

**Avantages** :
- ✅ Rapide à récupérer
- ✅ Facile à analyser
- ✅ Économie de ressources
- ✅ Exactement ce que vous cherchez

---

## Qu'est-ce que le filtrage ?

### Définition

**Filtrer** des données, c'est appliquer des **critères de sélection** pour ne garder que les lignes qui correspondent à ce que vous recherchez.

### Analogie : Le tamis à farine

Imaginez que vous tamisez de la farine :
- **Entrée** : Farine avec grumeaux (toutes les données de la table)
- **Tamis** : Vos critères de filtrage
- **Sortie** : Farine fine sans grumeaux (données filtrées)

Le tamis **laisse passer** ce qui correspond aux critères, et **bloque** le reste.

En SQL, vos critères de filtrage sont comme ce tamis : ils laissent passer certaines lignes et en bloquent d'autres.

---

## Pourquoi le filtrage est essentiel ?

### 1. Performance

**Sans filtrage** : La base de données lit et transmet toutes les lignes.

**Avec filtrage** : La base de données :
- Lit uniquement les lignes nécessaires
- Utilise des index pour aller plus vite (nous verrons cela plus tard)
- Transmet moins de données sur le réseau

**Résultat** : Requêtes **10x, 100x, voire 1000x plus rapides** !

---

### 2. Pertinence

Vous obtenez **exactement** ce dont vous avez besoin :

**Exemples de besoins réels** :
- "Les clients de Paris ayant passé commande ce mois-ci"
- "Les produits en rupture de stock"
- "Les employés embauchés en 2024 avec un salaire supérieur à 3000€"
- "Les commandes non livrées depuis plus de 30 jours"

Sans filtrage, vous devriez parcourir manuellement toutes les données. Avec le filtrage, SQL fait le travail pour vous en millisecondes !

---

### 3. Sécurité

Le filtrage permet aussi de **limiter l'accès** aux données :
- Un vendeur ne voit que ses propres clients
- Un manager ne voit que son département
- Un client ne voit que ses propres commandes

---

### 4. Analyse et reporting

Pour créer des **rapports pertinents**, vous devez filtrer :
- Chiffre d'affaires du **dernier trimestre**
- Produits de la catégorie **Électronique**
- Clients **actifs** (ayant commandé récemment)

---

## Les outils du filtrage en SQL

Cette section (3.2) vous présente **tous les outils** dont vous avez besoin pour filtrer efficacement vos données.

### Vue d'ensemble des sections

```
3.2 FILTRAGE DES DONNÉES
│
├─ 3.2.1 La clause WHERE
│  └─ Le fondement du filtrage
│
├─ 3.2.2 Opérateurs de comparaison
│  └─ =, !=, >, <, >=, <=
│
├─ 3.2.3 Opérateurs logiques
│  └─ AND, OR, NOT
│
├─ 3.2.4 Opérateurs spéciaux
│  └─ IN, BETWEEN, LIKE
│
└─ 3.2.5 Gestion des valeurs NULL
   └─ IS NULL, IS NOT NULL
```

---

## Ce que vous allez apprendre

### 3.2.1 - La clause WHERE : Votre premier filtre

La clause `WHERE` est la **base du filtrage**. C'est elle qui permet de spécifier vos critères.

**Exemple** :
```sql
SELECT Prenom, Nom
FROM Clients
WHERE Ville = 'Paris'
```

Vous apprendrez :
- Comment utiliser WHERE
- Où la placer dans une requête
- Les règles de syntaxe
- Les types de données (texte, nombres, dates)

---

### 3.2.2 - Opérateurs de comparaison : Comparer des valeurs

Les six opérateurs pour comparer des valeurs entre elles.

**Exemples** :
```sql
WHERE Prix > 100          -- Supérieur à
WHERE Age >= 18           -- Supérieur ou égal à
WHERE Stock < 10          -- Inférieur à
WHERE Ville != 'Paris'    -- Différent de
```

Vous apprendrez :
- Les 6 opérateurs de base
- Quand utiliser chacun
- La différence entre > et >=
- Comment comparer dates, nombres et texte

---

### 3.2.3 - Opérateurs logiques : Combiner des conditions

Comment créer des filtres **complexes** en combinant plusieurs conditions.

**Exemples** :
```sql
-- ET : Les deux conditions doivent être vraies
WHERE Ville = 'Paris' AND Age > 30

-- OU : Au moins une condition doit être vraie
WHERE Ville = 'Paris' OR Ville = 'Lyon'

-- NON : Inverse une condition
WHERE NOT (Statut = 'Annulé')
```

Vous apprendrez :
- AND : Toutes les conditions vraies
- OR : Au moins une condition vraie
- NOT : Inverser une condition
- Comment combiner plusieurs opérateurs
- L'ordre de priorité (les parenthèses !)

---

### 3.2.4 - Opérateurs spéciaux : Simplifier vos requêtes

Trois opérateurs **puissants** qui simplifient des cas courants.

**IN** : Tester plusieurs valeurs
```sql
WHERE Ville IN ('Paris', 'Lyon', 'Marseille')
-- Au lieu de : Ville = 'Paris' OR Ville = 'Lyon' OR Ville = 'Marseille'
```

**BETWEEN** : Plage de valeurs
```sql
WHERE Prix BETWEEN 50 AND 100
-- Au lieu de : Prix >= 50 AND Prix <= 100
```

**LIKE** : Recherche de motifs dans du texte
```sql
WHERE Email LIKE '%@gmail.com'     -- Se termine par @gmail.com
WHERE Nom LIKE 'Mar%'              -- Commence par Mar
WHERE Telephone LIKE '06%'         -- Commence par 06
```

Vous apprendrez :
- Comment simplifier des conditions complexes
- Les wildcards % (plusieurs caractères) et _ (un caractère)
- Les pièges à éviter
- Les questions de performance

---

### 3.2.5 - Gestion des NULL : Le cas particulier

NULL représente une **absence de valeur**, et se comporte différemment de toutes les autres valeurs.

**Le piège** :
```sql
WHERE Telephone = NULL   -- ❌ NE FONCTIONNE PAS !
```

**La solution** :
```sql
WHERE Telephone IS NULL      -- ✅ Correct
WHERE Telephone IS NOT NULL  -- ✅ Correct
```

Vous apprendrez :
- Ce qu'est NULL (et ce qu'il n'est pas)
- Pourquoi = NULL ne fonctionne pas
- Comment tester NULL correctement
- Comment gérer NULL dans vos calculs
- Les fonctions ISNULL() et COALESCE()

---

## La progression pédagogique

Cette section suit une progression logique :

### Étape 1 : Les bases
**WHERE** → Comprendre le concept de filtrage

### Étape 2 : Les outils simples
**Opérateurs de comparaison** → Comparer des valeurs

### Étape 3 : Les combinaisons
**Opérateurs logiques** → Conditions multiples

### Étape 4 : Les raccourcis
**IN, BETWEEN, LIKE** → Simplifier les cas courants

### Étape 5 : Le cas spécial
**NULL** → Gérer l'absence de valeur

Chaque section s'appuie sur les précédentes, comme des **briques** qui se construisent les unes sur les autres.

---

## Exemples de filtres que vous saurez créer

À la fin de cette section, vous serez capable d'écrire des requêtes comme :

### E-commerce

```sql
-- Produits électroniques de moins de 500€, en stock, en promotion
SELECT NomProduit, Prix
FROM Produits
WHERE (Categorie = 'Électronique' OR Categorie = 'Informatique')
  AND Prix < 500
  AND Stock > 0
  AND EnPromotion = 1
```

---

### Gestion de clients

```sql
-- Clients VIP de Paris ou Lyon, avec email, ayant commandé récemment
SELECT Prenom, Nom, Email
FROM Clients
WHERE (Ville IN ('Paris', 'Lyon'))
  AND StatutVIP = 1
  AND Email IS NOT NULL
  AND DerniereCommande >= '2024-01-01'
```

---

### Ressources humaines

```sql
-- Employés IT ou Marketing, seniors, avec bonus
SELECT Prenom, Nom, Departement
FROM Employes
WHERE (Departement = 'IT' OR Departement = 'Marketing')
  AND Age >= 45
  AND Bonus IS NOT NULL
  AND Bonus > 0
```

---

## Les questions que vous vous poserez

Tout au long de cette section, vous apprendrez à répondre à des questions comme :

**Questions simples** :
- "Quels sont les clients de Paris ?"
- "Quels produits coûtent plus de 100€ ?"
- "Qui a été embauché en 2024 ?"

**Questions intermédiaires** :
- "Quels produits coûtent entre 50€ et 100€ ?"
- "Quels clients de Paris ou Lyon ont plus de 30 ans ?"
- "Quelles commandes ne sont pas encore livrées ?"

**Questions avancées** :
- "Quels produits électroniques ou informatiques, de moins de 500€, sont en stock ou en promotion ?"
- "Quels employés IT avec plus de 5 ans d'ancienneté n'ont pas de manager assigné ?"
- "Quels clients ont un email Gmail ou Yahoo et ont commandé ce trimestre ?"

---

## Conseils avant de commencer

### 1. Progressez étape par étape

Ne sautez pas d'étapes ! Chaque section introduit des concepts qui seront utilisés dans les suivantes.

**Ordre recommandé** :
1. ✅ Lisez d'abord 3.2.1 (WHERE)
2. ✅ Puis 3.2.2 (Opérateurs de comparaison)
3. ✅ Puis 3.2.3 (Opérateurs logiques)
4. ✅ Puis 3.2.4 (IN, BETWEEN, LIKE)
5. ✅ Enfin 3.2.5 (NULL)

---

### 2. Testez mentalement

Pour chaque exemple, essayez de **visualiser** :
- Quelles lignes seront incluses ?
- Quelles lignes seront exclues ?
- Pourquoi ?

---

### 3. Pensez en termes de questions

Transformez vos besoins en questions :
- ❓ "Je veux..." → "Quels sont les X qui..." ?
- 🔍 Puis traduisez en SQL avec WHERE

---

### 4. Attention aux détails

Le filtrage SQL est **précis** :
- `Ville = 'Paris'` n'est **pas** pareil que `Ville = 'paris'` (selon la configuration)
- `Prix > 100` exclut 100, `Prix >= 100` l'inclut
- `NULL` se comporte différemment de tout le reste

---

### 5. Les erreurs sont normales

Vous ferez des erreurs, c'est **normal** et **utile** :
- ✅ Oublier des apostrophes : `WHERE Nom = Paris` → Erreur !
- ✅ Comparer avec NULL incorrectement : `WHERE Tel = NULL` → Ne marche pas
- ✅ Confondre AND et OR → Résultats inattendus

Chaque erreur vous apprendra quelque chose !

---

## Le pouvoir du filtrage

Une fois que vous maîtriserez le filtrage, vous pourrez :

### 🎯 Extraire l'information pertinente
Ne plus jamais être submergé par trop de données

### ⚡ Créer des requêtes rapides
Des milliers de fois plus rapides qu'un `SELECT *` sans filtre

### 🔒 Sécuriser l'accès aux données
Limiter ce que chaque utilisateur peut voir

### 📊 Générer des rapports précis
Analyser exactement ce qui vous intéresse

### 🛠️ Résoudre des problèmes métier
"Trouver tous les clients inactifs", "Identifier les produits en rupture", etc.

---

## Analogie finale : Le bibliothécaire expert

Imaginez une bibliothèque avec 1 million de livres.

**Sans filtrage**, vous demandez :
> "Donnez-moi tous les livres !"

Le bibliothécaire vous apporte... 1 million de livres. Impossible à gérer !

**Avec filtrage**, vous demandez :
> "Je veux les livres de science-fiction, publiés après 2020, en français, disponibles en ce moment"

Le bibliothécaire vous apporte exactement 15 livres correspondants. Parfait !

**C'est exactement ce que fait WHERE** : il transforme une demande vague en une recherche précise.

---

## Récapitulatif de la section

| Sous-section | Concept clé | Exemple |
|--------------|-------------|---------|
| **3.2.1** | WHERE (base) | `WHERE Ville = 'Paris'` |
| **3.2.2** | Comparaisons | `WHERE Prix > 100` |
| **3.2.3** | Logique | `WHERE A AND B` |
| **3.2.4** | Opérateurs spéciaux | `WHERE Ville IN (...)` |
| **3.2.5** | NULL | `WHERE Tel IS NULL` |

---

## Prêt à filtrer ?

Vous avez maintenant une vision claire de :
- ✅ Pourquoi le filtrage est essentiel
- ✅ Ce que vous allez apprendre
- ✅ Comment les sections s'articulent
- ✅ Les compétences que vous développerez

**Le filtrage est votre superpouvoir en SQL !**

Il transforme une requête basique en un outil d'analyse puissant. C'est la différence entre :
- Afficher 1 million de lignes inutiles
- Obtenir exactement les 10 lignes qui vous intéressent

**Prochaine étape** : Découvrons ensemble la clause WHERE dans la section 3.2.1 ! 🚀

---

**Conseil final** : Prenez votre temps avec chaque section. Le filtrage est au cœur de SQL. Une fois que vous le maîtriserez, vous serez capable de répondre à pratiquement n'importe quelle question métier avec vos données !

Bon apprentissage ! 🎯

⏭️ [La clause WHERE](/03-interrogation-des-donnees-select/02.1-la-clause-where.md)
