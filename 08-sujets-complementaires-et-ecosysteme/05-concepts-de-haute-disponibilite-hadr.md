🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 8.5 Concepts de Haute Disponibilité (HA/DR)

## Introduction

Dans le monde professionnel d'aujourd'hui, les bases de données sont souvent au cœur des systèmes d'information. Qu'il s'agisse d'un site de commerce en ligne, d'un système bancaire, d'une application médicale ou d'un ERP d'entreprise, **l'arrêt de la base de données signifie généralement l'arrêt complet du service**.

Cette section explore les concepts et technologies qui permettent de **maintenir les bases de données disponibles et protégées**, même face à des pannes matérielles, des catastrophes naturelles ou des erreurs humaines.

## Qu'est-ce que la Haute Disponibilité (High Availability - HA) ?

### Définition simple

La **Haute Disponibilité** est la capacité d'un système à rester opérationnel et accessible pendant une proportion de temps très élevée, généralement exprimée en pourcentage.

### Les "neuf" de la disponibilité

La disponibilité est souvent exprimée en nombre de "neuf" :

| Disponibilité | Temps d'arrêt par an | Temps d'arrêt par mois | Qualification |
|---------------|---------------------|------------------------|---------------|
| 90% | 36,5 jours | 3 jours | Médiocre |
| 99% | 3,65 jours | 7,2 heures | Acceptable |
| 99,9% (trois neuf) | 8,76 heures | 43,2 minutes | Bien |
| 99,99% (quatre neuf) | 52,6 minutes | 4,32 minutes | Très bien |
| 99,999% (cinq neuf) | 5,26 minutes | 25,9 secondes | Excellent |
| 99,9999% (six neuf) | 31,5 secondes | 2,59 secondes | Exceptionnel |

**Exemple concret :**
- Un système avec 99% de disponibilité peut être en panne **plus de 3 jours par an**
- Un système avec 99,99% de disponibilité ne peut être en panne que **52 minutes par an**

### Pourquoi viser la haute disponibilité ?

#### Impact financier

Voici quelques exemples de coûts de panne pour différents secteurs :

```
┌──────────────────────────────────────────────────────────────┐
│  Secteur            │  Coût moyen par heure de panne         │
├─────────────────────┼────────────────────────────────────────┤
│  E-commerce         │  100 000 € - 500 000 €                 │
│  Banque/Finance     │  250 000 € - 1 000 000 €               │
│  Télécommunications │  200 000 € - 500 000 €                 │
│  Santé              │  100 000 € - 300 000 €                 │
│  Manufacturing      │  50 000 € - 200 000 €                  │
└──────────────────────────────────────────────────────────────┘
```

**Cas réel :** Amazon a estimé qu'une panne de son site web lui coûtait environ **220 000 $ par minute** en 2013.

#### Impact sur la réputation

Au-delà des pertes financières directes :
- **Perte de confiance** des clients
- **Dommages à la marque** et à l'image de l'entreprise
- **Perte de parts de marché** au profit de concurrents
- **Conséquences juridiques** (amendes, poursuites, non-conformité réglementaire)

#### Obligations réglementaires

Certains secteurs ont des exigences légales :
- **Santé** : Les dossiers patients doivent être accessibles en permanence
- **Finance** : Réglementations bancaires strictes sur la disponibilité
- **Télécommunications** : Services d'urgence (112, 911) doivent fonctionner 24/7

### Analogie : La station-service

Imaginez une station-service sur une autoroute :

**Sans Haute Disponibilité :**
- Une seule pompe à essence
- Si elle tombe en panne, la station ferme complètement
- Les clients partent chez le concurrent

**Avec Haute Disponibilité :**
- Plusieurs pompes à essence
- Si une tombe en panne, les autres continuent à fonctionner
- Les clients peuvent toujours se servir
- Temps de réparation sans impact sur le service

C'est exactement le principe appliqué aux bases de données.

## Qu'est-ce que la Reprise après Sinistre (Disaster Recovery - DR) ?

### Définition simple

La **Reprise après Sinistre** est la capacité à restaurer rapidement les systèmes et les données après un **événement catastrophique majeur** qui détruit ou rend inaccessible le système principal.

### Différence entre HA et DR

