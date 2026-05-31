/* ============================================================================
   Base de données d'exemple "Boutique"
   Formation MS SQL Server et T-SQL
   ----------------------------------------------------------------------------
   Ce script crée la base Boutique, ses 6 tables (avec contraintes) et insère
   un jeu de données cohérent pour les exercices.

   ATTENTION : ce script SUPPRIME puis RECRÉE la base "Boutique".
               Ne l'exécutez pas sur une base de production de ce nom.

   Cible : SQL Server 2022+ (Developer/Express/Standard) ou Azure SQL.
   ============================================================================ */

------------------------------------------------------------------------------
-- 0. (Re)création de la base
------------------------------------------------------------------------------
USE master;
GO

IF DB_ID('Boutique') IS NOT NULL
BEGIN
    ALTER DATABASE Boutique SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Boutique;
END
GO

CREATE DATABASE Boutique;
GO

USE Boutique;
GO

------------------------------------------------------------------------------
-- 1. Création des tables
------------------------------------------------------------------------------

-- Catégories de produits
CREATE TABLE Categories (
    CategorieID   INT IDENTITY(1,1) CONSTRAINT PK_Categories PRIMARY KEY,
    NomCategorie  NVARCHAR(50) NOT NULL CONSTRAINT UQ_Categories_Nom UNIQUE
);

-- Produits
CREATE TABLE Produits (
    ProduitID     INT IDENTITY(1,1) CONSTRAINT PK_Produits PRIMARY KEY,
    NomProduit    NVARCHAR(100) NOT NULL,
    CategorieID   INT NOT NULL,
    PrixUnitaire  DECIMAL(10,2) NOT NULL CONSTRAINT CK_Produits_Prix CHECK (PrixUnitaire > 0),
    Stock         INT NOT NULL
                  CONSTRAINT DF_Produits_Stock DEFAULT (0)
                  CONSTRAINT CK_Produits_Stock CHECK (Stock >= 0),
    CONSTRAINT FK_Produits_Categories
        FOREIGN KEY (CategorieID) REFERENCES Categories(CategorieID)
);

-- Clients
CREATE TABLE Clients (
    ClientID        INT IDENTITY(1,1) CONSTRAINT PK_Clients PRIMARY KEY,
    Nom             NVARCHAR(50)  NOT NULL,
    Prenom          NVARCHAR(50)  NOT NULL,
    Email           NVARCHAR(255) NOT NULL CONSTRAINT UQ_Clients_Email UNIQUE,
    Ville           NVARCHAR(100) NULL,
    DateInscription DATE NOT NULL
                    CONSTRAINT DF_Clients_DateInsc DEFAULT (CAST(SYSDATETIME() AS DATE))
);

-- Employés (hiérarchie via ManagerID -> auto-référence)
CREATE TABLE Employes (
    EmployeID    INT IDENTITY(1,1) CONSTRAINT PK_Employes PRIMARY KEY,
    Nom          NVARCHAR(50) NOT NULL,
    Prenom       NVARCHAR(50) NOT NULL,
    Fonction     NVARCHAR(60) NULL,
    Service      NVARCHAR(50) NULL,
    ManagerID    INT NULL,
    DateEmbauche DATE NOT NULL,
    Salaire      DECIMAL(10,2) NULL CONSTRAINT CK_Employes_Salaire CHECK (Salaire > 0),
    CONSTRAINT FK_Employes_Manager
        FOREIGN KEY (ManagerID) REFERENCES Employes(EmployeID)
);

-- Commandes
CREATE TABLE Commandes (
    CommandeID   INT IDENTITY(1,1) CONSTRAINT PK_Commandes PRIMARY KEY,
    ClientID     INT NOT NULL,
    EmployeID    INT NULL,
    DateCommande DATETIME2 NOT NULL CONSTRAINT DF_Commandes_Date DEFAULT (SYSDATETIME()),
    Statut       NVARCHAR(20) NOT NULL
                 CONSTRAINT DF_Commandes_Statut DEFAULT (N'En attente')
                 CONSTRAINT CK_Commandes_Statut
                     CHECK (Statut IN (N'En attente', N'Validée', N'Expédiée', N'Livrée', N'Annulée')),
    CONSTRAINT FK_Commandes_Clients  FOREIGN KEY (ClientID)  REFERENCES Clients(ClientID),
    CONSTRAINT FK_Commandes_Employes FOREIGN KEY (EmployeID) REFERENCES Employes(EmployeID)
);

