🔝 Retour au [Sommaire](/SOMMAIRE.md)

# C.8 — Exercices du chapitre 8 : Sujets complémentaires

JSON, XML, tables temporelles, columnstore et sécurité (DCL), sur la base `Boutique`.

---

## Exercice 8.1 ⭐⭐ — Générer du JSON (FOR JSON)

📝 **Énoncé** : Renvoyez la liste des catégories au format JSON.

✅ **Corrigé** :
```sql
SELECT CategorieID, NomCategorie
FROM Categories
FOR JSON PATH;
```

🧠 **Explication** : `FOR JSON PATH` transforme un résultat tabulaire en tableau JSON. `FOR JSON AUTO` structure selon les jointures (voir §8.2.4).

---

## Exercice 8.2 ⭐⭐ — Extraire d'un JSON (JSON_VALUE)

📝 **Énoncé** : Soit la variable JSON ci-dessous. Extrayez la ville.

```sql
DECLARE @j NVARCHAR(200) = N'{ "client": "Dupont", "ville": "Paris" }';
```

✅ **Corrigé** :
```sql
SELECT JSON_VALUE(@j, '$.ville') AS Ville;   -- 'Paris'
```

🧠 **Explication** : `JSON_VALUE` extrait une **valeur scalaire** via un chemin (`$.propriété`). Pour un objet/tableau, on utilise `JSON_QUERY`. Voir §8.2.2.

---

## Exercice 8.3 ⭐⭐⭐ — OPENJSON

📝 **Énoncé** : Transformez ce tableau JSON en table (lignes).

```sql
DECLARE @produits NVARCHAR(MAX) = N'[{"nom":"Stylo","prix":2.5},{"nom":"Cahier","prix":4.0}]';
```

✅ **Corrigé** :
```sql
SELECT *
FROM OPENJSON(@produits)
WITH (
    nom  NVARCHAR(50) '$.nom',
    prix DECIMAL(10,2) '$.prix'
);
```

🧠 **Explication** : `OPENJSON ... WITH (...)` projette un JSON en table relationnelle typée — l'inverse de `FOR JSON`. Voir §8.2.3.

---

## Exercice 8.4 ⭐⭐ — Générer du XML (FOR XML)

📝 **Énoncé** : Renvoyez les produits de la catégorie 1 au format XML.

✅ **Corrigé** :
```sql
SELECT ProduitID, NomProduit, PrixUnitaire
FROM Produits
WHERE CategorieID = 1
FOR XML PATH('Produit'), ROOT('Produits');
```

🧠 **Explication** : `FOR XML PATH(...)` contrôle le nom des éléments, `ROOT(...)` ajoute un élément racine. Voir §8.1.3.

---

## Exercice 8.5 ⭐⭐⭐ — Table temporelle (conceptuel + requête)

📝 **Énoncé** : Une table `Produits` est *system-versioned*. Comment récupérer l'état des produits **tel qu'il était le 1ᵉʳ janvier 2025** ?

✅ **Corrigé** :
```sql
SELECT *
FROM Produits
FOR SYSTEM_TIME AS OF '2025-01-01T00:00:00';
```

🧠 **Explication** : `FOR SYSTEM_TIME AS OF` interroge l'historique automatiquement conservé par une table temporelle — sans restauration de sauvegarde. Voir §8.3.3.

---

## Exercice 8.6 ⭐⭐ — Index columnstore

📝 **Énoncé** : `LignesCommande` deviendra une grosse table de faits analytique. Quel type d'index columnstore créer si on veut conserver l'usage OLTP, et comment ?

✅ **Corrigé** :
```sql
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_Lignes
ON LignesCommande (CommandeID, ProduitID, Quantite, PrixUnitaire);
```

🧠 **Explication** : un index columnstore **non-cluster** (NCCI) ajoute une vue analytique tout en gardant la table rowstore pour l'OLTP (approche HTAP). Voir §8.7.2.

---

## Exercice 8.7 ⭐⭐ — Sécurité : GRANT / DENY / REVOKE

📝 **Énoncé** :
a) Autorisez l'utilisateur `analyste` à lire la table `Produits`.  
b) Interdisez-lui explicitement la suppression.  
c) Retirez l'autorisation de lecture donnée en (a).  

✅ **Corrigé** :
```sql
GRANT SELECT ON Produits TO analyste;     -- a)
DENY DELETE ON Produits TO analyste;      -- b)
REVOKE SELECT ON Produits FROM analyste;  -- c)
```

🧠 **Explication** : `GRANT` autorise, `DENY` interdit (priorité absolue), `REVOKE` retire une autorisation/interdiction existante. Voir §8.4.2 à §8.4.4.

---

## Exercice 8.8 ⭐⭐⭐ — Rôle de base de données

📝 **Énoncé** : Créez un rôle `lecteurs_catalogue` ayant le droit de lire `Produits` et `Categories`, puis ajoutez-y l'utilisateur `analyste`.

✅ **Corrigé** :
```sql
CREATE ROLE lecteurs_catalogue;
GRANT SELECT ON Produits   TO lecteurs_catalogue;
GRANT SELECT ON Categories TO lecteurs_catalogue;
ALTER ROLE lecteurs_catalogue ADD MEMBER analyste;
```

🧠 **Explication** : les **rôles** regroupent des permissions et simplifient la gestion : on gère les droits au niveau du rôle, pas de chaque utilisateur. Voir §8.4.1.

---

## Bravo !

Vous avez parcouru les exercices des 8 chapitres. Pour consolider, reprenez les défis ⭐⭐⭐ sans regarder les corrigés, et inventez vos propres questions sur la base `Boutique`. La maîtrise vient de la **répétition active**.

---

⏭️ [Annexe D — Aide-mémoire T-SQL](/09-annexes/D-aide-memoire-tsql.md)
