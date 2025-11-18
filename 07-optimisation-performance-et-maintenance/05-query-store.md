🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 7.5 Query Store (Magasin de requêtes)

## Introduction à cette section

Bienvenue dans la section consacrée au **Query Store** (Magasin de requêtes), l'une des fonctionnalités les plus précieuses de SQL Server pour le diagnostic et l'optimisation des performances.

### Pourquoi cette section est importante ?

Jusqu'à présent dans cette formation, vous avez appris à :
- Écrire des requêtes SQL efficaces
- Comprendre les index et leur importance
- Lire les plans d'exécution
- Identifier les problèmes de performance

Mais une question cruciale restait sans réponse : **Comment suivre l'évolution des performances dans le temps ?**

C'est exactement ce que le Query Store vous permet de faire. Il transforme le diagnostic de performance d'une tâche difficile et réactive en un processus simple et proactif.

### Le défi avant Query Store

Imaginez ces situations courantes :

**Scénario 1 : Le mystère du lundi matin**
```
Utilisateurs : "L'application est très lente ce matin !"
DBA : "Laissez-moi vérifier... Mais je ne vois que les performances actuelles."
       "Je ne sais pas comment c'était hier ou la semaine dernière."
       "Je ne peux pas comparer..."
```

**Scénario 2 : La régression invisible**
```
Développeur : "J'ai optimisé une requête vendredi dernier."
Manager : "Es-tu sûr que c'est mieux ?"
Développeur : "Euh... je crois ? Je n'ai pas de données avant/après..."
```

**Scénario 3 : Le redémarrage qui efface tout**
```
Admin : "Le serveur a redémarré cette nuit."
DBA : "Toutes les statistiques de performance ont disparu !"
      "Je ne peux pas analyser ce qui s'est passé avant..."
```

### La solution : Query Store

Le Query Store résout tous ces problèmes en agissant comme une **boîte noire** pour votre base de données. Il enregistre automatiquement :

📊 **L'historique des requêtes**
- Quelles requêtes ont été exécutées
- Quand elles ont été exécutées
- Combien de fois

📈 **Les métriques de performance**
- Durée d'exécution
- Consommation CPU
- Lectures/écritures disque
- Et bien plus...

🗺️ **Les plans d'exécution**
- Tous les plans utilisés pour chaque requête
- Quand chaque plan a été actif
- Lequel est le plus performant

💾 **La persistance des données**
- Les informations survivent aux redémarrages
- L'historique est conservé selon votre configuration
- Les données sont stockées dans la base de données elle-même

### Analogie pour comprendre le Query Store

Pensez au Query Store comme au **tableau de bord d'une voiture moderne** :

🚗 **Sans Query Store (voiture ancienne)** :
- Vous voyez seulement la vitesse actuelle
- Pas d'ordinateur de bord
- Pas d'historique
- Si vous coupez le contact, tout disparaît

🚗 **Avec Query Store (voiture moderne)** :
- Tableau de bord complet avec historique
- Consommation moyenne sur 100 km, 500 km, depuis le départ
- Enregistrement des trajets
- Comparaison des performances
- Alertes automatiques si quelque chose d'anormal
- Les données restent même si vous coupez le contact

### Ce que vous allez apprendre

Cette section est divisée en quatre parties progressives :

#### **7.5.1 Introduction au Query Store**
Vous découvrirez :
- Ce qu'est concrètement le Query Store
- Comment il fonctionne en coulisses
- Comment l'activer et le configurer
- Les premières explorations dans SSMS

**Objectif** : Comprendre les fondamentaux et être capable d'activer le Query Store.

#### **7.5.2 Identification des régressions de performance**
Vous apprendrez à :
- Détecter quand une requête devient plus lente
- Utiliser le rapport "Regressed Queries"
- Comparer les anciens et nouveaux plans d'exécution
- Comprendre pourquoi les performances se dégradent

**Objectif** : Identifier rapidement les problèmes de performance dès qu'ils apparaissent.

#### **7.5.3 Forcer un plan d'exécution**
Vous maîtriserez :
- Le concept de forçage de plan
- Quand et pourquoi forcer un plan
- Comment forcer et "déforcer" un plan
- Les bonnes pratiques et pièges à éviter

**Objectif** : Corriger rapidement une régression en forçant un bon plan d'exécution.

#### **7.5.4 Analyse historique des performances**
Vous explorerez :
- L'analyse des tendances dans le temps
- L'identification des patterns et de la saisonnalité
- La comparaison de périodes (avant/après)
- L'établissement de baselines de performance

**Objectif** : Utiliser l'historique pour comprendre, prévoir et optimiser proactivement.