| Critère | Haute Disponibilité (HA) | Reprise après Sinistre (DR) |
|---------|--------------------------|----------------------------|
| **Objectif** | Éviter les petites pannes | Survivre aux catastrophes |
| **Portée** | Pannes locales (serveur, disque) | Catastrophes majeures (datacenter entier) |
| **Distance** | Même site ou proximité | Site distant (autre ville/pays) |
| **Fréquence** | Événements fréquents | Événements rares |
| **Coût** | Modéré à élevé | Élevé à très élevé |
| **Basculement** | Automatique, rapide (secondes/minutes) | Manuel ou semi-automatique (minutes/heures) |

**Analogie simple :**
- **HA** = Avoir une roue de secours dans votre voiture (panne de pneu)
- **DR** = Avoir une voiture de remplacement dans une autre ville (votre voiture est détruite dans un incendie)

### Types de catastrophes couvertes par DR

#### Catastrophes naturelles
- 🌊 Inondations
- 🔥 Incendies
- ⚡ Foudre
- 🌪️ Tornades, ouragans, tremblements de terre
- ❄️ Tempêtes de neige, verglas

#### Catastrophes technologiques
- 💥 Pannes électriques majeures
- 🔌 Défaillance de climatisation (surchauffe du datacenter)
- 🌐 Pannes réseau généralisées
- 💣 Défaillance totale de l'infrastructure (incendie datacenter)

#### Catastrophes humaines
- 👤 Erreurs humaines majeures (suppression accidentelle de données)
- 🔒 Cyberattaques (ransomware, destruction de données)
- 🚫 Sabotage
- ⚠️ Erreurs de configuration critiques

### Exemple concret : Datacenter détruit

**Scénario :** Un incendie détruit complètement votre datacenter à Paris

**Sans DR :**
```
Jour 0 : Incendie
Jour 1 : Constat des dégâts, commande de nouveau matériel
Jour 7 : Réception du matériel
Jour 10 : Installation et configuration
Jour 15 : Restauration depuis les dernières sauvegardes
Jour 20 : Retour à la normale

➡️ 20 JOURS D'ARRÊT COMPLET
➡️ Perte potentielle de données selon l'ancienneté des sauvegardes
➡️ Coût : Millions d'euros + clients perdus
```

**Avec DR (site de secours à Lyon) :**
```
Jour 0 : Incendie détecté
Heure 0 : Activation du plan DR
Heure 1 : Basculement vers le site de Lyon
Heure 2 : Services opérationnels

➡️ 2 HEURES D'ARRÊT
➡️ Perte minimale ou nulle de données
➡️ Coût : Maîtrisé, clients conservés
```

## Les métriques clés : RPO et RTO

Deux concepts fondamentaux définissent les objectifs de HA/DR :

### RPO - Recovery Point Objective (Objectif de point de récupération)

**Définition :** La **quantité maximale de données** que vous pouvez vous permettre de perdre, mesurée en temps.

**Question clé :** *"Si un sinistre survient MAINTENANT, combien de données suis-je prêt à perdre ?"*

#### Illustration visuelle

```
Passé ◄──────────────────────────────────────────► Présent
      │                                           │
      │                                           ▼
      │                                      SINISTRE !
      │
      │◄─────────── RPO = 1 heure ───────────────►│
      │                                           │
   Dernière                                       │
  sauvegarde                                      │
  exploitable                                     │

➡️ Perte de données : 1 heure de transactions
```

#### Exemples concrets

| Secteur | RPO typique | Signification |
|---------|-------------|---------------|
| Site web vitrine | 24 heures | Une journée de données perdues est acceptable |
| Blog personnel | 1 semaine | Les articles récents peuvent être réécrits |
| E-commerce | 5-15 minutes | Quelques commandes perdues |
| Banque en ligne | 0 seconde | Aucune transaction ne peut être perdue |
| Application médicale | 0 seconde | Aucune donnée patient ne peut être perdue |

**Impact du RPO sur la technologie :**
- RPO = 0 → Réplication synchrone obligatoire (coûteux)
- RPO = 15 minutes → Sauvegardes fréquentes suffisent
- RPO = 24 heures → Sauvegarde quotidienne suffit (économique)

### RTO - Recovery Time Objective (Objectif de temps de récupération)

**Définition :** Le **temps maximum** que vous pouvez vous permettre d'être hors ligne après un sinistre.

**Question clé :** *"Combien de temps puis-je rester sans mon système avant que cela devienne catastrophique ?"*

#### Illustration visuelle

```
              SINISTRE !
                 │
                 │
Présent ─────────▼──────────────────────────────────► Futur
                 │                                   │
                 │◄────── RTO = 4 heures ───────────►│
                 │                                   │
                 │                                   ▼
              Panne                            Service
              détectée                         restauré

➡️ Temps d'indisponibilité : 4 heures maximum
```

