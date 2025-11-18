🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 7.6 Bonnes pratiques de T-SQL (SARGability)

## Introduction à cette section

Bienvenue dans la section consacrée aux **bonnes pratiques d'écriture de requêtes T-SQL**. Cette section est cruciale car elle aborde des principes qui peuvent transformer des requêtes lentes en requêtes ultra-rapides, sans avoir à modifier l'infrastructure ou ajouter du matériel.

### Pourquoi cette section est-elle si importante ?

Jusqu'à présent dans ce chapitre sur l'optimisation, vous avez appris :
- Comment fonctionnent les index (7.1 et 7.2)
- Comment lire et comprendre les plans d'exécution (7.3)
- L'importance des statistiques (7.4)
- Comment utiliser Query Store pour diagnostiquer les problèmes (7.5)

Mais il manque un élément essentiel : **Comment écrire des requêtes qui permettent à SQL Server d'utiliser efficacement tous ces outils ?**

C'est exactement l'objet de cette section.

## Le paradoxe du développeur

### Le scénario courant

Imaginez cette situation (très fréquente) :

```
DBA : "J'ai créé un index parfait sur la colonne OrderDate."
Développeur : "Super ! J'ai écrit ma requête."
*Une semaine plus tard*
Utilisateurs : "L'application est très lente !"
DBA : "Mais... l'index n'est pas utilisé !"
Développeur : "Pourquoi ? Je filtre bien sur OrderDate !"
```

**Le code du développeur :**
```sql
SELECT * FROM Orders
WHERE YEAR(OrderDate) = 2024;
```

**Le problème :**
La requête est syntaxiquement correcte et retourne les bons résultats, mais elle empêche SQL Server d'utiliser l'index. C'est comme avoir une Ferrari et conduire avec le frein à main serré.

### Analogie : Le GPS et la route

**Situation 1 - Mauvaise pratique :**
```
Vous demandez au GPS :
"Trouve-moi tous les endroits dont le nom à l'envers commence par 'sirap'"

GPS : "Je ne peux pas utiliser ma base de données optimisée"
      "Je dois parcourir TOUS les lieux un par un"
      "Inverser chaque nom"
      "Vérifier s'il commence par 'sirap'"

Résultat : 2 heures pour trouver "Paris"
```

**Situation 2 - Bonne pratique :**
```
Vous demandez au GPS :
"Trouve-moi tous les endroits dont le nom commence par 'Paris'"

GPS : "Parfait ! J'utilise mon index alphabétique"
      "Section P... Pa... Par... Paris"

Résultat : 2 secondes
```

C'est exactement ce qui se passe avec SQL Server : la façon dont vous écrivez votre requête détermine si SQL Server peut utiliser ses index ou non.

## Les trois piliers des bonnes pratiques

Cette section couvre trois principes fondamentaux qui, combinés, peuvent améliorer les performances de 10x à 1000x :

### 1. La SARGability - Rendre les requêtes recherchables (7.6.1)

**Le principe :**
Écrire des conditions WHERE de manière à ce que SQL Server puisse utiliser les index.

**Exemple problématique :**
```sql
WHERE UPPER(CustomerName) = 'MARTIN'
-- La fonction UPPER() empêche l'utilisation de l'index
```

**Exemple optimisé :**
```sql
WHERE CustomerName = 'Martin' COLLATE Latin1_General_CI_AS
-- L'index peut être utilisé
```

**Impact typique :**
- Table de 1 million de lignes
- Avant : 3 secondes (Table Scan)
- Après : 5 millisecondes (Index Seek)
- **Amélioration : 600x plus rapide**

### 2. Éviter les fonctions dans le WHERE (7.6.2)

**Le principe :**
Ne jamais appliquer de fonctions sur les colonnes indexées dans la clause WHERE.

**Exemple problématique :**
```sql
WHERE YEAR(OrderDate) = 2024
-- Fonction YEAR() empêche l'utilisation de l'index
```

**Exemple optimisé :**
```sql
WHERE OrderDate >= '2024-01-01' AND OrderDate < '2025-01-01'
-- L'index sur OrderDate est utilisé efficacement
```

**Impact typique :**
- Table Orders avec 5 millions de lignes
- Avant : 8 secondes, 50,000 pages lues
- Après : 10 millisecondes, 150 pages lues
- **Amélioration : 800x plus rapide, 99.7% de lectures en moins**

### 3. Éviter SELECT * (7.6.3)

