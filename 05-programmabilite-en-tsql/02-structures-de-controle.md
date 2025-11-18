🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 5.2 Structures de contrôle

## Introduction générale

Bienvenue dans cette section dédiée aux **structures de contrôle** en T-SQL ! Jusqu'à présent, nous avons appris à stocker des valeurs dans des variables et à comprendre comment SQL Server organise notre code en batches. Maintenant, nous allons franchir une étape décisive : apprendre à **contrôler le flux d'exécution** de notre code.

Les structures de contrôle sont les **outils de décision et de répétition** qui transforment un simple script en un véritable programme intelligent, capable de :
- **Prendre des décisions** en fonction des données
- **Répéter des actions** automatiquement
- **Organiser la logique** de manière claire et structurée
- **Adapter le comportement** selon les circonstances

Cette section est au cœur de la **programmation procédurale** en T-SQL et constitue un pilier fondamental pour tout développeur de bases de données.

---

## Qu'est-ce qu'une structure de contrôle ?

### Définition

Une **structure de contrôle** est une instruction ou un ensemble d'instructions qui détermine **l'ordre d'exécution** du code. Au lieu d'exécuter simplement toutes les instructions de haut en bas, les structures de contrôle permettent de :

1. **Décider** quelles instructions exécuter (choix)
2. **Répéter** certaines instructions (boucles)
3. **Sauter** certaines instructions (branchements)
4. **Grouper** des instructions ensemble (blocs)

### Analogie : La recette de cuisine

Imaginez une recette de cuisine :

**Sans structure de contrôle (linéaire) :**
```
1. Casser les œufs
2. Ajouter le sucre
3. Mélanger
4. Cuire au four
```

**Avec structures de contrôle (intelligent) :**
```
1. SI vous avez des œufs ALORS
       Casser les œufs
   SINON
       Utiliser un substitut d'œuf

2. TANT QUE le mélange n'est pas homogène
       Continuer à mélanger

3. SELON la recette choisie
       Gâteau → Cuire 30 minutes
       Crêpes → Cuire 2 minutes
       Mousse → Ne pas cuire
```

Les structures de contrôle rendent votre "recette de code" flexible et adaptable !

---

## Pourquoi avons-nous besoin de structures de contrôle ?

### Le problème du code linéaire

Sans structures de contrôle, votre code s'exécute toujours de la même manière, ligne après ligne. Cela pose des problèmes :

**Exemple : Augmentation de salaire**

Sans structures de contrôle, vous devriez écrire :
```sql
-- Augmenter tout le monde de 10% (pas idéal !)
UPDATE Employes SET Salaire = Salaire * 1.10;
```

Mais dans la réalité, vous voulez :
- Augmenter de 15% les employés excellents
- Augmenter de 10% les employés performants
- Augmenter de 5% les autres
- Ne pas augmenter les employés en période d'essai

**C'est là qu'interviennent les structures de contrôle !**

### Les bénéfices

Les structures de contrôle permettent de créer du code :

1. **Intelligent** : Prend des décisions basées sur les données
2. **Flexible** : S'adapte à différentes situations
3. **Efficace** : Évite les répétitions inutiles
4. **Maintenable** : Plus facile à comprendre et modifier
5. **Robuste** : Gère les cas particuliers et erreurs

---

## Les quatre piliers des structures de contrôle en T-SQL

Cette section couvre quatre concepts essentiels :

### 1. Blocs BEGIN ... END : Grouper les instructions

**Pourquoi c'est important :**
BEGIN ... END permet de **grouper plusieurs instructions** pour qu'elles soient traitées comme une seule unité logique.

**Analogie :** C'est comme mettre plusieurs objets dans une boîte pour les transporter ensemble.

**Ce que vous apprendrez :**
- Comment regrouper des instructions
- Quand et pourquoi utiliser BEGIN ... END
- L'importance de l'indentation pour la lisibilité
- Les blocs imbriqués

**Exemple de ce que vous saurez faire :**
```sql
IF @Condition = 1
BEGIN
    -- Plusieurs instructions groupées
    PRINT 'Condition vraie';
    UPDATE Employes SET Statut = 'Actif';
    INSERT INTO Logs VALUES ('Mise à jour effectuée');
END
```

### 2. Conditions IF ... ELSE : Prendre des décisions

**Pourquoi c'est important :**
IF ... ELSE permet à votre code de **choisir** quelle action exécuter en fonction de conditions.

**Analogie :** C'est comme un aiguillage de train qui dirige le train sur différentes voies selon sa destination.

