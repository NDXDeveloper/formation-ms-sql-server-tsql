🔝 Retour au [Sommaire](/SOMMAIRE.md)

# Annexe F — Mots-clés réservés et conventions de nommage

> Deux sujets pour écrire un code propre et durable : éviter les **mots réservés** comme noms d'objets, et adopter des **conventions de nommage** cohérentes.

---

## Partie 1 — Les mots-clés réservés

### Pourquoi s'en préoccuper ?

T-SQL réserve plusieurs centaines de mots-clés (`SELECT`, `TABLE`, `USER`, `ORDER`…). Nommer une colonne ou une table avec l'un d'eux provoque des erreurs ou oblige à des contournements disgracieux.

```sql
-- ❌ Problématique : "Order" et "User" sont des mots réservés
CREATE TABLE Order (User INT, Date DATE);   -- erreur de syntaxe

-- ⚠️ Contournement possible avec des crochets (mais à éviter à la source)
CREATE TABLE [Order] ([User] INT, [Date] DATE);
```

> 💡 **La bonne pratique n'est pas d'échapper avec `[ ]`, mais d'éviter les mots réservés** dès le nommage : `Commandes` au lieu de `[Order]`, `Utilisateurs` au lieu de `[User]`, `DateCommande` au lieu de `[Date]`.

### Échappement par crochets

Quand on doit référencer un identifiant contenant un mot réservé, un espace ou un caractère spécial, on l'entoure de **crochets** `[ ]` (standard SQL Server) :

```sql
SELECT [User], [Order Date] FROM [Order Details];
```

### Mots réservés fréquents (échantillon)

Voici les plus courants à **ne pas** utiliser comme noms d'objets :

```
ADD ALL ALTER AND AS ASC AUTHORIZATION BACKUP BEGIN BETWEEN BREAK BROWSE BULK
BY CASCADE CASE CHECK CLOSE COLUMN COMMIT CONSTRAINT CONTAINS CONTINUE CREATE
CURRENT CURSOR DATABASE DEFAULT DELETE DENY DESC DISTINCT DROP ELSE END EXEC
EXECUTE EXISTS FETCH FILE FOR FOREIGN FROM FULL FUNCTION GRANT GROUP HAVING
IDENTITY IF IN INDEX INNER INSERT INTO IS JOIN KEY LEFT LIKE NULL OF ON OPEN
OPTION OR ORDER OUTER PRIMARY PROCEDURE PUBLIC READ REFERENCES RETURN REVOKE
RIGHT ROLLBACK ROWCOUNT SAVE SCHEMA SELECT SET TABLE THEN TO TOP TRANSACTION
TRIGGER TRUNCATE UNION UNIQUE UPDATE USER VALUES VIEW WHEN WHERE WHILE WITH
```

> 📚 La liste complète et à jour est dans la documentation Microsoft Learn (« Reserved Keywords - Transact-SQL »). Il existe aussi des mots-clés réservés **ODBC** et de **futures versions** à éviter par prudence.

### Le cas spécial du préfixe `sp_`

⚠️ **Ne préfixez jamais vos procédures par `sp_`** : ce préfixe est réservé aux procédures **système**. SQL Server cherche d'abord dans la base `master`, ce qui nuit aux performances et peut créer des conflits. Utilisez `usp_` (user stored procedure) à la place.

---

## Partie 2 — Conventions de nommage recommandées

Les conventions ne sont pas « obligatoires », mais une **cohérence** dans tout le projet rend le code lisible et maintenable. Voici un ensemble répandu et solide.

### Règles générales