#### Exemples concrets

| Secteur | RTO typique | Signification |
|---------|-------------|---------------|
| Site web vitrine | 24 heures | Peut attendre une journée |
| Intranet d'entreprise | 4-8 heures | Peut attendre quelques heures |
| E-commerce | 1 heure | Doit être rapide |
| Banque en ligne | 15 minutes | Urgence élevée |
| Service d'urgence (112) | 0 seconde | Aucune interruption tolérée |

**Impact du RTO sur l'architecture :**
- RTO = 0 → Basculement automatique obligatoire (très coûteux)
- RTO = 1 heure → Basculement manuel rapide acceptable
- RTO = 24 heures → Restauration depuis sauvegardes suffit (économique)

### La relation RPO/RTO et le coût

Plus les objectifs sont stricts, plus le coût est élevé :

```
Coût
 │
 │                                              ╱
 │                                          ╱
 │                                      ╱
 │                                  ╱
 │                              ╱
 │                          ╱
 │                      ╱
 │                  ╱
 │              ╱
 │          ╱
 │      ╱
 │  ╱
 └──────────────────────────────────────────────► RPO/RTO
   Heures/Jours      Minutes        Secondes     0 (instantané)

   Économique     Modéré        Coûteux      Très coûteux
```

**Exemple de coûts relatifs :**
- RPO=24h, RTO=24h : Sauvegardes quotidiennes → 1x de coût
- RPO=1h, RTO=4h : Log Shipping → 3x de coût
- RPO=15min, RTO=1h : AlwaysOn asynchrone → 10x de coût
- RPO=0, RTO=30s : AlwaysOn synchrone + Cluster → 50x de coût

### Déterminer vos RPO/RTO

Posez-vous ces questions :

**Pour le RPO :**
1. Combien coûte la perte d'une heure de données ?
2. Peut-on reconstituer les données perdues ? Comment ?
3. Y a-t-il des obligations légales sur la rétention des données ?
4. Quelle est la fréquence des transactions critiques ?

**Pour le RTO :**
1. Combien perd-on par heure d'arrêt ?
2. Y a-t-il des alternatives temporaires (processus manuel) ?
3. Quelle est la tolérance des utilisateurs/clients ?
4. Y a-t-il des obligations contractuelles (SLA) ?

**Exemple de calcul simplifié :**
```
Perte financière par heure d'arrêt : 50 000 €
RTO acceptable : 4 heures
Coût maximal d'une panne : 200 000 €

➡️ Investissement justifié en HA/DR :
   Au moins 200 000 € par an (coût d'une seule panne)
```

## Vue d'ensemble des technologies SQL Server HA/DR

SQL Server propose plusieurs technologies pour répondre à différents besoins de HA/DR. Voici une vue d'ensemble avant d'explorer chacune en détail dans les sections suivantes.

### 1. Groupes de disponibilité AlwaysOn (Availability Groups)

**Résumé en une phrase :** Plusieurs copies synchronisées de vos bases de données sur différents serveurs.

**Caractéristiques :**
- RPO : 0 (synchrone) ou quelques secondes (asynchrone)
- RTO : 30 secondes à 2 minutes (automatique)
- Basculement automatique possible
- Lecture sur secondaires possible

**Idéal pour :** Applications critiques modernes nécessitant HA et DR

*Détaillé dans la section 8.5.1*

### 2. Log Shipping (Envoi de journaux)

**Résumé en une phrase :** Copie et restauration automatique des sauvegardes de journaux de transactions.

**Caractéristiques :**
- RPO : Minutes à heures (selon configuration)
- RTO : 15-30 minutes (manuel)
- Basculement manuel uniquement
- Simple et économique

**Idéal pour :** DR à distance avec budget limité (fonctionne avec toutes les éditions)

*Détaillé dans la section 8.5.3*

### 3. Failover Clustering (Cluster de basculement)

**Résumé en une phrase :** Plusieurs serveurs partageant le même stockage, un seul actif à la fois.

**Caractéristiques :**
- RPO : 0 (aucune perte)
- RTO : 30 secondes à 2 minutes (automatique)
- Nécessite un stockage partagé (SAN)
- HA locale uniquement

**Idéal pour :** HA locale avec infrastructure SAN existante

*Détaillé dans la section 8.5.3*

### 4. Autres technologies (aperçu)