**Ce que vous apprendrez :**
- Tester des conditions simples et complexes
- Utiliser IF, ELSE, et ELSE IF
- Combiner des conditions avec AND, OR, NOT
- Tester l'existence de données avec EXISTS
- Gérer les valeurs NULL

**Exemple de ce que vous saurez faire :**
```sql
IF @Age >= 18 AND @Permis = 1
BEGIN
    PRINT 'Vous pouvez conduire';
END
ELSE IF @Age >= 18
BEGIN
    PRINT 'Vous devez obtenir votre permis';
END
ELSE
BEGIN
    PRINT 'Vous êtes trop jeune';
END
```

### 3. Boucles WHILE : Répéter des actions

**Pourquoi c'est important :**
WHILE permet de **répéter** des instructions tant qu'une condition est vraie, automatisant ainsi les tâches répétitives.

**Analogie :** C'est comme une machine à laver qui répète le cycle de lavage jusqu'à ce que le linge soit propre.

**Ce que vous apprendrez :**
- Créer des boucles qui répètent des actions
- Contrôler les boucles avec BREAK (sortir) et CONTINUE (sauter)
- Éviter les boucles infinies
- Traiter des données par lots (batch processing)
- Imbriquer des boucles

**Exemple de ce que vous saurez faire :**
```sql
DECLARE @Compteur INT = 1;

WHILE @Compteur <= 10
BEGIN
    PRINT 'Traitement de l''élément ' + CAST(@Compteur AS VARCHAR);

    IF @Compteur = 5
        BREAK;  -- Sortir de la boucle

    SET @Compteur = @Compteur + 1;
END
```

### 4. Instruction CASE : Transformer et classifier

**Pourquoi c'est important :**
CASE permet de **transformer des valeurs** directement dans vos requêtes, en choisissant parmi plusieurs possibilités.

**Analogie :** C'est comme un distributeur automatique qui donne différents produits selon le bouton que vous appuyez.

**Ce que vous apprendrez :**
- CASE Simple pour comparer une valeur à plusieurs options
- CASE Searched pour évaluer des conditions complexes
- Utiliser CASE dans SELECT, WHERE, ORDER BY, UPDATE
- Créer des colonnes calculées intelligentes
- Classifier et catégoriser des données

**Exemple de ce que vous saurez faire :**
```sql
SELECT
    Prenom,
    Nom,
    Salaire,
    CASE
        WHEN Salaire < 2000 THEN 'Niveau 1'
        WHEN Salaire < 4000 THEN 'Niveau 2'
        WHEN Salaire < 6000 THEN 'Niveau 3'
        ELSE 'Niveau 4'
    END AS NiveauSalaire
FROM Employes;
```

---

## Vue d'ensemble : Comment ces structures s'articulent

Les quatre structures de contrôle se complètent et travaillent ensemble :

```
BEGIN ... END
    │
    ├─► Utilisé avec IF ... ELSE pour grouper plusieurs instructions
    │
    ├─► Utilisé avec WHILE pour définir le corps de la boucle
    │
    └─► Obligatoire dans les procédures stockées

IF ... ELSE
    │
    ├─► Peut contenir des blocs BEGIN ... END
    │
    ├─► Peut contenir des boucles WHILE
    │
    └─► Peut contenir des expressions CASE

WHILE
    │
    ├─► Nécessite BEGIN ... END pour plusieurs instructions
    │
    ├─► Peut contenir des IF ... ELSE
    │
    └─► Peut contenir d'autres WHILE (imbrication)

CASE
    │
    ├─► Peut être utilisé dans les conditions IF
    │
    ├─► Peut être utilisé dans les SELECT, WHERE, etc.
    │
    └─► Alternative élégante à certains IF ... ELSE
```

---

## Progression pédagogique

Cette section suit une progression logique et naturelle :

### Étape 1 : Les fondations (BEGIN ... END)
Vous commencerez par apprendre à **grouper des instructions**. C'est la base sur laquelle tout le reste repose.

### Étape 2 : Les décisions (IF ... ELSE)
Ensuite, vous apprendrez à faire des **choix** dans votre code, à créer des branches logiques.

### Étape 3 : Les répétitions (WHILE)
Vous découvrirez comment **automatiser** les tâches répétitives avec des boucles.

### Étape 4 : Les transformations (CASE)
Enfin, vous maîtriserez **l'art de transformer** et classifier des données élégamment.

Chaque concept s'appuie sur les précédents, créant une compréhension solide et progressive.

---

## Exemples concrets d'utilisation

Voici quelques scénarios réels où vous utiliserez ces structures de contrôle :

### Scénario 1 : Validation de données