**Le principe :**
Toujours spécifier explicitement les colonnes dont vous avez besoin.

**Exemple problématique :**
```sql
SELECT * FROM Products WHERE Category = 'Electronics'
-- Transfère 30 colonnes alors que vous n'en utilisez que 3
```

**Exemple optimisé :**
```sql
SELECT ProductID, ProductName, Price
FROM Products
WHERE Category = 'Electronics'
-- Transfère uniquement les 3 colonnes nécessaires
```

**Impact typique :**
- 100,000 produits avec 30 colonnes (dont une colonne image de 2 MB)
- Avant : 200 GB de données, 5 minutes, serveur saturé
- Après : 15 MB de données, 1 seconde, serveur normal
- **Amélioration : 300x plus rapide, 13,000x moins de données**

## Pourquoi ces pratiques sont souvent négligées

### Raison 1 : Elles fonctionnent... jusqu'à un certain point

```sql
-- Cette requête fonctionne parfaitement
SELECT * FROM Orders
WHERE YEAR(OrderDate) = 2024;

-- Problème : Elle fonctionne sur 100 lignes en développement
-- Mais s'effondre sur 5 millions de lignes en production
```

Les mauvaises pratiques ne se révèlent souvent qu'à grande échelle.

### Raison 2 : Manque de visibilité

Sans outils de monitoring (comme Query Store), vous ne voyez pas :
- Que votre requête fait un Table Scan
- Que l'index parfaitement adapté n'est pas utilisé
- Que vous transférez 100x plus de données que nécessaire

### Raison 3 : Formation insuffisante

Beaucoup de développeurs apprennent SQL avec des exemples simples :
```sql
SELECT * FROM Users WHERE ID = 1;
```

Mais ces exemples n'enseignent pas :
- Pourquoi éviter SELECT *
- Comment écrire des requêtes SARGable
- L'impact des fonctions sur les performances

### Raison 4 : "Ça marchait avant"

```
Mois 1 : Table de 1,000 lignes → Requête en 0.01 seconde → "Parfait !"
Mois 6 : Table de 10,000 lignes → Requête en 0.1 seconde → "Bon..."
Mois 12 : Table de 100,000 lignes → Requête en 1 seconde → "C'est normal"
Mois 18 : Table de 1,000,000 lignes → Requête en 10 secondes → "PROBLÈME !"
```

La croissance progressive masque le problème jusqu'à ce qu'il devienne critique.

## L'impact cumulatif des bonnes pratiques

### Sans les bonnes pratiques

```sql
-- Requête typique mal optimisée
SELECT *
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE YEAR(o.OrderDate) = 2024
  AND UPPER(c.CustomerName) LIKE '%MARTIN%';
```

**Problèmes cumulés :**
1. ❌ SELECT * → Transfère 50 colonnes inutiles
2. ❌ YEAR(OrderDate) → Empêche l'index sur OrderDate
3. ❌ UPPER(CustomerName) → Empêche l'index sur CustomerName
4. ❌ LIKE '%...%' → Wildcard à gauche, non-SARGable

**Résultat sur 1M de commandes :**
- Durée : 45 secondes
- Lectures : 500,000 pages
- Plan : Table Scan sur Orders + Table Scan sur Customers
- Serveur : CPU à 100%

### Avec les bonnes pratiques

```sql
-- Requête optimisée
SELECT
    o.OrderID,
    o.OrderDate,
    c.CustomerName,
    o.TotalAmount
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderDate >= '2024-01-01'
  AND o.OrderDate < '2025-01-01'
  AND c.CustomerName LIKE 'Martin%';
```

**Améliorations cumulées :**
1. ✅ Colonnes spécifiques → Transfère uniquement 4 colonnes
2. ✅ Plage de dates → Index Seek sur OrderDate
3. ✅ Pas de fonction → Index utilisable sur CustomerName
4. ✅ LIKE 'Martin%' → SARGable (wildcard à droite)

**Résultat sur 1M de commandes :**
- Durée : 0.05 secondes (50 millisecondes)
- Lectures : 200 pages
- Plan : Index Seek sur Orders + Index Seek sur Customers
- Serveur : CPU à 5%

**Amélioration globale : 900x plus rapide !**

## Le coût de l'ignorance

### Impact sur les utilisateurs

