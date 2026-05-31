🔝 Retour au [Sommaire](/SOMMAIRE.md)

# Annexe E — Tableau récapitulatif des types de données

> Référence rapide des types de données T-SQL : plages, tailles, précision et conseils de choix. Complète le §2.1 du cours.

---

## Types numériques entiers

| Type | Taille | Plage | Usage |
|------|:------:|-------|-------|
| `BIT` | 1 bit* | 0, 1 ou NULL | Booléen (vrai/faux) |
| `TINYINT` | 1 octet | 0 à 255 | Petits entiers **positifs** |
| `SMALLINT` | 2 octets | −32 768 à 32 767 | Petits entiers |
| `INT` | 4 octets | ≈ −2,1 à +2,1 milliards | **Le choix par défaut** |
| `BIGINT` | 8 octets | ≈ ±9,2 × 10¹⁸ | Très grands entiers (identifiants massifs) |

\* Les colonnes `BIT` sont regroupées : 8 colonnes BIT tiennent dans 1 octet.

> 💡 `INT` couvre la grande majorité des besoins (clés, compteurs). Passez à `BIGINT` seulement si vous dépassez ~2 milliards de lignes/valeurs.

---

## Types numériques décimaux exacts

| Type | Taille | Plage / précision | Usage |
|------|:------:|-------------------|-------|
| `DECIMAL(p, s)` | 5 à 17 octets | précision `p` (1–38), `s` décimales | **Montants, valeurs exactes** |
| `NUMERIC(p, s)` | idem | identique à `DECIMAL` | Synonyme de `DECIMAL` |
| `MONEY` | 8 octets | ±922 337 203 685 477.5807 | Monétaire (4 décimales fixes) |
| `SMALLMONEY` | 4 octets | ±214 748.3647 | Monétaire (petits montants) |

- `p` (**précision**) = nombre **total** de chiffres ; `s` (**échelle**) = chiffres **après** la virgule.
- Ex. `DECIMAL(10,2)` : jusqu'à 99 999 999.99.

> 💡 **Pour l'argent, utilisez `DECIMAL`** (ex. `DECIMAL(12,2)`) plutôt que `MONEY` (arrondis plus contrôlés) et **jamais `FLOAT`** (imprécis).

---

## Types numériques à virgule flottante (approchés)

| Type | Taille | Précision | Usage |
|------|:------:|-----------|-------|
| `REAL` | 4 octets | ~7 chiffres | Scientifique, tolérant à l'imprécision |
| `FLOAT(n)` | 4 ou 8 octets | n≤24 → ~7 ; n 25–53 → ~15 | Scientifique |

> ⚠️ `FLOAT`/`REAL` sont **approchés** : `0.1 + 0.2 ≠ 0.3` exactement. Ne **jamais** les utiliser pour des montants ou des comparaisons d'égalité.

---

## Types chaînes de caractères

| Type | Taille | Max | Unicode ? |
|------|:------:|-----|:---------:|
| `CHAR(n)` | n octets (fixe) | 8 000 | Non |
| `VARCHAR(n)` | longueur + 2 octets | 8 000 | Non |
| `VARCHAR(MAX)` | variable | ~2 Go | Non |
| `NCHAR(n)` | 2×n octets (fixe) | 4 000 | **Oui** |
| `NVARCHAR(n)` | 2×longueur + 2 | 4 000 | **Oui** |
| `NVARCHAR(MAX)` | variable | ~2 Go | **Oui** |

- **Fixe (`CHAR`/`NCHAR`)** : complète avec des espaces ; bon pour des longueurs constantes (codes pays `CHAR(2)`).
- **Variable (`VARCHAR`/`NVARCHAR`)** : ne stocke que ce qui est saisi ; le choix par défaut.
- **`N`** = Unicode (UTF-16) : indispensable pour l'**international** (accents, alphabets non latins, emojis).

