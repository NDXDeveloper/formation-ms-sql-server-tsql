🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 6.3 Concurrence et Verrouillage (Locking)

## Introduction

Jusqu'à présent, nous avons appris à créer des bases de données, à manipuler des données et à gérer des transactions. Mais que se passe-t-il lorsque **plusieurs utilisateurs ou applications accèdent simultanément aux mêmes données** ? C'est une situation très courante dans le monde réel, et c'est ce qu'on appelle la **concurrence**.

La gestion de la concurrence est l'un des défis majeurs des systèmes de gestion de bases de données. SQL Server utilise un mécanisme appelé **verrouillage (locking)** pour garantir que les données restent cohérentes même lorsque plusieurs transactions s'exécutent en même temps.

Dans ce chapitre, nous allons explorer en profondeur ces concepts essentiels pour comprendre comment SQL Server gère les accès concurrents aux données.

---

## Qu'est-ce que la concurrence ?

### Définition

La **concurrence** désigne la capacité d'un système de base de données à permettre à **plusieurs transactions de s'exécuter simultanément** sur les mêmes données ou sur des données différentes.

### Exemple du quotidien

Imaginez un système de réservation de places de cinéma en ligne :
- À 20h00, **1000 personnes** se connectent simultanément pour réserver des places pour le même film
- Toutes consultent les places disponibles
- Plusieurs personnes veulent réserver la **même place A12**
- Le système doit garantir qu'**une seule personne** obtient cette place

C'est exactement le type de situation que SQL Server doit gérer quotidiennement dans les applications réelles.

### Scénarios typiques de concurrence

**1. E-commerce**
- Des milliers de clients consultent le catalogue en même temps
- Plusieurs clients tentent d'acheter le dernier article en stock
- Le stock doit être mis à jour correctement

**2. Banque en ligne**
- Un client consulte son solde depuis son téléphone
- Au même moment, un paiement automatique est prélevé sur son compte
- Le solde affiché doit être cohérent

**3. Système de gestion hospitalier**
- Des médecins consultent et mettent à jour les dossiers patients
- Des infirmières enregistrent des observations
- Les pharmaciens vérifient les prescriptions
- Toutes ces opérations se font en parallèle

---

## Pourquoi la concurrence est-elle un défi ?

### Le problème fondamental

Sans mécanisme de contrôle, l'accès concurrent aux mêmes données peut entraîner :

1. **Des incohérences** : Les données deviennent contradictoires
2. **Des pertes de mises à jour** : Des modifications sont écrasées par d'autres
3. **Des lectures incorrectes** : Les utilisateurs voient des données invalides
4. **Une corruption de données** : L'intégrité de la base est compromise

### Illustration : Le compte bancaire partagé

Prenons un exemple concret pour comprendre le problème :

**Situation initiale :**
- Compte bancaire : 1000€
- Deux retraits simultanés de 600€

**Sans contrôle de concurrence :**

```
Transaction A                  Transaction B
──────────────────────────────────────────────────
Lit le solde : 1000€
                               Lit le solde : 1000€
Vérifie : 1000 - 600 = OK
                               Vérifie : 1000 - 600 = OK
Retire 600€
Nouveau solde = 400€
                               Retire 600€
                               Nouveau solde = 400€
```

**Résultat :**
- 1200€ ont physiquement été retirés (2 × 600€)
- Mais le solde final affiché est **400€** : la seconde transaction a **écrasé** la mise à jour de la première (les deux avaient lu 1000€ et écrit 400€). C'est une **perte de mise à jour** (*lost update*).
- La banque a donc décaissé 1200€ tout en n'en comptabilisant que 600€ (solde passé de 1000€ à 400€) : **600€ se sont volatilisés sans que personne ne s'en aperçoive !** De plus, le second retrait — qui aurait dû être refusé pour solde insuffisant — a été autorisé à tort.

### Les objectifs du contrôle de concurrence

Un bon système de gestion de concurrence doit :

