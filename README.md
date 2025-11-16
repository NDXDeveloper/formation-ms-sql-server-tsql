# 🗄️ Formation Complète MS SQL Server et T-SQL

![License](https://img.shields.io/badge/License-CC%20BY%204.0-blue.svg)
![SQL Server](https://img.shields.io/badge/SQL%20Server-2019%2B-red.svg)
![Modules](https://img.shields.io/badge/Modules-8%2F8-green.svg)
![Chapitres](https://img.shields.io/badge/Chapitres-46-brightgreen.svg)
![Language](https://img.shields.io/badge/Langue-Français-blue.svg)

**Le guide complet pour maîtriser Microsoft SQL Server et le langage T-SQL, du niveau débutant au niveau expert.**

---

## 📖 Table des matières

- [À propos](#-à-propos)
- [Contenu](#-contenu-de-la-formation)
- [Prérequis](#-prérequis)
- [Démarrage rapide](#-démarrage-rapide)
- [Utilisation](#-comment-utiliser-cette-formation)
- [Structure](#-structure-du-projet)
- [Parcours suggéré](#️-parcours-suggéré)
- [Licence](#-licence)
- [Contact](#-contact)

---

## 📋 À propos

Cette formation complète couvre tous les aspects essentiels de Microsoft SQL Server et du langage T-SQL, de la création de bases de données aux techniques d'optimisation avancées. Conçue pour être progressive, elle convient aussi bien aux débutants qu'aux développeurs expérimentés souhaitant approfondir leurs connaissances.

**✨ Points clés :**
- 📚 **8 modules progressifs** structurés pédagogiquement
- 🎯 **46 chapitres détaillés** avec exemples pratiques
- 🏗️ **Architecture complète** : de la création aux optimisations
- 🔧 **Programmabilité T-SQL** : procédures, fonctions, triggers
- ⚡ **Performance et optimisation** : index, plans d'exécution, Query Store
- ☁️ **Azure SQL** : concepts cloud et haute disponibilité
- 🇫🇷 **En français** et gratuit (CC BY 4.0)

**Durée estimée :** 40-50 heures • **Niveau :** Tous niveaux

---

## 📚 Contenu de la formation

> 📄 **Voir le [SOMMAIRE.md](SOMMAIRE.md) complet** pour la table des matières détaillée

### Module 1 : Introduction et Concepts Fondamentaux
Bases de données relationnelles, modèle SGBDR, architecture SQL Server, outils (SSMS, Azure Data Studio), introduction à T-SQL

### Module 2 : Définition et Manipulation des Données
Types de données, DDL (CREATE, ALTER, DROP), contraintes d'intégrité, DML (INSERT, UPDATE, DELETE)

### Module 3 : Interrogation des Données - SELECT
Structure SELECT, filtrage (WHERE), tri (ORDER BY), agrégations (GROUP BY, HAVING), fonctions

### Module 4 : Techniques de Requêtage Avancées
Jointures (INNER, LEFT, RIGHT, FULL, CROSS), sous-requêtes, CTE, opérateurs d'ensemble, fonctions de fenêtrage, PIVOT, MERGE

### Module 5 : Programmabilité en T-SQL
Variables et lots, structures de contrôle, gestion des erreurs, vues, procédures stockées, fonctions (UDF), triggers, SQL dynamique

### Module 6 : Gestion des Transactions et Concurrence
Transactions ACID, TCL (BEGIN, COMMIT, ROLLBACK), verrouillage, deadlocks, niveaux d'isolation

### Module 7 : Optimisation, Performance et Maintenance
Index (clustered, non-clustered, composites, filtrés), plans d'exécution, statistiques, Query Store, SARGability, fragmentation

### Module 8 : Sujets Complémentaires et Écosystème
XML et JSON, tables temporelles, sécurité (DCL), haute disponibilité (AlwaysOn), Azure SQL Database

---

## 🔧 Prérequis

### Logiciels nécessaires

**SQL Server (une des options) :**
- SQL Server Express (gratuit) - recommandé pour l'apprentissage
- SQL Server Developer Edition (gratuit)
- Azure SQL Database (version cloud)

**Outils de gestion :**
- SQL Server Management Studio (SSMS) - recommandé
- Azure Data Studio (moderne et cross-platform)

### Connaissances recommandées
- Bases en informatique
- Logique et résolution de problèmes
- Aucune connaissance préalable en SQL requise pour débuter

---

## 🚀 Démarrage rapide

### Installation de SQL Server Express

**Windows :**
```powershell
# Télécharger SQL Server Express
# https://www.microsoft.com/fr-fr/sql-server/sql-server-downloads

# Installer SSMS
# https://docs.microsoft.com/sql/ssms/download-sql-server-management-studio-ssms
```

**Linux (Ubuntu/Debian) :**
```bash
# Importer la clé GPG
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# Ajouter le repository
sudo add-apt-repository "$(curl https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2019.list)"

# Installer SQL Server
sudo apt-get update
sudo apt-get install -y mssql-server

# Configurer SQL Server
sudo /opt/mssql/bin/mssql-conf setup
```

### Première connexion

```sql
-- Créer votre première base de données
CREATE DATABASE MaPremiereDB;
GO

-- Utiliser la base de données
USE MaPremiereDB;
GO

-- Créer votre première table
CREATE TABLE Utilisateurs (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Nom NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) UNIQUE,
    DateCreation DATETIME2 DEFAULT GETDATE()
);
GO
```

---

## 📁 Structure du projet

```
formation-ms-sql-server-tsql/
├── README.md
├── SOMMAIRE.md
├── LICENSE
├── 01-introduction-et-concepts-fondamentaux/
│   ├── README.md
│   ├── 01-quest-ce-quune-base-de-donnees.md
│   ├── 01.1-definition-donnees-informations.md
│   └── ...
├── 02-definition-et-manipulation-des-donnees/
│   ├── README.md
│   └── ...
├── 03-interrogation-des-donnees-select/
├── 04-techniques-de-requetage-avancees/
├── 05-programmabilite-en-tsql/
├── 06-gestion-des-transactions-et-concurrence/
├── 07-optimisation-performance-et-maintenance/
└── 08-sujets-complementaires-et-ecosysteme/
```

---

## 🎯 Comment utiliser cette formation

### Débutant complet
👉 Commencez par le [Module 1](01-introduction-et-concepts-fondamentaux/) et suivez l'ordre chronologique

### Développeur avec bases SQL
👉 Allez directement au [Module 4 : Techniques avancées](04-techniques-de-requetage-avancees/)

### Optimisation et performance
👉 Consultez le [Module 7 : Optimisation](07-optimisation-performance-et-maintenance/)

### Référence rapide
👉 Utilisez le [SOMMAIRE.md](SOMMAIRE.md) pour naviguer directement vers un sujet spécifique

**💡 Conseil :** Créez une base de données de test pour pratiquer :
```sql
CREATE DATABASE FormationTest;
```

---

## 🗓️ Parcours suggéré

| Niveau | Modules | Durée | Objectif |
|--------|---------|-------|----------|
| 🌱 **Débutant** | 1-3 | 12-15h | Maîtriser les fondamentaux et les requêtes SELECT |
| 🌿 **Intermédiaire** | 4-5 | 12-15h | Techniques avancées et programmabilité T-SQL |
| 🌳 **Avancé** | 6-8 | 15-20h | Transactions, optimisation et écosystème complet |

**Progression recommandée :** 2-3 chapitres par semaine • 1-2h de pratique quotidienne

---

## 💡 Ressources complémentaires

### Documentation officielle
- [Microsoft SQL Server Documentation](https://docs.microsoft.com/sql/)
- [T-SQL Reference](https://docs.microsoft.com/sql/t-sql/)
- [Azure SQL Documentation](https://docs.microsoft.com/azure/azure-sql/)

### Outils pratiques
- [SQL Server Management Studio (SSMS)](https://docs.microsoft.com/sql/ssms/)
- [Azure Data Studio](https://docs.microsoft.com/sql/azure-data-studio/)
- [SQL Server Data Tools (SSDT)](https://docs.microsoft.com/sql/ssdt/)

### Communautés
- [Microsoft Q&A - SQL Server](https://docs.microsoft.com/answers/topics/sql-server.html)
- [Stack Overflow - T-SQL](https://stackoverflow.com/questions/tagged/tsql)
- [SQLServerCentral](https://www.sqlservercentral.com/)

---

## ❓ FAQ

**Q : Quelle édition de SQL Server dois-je utiliser ?**
R : SQL Server Express (gratuit) est parfait pour apprendre. Developer Edition est aussi gratuite pour le développement.

**Q : Puis-je utiliser Azure SQL Database ?**
R : Oui ! La majorité des concepts s'appliquent. Le Module 8 couvre les spécificités cloud.

**Q : Combien de temps faut-il pour compléter la formation ?**
R : 40-50 heures réparties sur 2-3 mois en pratiquant régulièrement.

**Q : Dois-je suivre l'ordre des modules ?**
R : Oui pour les débutants. Les utilisateurs expérimentés peuvent naviguer librement.

**Q : Y a-t-il des exercices pratiques ?**
R : Chaque module contient des exemples de code à pratiquer. Créez une base de test pour expérimenter.

**Q : Cette formation couvre-t-elle Azure SQL ?**
R : Oui, le Module 8 aborde Azure SQL Database, Managed Instance, et les concepts cloud.

---

## 📝 Licence

Ce projet est sous licence **Creative Commons Attribution 4.0 International (CC BY 4.0)**.

✅ Vous êtes libre de :
- **Partager** : copier et redistribuer
- **Adapter** : remixer, transformer et créer
- **Usage commercial** : utiliser à des fins commerciales

📋 Sous les conditions suivantes :
- **Attribution** : vous devez créditer l'œuvre et indiquer si des modifications ont été effectuées

**Attribution suggérée :**
```
Formation MS SQL Server et T-SQL par Nicolas DEOUX
https://github.com/NDXDeveloper/formation-ms-sql-server-tsql
Licence CC BY 4.0
```

Voir le fichier [LICENSE](LICENSE) pour les détails complets.

---

## 👨‍💻 Contact

**Nicolas DEOUX**
- 📧 Email : [NDXDev@gmail.com](mailto:NDXDev@gmail.com)
- 🐙 GitHub : [@NDXDeveloper](https://github.com/NDXDeveloper)

---

## 🙏 Remerciements

Merci à Microsoft pour SQL Server, à la communauté T-SQL, et à tous les développeurs qui partagent leurs connaissances ! 🎉

**Ressources inspirantes :**
[Microsoft Docs](https://docs.microsoft.com/sql/) • [SQLServerCentral](https://www.sqlservercentral.com/) • [Brent Ozar](https://www.brentozar.com/) • [SQL Server Performance](https://www.sqlservercentral.com/articles/stairway-to-t-sql-dml)

---

<div align="center">

**🎉 Bon apprentissage avec SQL Server et T-SQL ! 🎉**

[![Star on GitHub](https://img.shields.io/github/stars/NDXDeveloper/formation-ms-sql-server-tsql?style=social)](https://github.com/NDXDeveloper/formation-ms-sql-server-tsql)

**[⬆ Retour en haut](#️-formation-complète-ms-sql-server-et-t-sql)**

*Dernière mise à jour : Novembre 2025*

</div>