#### Database Mirroring (déprécié)
- Prédécesseur d'AlwaysOn
- Encore fonctionnel mais Microsoft recommande AlwaysOn
- Une seule base à la fois

#### Replication (Réplication)
- Copie des données en quasi temps réel
- Plus orientée distribution de données que HA
- Trois types : Snapshot, Transactionnelle, Merge

#### Sauvegardes régulières
- **Indispensable** quelle que soit la solution HA/DR choisie
- Protection contre erreurs humaines, corruptions, ransomwares
- RPO/RTO dépendent de la fréquence

### Tableau de comparaison rapide

| Besoin | Solution recommandée |
|--------|---------------------|
| RPO=0, RTO<2min, budget élevé | AlwaysOn synchrone |
| DR distant, budget limité | Log Shipping |
| HA locale, SAN existant | Failover Clustering |
| RPO=0, RTO<2min, lecture secondaire | AlwaysOn |
| Protection erreurs humaines | Sauvegardes + rétention longue |
| Toutes les situations | Sauvegardes (base obligatoire) |

## Principes architecturaux de HA/DR

### Principe 1 : La redondance

**"Never have a single point of failure"** (Ne jamais avoir un point de défaillance unique)

Tout composant critique doit être dupliqué :
- ✅ Serveurs : Plusieurs serveurs SQL
- ✅ Stockage : RAID, SAN répliqué
- ✅ Réseau : Plusieurs cartes réseau, chemins redondants
- ✅ Alimentation : Onduleurs, générateurs
- ✅ Datacenter : Sites géographiquement séparés

### Principe 2 : La séparation géographique

Pour une vraie protection DR, les systèmes secondaires doivent être **suffisamment éloignés** :

```
┌─────────────────────────────────────────────────────────┐
│  Niveau de protection     │  Distance recommandée       │
├───────────────────────────┼─────────────────────────────┤
│  HA locale                │  Même datacenter            │
│                           │  (bâtiments différents)     │
├───────────────────────────┼─────────────────────────────┤
│  DR régionale             │  50-100 km                  │
│  (protège contre          │  (autre ville)              │
│   catastrophe locale)     │                             │
├───────────────────────────┼─────────────────────────────┤
│  DR nationale             │  500+ km                    │
│  (protège contre          │  (autre région)             │
│   catastrophe régionale)  │                             │
├───────────────────────────┼─────────────────────────────┤
│  DR continentale          │  Autre continent            │
│  (protection maximale)    │  (ou autre pays éloigné)    │
└─────────────────────────────────────────────────────────┘
```

**Exemple :** Une entreprise à Paris
- HA : Deux serveurs dans des salles différentes du même datacenter
- DR : Serveur de secours à Lyon (400 km)
- DR étendu : Backup dans le cloud Azure (Europe du Nord)

### Principe 3 : La stratégie 3-2-1 pour les sauvegardes

Règle d'or pour les sauvegardes :

- **3** copies de vos données (originale + 2 sauvegardes)
- **2** types de support différents (disque + bande, ou disque + cloud)
- **1** copie hors site (géographiquement séparée)

**Exemple d'implémentation :**
```
1. Base de données production (Paris)
2. Sauvegarde sur disque local (Paris)
3. Réplication vers SAN secondaire (Paris - autre bâtiment)
4. Copie vers stockage cloud (Azure - Europe du Nord)
```

### Principe 4 : Tester, tester, tester

**Un plan de reprise après sinistre non testé est un plan qui échouera.**

Tests recommandés :
- **Mensuels** : Restauration de sauvegardes
- **Trimestriels** : Basculement vers site secondaire
- **Annuels** : Simulation de catastrophe complète

**Citation célèbre :**
> "Everybody has a plan until they get punched in the mouth."
> *– Mike Tyson*

Votre plan DR doit être testé sous pression, pas découvert pendant une vraie panne !

## Considérations pour les développeurs

En tant que développeur travaillant avec des bases de données protégées par HA/DR, vous devez :

### 1. Concevoir pour la résilience

- ✅ Implémenter des **logiques de retry** (nouvelle tentative après échec)
- ✅ Gérer les **timeouts** correctement
- ✅ Utiliser des **transactions** appropriées
- ✅ Ne jamais supposer qu'une connexion reste valide indéfiniment

### 2. Comprendre les chaînes de connexion

- ✅ Utiliser des **noms logiques** (listeners, clusters) plutôt que des serveurs physiques
- ✅ Configurer les paramètres de **basculement automatique**
- ✅ Séparer les connexions **lecture/écriture** si applicable