- ✅ Noms **explicites** et en **un seul mot composé** (pas d'espaces) : `DateCommande`, pas `[Date Commande]`.
- ✅ **PascalCase** (`ClientID`, `LignesCommande`) — convention fréquente côté SQL Server. (Le `snake_case` est aussi valable si appliqué partout.)
- ✅ **Éviter les accents** et caractères spéciaux dans les **noms d'objets** (les *données*, elles, peuvent en contenir).
- ✅ **Cohérence avant tout** : choisissez une convention et tenez-vous-y dans tout le projet.
- ❌ Éviter les abréviations obscures (`cmd_dt` → préférez `DateCommande`).

### Tableau des conventions

| Objet | Convention | Exemple |
|-------|------------|---------|
| **Table** | PascalCase, nom métier clair | `Clients`, `LignesCommande` |
| **Colonne** | PascalCase | `NomProduit`, `PrixUnitaire` |
| **Clé primaire (colonne)** | `TableID` ou `Id` | `ClientID` |
| **Clé étrangère (colonne)** | nom de la PK référencée | `ClientID` dans `Commandes` |
| **Contrainte PK** | `PK_Table` | `PK_Clients` |
| **Contrainte FK** | `FK_Table_TableRef` | `FK_Commandes_Clients` |
| **Contrainte UNIQUE** | `UQ_Table_Colonne` | `UQ_Clients_Email` |
| **Contrainte CHECK** | `CK_Table_Regle` | `CK_Produits_Prix` |
| **Contrainte DEFAULT** | `DF_Table_Colonne` | `DF_Commandes_Statut` |
| **Index** | `IX_Table_Colonnes` | `IX_Commandes_ClientID` |
| **Vue** | `v_` ou `vw_` | `v_DetailCommandes` |
| **Procédure** | `usp_` | `usp_CommandesParClient` |
| **Fonction** | `fn_` | `fn_MontantLigne` |
| **Trigger** | `trg_` | `trg_MajStock` |

> 💡 Nommer **explicitement** les contraintes (au lieu de laisser SQL Server générer `PK__Clients__3214EC...`) facilite leur identification dans les messages d'erreur et leur suppression ultérieure.

### Tables : singulier ou pluriel ?

Débat éternel sans réponse universelle :
- **Pluriel** (`Clients`, `Produits`) : « la table contient plusieurs clients ». Très répandu.
- **Singulier** (`Client`, `Produit`) : « chaque ligne est un client ». Aussi défendable.

➡️ Peu importe le camp choisi : **soyez cohérent** dans toute la base. (Ce cours utilise le **pluriel**.)

### Schémas

Regroupez les objets par domaine fonctionnel via des **schémas** (§1.4.2 du cours) plutôt que des préfixes dans les noms :

```sql
-- ✅ Bon : usage des schémas
SELECT * FROM Ventes.Commandes;
SELECT * FROM RH.Employes;

-- ❌ Moins bon : préfixe dans le nom
SELECT * FROM Ventes_Commandes;
```

---

## Exemple cohérent (récapitulatif)

```sql
CREATE TABLE Ventes.Commandes (
    CommandeID   INT IDENTITY CONSTRAINT PK_Commandes PRIMARY KEY,
    ClientID     INT NOT NULL,
    DateCommande DATETIME2 NOT NULL CONSTRAINT DF_Commandes_Date DEFAULT SYSDATETIME(),
    Statut       NVARCHAR(20) NOT NULL
                 CONSTRAINT CK_Commandes_Statut CHECK (Statut IN (N'Ouverte', N'Close')),
    CONSTRAINT FK_Commandes_Clients FOREIGN KEY (ClientID) REFERENCES Ventes.Clients(ClientID)
);

CREATE NONCLUSTERED INDEX IX_Commandes_ClientID ON Ventes.Commandes (ClientID);
```

Tout est nommé de façon **prévisible** : un lecteur sait immédiatement ce que `FK_Commandes_Clients` ou `IX_Commandes_ClientID` représentent.

---

## Résumé

- **Évitez les mots réservés** comme noms d'objets ; au besoin, échappez avec `[ ]`, mais mieux vaut renommer.
- **Jamais** de préfixe `sp_` pour vos procédures (réservé système) → utilisez `usp_`.
- Adoptez des **conventions cohérentes** : PascalCase, préfixes de contraintes (`PK_`, `FK_`, `UQ_`, `CK_`, `DF_`), d'index (`IX_`), d'objets programmables (`v_`, `usp_`, `fn_`, `trg_`).
- **Nommez explicitement** vos contraintes et index.
- La **cohérence** dans tout le projet prime sur le choix précis de la convention.

---

⏭️ [Annexe G — Glossaire](/09-annexes/G-glossaire.md)