**Temps d'attente cumulé :**
```
Application avec 1,000 utilisateurs/jour
Chaque utilisateur exécute la requête mal optimisée 5 fois
Temps perdu par utilisateur : 45 secondes × 5 = 225 secondes (3.75 minutes)
Temps perdu total : 3.75 minutes × 1,000 = 3,750 minutes = 62.5 heures

Par an : 62.5 heures × 365 jours = 22,812 heures perdues
Soit 2.6 ANNÉES de temps d'attente !

Avec la version optimisée : 0.05 secondes × 5 × 1,000 = 4 minutes/jour
Par an : 24 heures perdues
Économie : 22,788 heures = 2.6 années !
```

### Impact financier

**Coût de l'infrastructure :**
```
Requêtes mal optimisées :
- Serveur SQL surchargé → Nécessite un upgrade
- Coût : 50,000€ de matériel supplémentaire
- Coût annuel de maintenance : 10,000€

Requêtes optimisées :
- Serveur actuel largement suffisant
- Coût : 0€ d'investissement
- Économie : 60,000€ sur 2 ans
```

**Coût de développement :**
```
Temps passé à déboguer les problèmes de performance :
- Sans bonnes pratiques : 20 heures/mois de débogage
- Avec bonnes pratiques : 2 heures/mois de maintenance

Économie : 18 heures × 12 mois = 216 heures/an
À 100€/heure = 21,600€ économisés par an
```

## Ce que vous allez apprendre

### Compétences techniques

À la fin de cette section, vous serez capable de :

**1. Identifier les requêtes non-optimisées**
- Reconnaître les anti-patterns
- Utiliser les plans d'exécution pour diagnostiquer
- Analyser avec Query Store

**2. Écrire des requêtes SARGable**
- Comprendre le concept de SARGability
- Isoler les colonnes dans le WHERE
- Utiliser les plages au lieu des fonctions

**3. Éviter les fonctions problématiques**
- Connaître les fonctions qui empêchent les index
- Savoir les remplacer par des alternatives optimisées
- Utiliser les colonnes calculées quand nécessaire

**4. Sélectionner intelligemment les colonnes**
- Comprendre l'impact de SELECT *
- Exploiter les index couvrants
- Réduire le transfert de données

**5. Mesurer l'impact de vos optimisations**
- Utiliser SET STATISTICS IO/TIME
- Comparer les plans d'exécution
- Valider les améliorations avec Query Store

### Méthodologie professionnelle

Vous développerez également une méthodologie complète :

```
1. Audit
   ↓
   Identifier les requêtes problématiques
   ↓
2. Analyse
   ↓
   Comprendre pourquoi elles sont lentes
   ↓
3. Optimisation
   ↓
   Appliquer les bonnes pratiques
   ↓
4. Validation
   ↓
   Mesurer l'amélioration
   ↓
5. Documentation
   ↓
   Expliquer les changements
   ↓
6. Monitoring
   ↓
   Surveiller dans le temps
```

## Prérequis pour cette section

Pour tirer le meilleur parti de cette section, vous devriez être à l'aise avec :

✅ **Les bases de T-SQL (Sections 2, 3, 4)**
- SELECT, WHERE, JOIN
- Vous allez optimiser ces requêtes

✅ **Les index (Sections 7.1 et 7.2)**
- Index Clustered et Non-Clustered
- Comprendre comment SQL Server les utilise

✅ **Les plans d'exécution (Section 7.3)**
- Lire un plan graphique
- Identifier Index Seek vs Index Scan
- Comprendre les opérateurs coûteux

✅ **Query Store (Section 7.5) - Recommandé**
- Pour mesurer l'impact de vos optimisations
- Comparer avant/après

Si certains de ces concepts ne sont pas clairs, nous vous recommandons de les réviser avant de continuer.

## Organisation de l'apprentissage

### Progression recommandée

Cette section suit une progression logique du général au spécifique :

```
7.6.1 Le concept de SARGability
   ↓
   Comprendre le principe fondamental
   Pourquoi certaines requêtes ne peuvent pas utiliser les index
   ↓
7.6.2 Éviter les fonctions dans le WHERE
   ↓
   Application pratique de la SARGability
   Cas spécifiques des fonctions (dates, chaînes, calculs)
   ↓
7.6.3 Éviter SELECT *
   ↓
   Optimisation de la sélection des colonnes
   Exploitation des index couvrants
```

### Temps estimé

- **Lecture et compréhension** : 2-3 heures
- **Expérimentation sur vos bases** : 2-4 heures
- **Application dans vos projets** : Ongoing