```sql
-- Avant d'insérer un nouveau client
IF EXISTS (SELECT 1 FROM Clients WHERE Email = @Email)
BEGIN
    PRINT 'Erreur : Email déjà utilisé';
END
ELSE IF @Email NOT LIKE '%@%'
BEGIN
    PRINT 'Erreur : Format email invalide';
END
ELSE
BEGIN
    INSERT INTO Clients (Nom, Email) VALUES (@Nom, @Email);
    PRINT 'Client créé avec succès';
END
```

### Scénario 2 : Traitement par lots

```sql
DECLARE @Compteur INT = 0;
DECLARE @BatchSize INT = 100;

WHILE @Compteur < 1000
BEGIN
    -- Archiver 100 commandes à la fois
    UPDATE TOP (@BatchSize) Commandes
    SET Statut = 'Archivé'
    WHERE Statut = 'Terminé' AND DateFin < DATEADD(YEAR, -1, GETDATE());

    SET @Compteur = @Compteur + @@ROWCOUNT;

    IF @@ROWCOUNT = 0
        BREAK;  -- Plus rien à traiter
END
```

### Scénario 3 : Rapports avec classification

```sql
SELECT
    ClientID,
    Nom,
    TotalAchats,
    CASE
        WHEN TotalAchats > 10000 THEN 'VIP'
        WHEN TotalAchats > 5000 THEN 'Gold'
        WHEN TotalAchats > 1000 THEN 'Silver'
        ELSE 'Bronze'
    END AS Statut,
    CASE
        WHEN TotalAchats > 10000 THEN 0.20
        WHEN TotalAchats > 5000 THEN 0.15
        WHEN TotalAchats > 1000 THEN 0.10
        ELSE 0.05
    END AS RemiseApplicable
FROM Clients;
```

---

## Prérequis

Avant de commencer cette section, vous devriez être à l'aise avec :

- ✅ Les variables locales et globales (section 5.1)
- ✅ La déclaration et l'assignation de variables
- ✅ Le concept de batch et le séparateur GO
- ✅ Les requêtes SELECT de base
- ✅ Les opérateurs de comparaison (=, >, <, etc.)
- ✅ Les types de données SQL

Si ces concepts ne sont pas encore clairs, nous vous recommandons de revoir la section 5.1 avant de continuer.

---

## Compétences que vous allez acquérir

À la fin de cette section, vous serez capable de :

### Compétences fondamentales
- ✓ Grouper des instructions logiquement avec BEGIN ... END
- ✓ Créer des branches conditionnelles avec IF ... ELSE
- ✓ Automatiser des tâches répétitives avec WHILE
- ✓ Transformer des données avec CASE

### Compétences avancées
- ✓ Imbriquer des structures de contrôle
- ✓ Optimiser le flux d'exécution avec BREAK et CONTINUE
- ✓ Créer des requêtes dynamiques et intelligentes
- ✓ Gérer des cas complexes avec plusieurs conditions

### Compétences pratiques
- ✓ Valider des données avant traitement
- ✓ Traiter des données par lots efficacement
- ✓ Créer des rapports avec classification automatique
- ✓ Implémenter une logique métier complexe

---

## À quoi s'attendre

### Niveau de difficulté

Cette section représente une **montée en complexité** par rapport à ce que vous avez vu jusqu'à présent. Les structures de contrôle introduisent la **logique procédurale**, qui demande une nouvelle façon de penser.

**Ne vous inquiétez pas !** Nous progresserons pas à pas, avec de nombreux exemples et explications détaillées.

### Approche pédagogique

Pour chaque structure de contrôle, nous suivrons ce schéma :

1. **Concept et analogie** : Comprendre l'idée générale
2. **Syntaxe de base** : Apprendre la structure formelle
3. **Exemples simples** : Pratiquer avec des cas basiques
4. **Exemples pratiques** : Appliquer à des scénarios réels
5. **Pièges et erreurs courantes** : Apprendre des erreurs typiques
6. **Bonnes pratiques** : Adopter les conventions professionnelles

### Temps estimé

Prévoyez environ **3 à 4 heures** pour parcourir l'ensemble de cette section :
- BEGIN ... END : 30 minutes
- IF ... ELSE : 1 heure
- WHILE : 1 heure 30 minutes
- CASE : 1 heure

Prenez votre temps et n'hésitez pas à expérimenter !

---

## Conseils pour réussir

### 1. Dessinez des schémas

Les structures de contrôle créent des **flux logiques**. N'hésitez pas à dessiner :
- Des organigrammes pour les IF ... ELSE
- Des diagrammes de flux pour les WHILE
- Des arbres de décision pour les CASE imbriqués