-- Lignes de commande (table de jonction Commandes <-> Produits)
CREATE TABLE LignesCommande (
    LigneCommandeID INT IDENTITY(1,1) CONSTRAINT PK_LignesCommande PRIMARY KEY,
    CommandeID      INT NOT NULL,
    ProduitID       INT NOT NULL,
    Quantite        INT NOT NULL CONSTRAINT CK_Lignes_Quantite CHECK (Quantite > 0),
    PrixUnitaire    DECIMAL(10,2) NOT NULL,  -- prix au moment de la commande
    CONSTRAINT FK_Lignes_Commandes FOREIGN KEY (CommandeID) REFERENCES Commandes(CommandeID),
    CONSTRAINT FK_Lignes_Produits  FOREIGN KEY (ProduitID)  REFERENCES Produits(ProduitID),
    CONSTRAINT UQ_Lignes_CommandeProduit UNIQUE (CommandeID, ProduitID)
);
GO

------------------------------------------------------------------------------
-- 2. Insertion des données
------------------------------------------------------------------------------

-- 2.1 Catégories (IDs 1 à 5)
INSERT INTO Categories (NomCategorie) VALUES
(N'Informatique'),
(N'Papeterie'),
(N'Mobilier'),
(N'Accessoires'),
(N'Logiciels');

-- 2.2 Produits
INSERT INTO Produits (NomProduit, CategorieID, PrixUnitaire, Stock) VALUES
(N'Ordinateur portable 14"',     1, 899.00, 25),
(N'Écran 27" 4K',                1, 349.90, 40),
(N'Souris sans fil',             1,  19.90, 150),
(N'Clavier mécanique',           1,  79.90, 80),
(N'Casque audio',                4,  59.90, 60),
(N'Webcam HD',                   1,  44.90, 35),
(N'Cahier A4 (lot de 5)',        2,  12.50, 300),
(N'Stylo bille (boîte de 50)',   2,  18.00, 200),
(N'Classeur à levier',           2,   4.90, 120),
(N'Chaise de bureau ergonomique',3, 189.00, 15),
(N'Bureau réglable',             3, 399.00,  8),
(N'Lampe de bureau LED',         3,  29.90, 50),
(N'Sac à dos pour ordinateur',   4,  49.90, 70),
(N'Suite bureautique (licence)', 5, 149.00, 999),
(N'Antivirus (licence 1 an)',    5,  39.90, 999);

-- 2.3 Clients
INSERT INTO Clients (Nom, Prenom, Email, Ville, DateInscription) VALUES
(N'Dupont',  N'Jean',     N'jean.dupont@email.fr',     N'Paris',     '2023-01-15'),
(N'Martin',  N'Marie',    N'marie.martin@email.fr',    N'Lyon',      '2023-02-20'),
(N'Bernard', N'Luc',      N'luc.bernard@email.fr',     N'Marseille', '2023-03-05'),
(N'Petit',   N'Sophie',   N'sophie.petit@email.fr',    N'Lille',     '2023-05-12'),
(N'Durand',  N'Thomas',   N'thomas.durand@email.fr',   N'Toulouse',  '2023-06-30'),
(N'Moreau',  N'Julie',    N'julie.moreau@email.fr',    N'Nantes',    '2024-01-08'),
(N'Laurent', N'Pierre',   N'pierre.laurent@email.fr',  N'Paris',     '2024-02-14'),
(N'Simon',   N'Emma',     N'emma.simon@email.fr',      N'Bordeaux',  '2024-04-22'),
(N'Michel',  N'Hugo',     N'hugo.michel@email.fr',     N'Lyon',      '2024-09-03'),
(N'Garcia',  N'Camille',  N'camille.garcia@email.fr',  N'Nice',      '2025-01-19');

-- 2.4 Employés (hiérarchie : on insère par niveau pour maîtriser les ManagerID)
-- Niveau 1 : direction (EmployeID = 1)
INSERT INTO Employes (Nom, Prenom, Fonction, Service, ManagerID, DateEmbauche, Salaire) VALUES
(N'Roussel', N'Sophie', N'Directrice Générale', N'Direction', NULL, '2015-03-01', 8500.00);

