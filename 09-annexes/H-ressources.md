🔝 Retour au [Sommaire](/SOMMAIRE.md)

# Annexe H — Ressources et bibliographie

> Une sélection de ressources fiables pour approfondir, rester à jour et résoudre vos problèmes au quotidien. Le SQL évolue : l'autoformation continue fait partie du métier.

---

## Documentation officielle (Microsoft)

| Ressource | Description |
|-----------|-------------|
| [Microsoft Learn — SQL Server](https://learn.microsoft.com/sql/) | La documentation de référence, complète et à jour |
| [Référence T-SQL](https://learn.microsoft.com/sql/t-sql/) | Syntaxe de **toutes** les instructions T-SQL |
| [Microsoft Learn — Azure SQL](https://learn.microsoft.com/azure/azure-sql/) | Documentation Azure SQL Database / Managed Instance |
| [Parcours d'apprentissage Microsoft Learn](https://learn.microsoft.com/training/) | Modules de formation gratuits et interactifs |

> 💡 Réflexe n°1 : pour toute commande, cherchez « *nom de la commande* + T-SQL Microsoft Learn ». La doc officielle donne syntaxe, arguments et exemples.

---

## Outils indispensables

| Outil | Usage |
|-------|-------|
| [SQL Server Management Studio (SSMS)](https://aka.ms/ssmsfullsetup) | Outil client complet (Windows) |
| [Extension MSSQL pour VS Code](https://learn.microsoft.com/sql/tools/visual-studio-code-extensions/mssql/) | Client multiplateforme (successeur d'Azure Data Studio) |
| [dbatools](https://dbatools.io/) | Automatisation PowerShell (sauvegardes, migrations…) |
| [Solution de maintenance d'Ola Hallengren](https://ola.hallengren.com/) | Scripts de sauvegarde/maintenance, référence en production |
| [First Responder Kit (Brent Ozar)](https://www.brentozar.com/first-aid/) | `sp_Blitz`, `sp_BlitzCache`… diagnostics gratuits |
| [sp_WhoIsActive (Adam Machanic)](http://whoisactive.com/) | Voir l'activité en temps réel sur une instance |

> ⚠️ Rappel : **Azure Data Studio est retiré depuis février 2026** ; utilisez **VS Code + extension MSSQL** (voir [annexe A](/09-annexes/A-guide-installation.md)).

---

## Blogs et experts de référence

| Source | Spécialité |
|--------|------------|
| [SQLskills (Paul Randal, Kimberly Tripp)](https://www.sqlskills.com/blogs/) | Internes du moteur, index, performance |
| [Brent Ozar](https://www.brentozar.com/blog/) | Performance, administration, conseils pratiques |
| [Erland Sommarskog](https://www.sommarskog.se/) | Articles de fond (SQL dynamique, erreurs, arrays…) |
| [Itzik Ben-Gan (articles SQLServerCentral / sqlperformance)](https://sqlperformance.com/author/itzik-ben-gan) | T-SQL avancé, fonctions de fenêtrage |
| [SQLServerCentral](https://www.sqlservercentral.com/) | Articles, forums, « Stairways » pédagogiques |
| [MSSQLTips](https://www.mssqltips.com/) | Tutoriels pratiques orientés solutions |
| [Redgate — Simple Talk](https://www.red-gate.com/simple-talk/databases/sql-server/) | Articles techniques de qualité |
| [Glenn Berry (Diagnostic Queries)](https://glennsqlperformance.com/) | Requêtes de diagnostic, matériel |

---

## Communautés (pour poser vos questions)

| Communauté | Pour quoi ? |
|------------|-------------|
| [Stack Overflow — tag sql-server](https://stackoverflow.com/questions/tagged/sql-server) | Questions de programmation T-SQL |
| [Database Administrators Stack Exchange](https://dba.stackexchange.com/) | Questions d'administration/conception |
| [Microsoft Q&A — SQL Server](https://learn.microsoft.com/answers/tags/sql-server.html) | Questions adressées à la communauté Microsoft |
| [r/SQLServer (Reddit)](https://www.reddit.com/r/SQLServer/) | Discussions, retours d'expérience |
| #sqlhelp (réseaux sociaux) | Aide rapide de la communauté SQL |

> 💡 **Bien poser une question** : indiquez la version de SQL Server, le schéma minimal des tables concernées, la requête exacte, le message d'erreur complet et le comportement attendu. Une question claire obtient une réponse rapide.

---

## Livres recommandés

- **« T-SQL Fundamentals »** — Itzik Ben-Gan : la référence pour des fondations T-SQL solides.
- **« T-SQL Querying »** et **« T-SQL Window Functions »** — Itzik Ben-Gan : pour le requêtage avancé.
- **« SQL Server Internals »** (gamme *Pro SQL Server Internals*, Dmitri Korotkevitch) : le fonctionnement interne du moteur.
- **« SQL Performance Explained »** — Markus Winand : les index expliqués (multi-SGBD, très pédagogique). Voir aussi [use-the-index-luke.com](https://use-the-index-luke.com/).
- **« The Art of SQL »** / classiques sur la conception relationnelle.

---

## Apprendre en pratiquant

- **Bases d'exemple** : `Boutique` ([annexe B](/09-annexes/B-base-exemple/README.md)) et **WideWorldImporters** (Microsoft).
- **Exercices** : [annexe C](/09-annexes/C-exercices/README.md) de ce cours ; sites d'entraînement type *SQL challenges*.
- **Reconstituez** : prenez un besoin métier réel (gestion de bibliothèque, blog, e-commerce) et modélisez-le de A à Z.

---

## Certifications (parcours professionnel)

Microsoft a fait évoluer ses certifications vers le **cloud et les données** :

- **DP-300** — *Azure Database Administrator Associate* : administration de bases SQL (sur site et Azure).
- **DP-900** — *Azure Data Fundamentals* : socle des concepts de données (idéal pour débuter).

> 💡 Même sans viser la certification, les **parcours d'apprentissage** associés sur Microsoft Learn sont gratuits et structurés.

---

## Rester à jour

- Suivez les **notes de version** de SQL Server et d'Azure SQL sur Microsoft Learn.
- Lisez les blogs ci-dessus (beaucoup proposent une newsletter).
- Participez à un **groupe d'utilisateurs** (PASS/groupes locaux, conférences comme *SQLBits*, *Data Saturdays*).
- Pratiquez régulièrement : la compétence SQL s'entretient.

---

## Conclusion de la formation

Vous voici au bout de cette formation — des concepts fondamentaux jusqu'aux sujets les plus avancés, en passant par la pratique. Le plus important commence maintenant : **mettez en pratique**, expérimentez sur vos propres données, et n'hésitez jamais à consulter la documentation et la communauté.

🎓 **Bon parcours dans le monde des bases de données SQL Server et T-SQL !**

---

⏭️ Retour au [Sommaire](/SOMMAIRE.md)
