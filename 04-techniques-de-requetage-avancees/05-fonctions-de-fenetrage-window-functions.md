🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 4.5 Fonctions de fenêtrage (Window Functions)

## Introduction

Les **fonctions de fenêtrage** (ou *window functions* en anglais) représentent l'une des fonctionnalités les plus puissantes et élégantes de T-SQL moderne. Introduites dans SQL Server 2005 et considérablement enrichies dans les versions ultérieures, elles ont révolutionné la façon dont nous analysons et manipulons les données.

## Qu'est-ce qu'une fonction de fenêtrage ?

Une fonction de fenêtrage est une fonction qui effectue un calcul sur un **ensemble défini de lignes** (appelé "fenêtre") tout en **conservant les détails de chaque ligne individuelle**.

### Le problème qu'elles résolvent

Avant l'existence des fonctions de fenêtrage, vous étiez confronté à un dilemme :

**Option 1 : GROUP BY pour des agrégations**
- Vous obtenez des résumés
- Mais vous **perdez** les détails des lignes individuelles

**Option 2 : Jointures ou sous-requêtes complexes**
- Vous conservez les détails
- Mais le code devient **complexe, difficile à lire et lent**

**Les fonctions de fenêtrage : Le meilleur des deux mondes !**
- Vous obtenez des calculs agrégés **ET** vous conservez tous les détails
- Le code est **simple, lisible et performant**

## Analogie simple : La classe d'étudiants

Imaginez une classe de 30 étudiants avec leurs notes :

### Sans fonctions de fenêtrage

**Avec GROUP BY**, vous pourriez calculer :
- La moyenne de la classe : **14/20**

Mais vous perdez la liste des étudiants individuels !

**Avec des jointures complexes**, vous pourriez :
- Afficher chaque étudiant avec la moyenne de la classe à côté
- Mais cela nécessite des sous-requêtes ou auto-jointures compliquées

### Avec les fonctions de fenêtrage

En une seule requête simple, vous pouvez afficher :
- **Chaque étudiant** avec sa note individuelle
- **La moyenne de la classe** affichée sur chaque ligne
- **Le rang** de chaque étudiant
- **L'écart** de chaque étudiant par rapport à la moyenne
- **La note la plus haute** et **la plus basse** de la classe

Tout cela **en conservant une ligne par étudiant** !

## Qu'est-ce qu'une "fenêtre" ?

Le terme **"fenêtre"** désigne l'ensemble de lignes sur lequel la fonction opère.

Pensez à une fenêtre comme :
- Une **vue** sur un sous-ensemble de vos données
- Un **cadre** que vous pouvez définir de différentes manières
- Un **contexte** dans lequel le calcul est effectué

