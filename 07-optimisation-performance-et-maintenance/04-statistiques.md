🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 7.4 Statistiques

## Introduction générale

Si les plans d'exécution sont la **carte routière** que SQL Server suit pour exécuter vos requêtes, alors les **statistiques** sont les **informations sur le terrain** qui permettent de tracer cette carte. Sans statistiques précises, même le meilleur optimiseur de requêtes du monde serait aveugle et ferait des choix au hasard.

Les statistiques sont l'un des concepts les plus importants — et souvent les plus méconnus — de l'optimisation des performances dans SQL Server. Elles travaillent silencieusement en arrière-plan, mais leur impact sur les performances peut être **spectaculaire** : la différence entre une requête qui prend 1 seconde et une qui prend 10 minutes peut souvent se résumer à des statistiques obsolètes.

## Qu'est-ce que les statistiques ? (Vue d'ensemble)

### Définition simple

Les **statistiques** sont des métadonnées que SQL Server collecte et maintient sur vos données. Elles contiennent des informations sur :
- **Combien** de lignes contient une table
- **Quelles valeurs** existent dans vos colonnes
- **Comment** ces valeurs sont distribuées
- **Quelle est la fréquence** de chaque valeur

En d'autres termes, les statistiques sont un **résumé intelligent** de vos données.

### L'analogie du GPS

Revenons à l'analogie du GPS que nous avons utilisée pour les plans d'exécution :

**Sans statistiques :**
- C'est comme un GPS qui ne connaît pas l'état du trafic
- Il peut vous proposer un itinéraire, mais ce sera basé sur des suppositions
- "Je pense que cette route est rapide... peut-être ?"
- Résultat : Vous risquez de vous retrouver dans un embouteillage monstre

**Avec de bonnes statistiques :**
- Le GPS connaît le trafic en temps réel
- Il sait quelle route est congestionnée et laquelle est fluide
- Il peut calculer l'itinéraire optimal basé sur des données réelles
- Résultat : Vous arrivez rapidement à destination

**Avec des statistiques obsolètes :**
- Le GPS utilise des données de trafic d'il y a 6 mois
- Il pense que l'autoroute est fluide, mais en réalité il y a des travaux depuis 3 mois
- Il vous envoie dans un piège
- Résultat : Vous perdez un temps fou

C'est exactement ce qui se passe avec SQL Server et les statistiques !

## Pourquoi les statistiques sont-elles si importantes ?

### Le défi de l'optimiseur

Dans la section sur les plans d'exécution, nous avons vu que l'optimiseur de requêtes doit choisir parmi de nombreuses façons d'exécuter une requête. Mais comment fait-il ce choix ?

Il doit **estimer** :
1. Combien de lignes seront traitées à chaque étape
2. Combien de temps chaque opération prendra
3. Combien de mémoire sera nécessaire
4. Quel est le coût relatif de chaque stratégie

**Question cruciale :** Comment peut-il estimer tout cela sans connaître les données ?

**Réponse :** Il ne peut pas ! C'est là que les statistiques interviennent.

### L'impact concret sur les performances

Les statistiques influencent **directement** les décisions les plus critiques de l'optimiseur :

#### Décision 1 : Index Seek vs Table Scan

```sql
SELECT * FROM Clients WHERE Ville = 'Paris';
```

**Question de l'optimiseur :** "Combien de clients habitent à Paris ?"

**Si les statistiques disent : 1%**
- Décision : Index Seek (chercher directement les 1%)
- Résultat : ⚡ Très rapide

**Si les statistiques disent : 90%**
- Décision : Table Scan (lire toute la table sera plus rapide)
- Résultat : ⚡ Rapide aussi

**Si les statistiques sont obsolètes et disent 1% alors que c'est 90%**
- Décision : Index Seek (basé sur info erronée)
- Réalité : Doit traiter 90% des données avec la mauvaise stratégie
- Résultat : 🔥 Catastrophique !

#### Décision 2 : Type de jointure

```sql
SELECT *
FROM Commandes c
JOIN Clients cl ON c.ClientID = cl.ClientID;
```

**Question de l'optimiseur :** "Combien de lignes dans chaque table ? Quelle est la cardinalité de la jointure ?"

**Avec de bonnes statistiques :**
- Sait que Commandes a 10M lignes, Clients 100K lignes
- Choisit : Hash Match (adapté pour grande × grande)
- Résultat : ⚡ 3 secondes