> 💡 **Préférez `NVARCHAR`** pour tout texte « humain » multilingue. Préfixez les littéraux Unicode d'un `N` : `N'café'`.  
> ⚠️ Les anciens types `TEXT` / `NTEXT` sont **dépréciés** → utilisez `VARCHAR(MAX)` / `NVARCHAR(MAX)`.

---

## Types date et heure

| Type | Taille | Plage | Précision | Fuseau ? |
|------|:------:|-------|-----------|:--------:|
| `DATE` | 3 octets | 0001-01-01 → 9999-12-31 | jour | Non |
| `TIME` | 3–5 octets | 00:00:00 → 23:59:59.9999999 | 100 ns | Non |
| `SMALLDATETIME` | 4 octets | 1900 → 2079 | minute | Non |
| `DATETIME` | 8 octets | 1753 → 9999 | ~3,33 ms | Non |
| `DATETIME2(n)` | 6–8 octets | 0001 → 9999 | jusqu'à 100 ns | Non |
| `DATETIMEOFFSET` | 8–10 octets | 0001 → 9999 | 100 ns | **Oui** |

> 💡 **Préférez `DATETIME2`** à l'ancien `DATETIME` : plage plus large, meilleure précision, même taille ou moindre. Utilisez `DATETIMEOFFSET` si le **fuseau horaire** compte.

---

## Types binaires

| Type | Taille | Max | Usage |
|------|:------:|-----|-------|
| `BINARY(n)` | n octets (fixe) | 8 000 | Données binaires de taille fixe |
| `VARBINARY(n)` | longueur + 2 | 8 000 | Données binaires variables |
| `VARBINARY(MAX)` | variable | ~2 Go | Fichiers, images, documents |

> ⚠️ `IMAGE` est **déprécié** → utilisez `VARBINARY(MAX)`. Pour de gros fichiers, envisagez `FILESTREAM`/`FileTable`.

---

## Autres types utiles

| Type | Taille | Description |
|------|:------:|-------------|
| `UNIQUEIDENTIFIER` | 16 octets | GUID (`NEWID()`, `NEWSEQUENTIALID()`) |
| `ROWVERSION` (`TIMESTAMP`) | 8 octets | Marqueur de version auto (concurrence optimiste) |
| `XML` | variable | Données XML natives (§8.1) |
| `SQL_VARIANT` | variable | Peut contenir plusieurs types (à éviter en général) |
| `HIERARCHYID` | variable | Représentation d'arborescences |
| `GEOGRAPHY` / `GEOMETRY` | variable | Données spatiales (§8.9) |

> 💡 **JSON** n'a pas de type dédié dans les versions classiques : on le stocke en `NVARCHAR(MAX)` avec la contrainte `ISJSON(col) = 1` (§8.2).

---

## Conseils de choix (mémo)

```
Entier             → INT (BIGINT si > 2 milliards)
Booléen            → BIT
Argent / exact     → DECIMAL(p, s)   (jamais FLOAT !)
Scientifique       → FLOAT
Texte humain       → NVARCHAR(n)     (préfixe N')
Code de longueur fixe → CHAR(n) / NCHAR(n)
Gros texte         → NVARCHAR(MAX)
Date seule         → DATE
Date + heure       → DATETIME2        (pas DATETIME)
Date + heure + fuseau → DATETIMEOFFSET
Fichier / binaire  → VARBINARY(MAX)
Identifiant global → UNIQUEIDENTIFIER
```

---

## Pièges fréquents

- ❌ Utiliser `FLOAT` pour des montants → erreurs d'arrondi.
- ❌ Oublier le `N'...'` pour des chaînes Unicode → caractères perdus (`?`).
- ❌ Surdimensionner (`NVARCHAR(4000)` pour un code postal) → gaspillage et mauvaises estimations de l'optimiseur.
- ❌ Stocker l'**âge** plutôt que la **date de naissance** → donnée qui se périme.
- ❌ Employer les types dépréciés `TEXT`/`NTEXT`/`IMAGE`.

---

⏭️ [Annexe F — Mots-clés réservés et conventions de nommage](/09-annexes/F-mots-cles-et-conventions.md)
