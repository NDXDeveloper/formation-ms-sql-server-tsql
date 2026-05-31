🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 7.8 Sauvegarde et Restauration (BACKUP / RESTORE)

## Introduction

Imaginez que vous travaillez depuis trois ans sur un roman. Chaque jour, vous écrivez de nouvelles pages, vous corrigez, vous peaufinez chaque chapitre. Et un matin, votre ordinateur refuse de démarrer. Le disque dur est mort. **Tout a disparu.**

Si vous aviez fait des copies régulières de votre travail (sur une clé USB, dans le cloud, sur un disque externe), vous auriez perdu au pire la journée d'hier. Sinon, vous venez de perdre **trois ans de votre vie**.

Pour une base de données, c'est exactement la même chose — sauf qu'il ne s'agit pas de votre roman, mais des **données vitales** d'une organisation : les commandes des clients, les transactions financières, les dossiers médicaux, la paie des employés, l'inventaire d'un entrepôt. Perdre ces données peut signifier des poursuites judiciaires, des amendes réglementaires, une perte de confiance irréparable, et parfois tout simplement **la fin de l'entreprise**.

> 💡 **La sauvegarde est, sans exagération, la compétence la plus importante de toute personne qui gère une base de données.** On survit à une requête lente. On survit à un index mal conçu. On ne survit pas toujours à une perte de données définitive.

Cette section est sans doute la plus importante de tout le chapitre 7. Prenez le temps de bien l'assimiler.

---

## Pourquoi la sauvegarde est-elle si critique ?

Toutes les autres compétences de ce cours — concevoir des tables, écrire des requêtes performantes, créer des index — visent à rendre une base **utile et rapide**. La sauvegarde, elle, vise à la rendre **survivante**.

Réfléchissez à la valeur réelle des données :

- Une entreprise peut racheter un serveur en panne en 24 heures.
- Elle peut réécrire une application perdue en quelques semaines.
- Mais elle ne peut **jamais** recréer les données de ses dix dernières années si elles disparaissent. Ces données sont **uniques et irremplaçables**.

C'est pourquoi, dans la hiérarchie des responsabilités d'un administrateur de bases de données, **« pouvoir restaurer » passe avant tout le reste**.

### Un cas réel : l'incident GitLab de 2017

Le 31 janvier 2017, un ingénieur de GitLab, en pleine intervention nocturne sur un incident, a exécuté une commande de suppression sur le **mauvais serveur** : la base de données de **production** au lieu d'un réplica. Près de 300 Go de données ont commencé à disparaître sous ses yeux.

Le plus instructif est la suite : l'équipe a alors découvert que **plusieurs de leurs mécanismes de sauvegarde avaient silencieusement échoué** depuis des jours. Les sauvegardes automatiques produisaient des fichiers vides. Au final, ils ont pu restaurer à partir d'un instantané vieux de **six heures**, perdant tout de même les données saisies pendant ce laps de temps.

La leçon n'est pas « ils étaient incompétents » — c'était une équipe d'ingénieurs talentueux. La leçon est : **une sauvegarde dont on n'a jamais testé la restauration n'est pas une sauvegarde.** Nous y reviendrons, car c'est le fil rouge de toute cette section.

---

## Les sinistres qui menacent vos données

Une base de données peut être perdue ou corrompue de multiples façons. Les connaître aide à comprendre **pourquoi** il faut plusieurs lignes de défense.

| Type de sinistre | Exemple concret | Fréquence |
|------------------|-----------------|-----------|
| 🧑‍💻 **Erreur humaine** | `DELETE FROM Clients` sans clause `WHERE` ; mauvais `UPDATE` ; `DROP TABLE` par erreur | ⭐⭐⭐ Très fréquent |
| 💥 **Panne matérielle** | Le disque dur du serveur tombe en panne, contrôleur RAID défaillant | ⭐⭐ Fréquent |
| 🐛 **Bug applicatif** | Une mise à jour défectueuse corrompt des milliers de lignes en boucle | ⭐⭐ Fréquent |
| 🦠 **Rançongiciel** | Un *ransomware* chiffre toutes les données et exige une rançon | ⭐⭐ En forte hausse |
| ⚡ **Corruption physique** | Coupure de courant pendant une écriture, secteur disque défectueux | ⭐ Occasionnel |
| 🔥 **Sinistre du site** | Incendie, inondation, vol dans la salle serveur | ⭐ Rare mais total |

Le point essentiel : **la majorité des pertes de données viennent de l'erreur humaine**, pas de la panne matérielle. Or, contre l'erreur humaine, ni le RAID, ni les réplicas ne protègent — seule une **copie antérieure** des données vous sauve.