### 3. Anticiper les basculements

Votre application doit continuer à fonctionner même si :
- La connexion est brutalement interrompue
- Le basculement prend 30-60 secondes
- Les transactions en cours sont annulées
- Les données ont quelques secondes de retard (réplicas en lecture)

### 4. Documenter les dépendances

Identifiez tous les composants dont votre application dépend :
- Base de données principale
- Bases secondaires
- Services externes
- Caches, files d'attente

Chacun peut nécessiter sa propre stratégie HA/DR.

## Le coût de la haute disponibilité

### Coûts directs

- **Licences** : SQL Server Enterprise pour AlwaysOn
- **Matériel** : Serveurs supplémentaires, stockage, réseau
- **Infrastructure** : Datacenter secondaire, bande passante
- **Personnel** : Compétences spécialisées, administration

### Coûts indirects

- **Complexité** : Plus difficile à maintenir et dépanner
- **Performance** : Légère dégradation possible (réplication synchrone)
- **Tests** : Temps et ressources pour tester régulièrement

### Analyse coût-bénéfice

**Question clé :** Le coût de la solution HA/DR est-il inférieur au coût d'une panne ?

**Exemple de calcul :**
```
Coût d'une panne de 4 heures : 200 000 €
Probabilité de panne par an : 5% (1 fois tous les 20 ans)
Coût annuel attendu de panne : 10 000 €

Coût annuel solution HA/DR : 30 000 €

➡️ La solution coûte 3x le risque
➡️ Mais : Intangibles (réputation, conformité, tranquillité d'esprit)
```

**Conseil :** Commencez par les sauvegardes solides (peu coûteux, indispensable), puis ajoutez HA/DR selon les besoins critiques.

## Checklist de préparation HA/DR

Avant d'implémenter une solution, répondez à ces questions :

### Questions stratégiques
- [ ] Quels sont nos RPO et RTO pour chaque système ?
- [ ] Quel est le coût d'une heure d'arrêt ?
- [ ] Quelles sont nos obligations légales/contractuelles ?
- [ ] Quel budget pouvons-nous allouer ?
- [ ] Qui sera responsable de la gestion HA/DR ?

### Questions techniques
- [ ] Quelle édition de SQL Server utilisons-nous ?
- [ ] Quelle est notre infrastructure actuelle (SAN, réseau) ?
- [ ] Avons-nous un site secondaire disponible ?
- [ ] Quelle est la latence réseau entre les sites ?
- [ ] Nos applications supportent-elles les basculements ?

### Questions opérationnelles
- [ ] Avons-nous les compétences nécessaires ?
- [ ] Comment allons-nous tester le plan DR ?
- [ ] Qui décide de déclencher un basculement ?
- [ ] Comment documentons-nous les procédures ?
- [ ] Quelle est notre stratégie de communication en cas de sinistre ?

## Conclusion de l'introduction

La haute disponibilité et la reprise après sinistre ne sont pas des luxes, mais des **nécessités** pour la plupart des organisations modernes. Le choix de la bonne solution dépend de nombreux facteurs :

**Facteurs à considérer :**
- Criticité des données et applications
- Objectifs RPO et RTO
- Budget disponible
- Compétences de l'équipe
- Infrastructure existante
- Exigences réglementaires

**Points clés à retenir :**

1. **HA ≠ DR** : Haute disponibilité protège contre les pannes locales, la reprise après sinistre protège contre les catastrophes majeures

2. **RPO et RTO** : Ces deux métriques définissent vos besoins et influencent directement le choix technologique

3. **Pas de solution unique** : Souvent, une combinaison de technologies est nécessaire (HA locale + DR distante + sauvegardes)

4. **Les sauvegardes sont obligatoires** : Quelle que soit votre solution HA/DR, des sauvegardes régulières testées sont indispensables

5. **Testez régulièrement** : Un plan non testé est un plan qui échouera au moment critique

---

**Dans les sections suivantes**, nous explorerons en détail :
- **8.5.1** : Groupes de disponibilité AlwaysOn
- **8.5.2** : Implications pour les développeurs (chaînes de connexion, basculement)
- **8.5.3** : Log Shipping et Clustering

Chaque section fournira les connaissances nécessaires pour comprendre, choisir et travailler efficacement avec ces technologies.

⏭️ [Théorie : Groupes de disponibilité AlwaysOn (Concepts)](/08-sujets-complementaires-et-ecosysteme/05.1-groupes-disponibilite-alwayson.md)
