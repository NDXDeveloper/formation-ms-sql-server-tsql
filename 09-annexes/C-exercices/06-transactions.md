🔝 Retour au [Sommaire](/SOMMAIRE.md)

# C.6 — Exercices du chapitre 6 : Transactions et concurrence

Transactions, propriétés ACID, points de sauvegarde et niveaux d'isolation, sur la base `Boutique`.

---

## Exercice 6.1 ⭐ — Transaction validée

📝 **Énoncé** : Dans une transaction, augmentez le stock du produit 1 de 10 unités, puis validez.

✅ **Corrigé** :
```sql
BEGIN TRANSACTION;
    UPDATE Produits SET Stock = Stock + 10 WHERE ProduitID = 1;
COMMIT TRANSACTION;
```

🧠 **Explication** : `BEGIN TRANSACTION` ouvre la transaction, `COMMIT` rend les modifications **définitives et durables** (voir §6.2).

---

## Exercice 6.2 ⭐⭐ — ROLLBACK

📝 **Énoncé** : Démarrez une transaction, supprimez tous les clients, **constatez** l'effet avec un `SELECT`, puis **annulez** tout.

✅ **Corrigé** :
```sql
BEGIN TRANSACTION;
    DELETE FROM Clients;
    SELECT COUNT(*) AS ClientsRestants FROM Clients;  -- 0 (dans la transaction)
ROLLBACK TRANSACTION;
SELECT COUNT(*) AS ClientsApresRollback FROM Clients; -- de nouveau 10
```

🧠 **Explication** : `ROLLBACK` annule toutes les modifications depuis `BEGIN TRANSACTION` — illustration de l'**Atomicité** (tout ou rien). *(Note : la suppression échouerait en réalité à cause des FK ; exécutez ce schéma sur une table sans dépendance pour voir le rollback.)*

---

## Exercice 6.3 ⭐⭐⭐ — Atomicité d'une opération métier

📝 **Énoncé** : Écrivez une transaction qui, pour la commande n°5, crée une ligne (produit 3, quantité 2) **et** décrémente le stock correspondant. Les deux doivent réussir ou échouer **ensemble**.

✅ **Corrigé** :
```sql
BEGIN TRY
    BEGIN TRANSACTION;
        INSERT INTO LignesCommande (CommandeID, ProduitID, Quantite, PrixUnitaire)
        VALUES (5, 3, 2, 19.90);

        UPDATE Produits SET Stock = Stock - 2 WHERE ProduitID = 3;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'Échec : ' + ERROR_MESSAGE();
END CATCH;
```

🧠 **Explication** : c'est le **pattern robuste** : `TRY/CATCH` + transaction. Si une instruction échoue, le `CATCH` annule tout. `@@TRANCOUNT > 0` vérifie qu'une transaction est bien ouverte avant le `ROLLBACK`. Voir §6.2 et §5.3.

---

## Exercice 6.4 ⭐⭐⭐ — Point de sauvegarde (SAVE TRANSACTION)

📝 **Énoncé** : Dans une transaction, faites deux mises à jour, mais annulez **seulement la seconde** grâce à un point de sauvegarde.

✅ **Corrigé** :
```sql
BEGIN TRANSACTION;
    UPDATE Produits SET Stock = Stock + 5 WHERE ProduitID = 1;  -- conservée

    SAVE TRANSACTION pt1;
    UPDATE Produits SET Stock = Stock + 999 WHERE ProduitID = 2; -- à annuler
    ROLLBACK TRANSACTION pt1;   -- annule jusqu'au point de sauvegarde

COMMIT TRANSACTION;             -- valide la 1re mise à jour seulement
```

🧠 **Explication** : `SAVE TRANSACTION` crée un point intermédiaire ; `ROLLBACK TRANSACTION nom` n'annule que jusqu'à ce point, pas toute la transaction (voir §6.2.4).

---

## Exercice 6.5 ⭐⭐ — Comprendre ACID

📝 **Énoncé** : Associez chaque situation à la propriété ACID concernée :

a) Un virement débite un compte et crédite l'autre ; jamais l'un sans l'autre.  
b) Après un `COMMIT`, une coupure de courant ne fait pas perdre les données.  
c) Deux transactions simultanées ne se marchent pas dessus.  
d) Une transaction ne peut pas laisser la base dans un état violant les contraintes.  

✅ **Corrigé** :
- a) **Atomicité**
- b) **Durabilité**
- c) **Isolation**
- d) **Cohérence**

🧠 **Explication** : ACID = **A**tomicité, **C**ohérence, **I**solation, **D**urabilité (voir §6.1.2).

---

## Exercice 6.6 ⭐⭐⭐ — Niveaux d'isolation (conceptuel)

📝 **Énoncé** : Une transaction lit deux fois la même ligne et obtient deux valeurs différentes (une autre transaction l'a modifiée entre-temps). De quel phénomène s'agit-il ? Quel niveau d'isolation l'empêche ?

✅ **Corrigé** :
- Phénomène : **lecture non répétable** (*non-repeatable read*).
- Niveau qui l'empêche : **REPEATABLE READ** (et au-dessus : SERIALIZABLE, SNAPSHOT).

🧠 **Explication** : chaque niveau d'isolation représente un compromis entre cohérence et concurrence. `READ COMMITTED` (défaut) autorise les lectures non répétables ; `REPEATABLE READ` les empêche. Voir §6.3.1 et §6.4.

---

## Exercice 6.7 ⭐⭐⭐ — Deadlock (conceptuel)

📝 **Énoncé** : Décrivez un scénario simple de **deadlock** (interblocage) entre deux transactions, et indiquez comment SQL Server le résout.

✅ **Corrigé** :
- Transaction A verrouille la ligne 1 puis demande la ligne 2 ; transaction B verrouille la ligne 2 puis demande la ligne 1. Chacune attend l'autre indéfiniment.
- SQL Server **détecte** le cycle et choisit une **victime** (généralement la transaction la moins coûteuse à annuler), qu'il annule (erreur 1205). L'application doit alors **réessayer**.

🧠 **Explication** : pour limiter les deadlocks, on accède aux ressources **dans le même ordre** partout, on garde les transactions **courtes**, et on prévoit une logique de **retry**. Voir §6.3.3.

---

⏭️ [C.7 — Exercices du chapitre 7](/09-annexes/C-exercices/07-performance.md)
