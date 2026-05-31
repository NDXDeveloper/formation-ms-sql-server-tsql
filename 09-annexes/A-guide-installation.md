🔝 Retour au [Sommaire](/SOMMAIRE.md)

# Annexe A — Guide d'installation

## Introduction

Avant de pratiquer, il vous faut un environnement de travail : un **serveur SQL Server** et un **outil client** pour vous y connecter. Cette annexe vous guide pas à pas selon votre système et vos préférences. Trois voies sont proposées :

1. **Windows** — installer SQL Server Developer (le plus classique).
2. **Docker** — un conteneur Linux, rapide et multiplateforme (Windows, macOS, Linux).
3. **Azure SQL Database** — sans rien installer, dans le cloud.

> 💡 **Recommandation pour apprendre** : sur Windows, choisissez **SQL Server Developer Edition** (gratuite, toutes les fonctionnalités). Sur macOS/Linux, choisissez **Docker**. Dans les deux cas, ajoutez l'outil client **SSMS** (Windows) ou **VS Code + extension MSSQL** (multiplateforme).

---

## 1. Choisir son édition de SQL Server

| Édition | Prix | Pour quoi ? |
|---------|------|-------------|
| **Developer** | Gratuit | **Apprentissage / dev** — toutes les fonctionnalités d'Enterprise, mais usage non-production. **Recommandée pour ce cours.** |
| **Express** | Gratuit | Petites applis — limitée (10 Go par base, ~1,4 Go de cache mémoire/buffer pool, 1 socket ou 4 cœurs, pas de SQL Agent) |
| **Standard / Enterprise** | Payant | Production |
| **Evaluation** | Gratuit 180 j | Tester Enterprise temporairement |

> ⚠️ Ne prenez **pas** Express pour apprendre : il lui manque des fonctionnalités abordées dans ce cours (SQL Server Agent, certaines options). La **Developer Edition** est gratuite et complète.

---

## 2. Option Windows — SQL Server Developer

### Téléchargement