### À qui s'adresse cette section ?

Le Query Store est utile pour :

**👨‍💻 Développeurs**
- Valider que vos optimisations fonctionnent vraiment
- Comprendre l'impact de vos changements de code
- Identifier les requêtes problématiques à optimiser

**🔧 Administrateurs de bases de données (DBA)**
- Diagnostiquer les problèmes de performance rapidement
- Surveiller la santé globale de la base de données
- Planifier les optimisations de manière proactive

**📊 Analystes de performance**
- Comprendre les patterns d'utilisation
- Établir des métriques et des baselines
- Créer des rapports de performance

**🎓 Débutants en SQL Server**
- Apprendre à diagnostiquer les problèmes de performance
- Comprendre l'évolution des requêtes dans le temps
- Acquérir une méthodologie de résolution de problèmes

### Prérequis pour cette section

Pour tirer le meilleur parti de cette section, vous devriez être à l'aise avec :

✅ **Les bases de T-SQL**
- SELECT, WHERE, JOIN (Section 3 et 4)
- Vous allez interroger les vues système du Query Store

✅ **Les plans d'exécution (Section 7.3)**
- Comprendre ce qu'est un plan d'exécution
- Savoir identifier les opérateurs coûteux
- Le Query Store manipule beaucoup les plans

✅ **Les index (Section 7.1 et 7.2)**
- Comprendre l'impact des index sur les performances
- Savoir quand un index est utilisé ou non

✅ **SSMS (SQL Server Management Studio)**
- Naviguer dans l'interface
- Exécuter des requêtes
- Visualiser des résultats

Si vous n'êtes pas encore à l'aise avec ces concepts, nous vous recommandons de les réviser avant de poursuivre.

### Environnement requis

Pour suivre cette section, vous aurez besoin de :

**Version de SQL Server :**
- SQL Server 2016 ou ultérieur (Query Store a été introduit en 2016)
- SQL Server 2017+ recommandé pour toutes les fonctionnalités
- Azure SQL Database (Query Store est activé par défaut)

**Outils :**
- SQL Server Management Studio (SSMS) version 17 ou ultérieure
- Droits suffisants pour activer Query Store (db_owner ou équivalent)

**Note :** Si vous utilisez une version antérieure à SQL Server 2016, cette section ne sera pas applicable à votre environnement.

### Organisation de l'apprentissage

Nous vous recommandons de suivre cette section dans l'ordre :

```
1. Lire 7.5.1 (Introduction)
   ↓
   Comprendre les concepts de base
   Activer Query Store sur une base de test
   ↓
2. Lire 7.5.2 (Identification des régressions)
   ↓
   Pratiquer l'identification de problèmes
   Utiliser les rapports SSMS
   ↓
3. Lire 7.5.3 (Forcer un plan)
   ↓
   Comprendre quand et comment forcer
   Tester sur des scénarios réels
   ↓
4. Lire 7.5.4 (Analyse historique)
   ↓
   Explorer les tendances
   Créer vos propres analyses
```

**Temps estimé :** 3-4 heures pour lire et comprendre toute la section, plus du temps de pratique sur vos propres bases de données.

### Ce que Query Store n'est PAS

Pour éviter les malentendus, clarifions ce que Query Store ne fait pas :

❌ **Ce n'est pas un outil d'optimisation automatique**
- Il identifie les problèmes, mais ne les corrige pas automatiquement
- Vous devez toujours analyser et décider des actions

❌ **Ce n'est pas un remplacement de la surveillance système**
- Il se concentre sur les requêtes SQL
- Il ne surveille pas le CPU global, la mémoire serveur, le réseau, etc.
- Utilisez-le en complément d'autres outils de monitoring

❌ **Ce n'est pas un historique complet de toutes les données**
- Il agrège les statistiques par intervalles (par défaut 60 minutes)
- Il ne garde pas chaque exécution individuelle
- Il a une limite de rétention (par défaut 30 jours)

❌ **Ce n'est pas gratuit en ressources**
- Il consomme un peu de CPU (généralement <5%)
- Il utilise de l'espace disque dans votre base de données
- L'impact est faible mais existe

### Les bénéfices concrets

Après avoir maîtrisé le Query Store, vous serez capable de :

**🎯 Diagnostiquer plus rapidement**
```
Avant : "L'application est lente... où est le problème ?"
        → Investigation de plusieurs heures

Après : "Query Store montre que la requête X est 10x plus lente depuis ce matin"
        → Problème identifié en 5 minutes
```

**📊 Prendre des décisions basées sur des données**
```
Avant : "Je pense que cet index aidera"
        → Hypothèse non vérifiée

Après : "Query Store confirme que l'index a réduit la durée de 80%"
        → Validation objective
```