### 2. Testez avec des données simples

Avant de traiter des milliers de lignes :
- Créez de petites tables de test
- Utilisez des variables avec des valeurs simples
- Vérifiez le comportement étape par étape

### 3. Utilisez PRINT pour déboguer

```sql
IF @Condition = 1
BEGIN
    PRINT 'Debug : Condition vraie';  -- Messages de débogage
    -- Votre code
END
```

### 4. Indentez votre code

Une bonne indentation rend les structures de contrôle **beaucoup plus faciles** à comprendre :

**❌ Difficile à lire :**
```sql
IF @X > 0
BEGIN
IF @Y > 0
BEGIN
PRINT 'Les deux sont positifs';
END
END
```

**✅ Facile à lire :**
```sql
IF @X > 0
BEGIN
    IF @Y > 0
    BEGIN
        PRINT 'Les deux sont positifs';
    END
END
```

### 5. Commencez simple, puis complexifiez

Ne cherchez pas à écrire la solution parfaite du premier coup :
1. Écrivez une version simple qui fonctionne
2. Testez-la
3. Ajoutez progressivement de la complexité
4. Testez à chaque étape

---

## Erreurs courantes de débutants

Voici les erreurs que nous allons vous aider à éviter :

### 1. Oublier BEGIN ... END

```sql
-- ❌ Erreur : seule la première instruction est liée au IF
IF @Condition = 1
    PRINT 'Message 1';
    PRINT 'Message 2';  -- S'exécute toujours !

-- ✅ Correct
IF @Condition = 1
BEGIN
    PRINT 'Message 1';
    PRINT 'Message 2';
END
```

### 2. Créer des boucles infinies

```sql
-- ❌ Boucle infinie : @Compteur ne change jamais
DECLARE @Compteur INT = 1;
WHILE @Compteur <= 10
BEGIN
    PRINT @Compteur;
    -- Oubli d'incrémenter !
END

-- ✅ Correct
DECLARE @Compteur INT = 1;
WHILE @Compteur <= 10
BEGIN
    PRINT @Compteur;
    SET @Compteur = @Compteur + 1;
END
```

### 3. Oublier END dans CASE

```sql
-- ❌ Erreur : END manquant
SELECT CASE @Status
    WHEN 'A' THEN 'Actif'
    WHEN 'I' THEN 'Inactif'
-- Oubli de END

-- ✅ Correct
SELECT CASE @Status
    WHEN 'A' THEN 'Actif'
    WHEN 'I' THEN 'Inactif'
END AS Statut
```

---

## Transition avec les sections suivantes

Les structures de contrôle que vous allez apprendre ici sont la **base de tout** ce qui suit dans ce cours :

### Section 5.3 - Gestion des erreurs (TRY ... CATCH)
Utilisera IF ... ELSE et BEGIN ... END pour gérer les erreurs de manière robuste.

### Section 5.5 - Procédures stockées
Combinera toutes les structures de contrôle pour créer des programmes SQL réutilisables.

### Section 5.6 - Fonctions utilisateur
Utilisera CASE et IF pour transformer et calculer des valeurs.

### Section 5.7 - Triggers
Appliquera les structures de contrôle pour réagir automatiquement aux modifications de données.

**Maîtriser les structures de contrôle, c'est poser les fondations solides de votre expertise en T-SQL.**

---

## Un dernier mot avant de commencer

Les structures de contrôle représentent le **passage de l'utilisateur au programmeur**. Vous ne vous contentez plus d'exécuter des requêtes ; vous créez maintenant des **programmes intelligents** qui prennent des décisions et s'adaptent aux données.

C'est une étape excitante ! Au début, certains concepts peuvent sembler abstraits, mais avec la pratique, ils deviendront une seconde nature. Chaque développeur SQL professionnel utilise ces structures quotidiennement.

Rappelez-vous :
- **La pratique est essentielle** : tapez les exemples vous-même
- **Les erreurs sont normales** : elles font partie de l'apprentissage
- **Progressez à votre rythme** : il n'y a pas de course
- **Expérimentez** : modifiez les exemples, testez vos idées

---

## Prêt à commencer ?

Vous avez maintenant une vision claire de ce qui vous attend. Les structures de contrôle vont transformer votre façon d'écrire du code T-SQL et vous ouvrir un monde de possibilités.

Commençons par la base de tout : les blocs **BEGIN ... END** ! 🚀

---


⏭️ [Blocs BEGIN ... END](/05-programmabilite-en-tsql/02.1-blocs-begin-end.md)
