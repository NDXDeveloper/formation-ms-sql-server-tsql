🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 5.1 Variables et Lots (Batches)

## Introduction générale

Bienvenue dans cette section consacrée aux **variables** et aux **lots (batches)** en T-SQL ! Jusqu'à présent, nous avons principalement travaillé avec des requêtes SQL simples et directes. Maintenant, nous allons découvrir comment rendre notre code plus **dynamique**, plus **flexible** et mieux **structuré**.

Les concepts que nous allons explorer dans cette section constituent les **fondations de la programmation** en T-SQL. Ils vous permettront de :
- Stocker et manipuler des données temporaires
- Créer des scripts plus complexes et réutilisables
- Comprendre comment SQL Server organise et exécute votre code
- Préparer le terrain pour des concepts plus avancés (procédures stockées, fonctions, etc.)

---

## Pourquoi avons-nous besoin de variables ?

### Les limites des requêtes simples

Imaginons que vous souhaitiez augmenter le salaire de tous les employés d'un département spécifique de 5%. Sans variables, vous devriez écrire :

```sql
UPDATE Employes
SET Salaire = Salaire * 1.05
WHERE Departement = 'IT';
```

C'est simple, mais que se passe-t-il si :
- Vous voulez changer le pourcentage d'augmentation ?
- Vous voulez appliquer la même logique à plusieurs départements ?
- Vous voulez stocker le nombre d'employés affectés pour l'utiliser plus tard ?

### La solution : les variables

Les **variables** permettent de stocker des valeurs temporairement et de les réutiliser dans votre code. Elles rendent votre code plus :

1. **Flexible** : Changez une valeur à un seul endroit
2. **Lisible** : Donnez des noms significatifs aux valeurs
3. **Maintenable** : Facilitez les modifications futures
4. **Dynamique** : Adaptez le comportement en fonction de conditions

**Exemple avec variable :**

```sql
DECLARE @Augmentation DECIMAL(5,2) = 5.00;
DECLARE @Departement VARCHAR(50) = 'IT';

UPDATE Employes
SET Salaire = Salaire * (1 + @Augmentation / 100)
WHERE Departement = @Departement;
```

---

## Qu'est-ce qu'un Lot (Batch) ?

### Le concept

Lorsque vous écrivez plusieurs lignes de code T-SQL, vous ne travaillez pas toujours avec une seule instruction continue. Votre code est en réalité organisé en **lots** (ou **batches** en anglais).

Un **batch** est un groupe d'instructions T-SQL qui sont :
- **Envoyées ensemble** à SQL Server
- **Compilées** (préparées) en une seule fois
- **Exécutées** comme une unité

### Pourquoi c'est important ?

Comprendre les batches est essentiel car :

1. **Certaines instructions doivent être isolées**
   - Par exemple, `CREATE PROCEDURE` doit être la première instruction d'un batch

2. **Les variables ont une portée limitée**
   - Une variable déclarée dans un batch n'existe plus dans le suivant

3. **L'organisation du code**
   - Les batches permettent de structurer logiquement vos scripts

4. **La gestion des erreurs**
   - Une erreur dans un batch n'affecte pas nécessairement les autres

### Le séparateur GO

Le séparateur **GO** est utilisé pour marquer la **fin d'un batch** et le **début d'un nouveau**. C'est un concept fondamental que nous explorerons en détail.

```sql
-- Batch 1
DECLARE @Message VARCHAR(50);
SET @Message = 'Premier batch';
SELECT @Message;
GO

-- Batch 2 (nouvelle portée)
DECLARE @Message VARCHAR(50);
SET @Message = 'Deuxième batch';
SELECT @Message;
GO
```

---

## Ce que vous allez apprendre

Cette section est divisée en trois parties principales :

### 5.1.1 Déclaration et assignation de variables

Vous apprendrez à :
- Déclarer des variables avec `DECLARE`
- Assigner des valeurs avec `SET` et `SELECT`
- Comprendre les différences entre les deux méthodes
- Initialiser des variables lors de leur déclaration
- Utiliser des variables dans vos requêtes

**Exemple de ce que vous saurez faire :**
```sql
DECLARE @PrixHT DECIMAL(10,2) = 100.00;
DECLARE @TauxTVA DECIMAL(5,2) = 20.00;
DECLARE @PrixTTC DECIMAL(10,2);

SET @PrixTTC = @PrixHT * (1 + @TauxTVA / 100);

SELECT @PrixTTC AS PrixTTC;
```

### 5.1.2 Variables locales vs globales

Vous découvrirez :
- La différence entre variables locales (`@`) et globales (`@@`)
- Les variables système les plus utiles (comme `@@ROWCOUNT`)
- Comment utiliser ces variables pour obtenir des informations sur vos opérations
- Les bonnes pratiques d'utilisation

**Exemple de ce que vous saurez faire :**
```sql
UPDATE Employes
SET Salaire = Salaire * 1.10
WHERE Departement = 'Ventes';

-- Capturer le nombre de lignes affectées
DECLARE @NombreModifie INT = @@ROWCOUNT;
PRINT 'Nombre d''employés mis à jour : ' + CAST(@NombreModifie AS VARCHAR);
```

### 5.1.3 Le concept de Batch et le séparateur GO