1. **Maximiser la concurrence** : Permettre à un maximum de transactions de s'exécuter simultanément
2. **Garantir la cohérence** : Assurer que les données restent toujours dans un état valide
3. **Maintenir les performances** : Ne pas ralentir excessivement le système
4. **Être transparent** : Les développeurs et utilisateurs ne doivent pas avoir à gérer la complexité

C'est un **compromis délicat** entre performance et cohérence.

---

## Le verrouillage : La solution de SQL Server

### Principe de base

SQL Server utilise un système de **verrous (locks)** pour contrôler l'accès concurrent aux données. Un verrou est comme un panneau "Occupé" qui indique qu'une ressource est en cours d'utilisation.

### Analogie : La salle de bain

Imaginez une salle de bain dans un restaurant :
- Quand quelqu'un entre, il **verrouille la porte** (pose un verrou)
- Les autres personnes qui veulent entrer **doivent attendre** (sont bloquées)
- Quand la personne sort, elle **déverrouille la porte** (libère le verrou)
- La personne suivante peut alors entrer

C'est exactement ainsi que fonctionnent les verrous dans SQL Server : ils régulent l'accès aux données pour éviter les conflits.

### Exemple avec notre compte bancaire

**Avec contrôle de concurrence :**

```
Transaction A                  Transaction B
──────────────────────────────────────────────────
VERROUILLE le compte
Lit le solde : 1000€
                               Tente de VERROUILLER le compte
                               → BLOQUÉE (doit attendre)
Vérifie : 1000 - 600 = OK
Retire 600€
Nouveau solde = 400€
LIBÈRE le verrou
                               VERROUILLE le compte (maintenant disponible)
                               Lit le solde : 400€
                               Vérifie : 400 - 600 = NON OK
                               → Retrait REFUSÉ
                               LIBÈRE le verrou
```

**Résultat :**
- Transaction A réussit : 600€ retirés
- Transaction B échoue : Solde insuffisant
- Le solde final est correct : 400€
- **L'intégrité est préservée !**

---

## Les défis du verrouillage

Bien que le verrouillage soit essentiel, il introduit ses propres défis :

### 1. Le compromis Performance vs Cohérence

**Plus de verrous = Plus de cohérence, mais Moins de performance**

- **Verrous stricts** : Garantissent une cohérence maximale, mais ralentissent le système (files d'attente)
- **Verrous légers** : Améliorent les performances, mais peuvent permettre des incohérences

### 2. Les types de problèmes

Le verrouillage doit gérer plusieurs types de problèmes :

**a) Les anomalies de lecture**
- Lire des données temporaires qui seront annulées
- Relire une donnée et obtenir une valeur différente
- Relire des données et trouver de nouvelles lignes

**b) Le blocage (Blocking)**
- Une transaction attend qu'une autre libère un verrou
- C'est normal, mais peut ralentir le système si excessif

**c) L'interblocage (Deadlock)**
- Deux transactions s'attendent mutuellement
- Situation d'impasse qui nécessite l'annulation d'une transaction

### 3. La granularité des verrous

SQL Server peut verrouiller à différents niveaux :
- Une seule **ligne** (précis, mais coûteux en ressources)
- Une **page** de données (compromis)
- Une **table** entière (rapide, mais bloque beaucoup)

Le choix du niveau approprié est crucial pour l'équilibre performance/cohérence.

---

## Les propriétés ACID et la concurrence

Rappelons les propriétés **ACID** des transactions :

| Propriété | Description | Lien avec la concurrence |
|-----------|-------------|--------------------------|
| **A**tomicité | Tout ou rien | Garantit qu'une transaction interrompue (ex: deadlock) est annulée complètement |
| **C**ohérence | Données valides | Les verrous empêchent les états incohérents |
| **I**solation | Indépendance | Le verrouillage isole les transactions les unes des autres |
| **D**urabilité | Persistance | Garantit que les modifications validées sont permanentes |

La gestion de la concurrence est principalement liée à la propriété **I**solation. C'est elle qui détermine :
- Quels types de verrous sont utilisés
- Combien de temps ils sont maintenus
- Quelles anomalies sont autorisées ou bloquées