La fenêtre peut être :
- **Toutes les lignes** de la table
- **Un groupe de lignes** (par exemple, tous les employés d'un même département)
- **Une plage de lignes** autour de la ligne courante (par exemple, les 3 lignes précédentes)

## Les grandes familles de fonctions de fenêtrage

Les fonctions de fenêtrage se divisent en plusieurs catégories :

### 1. Fonctions d'agrégation analytiques
Les fonctions d'agrégation classiques (SUM, AVG, COUNT, MIN, MAX) utilisées dans un contexte de fenêtrage.

**Exemple d'utilisation :**
- Afficher chaque vente avec le total des ventes du mois
- Calculer des moyennes mobiles
- Créer des totaux cumulatifs

### 2. Fonctions de classement
Des fonctions spéciales pour attribuer des rangs ou numéros aux lignes.

**Les principales :**
- **ROW_NUMBER()** : Numérotation séquentielle unique
- **RANK()** : Classement avec sauts en cas d'égalité
- **DENSE_RANK()** : Classement sans sauts
- **NTILE()** : Division en groupes de taille égale

**Exemple d'utilisation :**
- Identifier les 10 meilleurs vendeurs
- Numéroter les transactions par client
- Diviser les produits en quartiles de prix

### 3. Fonctions de décalage
Des fonctions pour accéder aux valeurs d'autres lignes sans jointures.

**Les principales :**
- **LAG()** : Accède aux lignes précédentes
- **LEAD()** : Accède aux lignes suivantes
- **FIRST_VALUE()** : Première valeur de la fenêtre
- **LAST_VALUE()** : Dernière valeur de la fenêtre

**Exemple d'utilisation :**
- Comparer les ventes du mois avec celles du mois précédent
- Calculer la durée entre deux événements
- Détecter des changements d'état

### 4. Fonctions de distribution (avancé)
Des fonctions statistiques pour calculer des percentiles et distributions.

**Les principales :**
- **PERCENT_RANK()** : Rang en pourcentage
- **CUME_DIST()** : Distribution cumulative
- **PERCENTILE_CONT()** : Percentile continu
- **PERCENTILE_DISC()** : Percentile discret

## Pourquoi utiliser les fonctions de fenêtrage ?

### 1. Simplicité et lisibilité

**Avant (sans fonctions de fenêtrage) :**
```sql
-- Code complexe avec sous-requête corrélée
SELECT
    E1.Nom,
    E1.Salaire,
    (SELECT AVG(E2.Salaire)
     FROM Employes E2
     WHERE E2.Departement = E1.Departement) AS MoyenneDept
FROM Employes E1;
```

**Après (avec fonctions de fenêtrage) :**
```sql
-- Code simple et clair
SELECT
    Nom,
    Salaire,
    AVG(Salaire) OVER(PARTITION BY Departement) AS MoyenneDept
FROM Employes;
```

### 2. Performance

Les fonctions de fenêtrage sont **optimisées par SQL Server** :
- Elles évitent les jointures coûteuses
- Elles réduisent le nombre de passes sur les données
- Elles utilisent efficacement la mémoire et les index

### 3. Expressivité

Elles permettent d'exprimer des calculs complexes de manière naturelle :
- Totaux cumulatifs (running totals)
- Moyennes mobiles (moving averages)
- Comparaisons période à période
- Classements et percentiles
- Détection de tendances

### 4. Standard SQL

Les fonctions de fenêtrage font partie du **standard SQL:2003**, ce qui signifie :
- Elles sont portables vers d'autres SGBD (PostgreSQL, Oracle, MySQL 8+)
- Elles représentent une compétence transférable
- Elles suivent une syntaxe standardisée

## Exemples concrets de problèmes résolus

### Problème 1 : Top N par catégorie

**Question :** "Quels sont les 3 produits les plus vendus dans chaque catégorie ?"

Sans fonctions de fenêtrage, cela nécessite des jointures complexes ou des curseurs.

Avec fonctions de fenêtrage : quelques lignes de code simple !

### Problème 2 : Comparaison avec la période précédente

**Question :** "Quelles sont les ventes de chaque mois comparées au mois précédent ?"

Sans fonctions de fenêtrage, vous devez faire une auto-jointure sur la table.

Avec fonctions de fenêtrage : accès direct à la ligne précédente !

### Problème 3 : Total cumulatif

**Question :** "Quel est le chiffre d'affaires cumulé mois par mois ?"

Sans fonctions de fenêtrage, vous devez utiliser des sous-requêtes ou des variables.

Avec fonctions de fenêtrage : calcul automatique et optimal !

### Problème 4 : Pourcentage du total

**Question :** "Quelle est la contribution de chaque vendeur au total des ventes de sa région ?"

Sans fonctions de fenêtrage, vous devez faire une jointure avec une sous-requête agrégée.

Avec fonctions de fenêtrage : calcul direct sur chaque ligne !

## Différence fondamentale avec GROUP BY

C'est la distinction la plus importante à comprendre :

### GROUP BY : Agrégation réductrice

```sql
SELECT
    Departement,
    AVG(Salaire) AS SalaireMoyen
FROM Employes
GROUP BY Departement;
```

**Résultat :** 3 lignes (si 3 départements)
- Vous obtenez un résumé
- Vous **perdez** les détails des employés individuels

### Fonctions de fenêtrage : Agrégation enrichissante

```sql
SELECT
    Nom,
    Departement,
    Salaire,
    AVG(Salaire) OVER(PARTITION BY Departement) AS SalaireMoyen
FROM Employes;
```

**Résultat :** Autant de lignes que d'employés (par exemple 50 lignes)
- Vous conservez tous les détails
- Vous **ajoutez** des informations contextuelles

## Quand utiliser les fonctions de fenêtrage ?

Utilisez les fonctions de fenêtrage quand vous avez besoin de :

### ✅ Utilisez-les pour :
- Calculer des agrégations **tout en gardant les détails** de chaque ligne
- Attribuer des **rangs** ou **numéros de ligne**
- Comparer une ligne avec les lignes **précédentes ou suivantes**
- Calculer des **totaux cumulatifs** ou **moyennes mobiles**
- Identifier les **top N** dans chaque groupe
- Calculer des **pourcentages du total**
- Effectuer des **analyses temporelles** (évolutions, tendances)

### ❌ Ne les utilisez pas pour :
- Des agrégations simples où vous voulez **réduire les lignes** (utilisez GROUP BY)
- Des calculs qui ne nécessitent **pas de contexte** d'autres lignes
- Quand les performances sont critiques et que des alternatives plus simples existent

## Structure de ce chapitre

Dans les sections suivantes, nous allons explorer en détail :

### **4.5.1 - Le concept de la clause OVER()**
Comprendre la clause fondamentale qui permet d'utiliser les fonctions de fenêtrage. C'est la base de tout !

### **4.5.2 - PARTITION BY (Agrégation sans GROUP BY)**
Apprendre à diviser les données en groupes pour des calculs par partition, tout en conservant les détails de chaque ligne.

### **4.5.3 - Fonctions de classement**
Maîtriser ROW_NUMBER, RANK, DENSE_RANK et NTILE pour numéroter et classer les lignes.

### **4.5.4 - Fonctions d'agrégation analytiques**
Utiliser SUM, AVG, COUNT, MIN, MAX avec OVER() pour créer des totaux cumulatifs, moyennes mobiles, et plus encore.

### **4.5.5 - Fonctions de décalage**
Découvrir LAG et LEAD pour accéder aux valeurs des lignes précédentes ou suivantes sans jointures.

## Prérequis

Avant d'aborder les fonctions de fenêtrage, assurez-vous d'être à l'aise avec :

- ✅ La requête **SELECT** de base
- ✅ Les clauses **WHERE**, **ORDER BY**, **GROUP BY**
- ✅ Les **fonctions d'agrégation** classiques (SUM, AVG, COUNT, MIN, MAX)
- ✅ Le concept de **jointures**
- ✅ Les **sous-requêtes** (au moins les bases)

Si ces concepts sont clairs, vous êtes prêt à découvrir les fonctions de fenêtrage !

## Note sur la syntaxe

La syntaxe générale des fonctions de fenêtrage suit ce modèle :

```sql
fonction() OVER(
    [PARTITION BY colonne1, colonne2, ...]
    [ORDER BY colonne3, ...]
    [ROWS | RANGE ...]
)
```

**Ne vous inquiétez pas si cela semble abstrait pour l'instant !** Nous allons décortiquer chaque élément progressivement dans les sections suivantes.

## Versions de SQL Server

Les fonctions de fenêtrage ont été introduites progressivement :

- **SQL Server 2005** : Introduction de ROW_NUMBER, RANK, DENSE_RANK, NTILE
- **SQL Server 2012** : Ajout majeur de fonctionnalités (LAG, LEAD, fenêtres ROWS/RANGE, agrégations analytiques)
- **SQL Server 2016+** : Améliorations de performance continues

Si vous utilisez SQL Server 2012 ou plus récent, vous avez accès à toutes les fonctionnalités que nous allons couvrir.

## Conseils pour l'apprentissage

### 1. Progressez étape par étape
Les fonctions de fenêtrage sont un sujet vaste. Ne cherchez pas à tout maîtriser d'un coup !
- Commencez par OVER() et PARTITION BY
- Puis les fonctions de classement
- Ensuite les agrégations analytiques
- Enfin les fonctions de décalage

### 2. Pratiquez avec des exemples simples
Commencez avec des petits jeux de données (5-10 lignes) pour bien **voir** ce qui se passe.

### 3. Visualisez les fenêtres
Essayez de visualiser mentalement (ou sur papier) quelle est la "fenêtre" sur laquelle la fonction opère.

### 4. Comparez avec GROUP BY
Pour chaque exemple, demandez-vous : "Comment ferais-je cela avec GROUP BY ?" Cela vous aidera à comprendre la différence.

### 5. Expérimentez
N'hésitez pas à modifier les exemples, à changer les colonnes de PARTITION BY ou ORDER BY, pour voir l'impact sur les résultats.

## Ressources complémentaires

Une fois que vous aurez maîtrisé les bases, vous pourrez approfondir avec :
- La documentation officielle Microsoft sur les fonctions de fenêtrage
- Les cadres de fenêtre avancés (ROWS BETWEEN, RANGE BETWEEN)
- Les optimisations de performance spécifiques
- Les fonctions de distribution statistique

Mais tout cela viendra en temps voulu. Pour l'instant, concentrons-nous sur les fondamentaux !

## Prêt à commencer ?

Les fonctions de fenêtrage vont transformer votre façon d'écrire des requêtes SQL. Elles élimineront de nombreuses jointures complexes, rendront votre code plus lisible, et vous permettront d'effectuer des analyses qui seraient autrement très difficiles.

Dans la section suivante, nous allons explorer **le concept de la clause OVER()**, qui est la pierre angulaire de toutes les fonctions de fenêtrage.

C'est parti pour cette aventure passionnante ! 🚀

---

**Note :** Les fonctions de fenêtrage sont souvent considérées comme un sujet "avancé" en SQL. Ne vous découragez pas si tout ne semble pas clair immédiatement. Avec de la pratique et des exemples concrets, elles deviendront rapidement l'un de vos outils préférés en T-SQL !

⏭️ [Le concept de la clause OVER()](/04-techniques-de-requetage-avancees/05.1-concept-clause-over.md)
