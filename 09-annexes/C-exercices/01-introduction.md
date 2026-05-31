🔝 Retour au [Sommaire](/SOMMAIRE.md)

# C.1 — Exercices du chapitre 1 : Introduction et concepts fondamentaux

Le chapitre 1 étant **conceptuel**, ces exercices vérifient votre **compréhension** (peu de SQL ici — la pratique commence au chapitre 2). Prenez le temps de formuler vos réponses **avec vos propres mots** avant de consulter les corrigés.

---

## Exercice 1.1 ⭐ — Données vs informations

📝 **Énoncé** : Pour chacun des éléments suivants, indiquez s'il s'agit d'une **donnée brute** ou d'une **information**, et justifiez.

a) `42`  
b) « Le client n°7 a 42 ans »  
c) `2026-05-31`  
d) « La commande n°12 a été passée le 10 juin 2025 »  

💡 **Indice** : une donnée seule a-t-elle un sens sans contexte ?

✅ **Corrigé** :
- a) **Donnée** brute (un nombre sans contexte).
- b) **Information** (la donnée 42 est contextualisée : c'est un âge, rattaché à un client).
- c) **Donnée** brute (une date isolée).
- d) **Information** (la date est rattachée à un événement métier).

🧠 **Explication** : une **donnée** devient une **information** lorsqu'elle est mise en **contexte** et devient **exploitable** pour une décision (voir §1.1.1).

---

## Exercice 1.2 ⭐ — Identifier des entités

📝 **Énoncé** : Une médiathèque veut informatiser sa gestion. Citez au moins **quatre entités** que l'on retrouverait dans sa base de données, et pour l'une d'elles, proposez **trois attributs**.

✅ **Corrigé** (exemples) :
- Entités : `Adhérent`, `Document` (livre/DVD), `Emprunt`, `Auteur`, `Catégorie`.
- Attributs de `Adhérent` : `NuméroAdhérent`, `Nom`, `DateInscription`, `Email`.

🧠 **Explication** : une **entité** représente un objet/concept du monde réel dont on stocke plusieurs occurrences, ayant des **attributs** propres (voir §1.1.2).

---

## Exercice 1.3 ⭐⭐ — Types de relations

📝 **Énoncé** : Pour chaque paire d'entités, indiquez le **type de relation** (1:1, 1:N ou N:M) :

a) `Client` ↔ `Commande`  
b) `Commande` ↔ `Produit`  
c) `Personne` ↔ `Passeport`  
d) `Auteur` ↔ `Livre` (un livre peut être co-écrit)  

✅ **Corrigé** :
- a) **1:N** (un client passe plusieurs commandes ; une commande appartient à un client).
- b) **N:M** (une commande contient plusieurs produits ; un produit est dans plusieurs commandes).
- c) **1:1** (une personne a un passeport ; un passeport appartient à une personne).
- d) **N:M** (un auteur écrit plusieurs livres ; un livre peut avoir plusieurs auteurs).

🧠 **Explication** : les relations **N:M** nécessitent une **table de jonction** (ex. `LignesCommande` pour b, `LivreAuteur` pour d). Voir §1.1.2.

---

## Exercice 1.4 ⭐⭐ — SGBD vs SGBDR

📝 **Énoncé** : Vrai ou faux, et justifiez :

a) « Tout SGBD est forcément relationnel. »  
b) « Dans un SGBDR, les données sont organisées en tables liées par des clés. »  
c) « SQL Server est un SGBD mais pas un SGBDR. »  

✅ **Corrigé** :
- a) **Faux** : il existe des SGBD non relationnels (hiérarchiques, documents/NoSQL, graphes…).
- b) **Vrai** : c'est la définition même d'un SGBDR.
- c) **Faux** : SQL Server est un **SGBDR** (système de gestion de base de données **relationnel**).

🧠 **Explication** : le **R** de SGBDR signifie « relationnel » : les données sont en tables reliées, avec intégrité référentielle (voir §1.1.3).

---

## Exercice 1.5 ⭐⭐ — Clé primaire et clé étrangère

📝 **Énoncé** : Dans la base `Boutique`, la table `Commandes` contient une colonne `ClientID`.

a) Quel est le rôle de `ClientID` dans `Commandes` ?  
b) Dans quelle table `ClientID` est-il la clé primaire ?  
c) Que se passe-t-il si on tente d'insérer une commande avec `ClientID = 999` alors qu'aucun client n'a cet identifiant ?  

✅ **Corrigé** :
- a) `ClientID` est une **clé étrangère** dans `Commandes` : elle référence le client concerné.
- b) Dans la table `Clients` (`ClientID` y est la **clé primaire**).
- c) L'insertion **échoue** : la contrainte de clé étrangère (`FK_Commandes_Clients`) interdit de référencer un client inexistant (**intégrité référentielle**).

🧠 **Explication** : la **clé étrangère** matérialise la relation entre tables et garantit la cohérence (pas de commande « orpheline »). Voir §1.1.2 et chapitre 2.

---

## Exercice 1.6 ⭐⭐⭐ — Modélisation

📝 **Énoncé** : Une école veut gérer les **inscriptions** des étudiants aux cours. Un étudiant suit plusieurs cours ; un cours accueille plusieurs étudiants ; on veut aussi mémoriser la **date d'inscription** et la **note finale** de chaque étudiant à chaque cours.

Proposez les **tables** nécessaires avec leurs clés (primaires et étrangères).

💡 **Indice** : une relation N:M avec des attributs propres mène à quoi ?

✅ **Corrigé** :
- `Etudiants(EtudiantID **PK**, Nom, Prenom, …)`
- `Cours(CoursID **PK**, Intitulé, …)`
- `Inscriptions(EtudiantID **FK**, CoursID **FK**, DateInscription, NoteFinale)`, avec **clé primaire composite** `(EtudiantID, CoursID)`.

🧠 **Explication** : la relation N:M Étudiants↔Cours se résout par une **table de jonction** `Inscriptions`. Comme on veut y stocker des attributs (`DateInscription`, `NoteFinale`), cette table est indispensable — on ne peut pas placer ces informations ni dans `Etudiants` ni dans `Cours`. Voir §1.1.2.

---

## Pour aller plus loin

- Reformulez avec vos mots la différence **donnée / information / connaissance** (pyramide DIKW, §1.1.1).
- Dessinez le schéma relationnel complet de la base `Boutique` (6 tables) avec ses relations. Comparez avec le diagramme de l'[annexe B](/09-annexes/B-base-exemple/README.md).

---

⏭️ [C.2 — Exercices du chapitre 2](/09-annexes/C-exercices/02-ddl-dml.md)