Face à tous ces risques, une seule protection est universelle : **disposer d'une copie saine et récente de vos données, et savoir la remettre en service rapidement.** C'est précisément le rôle des opérations de **sauvegarde** (`BACKUP`) et de **restauration** (`RESTORE`).

---

## Première analogie : la sauvegarde d'un jeu vidéo

Si vous avez déjà joué à un jeu vidéo, vous connaissez déjà l'essentiel :

- Une **sauvegarde complète** = vous enregistrez l'intégralité de votre progression dans un emplacement.
- Une **sauvegarde différentielle** = vous notez seulement ce qui a changé depuis votre dernière sauvegarde complète.
- Une **sauvegarde du journal** = le jeu enregistre en continu chacune de vos actions, ce qui permet de revenir *exactement* à l'instant juste avant que votre personnage ne tombe dans le ravin.

Et la **restauration** ? C'est le bouton « Charger la partie » : vous remettez le jeu dans l'état d'une sauvegarde antérieure. SQL Server propose exactement ces mécanismes, mais avec une rigueur de niveau professionnel.

## Deuxième analogie : l'assurance

Une sauvegarde, c'est comme une **assurance habitation** :

- Vous payez une « prime » (l'espace disque, le temps de sauvegarde) que vous espérez ne jamais avoir à « utiliser ».
- Le jour du sinistre, c'est elle — et elle seule — qui vous sauve.
- Une assurance que vous n'avez jamais vérifiée (clauses, plafonds) peut vous réserver de mauvaises surprises au pire moment. D'où l'importance de **tester** régulièrement.

---

## Trois confusions à dissiper tout de suite

### Sauvegarde ≠ Haute disponibilité

C'est la confusion la plus dangereuse, alors clarifions-la immédiatement :

- La **sauvegarde/restauration** vous protège contre la **perte de données** : elle permet de **remonter dans le temps**.
- La **haute disponibilité** (réplicas, *AlwaysOn*, abordés au §8.5) vous protège contre l'**indisponibilité** : elle permet de **continuer à fonctionner** si un serveur tombe.

```
   PERTE DE DONNÉES                    INDISPONIBILITÉ
   (revenir en arrière)                (continuer malgré une panne)
          │                                     │
          ▼                                     ▼
   ┌──────────────┐                    ┌──────────────────┐
   │ SAUVEGARDE / │                    │ HAUTE            │
   │ RESTAURATION │                    │ DISPONIBILITÉ    │
   └──────────────┘                    └──────────────────┘
```

⚠️ **Un réplica n'est PAS une sauvegarde !** Si vous exécutez `DELETE FROM Clients` sans `WHERE`, la suppression est **instantanément répliquée** sur tous les réplicas. Vos données disparaissent partout en même temps. Seule une sauvegarde antérieure vous sauvera. Les deux mécanismes sont **complémentaires**, jamais interchangeables.

### Sauvegarde ≠ copie des fichiers .mdf/.ldf

On ne sauvegarde **pas** une base SQL Server en copiant simplement ses fichiers `.mdf` et `.ldf` avec l'explorateur de fichiers. Pourquoi ?

- Tant que la base est **en ligne**, ces fichiers sont **verrouillés** par SQL Server (la copie échouera, ou pire, donnera un fichier incohérent).
- Une base est constamment en train d'écrire : copier les fichiers « à chaud » donne une photo **incohérente** (certaines transactions à moitié écrites).

La commande `BACKUP` est conçue pour produire une image **cohérente sur le plan transactionnel**, même pendant que la base est utilisée par des centaines d'utilisateurs. C'est tout son intérêt.

### Sauvegarde ≠ RAID

Le **RAID** (redondance de disques) protège contre la panne **d'un disque**, mais pas contre l'erreur humaine, la corruption logique ou le rançongiciel. Le RAID écrit vos erreurs sur tous les disques en même temps. C'est une protection matérielle utile, **en plus** des sauvegardes, jamais à leur place.

---

## Les deux composants d'une base : données et journal

Pour comprendre la suite, rappelons qu'une base SQL Server repose sur (au moins) deux fichiers :

| Fichier | Extension | Contenu |
|---------|-----------|---------|
| Fichier de données | `.mdf` (et `.ndf`) | Tables, index, vues, procédures, données |
| Journal des transactions | `.ldf` | Historique de toutes les modifications, avant leur écriture définitive |

La sauvegarde s'appuie sur **ces deux composants** : la sauvegarde de **base de données** capture les données, la sauvegarde de **journal** capture l'historique des transactions. C'est la combinaison des deux qui permet de remonter à un instant précis.

---

## Le cycle de vie de la protection des données

La sauvegarde n'est qu'une étape d'un cycle plus large :

```
   ┌─────────────┐      ┌─────────────┐      ┌──────────────┐      ┌─────────────┐
   │ 1. SAUVE-   │ ───▶ │ 2. VÉRIFIER │ ───▶ │ 3. STOCKER   │ ───▶ │ 4. TESTER   │
   │    GARDER   │      │  (CHECKSUM) │      │ (hors site)  │      │ la RESTORE  │
   └─────────────┘      └─────────────┘      └──────────────┘      └─────────────┘
          ▲                                                                │
          └────────────────────────────────────────────────────────────────┘
                          (le jour du sinistre : on RESTAURE)
```

Beaucoup d'organisations s'arrêtent à l'étape 1. Les bonnes équipes vont jusqu'à l'étape 4 — **et c'est ce qui fait toute la différence**.

---

## Ce que vous allez apprendre dans cette section

Cette section couvre tout le socle de la sauvegarde et de la restauration :

| Sous-section | Sujet | Ce que vous saurez faire |
|--------------|-------|--------------------------|
| **7.8.1** | Modèles de récupération | Choisir entre `FULL`, `SIMPLE`, `BULK_LOGGED` |
| **7.8.2** | Types de sauvegarde | Distinguer complète, différentielle et journal |
| **7.8.3** | `BACKUP DATABASE` / `BACKUP LOG` | Écrire et vérifier vos sauvegardes |
| **7.8.4** | `RESTORE` et séquence | Remettre une base en service correctement |
| **7.8.5** | Restauration à un instant T | Récupérer juste avant une erreur (`STOPAT`) |
| **7.8.6** | Stratégie (RTO, RPO) | Concevoir un plan de sauvegarde fiable |

---

## Idées reçues fréquentes

**❌ « Mon hébergeur fait les sauvegardes, je n'ai rien à faire. »**
✅ Vérifiez **toujours** : que sauvegarde-t-il exactement ? À quelle fréquence ? Savez-vous déclencher une restauration ? Beaucoup de mauvaises surprises naissent de cette hypothèse.

**❌ « J'ai un réplica AlwaysOn, donc je suis protégé. »**
✅ Le réplica protège de l'indisponibilité, pas des suppressions accidentelles (voir plus haut).

**❌ « Mes sauvegardes tournent toutes les nuits, donc tout va bien. »**
✅ Tant que vous n'avez pas **restauré** une de ces sauvegardes pour de vrai, vous n'avez aucune preuve qu'elles fonctionnent.

**❌ « La base est petite, une sauvegarde par semaine suffit. »**
✅ La fréquence dépend de la **quantité de données que vous acceptez de perdre** (le RPO, voir §7.8.6), pas de la taille de la base.

---

## La règle d'or à graver dès maintenant

```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│   « Une sauvegarde qui n'a jamais été restaurée          │
│     n'est PAS une sauvegarde — c'est juste un espoir. »  │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

Tout au long de cette section, gardez à l'esprit que l'objectif n'est pas de *faire* des sauvegardes, mais d'être **capable de restaurer** vos données quand le pire arrive. Une sauvegarde que l'on ne sait pas restaurer ne vaut rien.

---

## Résumé

- La sauvegarde/restauration protège contre la **perte de données** ; c'est la compétence la plus critique en gestion de bases de données.
- La majorité des pertes viennent de l'**erreur humaine**, contre laquelle ni le RAID ni les réplicas ne protègent — seule une **copie antérieure** le fait.
- **Sauvegarde ≠ haute disponibilité ≠ RAID ≠ copie de fichiers** : ce sont des protections différentes et complémentaires.
- Une base repose sur un fichier de **données** (`.mdf`) et un **journal** (`.ldf`) ; la sauvegarde s'appuie sur les deux.
- Le cycle complet est : sauvegarder → vérifier → stocker hors site → **tester la restauration**.
- Règle d'or : **une sauvegarde non testée n'est pas une sauvegarde.**

---

**Note pour les développeurs** : même si l'administration des sauvegardes relève souvent du DBA, tout développeur doit en comprendre les principes. Vous serez amené à restaurer une base sur votre poste, à diagnostiquer un journal qui sature un disque, ou à dialoguer avec l'exploitation. Ces concepts font partie du socle commun à toute la filière données.

⏭️ [Modèles de récupération (FULL, SIMPLE, BULK_LOGGED)](/07-optimisation-performance-et-maintenance/08.1-modeles-de-recuperation.md)