**Total pour maîtriser** : Une journée de formation intensive, puis pratique continue

## Philosophie de cette section

### Principe 1 : La performance est une fonctionnalité

Une application lente est une application cassée, même si elle retourne les bons résultats.

```
Application avec requêtes mal optimisées :
"Ça marche, mais c'est lent" = Ça ne marche pas bien

Application avec requêtes optimisées :
"Ça marche ET c'est rapide" = Ça marche vraiment bien
```

### Principe 2 : Optimiser tôt coûte moins cher

```
Optimiser dès l'écriture de la requête : 5 minutes
Optimiser en développement : 30 minutes
Optimiser en pré-production : 2 heures
Optimiser en production (en urgence) : 1 journée + stress + impact utilisateurs

→ Mieux vaut prendre 5 minutes dès le début
```

### Principe 3 : Les bonnes pratiques sont universelles

Ces principes s'appliquent à :
- Toutes les versions de SQL Server
- Toutes les tailles de tables
- Tous les types d'applications
- Tous les niveaux d'expérience

### Principe 4 : Mesurer, ne pas deviner

```
❌ "Je pense que cette requête est optimale"
✅ "J'ai mesuré : elle fait 150 lectures logiques avec un Index Seek"

❌ "Cette version semble plus rapide"
✅ "Cette version est 500x plus rapide : 5 secondes → 10 millisecondes"
```