**🔮 Être proactif plutôt que réactif**
```
Avant : Attendre qu'un utilisateur se plaigne
        → Réaction tardive

Après : Query Store alerte sur une dégradation progressive
        → Action préventive
```

**💰 Économiser du temps et de l'argent**
```
Avant : Heures d'investigation sans garantie de trouver la cause
        → Coûteux en temps

Après : Diagnostic précis et rapide
        → Résolution efficace
```

### Aperçu visuel : Le tableau de bord Query Store

Une fois le Query Store activé, vous aurez accès à plusieurs rapports visuels dans SSMS :

**Exemple de rapports disponibles :**

1. **Regressed Queries** (Requêtes régressées)
   - Affiche les requêtes devenues plus lentes
   - Graphique visuel avec comparaison avant/après

2. **Overall Resource Consumption** (Consommation globale)
   - Vue d'ensemble de l'utilisation des ressources
   - Graphique temporel de la charge

3. **Top Resource Consuming Queries** (Requêtes les plus gourmandes)
   - Liste des requêtes qui consomment le plus
   - Par durée, CPU, I/O, etc.

4. **Queries With Forced Plans** (Requêtes avec plans forcés)
   - Suivi des plans d'exécution que vous avez forcés
   - État et statistiques

5. **Queries With High Variation** (Requêtes à forte variation)
   - Requêtes avec performances instables
   - Identification de comportements erratiques

6. **Tracked Queries** (Requêtes suivies)
   - Suivi personnalisé de requêtes spécifiques
   - Monitoring ciblé

Ces rapports transforment des données complexes en visualisations claires et actionnables.

### Philosophie de cette section

Notre approche pédagogique pour le Query Store :

**🎓 Du simple au complexe**
- Nous commençons par les concepts de base
- Nous progressons vers des analyses avancées
- Chaque sous-section s'appuie sur la précédente

**💡 Pratique et concret**
- Des exemples réels et parlants
- Des analogies pour faciliter la compréhension
- Des scénarios que vous rencontrerez en production

**⚠️ Mise en garde sur les pièges**
- Les erreurs communes à éviter
- Les limitations à connaître
- Les bonnes pratiques éprouvées

**🔧 Utilisable immédiatement**
- Des requêtes prêtes à l'emploi
- Des configurations recommandées
- Des méthodologies applicables dès maintenant

### Un dernier mot avant de commencer

Le Query Store est souvent considéré comme l'une des **meilleures fonctionnalités ajoutées à SQL Server ces dernières années**. C'est un outil qui change vraiment la donne pour le diagnostic de performance.

Cependant, comme tout outil puissant :
- Il nécessite une compréhension de base pour être utilisé efficacement
- Il ne remplace pas la connaissance des fondamentaux SQL
- Il est un complément, pas un substitut à une bonne conception

**Notre promesse :** À la fin de cette section, vous aurez les connaissances et la confiance nécessaires pour utiliser le Query Store efficacement dans vos projets réels.

### Prêt à commencer ?

Vous êtes maintenant prêt à plonger dans le monde du Query Store. La section suivante (7.5.1) vous donnera une introduction détaillée à cette fonctionnalité essentielle.

**Conseil avant de démarrer :**
- Ayez une instance SQL Server 2016+ sous la main pour tester
- Gardez SSMS ouvert pour suivre les exemples
- N'hésitez pas à expérimenter sur une base de test
- Prenez des notes sur les concepts clés

**Rappel important :** Comme pour tout changement de configuration en base de données, testez d'abord dans un environnement de développement ou de test avant d'activer le Query Store en production.

---

**🎯 Objectifs d'apprentissage de la section 7.5 :**

À la fin de cette section complète, vous serez capable de :

- ✅ Expliquer ce qu'est le Query Store et comment il fonctionne
- ✅ Activer et configurer le Query Store de manière appropriée
- ✅ Identifier rapidement les régressions de performance
- ✅ Comparer et analyser différents plans d'exécution
- ✅ Forcer un plan d'exécution quand nécessaire
- ✅ Effectuer des analyses historiques pour comprendre les tendances
- ✅ Établir des baselines de performance
- ✅ Utiliser les rapports SSMS et écrire des requêtes personnalisées
- ✅ Intégrer Query Store dans votre workflow de diagnostic quotidien

**Bonne lecture et bon apprentissage ! 🚀**

---

**Passons maintenant à la section 7.5.1 pour découvrir le Query Store en détail.**

⏭️ [Introduction au Query Store](/07-optimisation-performance-et-maintenance/05.1-introduction-query-store.md)