-- Niveau 2 : responsables (ManagerID = 1) -> EmployeID 2 et 3
INSERT INTO Employes (Nom, Prenom, Fonction, Service, ManagerID, DateEmbauche, Salaire) VALUES
(N'Faure',   N'Marc',  N'Responsable Ventes',     N'Ventes',     1, '2016-06-15', 5200.00),
(N'Girard',  N'Julie', N'Responsable Logistique', N'Logistique', 1, '2017-01-10', 5000.00);

-- Niveau 3 : équipes (ManagerID = 2 pour Ventes, 3 pour Logistique)
INSERT INTO Employes (Nom, Prenom, Fonction, Service, ManagerID, DateEmbauche, Salaire) VALUES
(N'Lambert', N'Lucas',  N'Commercial',         N'Ventes',     2, '2019-09-01', 3200.00),
(N'Mercier', N'Léa',    N'Commerciale',        N'Ventes',     2, '2020-11-15', 3100.00),
(N'Blanc',   N'Nicolas',N'Préparateur',        N'Logistique', 3, '2021-02-01', 2600.00),
(N'Henry',   N'Chloé',  N'Magasinière',        N'Logistique', 3, '2022-07-20', 2550.00);

-- 2.5 Commandes (ClientID 1-10, EmployeID commerciaux = 2,4,5)
INSERT INTO Commandes (ClientID, EmployeID, DateCommande, Statut) VALUES
(1,  4, '2025-01-10T10:30:00', N'Livrée'),
(2,  5, '2025-01-12T14:15:00', N'Livrée'),
(1,  4, '2025-02-03T09:00:00', N'Expédiée'),
(3,  4, '2025-02-18T16:45:00', N'Livrée'),
(4,  5, '2025-03-01T11:20:00', N'Validée'),
(5,  4, '2025-03-15T13:10:00', N'Livrée'),
(2,  5, '2025-04-02T10:05:00', N'Annulée'),
(6,  4, '2025-04-20T15:30:00', N'Expédiée'),
(7,  5, '2025-05-05T09:45:00', N'Validée'),
(8,  4, '2025-05-21T17:00:00', N'En attente'),
(1,  5, '2025-06-01T08:30:00', N'En attente'),
(9,  4, '2025-06-10T12:00:00', N'Validée');

-- 2.6 Lignes de commande (CommandeID 1-12, ProduitID 1-15)
INSERT INTO LignesCommande (CommandeID, ProduitID, Quantite, PrixUnitaire) VALUES
(1,  1, 1, 899.00), (1,  3, 2,  19.90), (1,  4, 1,  79.90),
(2,  7, 3,  12.50), (2,  8, 1,  18.00),
(3,  2, 2, 349.90), (3,  5, 1,  59.90),
(4, 10, 1, 189.00), (4, 12, 2,  29.90),
(5, 14, 5, 149.00),
(6,  1, 1, 899.00), (6, 13, 1,  49.90),
(7,  6, 1,  44.90),
(8, 11, 1, 399.00), (8, 10, 1, 189.00),
(9,  3, 4,  19.90), (9,  4, 2,  79.90), (9,  8, 1,  18.00),
(10, 15, 3,  39.90),
(11, 7, 10, 12.50), (11, 9, 20,  4.90),
(12, 2, 1, 349.90), (12, 5, 2,  59.90), (12, 13, 1, 49.90);
GO

------------------------------------------------------------------------------
-- 3. Vérification rapide
------------------------------------------------------------------------------
SELECT 'Categories'     AS Table_, COUNT(*) AS Lignes FROM Categories
UNION ALL SELECT 'Produits',       COUNT(*) FROM Produits
UNION ALL SELECT 'Clients',        COUNT(*) FROM Clients
UNION ALL SELECT 'Employes',       COUNT(*) FROM Employes
UNION ALL SELECT 'Commandes',      COUNT(*) FROM Commandes
UNION ALL SELECT 'LignesCommande', COUNT(*) FROM LignesCommande;
GO

PRINT N'Base "Boutique" créée et peuplée avec succès.';
GO