Vous comprendrez :
- Ce qu'est un batch et comment SQL Server l'exécute
- Le rôle du séparateur `GO`
- La portée des variables et les batches
- Quand et pourquoi utiliser `GO`
- Les règles et limitations des batches

**Exemple de ce que vous saurez faire :**
```sql
-- Créer une procédure stockée (nécessite GO)
CREATE PROCEDURE AfficherEmployes
AS
BEGIN
    SELECT * FROM Employes;
END
GO

-- Exécuter la procédure (nouveau batch)
EXEC AfficherEmployes;
GO
```

---

## Analogie pour mieux comprendre

### Les variables : des boîtes étiquetées

Imaginez les variables comme des **boîtes** que vous pouvez étiqueter et dans lesquelles vous pouvez mettre des objets (des valeurs) :

- **Déclaration** = Créer la boîte et y mettre une étiquette
- **Type de données** = La taille et le type de boîte (petite boîte pour les nombres, grande boîte pour les textes)
- **Assignation** = Mettre quelque chose dans la boîte
- **Utilisation** = Regarder ce qu'il y a dans la boîte

### Les batches : des chapitres d'un livre

Pensez aux batches comme aux **chapitres d'un livre** :

- Chaque chapitre (batch) a son propre contexte
- Vous devez finir un chapitre avant de passer au suivant
- Les personnages (variables) d'un chapitre n'existent pas forcément dans le suivant
- Mais l'histoire globale (la base de données) continue

---

## Prérequis

Avant de commencer cette section, vous devriez être à l'aise avec :

- ✅ Les requêtes SELECT de base
- ✅ Les instructions INSERT, UPDATE et DELETE
- ✅ Les types de données SQL (INT, VARCHAR, DATE, etc.)
- ✅ Les clauses WHERE et les opérateurs de comparaison

Si ces concepts ne sont pas encore clairs, nous vous recommandons de revoir les sections précédentes.

---

## À quoi s'attendre

### Niveau de difficulté

Cette section marque le début de la **programmation** en T-SQL. Les concepts sont nouveaux mais restent accessibles aux débutants. Nous progresserons étape par étape avec de nombreux exemples.

### Approche pédagogique

Pour chaque concept, nous suivrons cette structure :
1. **Définition simple** avec des analogies du quotidien
2. **Syntaxe de base** avec des exemples commentés
3. **Exemples progressifs** du plus simple au plus complexe
4. **Bonnes pratiques** et erreurs courantes à éviter
5. **Résumé** des points clés

### Temps estimé

Prévoyez environ **1 à 2 heures** pour parcourir l'ensemble de cette section. N'hésitez pas à prendre votre temps et à expérimenter avec les exemples dans votre propre environnement SQL Server.

---

## Conseils pour bien apprendre

### 1. Pratiquez au fur et à mesure

Ne vous contentez pas de lire les exemples. **Tapez-les** vous-même dans SQL Server Management Studio (SSMS) ou Azure Data Studio et **exécutez-les**. C'est en pratiquant que vous mémoriserez le mieux.

### 2. Expérimentez

Une fois que vous avez compris un exemple :
- Modifiez les valeurs
- Ajoutez vos propres variables
- Essayez de créer vos propres scénarios

### 3. Faites des erreurs

Les erreurs sont **normales** et **utiles**. Quand vous en rencontrez une :
- Lisez attentivement le message d'erreur
- Essayez de comprendre ce qui ne va pas
- Corrigez et réessayez

### 4. Prenez des notes

Notez les concepts qui vous semblent particulièrement importants ou ceux qui vous posent problème. Vous pourrez y revenir plus tard.

### 5. Construisez progressivement

Ne brûlez pas les étapes. Chaque sous-section s'appuie sur la précédente. Assurez-vous de bien comprendre 5.1.1 avant de passer à 5.1.2, et ainsi de suite.

---

## Où cela nous mène-t-il ?

Les compétences que vous allez acquérir dans cette section sont **fondamentales** pour tout ce qui suit :

- **Section 5.2** - Structures de contrôle (IF, WHILE, CASE) : utilisent massivement les variables
- **Section 5.3** - Gestion des erreurs : nécessite de comprendre les batches
- **Section 5.5** - Procédures stockées : combinent variables et batches
- **Section 5.6** - Fonctions utilisateur : s'appuient sur les variables
- Et bien plus encore...

Maîtriser les variables et les batches, c'est poser les **fondations solides** de votre apprentissage de T-SQL.

---

## Un dernier mot avant de commencer

La programmation en T-SQL peut sembler intimidante au début, mais rappelez-vous que **tous les développeurs SQL sont passés par là**. Chaque expert a commencé par apprendre ce qu'est une variable et comment fonctionne un batch.

Prenez votre temps, soyez patient avec vous-même, et surtout : **amusez-vous** ! La programmation T-SQL ouvre un monde de possibilités pour manipuler et analyser des données de manière puissante et efficace.

---

## Prêt à commencer ?

Maintenant que vous avez une vue d'ensemble de ce qui vous attend, plongeons dans le vif du sujet avec notre première sous-section : **la déclaration et l'assignation de variables**.

Passons à la section **5.1.1 - Déclaration (DECLARE) et assignation (SET, SELECT)** ! 🚀

---


⏭️ [Déclaration (DECLARE) et assignation (SET, SELECT)](/05-programmabilite-en-tsql/01.1-declaration-et-assignation.md)