**Avec des statistiques obsolètes :**
- Pense que Commandes a 100K lignes (info d'il y a 2 ans)
- Choisit : Nested Loops (adapté pour petite × grande)
- Réalité : Doit faire 10M itérations au lieu de 100K
- Résultat : 🔥 10 minutes ou timeout !

#### Décision 3 : Allocation mémoire

**Avec de bonnes statistiques :**
- Estime correctement 50 000 lignes à trier
- Alloue 50 MB de mémoire
- Tri en mémoire : ⚡ Rapide

**Avec des statistiques obsolètes :**
- Estime 5 000 lignes (faux)
- Alloue seulement 5 MB de mémoire
- Réalité : 50 000 lignes ne rentrent pas
- Débordement sur disque (TempDB)
- Résultat : 🔥 50× plus lent !

### Les chiffres parlent

Des études ont montré que :
- **70-80%** des problèmes de performance en SQL Server sont liés directement ou indirectement aux statistiques
- Une requête avec des statistiques obsolètes peut être **10 à 100 fois plus lente**
- Mettre à jour les statistiques peut résoudre instantanément des problèmes qui semblaient insolubles

**Message clé :** Ignorer les statistiques, c'est comme essayer d'optimiser une voiture de course en ignorant le moteur. Tout le reste est secondaire.

## Le lien avec les plans d'exécution

### Deux faces d'une même pièce

Si vous avez suivi la section 7.3 sur les plans d'exécution, vous avez déjà rencontré les statistiques sans le savoir !

**Les plans d'exécution :**
- Vous montrent **ce que** SQL Server a décidé de faire
- Vous permettent de voir si les choix sont bons
- Révèlent les problèmes de performance

**Les statistiques :**
- Sont les **données** sur lesquelles SQL Server base ses décisions
- Expliquent **pourquoi** tel plan a été choisi
- Sont souvent la **cause racine** des mauvais plans

### Le cercle vertueux (ou vicieux)

```
Bonnes statistiques → Bonnes estimations → Bon plan → Bonne performance ✅

Statistiques obsolètes → Mauvaises estimations → Mauvais plan → Performance catastrophique ❌
```

### Vous avez déjà vu les symptômes

Dans la section sur les plans d'exécution, nous avons parlé d'écarts entre **Estimated Rows** et **Actual Rows**. Rappelez-vous :

```
Opérateur : Index Seek
Estimated Rows : 100
Actual Rows : 500 000

Ratio : 5 000× !  🚨
```

**Maintenant vous savez pourquoi :** Les statistiques étaient obsolètes ! Elles disaient "100 lignes" alors qu'en réalité il y en avait 500 000.

## Les mythes à déconstruire

Avant d'aller plus loin, démystifions quelques idées reçues sur les statistiques.

### Mythe 1 : "SQL Server gère tout automatiquement"

**Réalité :** SQL Server fait beaucoup automatiquement, c'est vrai. Mais :
- Les seuils automatiques ne sont pas toujours adaptés (surtout pour grandes tables)
- Les changements de distribution peuvent ne pas déclencher de mise à jour
- Certaines situations nécessitent une intervention manuelle

**Vérité :** 90% automatique, 10% vigilance humaine nécessaire.

### Mythe 2 : "Les statistiques, c'est un truc de DBA, pas de développeurs"

**Réalité :** En tant que développeur, vous êtes le **mieux placé** pour comprendre :
- Quelles colonnes sont importantes pour vos requêtes
- Quelles colonnes sont corrélées entre elles
- Quand les données changent significativement
- Quel impact ont vos modifications de code

**Vérité :** Les statistiques sont autant votre responsabilité que celle du DBA.

### Mythe 3 : "Si j'ai des index, je n'ai pas besoin de m'inquiéter des statistiques"

**Réalité :** Les index **utilisent** les statistiques pour être efficaces. Un index sans bonnes statistiques peut :
- Ne pas être utilisé du tout
- Être utilisé de manière sous-optimale
- Donner de pires performances qu'un Table Scan !

**Vérité :** Index et statistiques sont **indissociables**.

### Mythe 4 : "Mettre à jour les statistiques résout tous les problèmes"

**Réalité :** Les statistiques obsolètes causent beaucoup de problèmes, mais pas tous. Parfois le problème est :
- Un index manquant
- Une requête mal écrite
- Un problème de verrouillage
- Une limitation hardware

**Vérité :** Les statistiques sont **une pièce** du puzzle de la performance, pas la solution universelle.

### Mythe 5 : "Les statistiques sont compliquées et techniques"

**Réalité :** Les concepts de base sont simples :
- SQL Server compte combien de lignes vous avez
- Il regarde quelles valeurs existent
- Il note lesquelles sont fréquentes et lesquelles sont rares

**Vérité :** Comprendre les statistiques est accessible à tous, même aux débutants !

## Ce que vous allez apprendre dans cette section

Cette section est organisée en trois parties progressives qui vous guideront de la compréhension théorique à la maîtrise pratique.

### Partie 1 : Le rôle des statistiques (7.4.1)

Vous comprendrez **en profondeur** comment les statistiques fonctionnent :
- Qu'est-ce qu'elles contiennent exactement (histogrammes, densité, etc.)
- Comment l'optimiseur les utilise pour prendre ses décisions
- Pourquoi elles sont indispensables pour des performances optimales
- Des exemples concrets d'impact sur les plans d'exécution

**Objectif :** Comprendre le "pourquoi" — pourquoi les statistiques sont si importantes.

### Partie 2 : Création et mise à jour (7.4.2)

Vous apprendrez **comment gérer** les statistiques au quotidien :
- Comment SQL Server crée et met à jour automatiquement les statistiques
- Les options de configuration (AUTO_CREATE_STATISTICS, AUTO_UPDATE_STATISTICS, etc.)
- Comment créer des statistiques manuellement (CREATE STATISTICS)
- Comment mettre à jour les statistiques (UPDATE STATISTICS)
- Différentes stratégies de maintenance selon vos besoins
- Quand laisser faire SQL Server et quand intervenir

**Objectif :** Maîtriser le "comment" — comment maintenir des statistiques à jour.

### Partie 3 : Problèmes et solutions (7.4.3)

Vous découvrirez **les problèmes courants** et comment les résoudre :
- Les symptômes de statistiques obsolètes
- Le mystérieux **Parameter Sniffing** (un des bugs les plus frustrants !)
- Comment diagnostiquer les problèmes liés aux statistiques
- Solutions pratiques pour chaque type de problème
- Comment prévenir ces problèmes

**Objectif :** Devenir un "médecin" capable de diagnostiquer et guérir les maladies liées aux statistiques.

## Une compétence progressive

### Le parcours d'apprentissage

Ne vous inquiétez pas si tout ne semble pas clair immédiatement. L'apprentissage des statistiques suit généralement cette progression :

#### Phase 1 : La découverte (Semaines 1-2)
- "Ah, donc ça explique pourquoi mes requêtes sont parfois lentes !"
- Vous commencez à regarder les dates de mise à jour
- Vous essayez UPDATE STATISTICS pour la première fois
- Vous observez les Estimated vs Actual Rows dans vos plans

#### Phase 2 : La reconnaissance (Semaines 3-4)
- Vous identifiez rapidement un problème de statistiques
- Vous savez quand mettre à jour manuellement
- Vous comprenez les écarts dans les plans d'exécution
- Vous commencez à anticiper les problèmes

#### Phase 3 : La maîtrise (Mois 2-3)
- Vous créez des statistiques multi-colonnes quand nécessaire
- Vous détectez le Parameter Sniffing
- Vous mettez en place des stratégies de maintenance
- Vous formez d'autres développeurs

#### Phase 4 : L'expertise (Au-delà)
- Les statistiques deviennent une seconde nature
- Vous optimisez proactivement avant les problèmes
- Vous comprenez les nuances et les cas complexes
- Vous pouvez troubleshooter les situations les plus obscures

**Message important :** Ce parcours est normal et naturel. Personne ne devient expert en statistiques du jour au lendemain !

## Pourquoi investir du temps dans les statistiques ?

### Pour vous-même

Maîtriser les statistiques vous rendra :

**Plus efficace :**
- Résolution rapide des problèmes de performance
- Moins de temps perdu à chercher la cause
- Capacité à prévenir plutôt que guérir

**Plus confiant :**
- Compréhension profonde du comportement de SQL Server
- Pas de mystères ou de "magie noire"
- Contrôle réel sur les performances

**Plus valorisé :**
- Compétence rare sur le marché
- Capacité à résoudre des problèmes que d'autres ne comprennent pas
- Reconnaissance comme expert en performance

### Pour votre équipe

Vous pourrez :
- Débloquer des situations où personne ne sait quoi faire
- Former vos collègues sur ces concepts
- Établir des bonnes pratiques de maintenance
- Réduire les escalades vers les DBA

### Pour votre entreprise

Vos applications seront :

**Plus rapides :**
- Requêtes qui passent de minutes à secondes
- Meilleure expérience utilisateur
- Moins de plaintes de lenteur

**Plus fiables :**
- Moins de timeouts aléatoires
- Performance prévisible
- Moins d'incidents de production

**Plus économiques :**
- Moins de ressources serveur nécessaires
- Pas besoin de scale-up prématuré
- Réduction des coûts d'infrastructure

### Retour sur investissement

Investir quelques heures pour comprendre les statistiques peut :
- Vous faire gagner des **jours ou semaines** de debugging
- Transformer des requêtes de **5 minutes en 5 secondes**
- Éviter des **achats de serveurs** coûteux
- Sauver votre **week-end** quand la prod plante

**Le ROI est spectaculaire !**

## Le contexte dans votre formation

### Où nous en sommes

Cette section 7.4 fait partie du chapitre 7 sur **l'optimisation et la performance**. Vous avez déjà vu :

✅ **7.1-7.2 : Les index**
- Comment SQL Server organise physiquement les données
- Les différents types d'index et leur utilisation
- Les stratégies d'indexation

✅ **7.3 : Les plans d'exécution**
- Comment lire et interpréter un plan
- Les opérateurs clés (Seek, Scan, Joins)
- Comment identifier les goulots d'étranglement

📍 **7.4 : Les statistiques** ← Vous êtes ici
- Le lien entre les données et les plans
- Comment SQL Server décide quel plan utiliser
- La maintenance des statistiques

**À venir après cette section :**
- **7.5 : Query Store** — Suivre l'évolution dans le temps
- **7.6 : SARGability** — Écrire des requêtes optimisables
- **7.7 : Maintenance** — Garder tout en bon état

### Comment tout s'articule

Pensez à ces concepts comme aux pièces d'un puzzle :

```
┌─────────────────────────────────────┐
│         DONNÉES (Tables)            │
│               ↓                     │
│   INDEX (Organisation physique)     │ ← 7.1-7.2
│               ↓                     │
│   STATISTIQUES (Métadonnées)        │ ← 7.4 (vous êtes ici)
│               ↓                     │
│   OPTIMISEUR (Décisions)            │
│               ↓                     │
│   PLANS D'EXÉCUTION (Actions)       │ ← 7.3
│               ↓                     │
│        RÉSULTATS                    │
└─────────────────────────────────────┘
```

**Les statistiques sont le pont** entre vos index et les plans d'exécution. Sans elles, SQL Server ne peut pas utiliser efficacement vos index.

## Les outils à votre disposition

### Dans SQL Server Management Studio (SSMS)

Vous utiliserez principalement :

**Commandes SQL :**
- `DBCC SHOW_STATISTICS` — Voir le contenu des statistiques
- `UPDATE STATISTICS` — Mettre à jour manuellement
- `CREATE STATISTICS` — Créer des statistiques personnalisées
- `sp_updatestats` — Mettre à jour toutes les statistiques

**Vues système :**
- `sys.stats` — Liste des statistiques
- `sys.stats_columns` — Colonnes dans les statistiques
- `STATS_DATE()` — Date de dernière mise à jour

**Plans d'exécution :**
- Comparaison Estimated vs Actual Rows
- Détection des problèmes de statistiques

### Scripts utiles

Vous créerez des scripts pour :
- Vérifier l'âge des statistiques
- Mettre à jour les tables critiques
- Surveiller les écarts d'estimation
- Automatiser la maintenance

## Les erreurs courantes à éviter

Apprenons des erreurs des autres avant de les commettre nous-mêmes :

### Erreur 1 : Ignorer les statistiques

**Le piège :**
```
"Mes requêtes sont lentes, je vais ajouter des index !"
[Ajoute 10 index]
"C'est toujours lent... je ne comprends pas !"
```

**La réalité :**
Les statistiques sont obsolètes. Les index ne sont pas utilisés correctement.

### Erreur 2 : Tout mettre à jour en FULLSCAN

**Le piège :**
```sql
-- Tous les jours, sur toutes les tables
UPDATE STATISTICS MaGrandeTable WITH FULLSCAN;
```

**La réalité :**
- Très long sur grandes tables
- Souvent inutile (échantillon suffirait)
- Consomme des ressources pour rien

### Erreur 3 : Désactiver les mises à jour automatiques

**Le piège :**
```sql
-- "Les MAJ auto ralentissent mes requêtes"
ALTER DATABASE SET AUTO_UPDATE_STATISTICS OFF;
-- [Oublie de mettre à jour manuellement]
```

**La réalité :**
Performance qui se dégrade progressivement sans comprendre pourquoi.

### Erreur 4 : Ne tester qu'avec des données de développement

**Le piège :**
```
Dev : 1 000 lignes → Tout va bien ! ✅
Prod : 10 000 000 lignes → Timeout ! ❌
```

**La réalité :**
Les distributions de données changent l'échelle. Testez avec des volumes réalistes.

### Erreur 5 : Ignorer le Parameter Sniffing

**Le piège :**
```
"Parfois ma requête prend 1 seconde, parfois 2 minutes.
C'est aléatoire, on ne peut rien y faire."
```

**La réalité :**
Ce n'est pas aléatoire, c'est du Parameter Sniffing ! Et c'est réparable.

## État d'esprit pour apprendre

### Curiosité scientifique

Les statistiques sont fascinantes quand vous adoptez un état d'esprit de chercheur :
- "Qu'est-ce qui fait que cette requête est lente ?"
- "Que disent les statistiques sur mes données ?"
- "Pourquoi SQL Server a-t-il choisi ce plan ?"

Chaque problème est un mystère à résoudre !

### Patience et méthode

Ne vous découragez pas si :
- Vos premières tentatives ne résolvent pas le problème
- Les concepts semblent abstraits au début
- Vous ne comprenez pas tout immédiatement

**C'est normal !** Les statistiques sont un domaine qui se révèle progressivement.

### Expérimentation pratique

La meilleure façon d'apprendre :
1. Créer une table de test
2. Insérer des données
3. Regarder les statistiques
4. Modifier les données
5. Observer comment les plans changent
6. Expérimenter avec les mises à jour

**Théorie + Pratique = Maîtrise**

### Documentation

Prenez l'habitude de noter :
- Quelles statistiques vous créez manuellement et pourquoi
- Les problèmes rencontrés et leurs solutions
- Les patterns que vous observez
- Vos scripts de maintenance

Cela constituera votre "livre de recettes" personnel.

## Le premier pas

### Commencez simplement

Après avoir lu cette introduction, votre premier exercice pratique peut être aussi simple que :

```sql
-- 1. Choisir une table de votre base
-- 2. Voir ses statistiques
SELECT name, STATS_DATE(object_id, stats_id) AS last_update
FROM sys.stats
WHERE object_id = OBJECT_ID('MaTable');

-- 3. Afficher le contenu d'une statistique
DBCC SHOW_STATISTICS('MaTable', 'NomStatistique');

-- 4. Observer l'histogramme
-- Vous venez de voir "l'intérieur" des statistiques !
```

**Félicitations !** Vous avez fait votre premier pas dans le monde des statistiques.

## Prêt pour le voyage ?

Vous comprenez maintenant :
- **Ce que sont** les statistiques et pourquoi elles existent
- **Pourquoi** elles sont absolument cruciales pour les performances
- **Comment** elles s'intègrent dans l'écosystème de l'optimisation SQL Server
- **Ce que vous allez apprendre** dans les sections suivantes
- **Comment** aborder cet apprentissage pour réussir

Les statistiques peuvent sembler invisibles et abstraites, mais elles sont en réalité au **cœur même** de tout ce que fait SQL Server. Comprendre les statistiques, c'est comprendre comment SQL Server "pense" et "décide".

Dans les sections qui suivent, nous allons plonger dans les détails techniques tout en restant accessibles. Vous allez découvrir comment manipuler cet outil puissant et résoudre des problèmes qui semblaient impossibles.

Rappelez-vous : chaque expert en statistiques SQL Server était un jour un débutant qui s'est simplement dit "Je veux comprendre comment ça marche".

C'est maintenant votre tour ! 🚀

---

## Navigation dans cette section

**Vous êtes ici :**
📍 **7.4 Statistiques — Introduction**

**Prochaines étapes :**
1. **7.4.1** — Rôle des statistiques pour l'optimiseur (Comprendre le "pourquoi")
2. **7.4.2** — Création et mise à jour des statistiques (Maîtriser le "comment")
3. **7.4.3** — Problèmes de statistiques obsolètes et Parameter Sniffing (Résoudre les crises)

**Conseil de lecture :** Lisez les sections dans l'ordre. La section 7.4.1 pose les fondations théoriques essentielles pour comprendre les sections pratiques qui suivent. Ne sautez pas d'étapes — chaque section construit sur la précédente.

**Lien avec les autres sections :**
- Revisitez la section **7.3** sur les plans d'exécution si besoin de rafraîchir votre mémoire
- Les concepts d'**index (7.1-7.2)** seront fréquemment mentionnés
- Après cette section, **7.5 Query Store** vous montrera comment suivre l'évolution dans le temps

Bonne lecture et bon apprentissage ! Les statistiques n'attendent que vous pour révéler leurs secrets. 📊⚡

⏭️ [Rôle des statistiques pour l'optimiseur de requêtes](/07-optimisation-performance-et-maintenance/04.1-role-des-statistiques.md)
