🔝 Retour au [Sommaire](/SOMMAIRE.md)

# 8.9 Types spatiaux (GEOGRAPHY et GEOMETRY)

## Introduction

« Quels magasins se trouvent à moins de 5 km de ma position ? » « Cette adresse est-elle dans notre zone de livraison ? » « Quelle est la distance entre Paris et Lyon ? » « Quelles parcelles sont traversées par cette rivière ? »

Toutes ces questions ont un point commun : elles portent sur des **données spatiales** — des positions, des formes et des distances dans l'espace. Les stocker sous forme de simples colonnes `latitude`/`longitude` ne suffit pas : calculer une distance « à vol d'oiseau » correcte sur la Terre (qui est courbe !) ou déterminer si un point est à l'intérieur d'un polygone devient vite un casse-tête mathématique.

Depuis SQL Server 2008, le moteur propose deux **types de données spatiaux** natifs — `GEOMETRY` et `GEOGRAPHY` — accompagnés de dizaines de **méthodes** pour manipuler points, lignes et surfaces, et d'**index spatiaux** pour que tout cela reste rapide.

---

## Deux types pour deux visions du monde

SQL Server distingue deux systèmes de coordonnées, et donc deux types :

| | **GEOMETRY** | **GEOGRAPHY** |
|---|---|---|
| Modèle | Plan **plat** (euclidien) | **Ellipsoïde** terrestre (rond) |
| Coordonnées | X, Y arbitraires | Longitude, latitude (degrés) |
| Distances | Unités du plan (sans dimension) | **Mètres** (réelles) |
| Cas d'usage | Plans, CAO, jeux, écrans, cartes locales projetées | Positions **GPS**, cartographie mondiale |
| Exemple | Plan d'un entrepôt en mètres | Coordonnées GPS d'un magasin |

> 🧠 **Analogie** : `GEOMETRY` raisonne comme une **feuille de papier millimétré** (plate). `GEOGRAPHY` raisonne comme un **globe terrestre** : il tient compte de la courbure de la Terre, ce qui est indispensable pour des distances correctes à l'échelle d'un pays ou du monde.

Pour la plupart des applications « du monde réel » (positions GPS, géolocalisation), c'est **`GEOGRAPHY`** que vous utiliserez. `GEOMETRY` sert pour des plans locaux, des données déjà projetées, ou des espaces non géographiques.

---

## Les formes géospatiales (norme OGC)

Les types spatiaux de SQL Server respectent les standards de l'**OGC** (*Open Geospatial Consortium*). On peut représenter de nombreuses formes :

| Forme | Description | Exemple |
|-------|-------------|---------|
| **Point** | Une position | Un magasin, une adresse |
| **LineString** | Une ligne (suite de points) | Une route, une rivière |
| **Polygon** | Une surface fermée | Une zone de livraison, un pays |
| **MultiPoint / MultiLineString / MultiPolygon** | Collections | Un archipel, un réseau routier |
| **GeometryCollection** | Mélange de formes | — |

Ces formes s'expriment couramment en **WKT** (*Well-Known Text*), un format texte standard :

```
POINT(2.3522 48.8566)            -- longitude latitude (Paris)
LINESTRING(0 0, 1 1, 2 2)
POLYGON((0 0, 4 0, 4 4, 0 4, 0 0))  -- une zone fermée (le 1er et dernier point coïncident)
```

> ⚠️ **Piège classique** : en WKT, l'ordre est **longitude puis latitude** (X puis Y). Beaucoup d'erreurs viennent d'une inversion lat/long. Nous y reviendrons en §8.9.1.

---

## Un avant-goût concret

```sql
-- Stocker la position d'un magasin (GEOGRAPHY, SRID 4326 = GPS/WGS84)
DECLARE @paris GEOGRAPHY = geography::Point(48.8566, 2.3522, 4326);
DECLARE @lyon  GEOGRAPHY = geography::Point(45.7640, 4.8357, 4326);

-- Distance « à vol d'oiseau » entre Paris et Lyon, en mètres
SELECT @paris.STDistance(@lyon) AS DistanceMetres;
-- ≈ 392 000 m, soit ~392 km
```

En quelques lignes, SQL Server calcule une distance géodésique correcte sur la surface terrestre — un calcul qui demanderait sinon de la trigonométrie sphérique.

---

## Ce que vous allez apprendre dans cette section

| Sous-section | Sujet |
|--------------|-------|
| **8.9.1** | `GEOMETRY` (plan) vs `GEOGRAPHY` (terrestre) : choix, SRID, création |
| **8.9.2** | Les méthodes spatiales (`STDistance`, `STIntersects`…) et les index spatiaux |

---

## Cas d'usage typiques

- 🏪 **Recherche de proximité** : « les 5 magasins les plus proches de l'utilisateur ».
- 🚚 **Zones de service** : « cette adresse est-elle dans une zone de livraison ? ».
- 🗺️ **Cartographie et SIG** : stockage de territoires, parcelles, itinéraires.
- 📍 **Géofencing** : déclencher une action quand un objet entre/sort d'une zone.
- 🌍 **Analyse géographique** : croiser des données métier avec leur localisation.

---

## Pièges courants

| Piège | Conséquence | Bon réflexe |
|-------|-------------|-------------|
| Inverser **latitude / longitude** | Points au mauvais endroit sur Terre | `Point(lat, long, 4326)` mais WKT `POINT(long lat)` |
| Utiliser `GEOMETRY` pour du **GPS** | Distances fausses (Terre ignorée) | `GEOGRAPHY` (SRID 4326) pour des positions réelles |
| **SRID différents** entre deux objets | `STDistance` renvoie `NULL` | Vérifier `.STSrid`, harmoniser les SRID |
| Oublier l'**index spatial** | Requêtes de proximité lentes | Créer un `SPATIAL INDEX` sur les gros volumes |

## Questions fréquentes

**Q : `GEOGRAPHY` ou `GEOMETRY` pour des coordonnées GPS ?**
R : **`GEOGRAPHY`** avec SRID **4326** — c'est le système des GPS, et les distances sont alors en mètres réels.

**Q : Puis-je afficher mes données sur une carte ?**
R : Oui : exportez-les en **WKT** (`STAsText()`) ou en GeoJSON, formats lus par la plupart des bibliothèques cartographiques.

**Q : Faut-il une édition particulière de SQL Server ?**
R : Non, les types spatiaux sont disponibles dans **toutes les éditions** depuis SQL Server 2008.

---

## Résumé

- SQL Server propose deux types spatiaux : **`GEOMETRY`** (plan plat, unités arbitraires) et **`GEOGRAPHY`** (Terre courbe, longitude/latitude, distances en mètres).
- Pour des positions **GPS** réelles, on utilise **`GEOGRAPHY`** (SRID 4326).
- Les formes (Point, LineString, Polygon…) suivent la norme **OGC** et s'expriment souvent en **WKT** (`POINT(long lat)`).
- Des dizaines de **méthodes** (`STDistance`, `STIntersects`…) et des **index spatiaux** rendent les requêtes géographiques simples et rapides.
- Cas d'usage : proximité, zones de livraison, cartographie, géofencing.

Comparons d'abord en détail `GEOMETRY` et `GEOGRAPHY`, et voyons comment créer ces objets correctement.

---

⏭️ [GEOMETRY (plan) vs GEOGRAPHY (ellipsoïde terrestre)](/08-sujets-complementaires-et-ecosysteme/09.1-geometry-vs-geography.md)