Utilisez toujours les outils (plans d'exécution, statistiques, Query Store) pour valider vos optimisations.

## Les mythes à déconstruire

### Mythe 1 : "Les index résolvent tous les problèmes"

**Faux.**
Un index parfait ne sert à rien si votre requête l'empêche d'être utilisé.

```sql
-- Index parfait sur OrderDate
CREATE INDEX IX_Orders_OrderDate ON Orders(OrderDate);

-- Mais cette requête ne l'utilise pas
SELECT * FROM Orders WHERE YEAR(OrderDate) = 2024;
```

### Mythe 2 : "SELECT * est juste une question de style"

**Faux.**
SELECT * a un impact mesurable et significatif sur les performances.

```
Impact de SELECT * vs colonnes spécifiques :
- 10x à 100x plus de données transférées
- Empêche les index couvrants
- Augmente la consommation mémoire
- Dégrade les temps de réponse
```

### Mythe 3 : "L'optimisation c'est pour plus tard"

**Faux.**
Les mauvaises pratiques créent une dette technique qui s'aggrave avec le temps.

```
Jour 1 : Mauvaise requête sur 1,000 lignes → 0.01 seconde
        "Pas grave, c'est rapide"

1 an plus tard : Même requête sur 1M lignes → 10 secondes
        "Il faut optimiser d'urgence !"
        Coût : Identifier le problème, corriger, tester, déployer = 1 semaine

Si optimisée dès le début :
Jour 1 : Bonne requête sur 1,000 lignes → 0.001 seconde
1 an plus tard : Même requête sur 1M lignes → 0.01 seconde
        "Tout va bien"
        Coût : 5 minutes de plus au début
```

### Mythe 4 : "Mon ORM gère l'optimisation"

**Partiellement vrai.**
Les ORM modernes génèrent du SQL correct, mais :
- Ils peuvent générer SELECT *
- Ils ne savent pas toujours comment rendre les requêtes SARGable
- Vous devez quand même comprendre le SQL généré

```csharp
// Entity Framework peut générer
customers.Where(c => c.Name.ToUpper() == "MARTIN")

// Ce qui se traduit en SQL non-SARGable
WHERE UPPER(Name) = 'MARTIN'

// Vous devez savoir optimiser
customers.Where(c => c.Name == "Martin")
```

### Mythe 5 : "C'est trop complexe pour moi"

**Faux.**
Les bonnes pratiques sont simples à comprendre et à appliquer.

```
Règle simple : La colonne doit être "nue" dans le WHERE
✅ WHERE OrderDate >= '2024-01-01'  ← Colonne nue
❌ WHERE YEAR(OrderDate) = 2024      ← Colonne transformée

C'est aussi simple que ça !
```

## Aperçu des gains possibles

### Cas réel 1 : Application e-commerce

**Avant optimisation :**
- Page de listing produits : 8 secondes
- Recherche clients : 12 secondes
- Dashboard admin : 45 secondes

**Après optimisation (bonnes pratiques appliquées) :**
- Page de listing produits : 0.2 secondes (40x plus rapide)
- Recherche clients : 0.3 secondes (40x plus rapide)
- Dashboard admin : 1.5 secondes (30x plus rapide)

**Impact :**
- Taux de conversion : +25%
- Satisfaction utilisateurs : +60%
- Charge serveur : -80%

### Cas réel 2 : Système de gestion interne

**Avant optimisation :**
- 50 rapports quotidiens : 6 heures de calcul total
- Serveur SQL : 90% CPU en permanence
- Plaintes utilisateurs : quotidiennes

**Après optimisation :**
- 50 rapports quotidiens : 20 minutes de calcul total
- Serveur SQL : 20% CPU en moyenne
- Plaintes utilisateurs : 0

**Économie :**
- Pas besoin d'upgrade serveur : 40,000€ économisés
- Productivité utilisateurs : +5 heures/jour disponibles

### Cas réel 3 : API publique

**Avant optimisation :**
- Endpoint /api/orders : 2000ms en moyenne
- Rate limit nécessaire : 10 requêtes/minute
- Serveur surchargé aux heures de pointe

**Après optimisation :**
- Endpoint /api/orders : 50ms en moyenne (40x plus rapide)
- Rate limit possible : 200 requêtes/minute
- Serveur stable en toutes circonstances

**Impact :**
- Capacité : 20x plus de clients sans investissement
- Expérience développeurs : Excellente
- Coûts cloud : -70%

## Votre engagement pour cette section

Pour tirer le maximum de cette section, engagez-vous à :

**1. Lire activement**
- Ne pas juste survoler
- Comprendre le "pourquoi", pas juste le "comment"
- Poser des questions si quelque chose n'est pas clair

**2. Expérimenter**
- Tester les exemples sur votre propre base
- Comparer les plans d'exécution
- Mesurer les différences de performance

**3. Appliquer immédiatement**
- Auditer vos requêtes existantes
- Identifier les quick wins
- Refactorer progressivement

**4. Partager les connaissances**
- Enseigner aux collègues
- Documenter les optimisations
- Créer des guidelines dans votre équipe

## Prêt à commencer ?

Vous êtes maintenant prêt à plonger dans le monde des bonnes pratiques T-SQL. Ces principes simples mais puissants vont transformer votre manière d'écrire des requêtes.

**Promesse de cette section :** À la fin, vous serez capable d'écrire des requêtes qui :
- Utilisent efficacement les index
- S'exécutent 10x à 1000x plus rapidement
- Scalent gracieusement avec la croissance des données
- Sont maintenables et compréhensibles
- Respectent les standards professionnels

**Rappel important :** Ces bonnes pratiques ne sont pas des "trucs avancés" réservés aux experts. Ce sont des fondamentaux que tout développeur travaillant avec SQL Server devrait maîtriser dès le début.

### Conseil avant de démarrer

Ayez sous la main :
- Une instance SQL Server pour tester (ou SQL Server Express gratuit)
- SSMS ouvert et prêt
- Une table de test avec quelques milliers de lignes
- Query Store activé (pour mesurer l'impact)
- Votre curiosité et votre envie d'améliorer vos compétences !

---

**🎯 Objectifs d'apprentissage de la section 7.6 :**

À la fin de cette section, vous serez capable de :

- ✅ Expliquer ce qu'est la SARGability et pourquoi c'est crucial
- ✅ Identifier les requêtes non-SARGable dans votre code
- ✅ Réécrire les requêtes pour les rendre SARGable
- ✅ Éviter les fonctions problématiques dans les clauses WHERE
- ✅ Remplacer les fonctions par des alternatives optimisées
- ✅ Comprendre pourquoi SELECT * est une mauvaise pratique
- ✅ Écrire des requêtes qui exploitent les index couvrants
- ✅ Mesurer et valider l'impact de vos optimisations
- ✅ Développer une méthodologie d'optimisation systématique
- ✅ Former vos collègues aux bonnes pratiques

**Transformation attendue :**
```
AVANT cette section :
"J'écris des requêtes qui fonctionnent"

APRÈS cette section :
"J'écris des requêtes qui fonctionnent ET qui sont performantes"
```

**Bonne lecture et excellente optimisation ! 🚀**

---

**Passons maintenant à la section 7.6.1 pour découvrir le concept fondamental de SARGability.**

⏭️ [Le concept de SARGability (Rendre les prédicats "recherchables")](/07-optimisation-performance-et-maintenance/06.1-concept-sargability.md)