1. Rendez-vous sur la page officielle : [aka.ms/sqldev](https://www.microsoft.com/sql-server/sql-server-downloads) (« SQL Server Downloads »).
2. Téléchargez **Developer**.

### Installation

1. Lancez l'installeur et choisissez le type d'installation :
   - **Basic** : installation rapide avec les options par défaut (recommandé pour débuter).
   - **Custom** : pour choisir les composants (incluez « Full-Text Search » si vous comptez faire le §8.8).
2. Choisissez l'**instance** :
   - **Instance par défaut** : elle s'appellera `MSSQLSERVER`, on s'y connecte via le nom de la machine (ou `localhost`).
   - **Instance nommée** : ex. `SQLDEV`, on s'y connecte via `localhost\SQLDEV`.
3. Choisissez le **mode d'authentification** :
   - **Windows** : votre compte Windows sert d'identité.
   - **Mixte (recommandé pour apprendre)** : active aussi le compte `sa` (administrateur SQL) avec un mot de passe — pratique et indispensable pour Docker/Azure plus tard.

### Vérifier que le service tourne

Ouvrez **SQL Server Configuration Manager** et vérifiez que le service **SQL Server (MSSQLSERVER)** est démarré. Si une connexion réseau est nécessaire, activez le protocole **TCP/IP** dans ce même outil, puis redémarrez le service.

---

## 3. Option Docker — conteneur Linux (multiplateforme)

C'est la voie **la plus rapide et la plus reproductible**, idéale sur macOS et Linux (et très pratique sur Windows avec Docker Desktop).

### Prérequis

- Installer **Docker Desktop** (Windows/macOS) ou **Docker Engine** (Linux).
- Allouer au moins **2 Go de RAM** au conteneur.

### Lancer SQL Server 2022 dans un conteneur

```bash
docker run \
  -e "ACCEPT_EULA=Y" \
  -e "MSSQL_SA_PASSWORD=MonMotDePasse!2026" \
  -p 1433:1433 \
  --name sql2022 \
  -d \
  mcr.microsoft.com/mssql/server:2022-latest
```

Décortiquons :
- `ACCEPT_EULA=Y` : accepter le contrat de licence (obligatoire).
- `MSSQL_SA_PASSWORD` : mot de passe du compte `sa`. **Il doit respecter la politique de complexité** : au moins 8 caractères, avec majuscules, minuscules, chiffres et symboles.
- `-p 1433:1433` : expose le port SQL Server standard.
- `--name sql2022` : nom du conteneur.
- `-d` : démarrage en arrière-plan.

### Vérifier et gérer le conteneur

```bash
docker ps                 # le conteneur sql2022 doit être listé
docker logs sql2022       # consulter les journaux de démarrage
docker stop sql2022       # arrêter
docker start sql2022      # redémarrer
```

> 💡 Sur **Apple Silicon (Mac M1/M2/M3)**, l'image SQL Server (x64) fonctionne via l'**émulation Rosetta** de Docker (activez « Use Rosetta for x86/amd64 emulation » dans Docker Desktop). Pensez à allouer suffisamment de mémoire à Docker. *(L'ancienne alternative ARM « Azure SQL Edge » a été **retirée en septembre 2025** et n'est plus recommandée.)*

---

## 4. Option Azure SQL Database — sans installation

Pour ne rien installer du tout :

1. Créez un compte sur le [portail Azure](https://portal.azure.com) (un niveau **gratuit** existe pour Azure SQL Database).
2. Créez une ressource **Azure SQL Database**, choisissez l'offre gratuite/serverless pour apprendre.
3. Autorisez votre adresse IP dans le **pare-feu** du serveur logique.
4. Connectez-vous avec un outil client (ci-dessous) en utilisant le **nom complet du serveur** (`monserveur.database.windows.net`).

> 💡 Avantage : les **sauvegardes** sont automatiques et la maintenance gérée par Azure (voir §7.8 et §8.6). Inconvénient : certaines fonctionnalités d'instance (SQL Agent, bases système) diffèrent.

---

## 5. Installer un outil client

Le serveur seul ne suffit pas : il faut un **client** pour écrire et exécuter des requêtes.

### SSMS — SQL Server Management Studio (Windows uniquement)

L'outil de référence historique, riche et complet (administration, requêtes, plans d'exécution graphiques).

- Téléchargement : [aka.ms/ssmsfullsetup](https://aka.ms/ssmsfullsetup)
- **Windows uniquement.**

### VS Code + extension MSSQL (Windows, macOS, Linux)

C'est l'outil **multiplateforme** recommandé aujourd'hui, et le **successeur officiel d'Azure Data Studio**.

1. Installez **Visual Studio Code**.
2. Dans l'onglet Extensions, installez l'extension **« SQL Server (mssql) »** publiée par Microsoft.
3. Connectez-vous à votre instance via la palette de commandes (`MS SQL: Connect`).

> ⚠️ **Azure Data Studio est retiré depuis le 28 février 2026** : il ne reçoit plus de mises à jour ni de correctifs de sécurité. Microsoft recommande désormais **VS Code avec l'extension MSSQL**. Cette extension inclut un assistant (*ADS Migration Toolkit*) qui reprend automatiquement vos connexions et paramètres si vous veniez d'Azure Data Studio.

### sqlcmd (ligne de commande)

Pour les scripts et l'automatisation, l'utilitaire `sqlcmd` (ou le plus récent `go-sqlcmd`) permet d'exécuter du T-SQL depuis le terminal :

```bash
sqlcmd -S localhost -U sa -P "MonMotDePasse!2026" -Q "SELECT @@VERSION;"
```

---

## 6. Première connexion et test

Quel que soit l'outil, les informations de connexion sont :

| Champ | Valeur typique |
|-------|----------------|
| Serveur | `localhost` (instance par défaut ou Docker) · `localhost\SQLEXPRESS` (instance nommée) · `monserveur.database.windows.net` (Azure) |
| Authentification | **SQL Login** (`sa` + mot de passe) ou **Windows** |
| Port | `1433` (par défaut) |

### Requête de vérification

Une fois connecté, exécutez :

```sql
-- Vérifier la version et l'édition installées
SELECT @@VERSION;
SELECT SERVERPROPERTY('Edition') AS Edition,
       SERVERPROPERTY('ProductVersion') AS Version;
```

Puis, pour vérifier que tout fonctionne de bout en bout :

```sql
CREATE DATABASE TestInstallation;
GO
USE TestInstallation;
GO
CREATE TABLE Essai (id INT PRIMARY KEY, message NVARCHAR(50));
INSERT INTO Essai VALUES (1, N'Installation réussie !');
SELECT * FROM Essai;
GO
-- Nettoyage
USE master;
GO
DROP DATABASE TestInstallation;
GO
```

Si vous voyez « Installation réussie ! », **félicitations** : votre environnement est prêt. 🎉

---

## 7. Dépannage des problèmes courants

| Symptôme | Cause probable | Solution |
|----------|----------------|----------|
| « Impossible de se connecter au serveur » | Service arrêté | Démarrer le service (Configuration Manager / `docker start`) |
| Connexion réseau refusée | TCP/IP désactivé | Activer TCP/IP dans SQL Server Configuration Manager, redémarrer |
| « Login failed for user 'sa' » | Auth Windows seule, ou mauvais mot de passe | Activer l'authentification **mixte** ; vérifier le mot de passe |
| Port 1433 inaccessible | Pare-feu | Ouvrir le port 1433 dans le pare-feu |
| Docker : conteneur s'arrête aussitôt | Mot de passe trop faible / RAM insuffisante | Mot de passe conforme à la politique ; allouer ≥ 2 Go |

---

## Résumé

- Pour apprendre : **SQL Server Developer** (gratuit, complet) sur Windows, ou **Docker** sur macOS/Linux.
- L'édition **Express** est trop limitée pour ce cours.
- Outils clients : **SSMS** (Windows) ou **VS Code + extension MSSQL** (multiplateforme, **successeur d'Azure Data Studio** qui est **retiré depuis février 2026**).
- **Azure SQL Database** permet de pratiquer sans rien installer (sauvegardes gérées).
- Vérifiez l'installation avec `SELECT @@VERSION;` puis un petit cycle `CREATE/INSERT/SELECT`.

Votre environnement est prêt : créons maintenant une base de données d'exemple sur laquelle vous exercer.

---

⏭️ [Annexe B — Base de données d'exemple](/09-annexes/B-base-exemple/README.md)
