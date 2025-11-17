🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 3.1 La structure de base de SELECT - Introduction

## Bienvenue dans l'interrogation des données !

Félicitations ! Vous avez franchi une étape importante dans votre apprentissage de SQL. Après avoir appris à **créer** des structures de données (tables) et à **insérer** des informations, vous allez maintenant découvrir comment **consulter** et **lire** ces données.

C'est ici que SQL prend toute sa puissance et son utilité au quotidien.

---

## Pourquoi SELECT est-elle LA commande la plus importante ?

Si vous deviez retenir une seule instruction SQL dans votre carrière, ce serait sans hésitation : **SELECT**.

### Les chiffres parlent d'eux-mêmes

Dans la plupart des applications et systèmes d'information :
- **80 à 90%** des requêtes SQL sont des requêtes de **lecture** (SELECT)
- Seulement **10 à 20%** sont des requêtes de **modification** (INSERT, UPDATE, DELETE)

**Pourquoi ?**

Parce que les données sont :
- Consultées en permanence (affichage de pages web, rapports, tableaux de bord, etc.)
- Modifiées beaucoup moins souvent

---

## Qu'est-ce que l'interrogation de données ?

**Interroger** une base de données, c'est lui **poser des questions** pour obtenir des informations précises.

### Analogie : La bibliothèque

Imaginez une immense bibliothèque (votre base de données) remplie de millions de livres (vos données).

Sans système d'interrogation, vous devriez :
- Parcourir **tous** les rayons
- Ouvrir **tous** les livres
- Lire **toutes** les pages
- Chercher manuellement l'information

**Avec SQL et SELECT**, vous avez un bibliothécaire expert qui :
- Comprend votre question
- Sait exactement où chercher
- Vous apporte **uniquement** les informations demandées
- Le fait en quelques millisecondes !

---

## La commande SELECT en quelques mots

### Définition simple

**SELECT** est l'instruction SQL qui permet de **récupérer** des données depuis une ou plusieurs tables d'une base de données.

### Que fait SELECT ?

La commande SELECT vous permet de :

1. **Choisir** quelles colonnes afficher
2. **Filtrer** les lignes selon des critères
3. **Trier** les résultats dans un ordre spécifique
4. **Calculer** de nouvelles valeurs
5. **Regrouper** les données pour des analyses
6. **Combiner** des informations de plusieurs tables

Et bien plus encore !

---

## Structure générale d'une requête SELECT

Voici à quoi ressemble une requête SELECT dans sa forme la plus simple :

```sql
SELECT quoi
FROM où
```

Et dans sa forme plus complète (nous verrons chaque élément progressivement) :

```sql
SELECT     quelles_colonnes           -- Que veux-je voir ?
FROM       quelle_table                -- Où sont les données ?
WHERE      conditions                  -- Quels critères ?
GROUP BY   regroupement                -- Comment regrouper ?
HAVING     conditions_sur_groupes      -- Filtrage des groupes ?
ORDER BY   tri                         -- Dans quel ordre ?
```

**Rassurez-vous !** Nous n'allons pas tout voir d'un coup. Cette section (3.1) se concentre uniquement sur les **fondamentaux** :
- La clause SELECT (choisir les colonnes)
- La clause FROM (choisir la source)
- Les alias (renommer temporairement les colonnes)

---

## Pourquoi commencer par les bases ?

Avant de courir, il faut savoir marcher !

### La progression pédagogique

**Section 3.1** (celle-ci) : Les fondamentaux
- Comment sélectionner des colonnes
- Comment indiquer la source des données
- Comment rendre les résultats plus lisibles

**Sections suivantes** (3.2, 3.3, etc.) : Les techniques avancées
- Filtrer les données (WHERE)
- Trier les résultats (ORDER BY)
- Effectuer des calculs
- Regrouper les données
- Et bien plus...

Chaque concept s'appuie sur le précédent, comme des briques qui forment un édifice solide.

---

## Ce que vous allez apprendre dans cette section

### 3.1.1 SELECT et FROM : Le duo indissociable

Vous découvrirez :
- Comment choisir quelles colonnes afficher
- Comment indiquer de quelle table proviennent les données
- La syntaxe de base de toute requête

**Exemple** :
```sql
SELECT Prenom, Nom
FROM Clients
```

---

### 3.1.2 SELECT * : L'astérisque magique

Vous apprendrez :
- Comment afficher toutes les colonnes d'une table rapidement
- Quand utiliser cette technique
- **Pourquoi il faut l'utiliser avec précaution en production**

**Exemple** :
```sql
SELECT *
FROM Produits
```

---

### 3.1.3 Les alias : Renommer pour clarifier

Vous maîtriserez :
- Comment donner des noms plus clairs aux colonnes
- La syntaxe avec le mot-clé AS
- Comment gérer les espaces dans les noms

**Exemple** :
```sql
SELECT
    Prenom AS PrenomClient,
    Nom AS NomClient
FROM Clients
```

---

## Le parcours d'apprentissage