---

## Vue d'ensemble de ce chapitre

Dans les sections suivantes, nous allons explorer en détail :

### 6.3.1 Problématiques de concurrence
Nous découvrirons les trois principales anomalies qui peuvent survenir :
- **Dirty Reads** (Lectures sales) : Lire des données non validées
- **Non-Repeatable Reads** (Lectures non répétables) : Une même lecture donne des résultats différents
- **Phantom Reads** (Lectures fantômes) : De nouvelles lignes apparaissent entre deux lectures

### 6.3.2 Le concept de verrou et de blocage
Nous comprendrons :
- Les différents types de verrous (partagé, exclusif, mise à jour)
- Comment fonctionne le blocage (blocking)
- L'impact sur les performances
- Les bonnes pratiques

### 6.3.3 L'interblocage (Deadlock)
Nous étudierons :
- Ce qu'est un deadlock et comment il se produit
- Comment SQL Server le détecte et le résout
- Comment prévenir les deadlocks
- Les stratégies de gestion des erreurs

---

## Concepts clés à retenir

Avant de plonger dans les détails, gardez en tête ces principes fondamentaux :

### 1. La concurrence est inévitable
Dans les applications modernes, **plusieurs utilisateurs accéderont toujours simultanément** à la base de données. Ce n'est pas un problème à éviter, mais une réalité à gérer.

### 2. Le verrouillage est nécessaire
Sans verrous, l'intégrité des données serait impossible à garantir. Les verrous ne sont **pas un mal**, ils sont une **solution**.

### 3. Tout est une question d'équilibre
Il n'existe pas de "configuration parfaite". Chaque application doit trouver le **bon compromis** entre :
- Cohérence des données
- Performance du système
- Expérience utilisateur

### 4. SQL Server gère beaucoup automatiquement
SQL Server possède des mécanismes sophistiqués pour gérer la concurrence. En tant que développeur, vous devez :
- **Comprendre** ces mécanismes
- **Choisir** les bons niveaux d'isolation
- **Concevoir** vos transactions intelligemment
- **Surveiller** les problèmes de performance

### 5. La prévention vaut mieux que la correction
De bonnes pratiques de conception (ordre d'accès aux tables, transactions courtes, index appropriés) préviennent la majorité des problèmes de concurrence.

---

## Analogie finale : La circulation routière

La gestion de la concurrence dans une base de données est similaire à la gestion du trafic routier :

- **Les transactions** sont comme des **voitures**
- **Les données** sont comme des **routes**
- **Les verrous** sont comme des **feux de signalisation**
- **Le blocage** est comme une **file d'attente** à un feu rouge
- **Le deadlock** est comme une **intersection complètement bloquée**

Tout comme la circulation, l'objectif est de maximiser le flux (performance) tout en garantissant la sécurité (intégrité des données). Trop de feux rouges ralentissent tout le monde. Pas assez de feux créent des accidents.

---

## Préparation pour les sections suivantes

Pour tirer le meilleur parti des sections suivantes, gardez à l'esprit ces questions :

1. **Quels types d'anomalies** mon application peut-elle tolérer ?
2. **Quelle est la fréquence** des accès concurrents dans mon système ?
3. **Quelles sont les données critiques** qui nécessitent une protection maximale ?
4. **Quel est le niveau de performance** acceptable pour mes utilisateurs ?

Ces questions vous aideront à choisir les bonnes stratégies de gestion de la concurrence pour votre application.

---

**Prochaine étape :** Dans la section 6.3.1, nous découvrirons en détail les trois principales **problématiques de concurrence** : Dirty Reads, Non-Repeatable Reads, et Phantom Reads. Nous verrons des exemples concrets de chaque anomalie et comprendrons pourquoi elles posent problème.

⏭️ [Problématiques de concurrence (Dirty Reads, Non-Repeatable Reads, Phantom Reads)](/06-gestion-des-transactions-et-concurrence/03.1-problematiques-de-concurrence.md)
