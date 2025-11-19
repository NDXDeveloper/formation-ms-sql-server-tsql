🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 8.2 Gestion des données JSON

## Introduction

Après avoir exploré la gestion des données XML dans la section précédente (8.1), nous allons maintenant nous concentrer sur **JSON** (JavaScript Object Notation), le format de données le plus populaire du web moderne.

Si le XML était le roi des échanges de données dans les années 2000, **JSON est devenu le standard de facto** pour les applications web, les APIs REST, et les services cloud depuis les années 2010. Sa simplicité, sa légèreté et sa compatibilité naturelle avec JavaScript en ont fait le choix privilégié des développeurs.

SQL Server, conscient de cette évolution, a introduit un **support complet pour JSON** à partir de la version **2016**. Cette section vous guidera à travers toutes les fonctionnalités JSON de SQL Server, de manière progressive et pratique.

## Qu'est-ce que JSON ?

### Définition

**JSON** signifie **JavaScript Object Notation** (Notation Objet JavaScript). C'est un format de données léger et facile à lire pour :
- **Stocker** des données structurées
- **Échanger** des informations entre systèmes
- **Transporter** des données sur le réseau

Bien que son nom fasse référence à JavaScript, JSON est **indépendant du langage** : pratiquement tous les langages de programmation modernes (Python, Java, C#, PHP, Ruby, Go, etc.) peuvent lire et écrire du JSON.

### Caractéristiques principales

| Caractéristique | Description |
|----------------|-------------|
| **Lisible** | Format texte simple, compréhensible par les humains |
| **Léger** | Moins verbeux que XML, donc plus compact |
| **Structuré** | Supporte hiérarchies, objets et tableaux |
| **Universel** | Supporté par tous les langages modernes |
| **Natif au web** | Format par défaut pour les APIs REST |
| **Sans schéma** | Flexible, pas de définition rigide requise |

### Exemple de JSON

Voici un exemple simple de données JSON représentant un client avec ses commandes :

```json
{
  "clientID": 12345,
  "nom": "Dupont",
  "email": "jean.dupont@example.com",
  "actif": true,
  "dateInscription": "2024-01-15",
  "adresse": {
    "rue": "10 rue de la Paix",
    "ville": "Paris",
    "codePostal": "75001"
  },
  "commandes": [
    {
      "numero": "CMD-001",
      "date": "2024-11-01",
      "montant": 250.00,
      "articles": 3
    },
    {
      "numero": "CMD-002",
      "date": "2024-11-15",
      "montant": 180.50,
      "articles": 2
    }
  ],
  "preferences": {
    "newsletter": true,
    "notifications": false
  }
}
```

**Observations** :
- Structure claire et **auto-descriptive**
- Supporte différents **types de données** (texte, nombres, booléens)
- Peut contenir des **objets imbriqués** (`adresse`, `preferences`)
- Peut contenir des **tableaux** (`commandes`)
- **Compact** : pas de balises fermantes comme en XML
- **Lisible** : facile à comprendre d'un coup d'œil

## Structure du JSON

Le JSON utilise deux structures principales :

### 1. Les objets (Object)

Un **objet** est une collection de **paires clé-valeur** délimitée par des accolades `{}` :

```json
{
  "clé1": "valeur1",
  "clé2": "valeur2",
  "clé3": "valeur3"
}
```

**Règles** :
- Les clés doivent être entre **guillemets doubles** `"clé"`
- Les clés et valeurs sont séparées par deux-points `:`
- Les paires sont séparées par des virgules `,`
- **Pas de virgule** après la dernière paire

**Analogie** : Un objet JSON est comme un dictionnaire ou un annuaire où chaque entrée a un nom (clé) et une information associée (valeur).

### 2. Les tableaux (Array)

Un **tableau** est une liste ordonnée de valeurs délimitée par des crochets `[]` :

```json
["valeur1", "valeur2", "valeur3"]
```

Ou un tableau d'objets :

```json
[
  {"nom": "Alice", "age": 30},
  {"nom": "Bob", "age": 25},
  {"nom": "Charlie", "age": 35}
]
```

**Règles** :
- Les valeurs sont séparées par des virgules `,`
- Les valeurs peuvent être de n'importe quel type JSON
- L'ordre des éléments est préservé

**Analogie** : Un tableau JSON est comme une liste de courses où chaque élément est ordonné.

### Types de valeurs JSON

JSON supporte **six types de valeurs** :

| Type | Exemple | Description |
|------|---------|-------------|
| **String (Chaîne)** | `"Hello"`, `"2024-11-18"` | Texte entre guillemets doubles |
| **Number (Nombre)** | `42`, `3.14`, `-10`, `2.5e3` | Entiers ou décimaux |
| **Boolean (Booléen)** | `true`, `false` | Valeurs logiques (minuscules) |
| **Null** | `null` | Absence de valeur (minuscule) |
| **Object (Objet)** | `{"key": "value"}` | Collection de paires clé-valeur |
| **Array (Tableau)** | `[1, 2, 3]` | Liste ordonnée de valeurs |

**Important** : Contrairement à JavaScript, JSON n'autorise PAS :
- Les guillemets simples `'texte'` (uniquement doubles `"texte"`)
- Les commentaires `// ou /* */`
- Les virgules finales `{"a": 1,}` ← erreur
- Les clés sans guillemets `{nom: "test"}` ← erreur

### Imbrication et hiérarchies

La vraie puissance de JSON vient de sa capacité à **imbriquer** des structures :

```json
{
  "entreprise": {
    "nom": "TechCorp",
    "adresse": {
      "rue": "123 Tech Avenue",
      "ville": "San Francisco",
      "pays": {
        "nom": "États-Unis",
        "code": "US"
      }
    },
    "employes": [
      {
        "nom": "Alice",
        "poste": "Développeur",
        "competences": ["Python", "SQL", "JavaScript"]
      },
      {
        "nom": "Bob",
        "poste": "Designer",
        "competences": ["Photoshop", "Figma"]
      }
    ]
  }
}
```

On peut avoir :
- Des objets dans des objets
- Des tableaux dans des objets
- Des objets dans des tableaux
- Des tableaux dans des tableaux
- ... à plusieurs niveaux de profondeur

## Pourquoi JSON est-il si populaire ?

### 1. Simplicité et lisibilité

**JSON est simple** :

```json
{"nom": "Alice", "age": 30}
```

Comparez avec l'équivalent XML :

```xml
<personne>
    <nom>Alice</nom>
    <age>30</age>
</personne>
```

JSON est plus compact (moins de caractères), plus rapide à écrire et plus facile à lire.

### 2. Compatibilité native avec JavaScript

JSON est **directement utilisable en JavaScript** sans parsing complexe :

```javascript
// JavaScript - conversion facile
const json = '{"nom": "Alice", "age": 30}';
const objet = JSON.parse(json);  // Conversion JSON → Objet
console.log(objet.nom);  // "Alice"

const nouveauJson = JSON.stringify(objet);  // Objet → JSON
```

Cette intégration naturelle fait de JSON le choix idéal pour les applications web.

### 3. Support universel

**Tous les langages modernes** ont des bibliothèques JSON intégrées ou facilement disponibles :

- **Python** : `json.loads()`, `json.dumps()`
- **C#/.NET** : `JsonSerializer`, `Newtonsoft.Json`
- **Java** : `Gson`, `Jackson`
- **PHP** : `json_encode()`, `json_decode()`
- **Ruby** : `JSON.parse()`, `JSON.generate()`
- **Go** : `json.Marshal()`, `json.Unmarshal()`

### 4. Standard pour les APIs REST

Les **APIs REST modernes** utilisent presque exclusivement JSON :

```
GET /api/clients/123
Response:
{
  "id": 123,
  "nom": "Dupont",
  "email": "dupont@example.com"
}

POST /api/commandes
Body:
{
  "clientID": 123,
  "articles": [
    {"code": "A001", "quantite": 2}
  ]
}
```

Si vous développez ou consommez des APIs, vous travaillez avec JSON.

### 5. Écosystème et outils

L'écosystème JSON est riche :
- **Éditeurs** : Visual Studio Code, Postman, JSON Formatter
- **Validateurs** : JSONLint, JSON Schema Validator
- **Documentation** : OpenAPI/Swagger (utilise JSON)
- **Bases de données** : MongoDB, PostgreSQL, SQL Server (support natif)

## JSON vs XML : Comparaison détaillée

Nous avons vu XML dans la section 8.1. Comparons-le avec JSON :

### Même données : XML vs JSON

**Version XML** :
```xml
<commande id="12345">
    <client>
        <nom>Dupont</nom>
        <email>dupont@example.com</email>
    </client>
    <articles>
        <article>
            <code>A001</code>
            <nom>Clavier</nom>
            <prix>79.99</prix>
        </article>
        <article>
            <code>A002</code>
            <nom>Souris</nom>
            <prix>29.99</prix>
        </article>
    </articles>
    <total>109.98</total>
</commande>
```

**Version JSON** :
```json
{
  "id": 12345,
  "client": {
    "nom": "Dupont",
    "email": "dupont@example.com"
  },
  "articles": [
    {"code": "A001", "nom": "Clavier", "prix": 79.99},
    {"code": "A002", "nom": "Souris", "prix": 29.99}
  ],
  "total": 109.98
}
```

### Tableau comparatif

| Aspect | XML | JSON |
|--------|-----|------|
| **Verbosité** | Très verbeux (balises fermantes) | Compact et concis |
| **Lisibilité** | Bonne mais chargée | Excellente |
| **Taille** | Plus volumineux (30-50% de plus) | Plus léger |
| **Parsing** | Plus lent | Plus rapide |
| **Types de données** | Tout est texte | Types natifs (nombre, booléen, null) |
| **Commentaires** | Supportés `<!-- -->` | Non supportés |
| **Attributs** | Oui `<tag attr="val">` | Non (seulement clé:valeur) |
| **Espaces de noms** | Oui | Non |
| **Schéma de validation** | XSD (mature, complexe) | JSON Schema (plus simple) |
| **Usage principal** | Documents, configurations legacy | APIs, web services, apps modernes |
| **Adoption web** | En déclin | Dominant |
| **Support navigateur** | Intégré (DOM) | Natif (JSON.parse/stringify) |
| **Cas d'usage typiques** | SOAP, RSS, fichiers Office, SVG | REST APIs, NoSQL, configs modernes |

### Quand utiliser XML vs JSON ?

**Utilisez XML quand** :
- Vous travaillez avec des **systèmes legacy** ou des standards existants (SOAP, RSS)
- Vous avez besoin de **validation stricte** avec XSD
- Vous gérez des **documents** complexes avec métadonnées
- Vous devez supporter des **commentaires** dans les données
- Vous travaillez avec des **espaces de noms** (namespaces)
- Les **attributs** sont importants pour votre structure

**Utilisez JSON quand** :
- Vous développez des **APIs REST modernes**
- Vous créez des **applications web/mobile**
- Vous avez besoin de **performance** et de **légèreté**
- Vous travaillez avec **JavaScript/Node.js**
- Vous voulez de la **simplicité**
- Vous échangez des données entre **microservices**

**En 2024** : JSON est le choix par défaut pour les nouveaux projets, sauf besoin spécifique.

## JSON dans le monde réel

### Cas d'usage courants

#### 1. APIs REST

```
GET https://api.example.com/utilisateurs/123

Response (JSON):
{
  "id": 123,
  "nom": "Alice Martin",
  "role": "admin",
  "permissions": ["read", "write", "delete"]
}
```

#### 2. Configuration d'applications

Fichier `config.json` :
```json
{
  "database": {
    "host": "localhost",
    "port": 5432,
    "name": "myapp_db"
  },
  "logging": {
    "level": "info",
    "file": "/var/log/app.log"
  }
}
```

#### 3. Stockage NoSQL

**MongoDB** stocke les documents en JSON (techniquement BSON) :
```json
{
  "_id": "507f1f77bcf86cd799439011",
  "nom": "Produit XYZ",
  "prix": 99.99,
  "tags": ["électronique", "gadget"],
  "stock": 42
}
```

#### 4. Échange de données

**Application mobile** ← JSON → **API Backend** ← JSON → **Base de données**

#### 5. Logs structurés

```json
{
  "timestamp": "2024-11-18T14:32:00Z",
  "level": "ERROR",
  "message": "Database connection failed",
  "details": {
    "host": "db.example.com",
    "port": 5432,
    "error": "Connection timeout"
  }
}
```

## JSON et SQL Server

### Historique du support JSON

| Version | Support JSON |
|---------|--------------|
| **SQL Server 2014 et antérieurs** | Aucun support natif |
| **SQL Server 2016** | Support complet introduit |
| **SQL Server 2017+** | Améliorations et optimisations |
| **SQL Server 2022** | Fonctions JSON supplémentaires |

### Pourquoi SQL Server supporte JSON ?

1. **Demande du marché** : Les développeurs veulent stocker et interroger du JSON
2. **APIs modernes** : Faciliter la création d'APIs REST avec SQL Server
3. **Intégration** : Échanger facilement des données avec des applications web
4. **Flexibilité** : Permettre des structures semi-structurées dans une base relationnelle
5. **Compétitivité** : PostgreSQL et MySQL avaient déjà un bon support JSON

### Approche de SQL Server pour JSON

**Différence fondamentale avec XML** :

- **XML** : Type de données dédié (`XML`)
- **JSON** : Stocké comme texte (`NVARCHAR`), avec des fonctions spécialisées

SQL Server traite JSON comme du **texte avec des fonctions spéciales**, plutôt que comme un type de données distinct. Cette approche est :
- ✅ Plus simple
- ✅ Plus flexible
- ✅ Plus performante pour le parsing
- ❌ Moins de validation automatique (mais ISJSON() existe)

### Les quatre piliers du JSON dans SQL Server

SQL Server offre des fonctionnalités dans quatre domaines :

#### 1. **Stockage** (Section 8.2.1)
- Stocker JSON dans des colonnes NVARCHAR
- Valider le JSON avec `ISJSON()`
- Contraintes pour garantir la validité

#### 2. **Interrogation** (Section 8.2.2)
- Extraire des valeurs avec `JSON_VALUE()`
- Extraire des objets/tableaux avec `JSON_QUERY()`
- Vérifier l'existence avec `ISJSON()`

#### 3. **Transformation** (Section 8.2.3)
- Convertir JSON en lignes avec `OPENJSON()`
- Créer des vues relationnelles sur du JSON
- Joindre des données JSON avec des tables

#### 4. **Génération** (Section 8.2.4)
- Créer du JSON depuis des tables avec `FOR JSON`
- Deux modes : AUTO (automatique) et PATH (contrôle total)
- Options pour personnaliser la structure

### Architecture JSON dans SQL Server

```
┌─────────────────────────────────────────────────────────────┐
│                    Application / API                        │
└───────────────────────────┬─────────────────────────────────┘
                            │
                    Envoie/Reçoit JSON
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                     SQL Server                              │
│                                                             │
│  ┌──────────────┐    ┌─────────────────┐                    │
│  │   Tables     │    │  Fonctions JSON │                    │
│  │              │◄───┤                 │                    │
│  │ ┌──────────┐ │    │ • ISJSON()      │                    │
│  │ │ Colonnes │ │    │ • JSON_VALUE()  │                    │
│  │ │ NVARCHAR │◄┼────┤ • JSON_QUERY()  │                    │
│  │ │   MAX    │ │    │ • OPENJSON()    │                    │
│  │ │          │ │    │ • FOR JSON      │                    │
│  │ │ {JSON}   │ │    └─────────────────┘                    │
│  │ └──────────┘ │                                           │
│  └──────────────┘                                           │
│                                                             │
│  ┌──────────────────────────────────────┐                   │
│  │   Colonnes calculées / Index         │                   │
│  │   (pour optimiser les performances)  │                   │
│  └──────────────────────────────────────┘                   │
└─────────────────────────────────────────────────────────────┘
```

## Approche hybride : Relationnel + JSON

SQL Server permet de combiner le **meilleur des deux mondes** :

### Exemple d'architecture hybride

```sql
-- Table avec colonnes relationnelles ET JSON
CREATE TABLE Produits (
    -- Colonnes relationnelles (données structurées, critiques)
    ProduitID INT PRIMARY KEY,
    Nom NVARCHAR(100) NOT NULL,
    Categorie NVARCHAR(50) NOT NULL,
    Prix DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL,
    DateCreation DATETIME DEFAULT GETDATE(),

    -- Colonne JSON (données semi-structurées, flexibles)
    AttributsJSON NVARCHAR(MAX),

    -- Contrainte pour valider le JSON
    CONSTRAINT CK_AttributsValides CHECK (
        AttributsJSON IS NULL OR
        ISJSON(AttributsJSON) = 1
    )
);
```

**Exemple de données** :

```sql
INSERT INTO Produits (Nom, Categorie, Prix, Stock, AttributsJSON) VALUES
('Ordinateur portable', 'Informatique', 899.99, 5, '{
    "marque": "Dell",
    "processeur": "Intel i7",
    "ram": "16GB",
    "ecran": "15.6 pouces",
    "ports": ["USB-C", "HDMI", "Ethernet"]
}'),

('T-shirt', 'Vêtements', 19.99, 100, '{
    "taille": ["S", "M", "L", "XL"],
    "couleur": ["Rouge", "Bleu", "Noir"],
    "matiere": "100% coton",
    "lavage": "30°C"
}');
```

**Avantages** :
- ✅ **Performance** : Colonnes relationnelles indexées pour recherches rapides
- ✅ **Flexibilité** : JSON pour attributs variables selon le type de produit
- ✅ **Intégrité** : Contraintes sur colonnes relationnelles
- ✅ **Évolutivité** : Ajouter de nouveaux attributs JSON sans ALTER TABLE

### Quand utiliser cette approche ?

**Colonnes relationnelles pour** :
- Identifiants et clés primaires
- Données interrogées fréquemment
- Données nécessitant des contraintes strictes
- Relations (clés étrangères)
- Données pour lesquelles vous faites des agrégations

**Colonnes JSON pour** :
- Attributs variables selon le type d'enregistrement
- Métadonnées extensibles
- Données provenant de sources externes (APIs)
- Configurations et préférences
- Données rarement interrogées individuellement

## Vocabulaire JSON essentiel

Avant de continuer, familiarisons-nous avec les termes que nous utiliserons :

| Terme | Définition | Exemple |
|-------|------------|---------|
| **Objet** | Collection de paires clé-valeur | `{"nom": "Alice"}` |
| **Tableau** | Liste ordonnée de valeurs | `[1, 2, 3]` |
| **Clé** | Nom d'une propriété | `"nom"` dans `{"nom": "Alice"}` |
| **Valeur** | Donnée associée à une clé | `"Alice"` dans `{"nom": "Alice"}` |
| **Paire** | Clé + valeur | `"nom": "Alice"` |
| **Imbrication** | Objets/tableaux dans objets/tableaux | `{"a": {"b": 1}}` |
| **Chemin JSON** | Navigation vers une valeur | `$.client.nom` |
| **JSON valide** | JSON syntaxiquement correct | Respecte toutes les règles |
| **JSON bien formé** | Même chose que JSON valide | |
| **Parsing** | Analyser et convertir le JSON | Texte → Structure de données |
| **Sérialisation** | Convertir en JSON | Données → Texte JSON |
| **Désérialisation** | Convertir depuis JSON | Texte JSON → Données |

## Vue d'ensemble du parcours d'apprentissage

Dans cette section 8.2, nous allons explorer ces quatre aspects du JSON dans SQL Server :

```
8.2 Gestion des données JSON
│
├── 8.2.1 Stockage de JSON (dans NVARCHAR)
│   ├── Pourquoi NVARCHAR (pas de type JSON natif)
│   ├── Créer des tables avec colonnes JSON
│   ├── Validation avec ISJSON()
│   └── Bonnes pratiques de stockage
│
├── 8.2.2 Fonctions natives JSON
│   ├── ISJSON() - Valider le JSON
│   ├── JSON_VALUE() - Extraire des valeurs scalaires
│   ├── JSON_QUERY() - Extraire des objets/tableaux
│   └── Chemins JSON (JSON Path)
│
├── 8.2.3 OPENJSON (Transformer JSON en table)
│   ├── Concept et utilité
│   ├── Mode par défaut (key, value, type)
│   ├── Mode avec schéma (WITH clause)
│   ├── CROSS APPLY pour colonnes JSON
│   └── Cas d'usage pratiques
│
└── 8.2.4 FOR JSON (Génération de JSON)
    ├── Mode AUTO (structure automatique)
    ├── Mode PATH (contrôle total)
    ├── Options (ROOT, WITHOUT_ARRAY_WRAPPER, etc.)
    └── Créer des APIs REST
```

Chaque section s'appuie sur la précédente pour vous donner une compréhension complète et pratique du JSON dans SQL Server.

## Prérequis pour cette section

Pour tirer le meilleur parti de cette section sur JSON, vous devriez être à l'aise avec :
- Les requêtes SELECT de base
- Les types de données SQL Server (particulièrement NVARCHAR)
- Les jointures entre tables
- Les sous-requêtes
- Les fonctions d'agrégation

Si ces concepts ne sont pas encore clairs, n'hésitez pas à revoir les sections précédentes du cours.

## Outils et ressources

### Outils pour travailler avec JSON

**Dans SQL Server** :
- **SQL Server Management Studio (SSMS)** : Support JSON avec coloration syntaxique
- **Azure Data Studio** : Excellent support JSON et formatage

**Éditeurs et validateurs en ligne** :
- **JSONLint** (jsonlint.com) : Valider et formater du JSON
- **JSON Editor Online** (jsoneditoronline.org) : Éditer et visualiser
- **Visual Studio Code** : Extensions JSON puissantes
- **Postman** : Tester des APIs REST avec JSON

### Documentation officielle

- **Microsoft Docs** : Documentation complète sur JSON dans SQL Server
- **JSON.org** : Spécification officielle de JSON
- **RFC 7159** : Standard IETF pour JSON

## JSON et NoSQL : Quelle différence ?

Vous avez peut-être entendu parler de bases de données **NoSQL** comme MongoDB qui utilisent JSON. Quelle est la différence avec SQL Server ?

### MongoDB (NoSQL) vs SQL Server (Relationnel + JSON)

| Aspect | MongoDB | SQL Server |
|--------|---------|------------|
| **Type** | Base orientée documents (NoSQL) | Base relationnelle avec support JSON |
| **Stockage** | Documents JSON/BSON natifs | Tables relationnelles + colonnes JSON |
| **Schéma** | Sans schéma (schema-less) | Schéma fixe avec zones flexibles (JSON) |
| **Requêtes** | Langage MongoDB spécifique | SQL avec fonctions JSON |
| **Transactions** | Limitées historiquement | ACID complètes |
| **Relations** | Références manuelles ou embedding | Clés étrangères, contraintes |
| **Cas d'usage** | Applications très flexibles, prototypage | Applications d'entreprise, données structurées |

**SQL Server avec JSON** = Le meilleur des deux mondes :
- Structure relationnelle pour données critiques
- Flexibilité JSON pour données variables
- Transactions ACID complètes
- Langage SQL familier

## Différences JSON entre SQL Server et PostgreSQL

Si vous connaissez PostgreSQL, voici les différences principales :

| Aspect | PostgreSQL | SQL Server |
|--------|-----------|------------|
| **Type de données** | `JSON` et `JSONB` (binaire) | NVARCHAR (texte) |
| **Opérateurs** | `->`, `->>`, `@>`, etc. | Fonctions (JSON_VALUE, etc.) |
| **Indexation** | Index GIN sur JSONB | Index calculés sur extractions |
| **Performance** | JSONB très performant | Bon avec colonnes calculées |
| **Syntaxe** | Plus concise avec opérateurs | Plus verbeuse avec fonctions |

Les deux approches sont valides - SQL Server privilégie les fonctions explicites, PostgreSQL les opérateurs.

## À quoi s'attendre dans les prochaines sections

### Section 8.2.1 : Stockage de JSON
Vous apprendrez à :
- Comprendre pourquoi JSON est stocké en NVARCHAR
- Créer des tables avec colonnes JSON
- Valider le JSON avec ISJSON()
- Choisir entre colonnes relationnelles et JSON
- Appliquer les bonnes pratiques

### Section 8.2.2 : Fonctions natives JSON
Vous apprendrez à :
- Valider du JSON avec ISJSON()
- Extraire des valeurs avec JSON_VALUE()
- Extraire des structures avec JSON_QUERY()
- Utiliser les chemins JSON (JSON Path)
- Optimiser les performances

### Section 8.2.3 : OPENJSON
Vous apprendrez à :
- Transformer des tableaux JSON en lignes SQL
- Utiliser OPENJSON avec et sans schéma
- Combiner OPENJSON avec CROSS APPLY
- Traiter des structures JSON complexes
- Importer des données JSON en masse

### Section 8.2.4 : FOR JSON
Vous apprendrez à :
- Générer du JSON depuis des tables SQL
- Utiliser les modes AUTO et PATH
- Créer des structures JSON complexes
- Personnaliser le JSON généré
- Créer des APIs REST avec SQL Server

## Conclusion de l'introduction

JSON est devenu **incontournable** dans le développement moderne. Que vous créiez des APIs, que vous intégriez des services externes, ou que vous stockiez des données flexibles, JSON est probablement impliqué.

SQL Server offre un **support JSON complet et performant** qui vous permet de :
- ✅ Stocker des données JSON de manière fiable
- ✅ Interroger efficacement du JSON avec SQL
- ✅ Transformer JSON en données relationnelles
- ✅ Générer du JSON pour vos applications
- ✅ Combiner relationnel et JSON de manière optimale

**Points clés à retenir de cette introduction** :
1. JSON est le format standard pour les APIs et applications web modernes
2. Plus simple et léger que XML
3. SQL Server stocke JSON en NVARCHAR avec des fonctions spécialisées
4. L'approche hybride (relationnel + JSON) offre flexibilité et performance
5. Quatre domaines : Stockage, Interrogation, Transformation, Génération

Maintenant que vous comprenez les concepts fondamentaux de JSON et son rôle dans SQL Server, vous êtes prêt à plonger dans les détails techniques en commençant par le stockage de JSON dans la section suivante.

**Passons maintenant à la section 8.2.1 pour voir comment stocker du JSON dans SQL Server !**

⏭️ [Stockage de JSON (dans NVARCHAR)](/08-sujets-complementaires-et-ecosysteme/02.1-stockage-de-json.md)