```
┌─────────────────────────────────────┐
│  Vous êtes ici : Section 3.1        │
│  Les fondamentaux de SELECT         │
└─────────────────────────────────────┘
           │
           ↓
┌─────────────────────────────────────┐
│  3.1.1 : SELECT et FROM             │
│  Le socle de toute requête          │
└─────────────────────────────────────┘
           │
           ↓
┌─────────────────────────────────────┐
│  3.1.2 : SELECT *                   │
│  Tout afficher d'un coup            │
└─────────────────────────────────────┘
           │
           ↓
┌─────────────────────────────────────┐
│  3.1.3 : Alias avec AS              │
│  Clarifier les résultats            │
└─────────────────────────────────────┘
           │
           ↓
┌─────────────────────────────────────┐
│  Suite : Section 3.2 et au-delà     │
│  Filtrage, tri, agrégation...       │
└─────────────────────────────────────┘
```

---

## Un conseil avant de commencer

### Adoptez une approche progressive

1. **Lisez** chaque section dans l'ordre
2. **Comprenez** les concepts avant de passer au suivant
3. **Imaginez** comment vous utiliseriez ces requêtes dans vos projets
4. **Pratiquez** mentalement avec vos propres exemples

### N'ayez pas peur des erreurs

Les erreurs de syntaxe sont **normales** et font partie de l'apprentissage. Même les développeurs expérimentés font des fautes de frappe !

Les messages d'erreur de SQL Server sont là pour vous guider :
- Ils indiquent où se trouve le problème
- Ils suggèrent souvent la solution

---

## Quelques règles de syntaxe SQL à connaître

Avant de plonger dans les détails, voici quelques règles générales sur l'écriture SQL :

### 1. SQL n'est pas sensible à la casse (pour les mots-clés)

Ces trois requêtes sont identiques :
```sql
SELECT Prenom FROM Clients
select Prenom from Clients
SeLeCt Prenom FrOm Clients
```

**Convention recommandée** : Écrire les mots-clés SQL en MAJUSCULES pour la lisibilité
```sql
SELECT Prenom
FROM Clients
```

### 2. Les espaces et retours à la ligne

SQL ignore les espaces supplémentaires et les sauts de ligne. Ces deux requêtes sont identiques :

**Version compacte** :
```sql
SELECT Prenom, Nom FROM Clients
```

**Version lisible** :
```sql
SELECT
    Prenom,
    Nom
FROM
    Clients
```

**Recommandation** : Aérez vos requêtes pour plus de lisibilité !

### 3. Le point-virgule (;)

En T-SQL, le point-virgule en fin de requête est **optionnel** mais recommandé :

```sql
SELECT Prenom, Nom
FROM Clients;
```

C'est une bonne habitude à prendre, même si SQL Server ne l'exige pas toujours.

### 4. Les commentaires

Vous pouvez ajouter des commentaires dans vos requêtes :

**Commentaire sur une ligne** :
```sql
-- Ceci est un commentaire
SELECT Prenom, Nom
FROM Clients
```

**Commentaire sur plusieurs lignes** :
```sql
/*
Ceci est un commentaire
qui s'étend sur
plusieurs lignes
*/
SELECT Prenom, Nom
FROM Clients
```

---

## Votre première requête (aperçu)

Pour vous mettre l'eau à la bouche, voici à quoi ressemble une requête SELECT simple :

```sql
SELECT Prenom, Nom, Email
FROM Clients
```

Cette requête signifie :
- **SELECT Prenom, Nom, Email** : "Je veux voir les colonnes Prenom, Nom et Email"
- **FROM Clients** : "Ces colonnes proviennent de la table Clients"

**Résultat attendu** : Un tableau avec trois colonnes (Prenom, Nom, Email) contenant tous les clients de la table.

Simple, n'est-ce pas ?

---

## L'état d'esprit du développeur SQL

### Pensez en termes de questions

Chaque requête SELECT est une **question** posée à la base de données :

- "Qui sont tous mes clients ?"
- "Quels produits coûtent plus de 100€ ?"
- "Combien de commandes avons-nous reçues ce mois-ci ?"
- "Quel est le chiffre d'affaires par région ?"

SELECT est votre outil pour obtenir ces réponses.

### Soyez précis et intentionnel

Une bonne requête SQL est :
- **Précise** : Elle demande exactement ce dont vous avez besoin
- **Efficace** : Elle ne récupère pas de données inutiles
- **Lisible** : Un autre développeur peut la comprendre facilement

---

## Prêt à commencer ?

Vous avez maintenant une vue d'ensemble de ce qui vous attend dans cette section. Vous comprenez :

- ✅ Pourquoi SELECT est la commande la plus importante
- ✅ Ce qu'est l'interrogation de données
- ✅ La structure générale d'une requête SELECT
- ✅ Ce que vous allez apprendre dans les sections suivantes
- ✅ Les règles de base de la syntaxe SQL

Il est temps de passer à la pratique avec la première sous-section : **3.1.1 SELECT et FROM** !

---

## Récapitulatif

| Concept | En bref |
|---------|---------|
| **SELECT** | La commande pour lire des données |
| **Importance** | 80-90% des requêtes en production |
| **Objectif Section 3.1** | Maîtriser les fondamentaux |
| **Progression** | SELECT/FROM → SELECT * → Alias |
| **État d'esprit** | Poser des questions à la base de données |

---

**Prochaine étape** : Direction la section 3.1.1 où vous écrirez vos premières véritables requêtes SELECT !

Bonne lecture et bon apprentissage ! 🚀

⏭️ [SELECT (Choix des colonnes) et FROM (Source des données)](/03-interrogation-des-donnees-select/01.1-select-et-from.md)
