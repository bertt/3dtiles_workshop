# Dataverwerking

## 3D Tiles specificatie

Bij de verwerking van data naar 3D ligt de focus op de 3D Tiles standaard. En niet zonder reden. Een digital twin bestaat vaak uit enorme hoeveelheden data. Als deze data allemaal in één keer ingeladen zou worden, zou dit tot problemen leiden met de performance. In een 3D tileset zijn de objecten hiërarchisch ingedeeld in tegels (Figuur 2) en wordt alleen de data geserveerd die zich in de buurt bevindt van het gezichtspunt van de gebruiker. Hierdoor wordt de performance van de applicatie zo veel mogelijk gewaarborgd. 3D Tiles is een open standaard van het Open Geospatial Consortium (OGC) en is ontwikkeld voor het serveren en visualiseren van grote 3D ruimtelijke datasets. 

Een gedetailleerd overzicht van de 3D Tiles specificatie kun je inzien (https://github.com/CesiumGS/3d-tiles/blob/main/3d-tiles-reference-card.pdf)[https://github.com/CesiumGS/3d-tiles/blob/main/3d-tiles-reference-card.pdf]. 


Wat betreft 3D tiling kan er een onderscheid gemaakt worden tussen batched 3D models (b3dm) en instanced 3D models (i3dm). 

Bij b3dm kan een grote hoeveelheid unieke 3D-objecten samengevoegd worden in een set. Bijvoorbeeld een set van panden. Deze 3D-objecten worden vervolgens in een enkel b3dm-bestand opgeslagen.

I3dm is een stuk lichter ten opzichte van b3dm, aangezien bij i3dm gebruik wordt gemaakt van een beperkt aantal standaard 3D-modellen die ingeladen worden op een groot aantal gedefinieerde locaties. Dit komt vooral van pas bij de weergave van objecten als windmolens, bomen of lantaarnpalen waarvoor steeds eenzelfde 3D-model kan worden gebruikt. 

De procedure voor het verwerken van data naar 3D tiles varieert tussen de verschillende 3D-databronnen en is onder andere afhankelijk of het b3dm of i3dm betreft. In de volgende opdrachten gaan we 3D tilesets maken met zowel b3dm als i3dm. 

 ##  Opdracht 1: Digitaal Topografisch Bestand (DTB) naar 3D Tiles

 In deze opdracht gaan we een kaartblad van het DTB converteren naar 3D tiles. Dit doen we via de open source tooling pg2b3dm en i3dm.export. De tool pg2b3dm converteert tabellen uit de database naar het b3dm-formaat en i3dm.export naar i3dm-formaat. Hierover later meer!  


Om de conversie voor elkaar te krijgen moeten we: 

- het DTB downloaden als Shapefile en importeren naar de PostgreSQL database met de PostGIS extensie; 

- twee tabellen aanmaken die dienen als input voor pg2b3dm en i3dm.export;  

- deze vervolgens converteren naar 3D tiles; 
 
### Data downloaden en importeren 

De volgende stappen laten zien hoe je de DTB data kan downloaden en kan laden op de database. Als voorbeeld gebruiken we de DTB voor Andijk.

- Zoek via de RWS DTB Bladindeling viewer (https://maps.rijkswaterstaat.nl/geoweb55/index.html?viewer=DTB_Bladindeling.Webviewer) het Andijk kaartblad (DTB kaartblad d15cz)

Klik op de link 'Klik hier om dit kaartblad als Shapefile (.zip) te downloaden' in de popup om de data te downloaden.

- Pak het zip-bestand uit

De zip bevat 3 shapefiles:

- d15cz_lin.shp (DTB lijnen)
- d15cz_reg.shp (DTB vlakken)
- d15cz_sym.shp (DTB punten)

 Voor het laden van de data in PostGIS gebruiken we commandline tool ogr2ogr. Als QGIS is geinstalleerd staat het in de bin directory van QGIS (bijvoorbeeld C:\Program Files\QGIS 3.36.1\bin).

 Voeg de bin directory toe aan de PATH om ogr2ogr te kunnen gebruiken. Dit kan via Windows - Settings of via de commandline:

 ```shell
  set PATH=%PATH%;D:\Program Files\QGIS 3.36.1\bin
```

- Open een command prompt en navigeer naar de directory waar de shapefiles zijn uitgepakt

Laden van de DTB vlakken:

```
 ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5439 user=postgres dbname=postgres password=postgres" d15cz_reg.shp -t_srs epsg:4979 -nln public.dtb_vlak_andijk -nlt MULTIPOLYGONZ
 ```

Laden van de DTB punten:

```shell
ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5439 user=postgres dbname=postgres password=postgres" d15cz_sym.shp -t_srs epsg:4979 -nln public.dtb_punt_andijk -nlt POINTZ
```

### Data voorbereiden

Om de data te kunnen converteren naar 3D tiles moeten we tabellen aanmaken die dienen als input voor pg2b3dm (vlakken) en i3dm.export (punten).


Create spatial indexen

```sql
CREATE INDEX ON public.dtb_vlak_andijk USING gist(st_centroid(st_envelope(wkb_geometry)));
CREATE INDEX ON public.dtb_punt_andijk USING GIST (wkb_geometry);
```

Voor de punten maken we een view aan die de attributen van de punten bevat.

```sql
CREATE or replace view public.v_dtb_punt_andijk AS
SELECT
RANDOM()*360 AS rotation,
(RANDOM()*1.5)+0.5 AS scale,
json_build_array(json_build_object('dtb id',dtb_id),
 json_build_object('omschrijving',omschr),
 json_build_object('datum',datum)) AS tags,
'tree.glb' AS model,
wkb_geometry AS geom
FROM public.dtb_punt_andijk
WHERE omschr = 'Boom';
```


### 3D Tiles maken van DTB vlakken

De volgende stappen laten zien hoe je 3D tiles kan maken van de DTB vlakken.

- Download command line tool pg2b3dm (https://github.com/Geodan/pg2b3dm/releases, voor Windows kies pg2b3dm-win-x64.zip
) en pak het zip-bestand uit.

- Open een command prompt en navigeer naar de directory waar pg2b3dm is uitgepakt

- Voer het volgende commando uit

```
pg2b3dm -U postgres -h localhost -p 5439 -d postgres -t public.dtb_vlak_andijk -a dtb_id,omschr,datum --use_implicit_tiling false -o ./dtb_vlakken -c wkb_geometry
```

Na het opgeven van het wachtwoord wordt de 3D tileset gemaakt in de directory 'dtb_vlakken'.

Uitvoer van het programma moet er als volgt uitzien:

```
Tool: pg2b3dm 2.14.1.0
Options: -U postgres -h localhost -p 5439 -d postgres -t public.dtb_vlak_andijk -a dtb_id,omschr,datum --use_implicit_tiling false -o ./dtb_vlakken -c wkb_geometry
Password for user postgres:
Start processing 2024-08-08T12:23:58....
Input table: public.dtb_vlak_andijk
Input geometry column: wkb_geometry
App mode: Cesium
Spatial reference of public.dtb_vlak_andijk.wkb_geometry: 4979
Spatial index detected on public.dtb_vlak_andijk.wkb_geometry
Query bounding box of public.dtb_vlak_andijk.wkb_geometry...
Bounding box for public.dtb_vlak_andijk.wkb_geometry (in WGS84): 5.16509253, 52.71234743, 5.29261079, 52.75545464
Height values: [37.44 m - 74.79 m]
Default color: #FFFFFF
Default metallic roughness: #008000
Doublesided: True
Create glTF tiles: True
Attribute columns: dtb_id,omschr,datum
Center (wgs84): 5.228851660450694, 52.733901034211115
Starting Cesium mode...
Translation ECEF: 3854182.25,352715.03125,5052667.5
3D Tiles version: 1.1
Lod column:
Radius column:
Geometric errors: 2000,0
Refinement: REPLACE
Add outlines: False
Use 3D Tiles 1.1 implicit tiling: False
Maximum features per tile: 1000
Start generating tiles...
Creating tile: 2_3_3.glb
Tiles created: 10
Geometric errors used: 2000,0

External tileset.json files: 0
Writing root tileset.json...

Time: 0h 0m 1s 972ms
Program finished 2024-08-08T12:24:00.
```

De directory 'dtb_vlakken' bevat:

- een tileset.json bestand. 

In dit bestand staan de referenties naar de 3D tiles.

- een directory 'content' met de 3D tiles in glb formaat. Een glb bestand is een binair formaat voor 3D modellen. Dubbelklik op een glb bestand om het te bekijken in programma '3D Viewer'. Het bestand kan ook geopend worden in https://gltf-viewer.donmccurdy.com/

### 3D Tiles maken van DTB punten

Voor het maken van 3D tiles van de DTB punten gebruiken we i3dm.export.

- Download command line tool i3dm.export (https://github.com/Geodan/i3dm.export/releases)

- Unzip het bestand en copieer i3dm.export.exe naar je werkdirectory

- Copieer het boom model 'tree.glb' naar je werkdirectory

- Voer het volgende commando uit

```shell
 i3dm.export -c "Host=localhost;Username=postgres;Password=postgres;Database=postgres;Port=5439" -t public.v_dtb_punt_andijk -o ./dtb_punten --use_i3dm true
```

Na het opgeven van het wachtwoord wordt de 3D tileset gemaakt in de directory 'dtb_punten'. De directory bevat: 

- een tileset.json bestand;

- een directory 'content' met de 3D tiles in I3dm formaat;

- een subtree folder met subtree file.


## Valideren tilesets

De 3D tilesets kunnen gevalideerd worden met de tool 3D Tiles Validator - https://github.com/CesiumGS/3d-tiles-validator

Voor installatie van deze tool is Node.js vereist.

- Download en installeer Node.js (https://nodejs.org/en/download/)

- Open een command prompt en installeer de 3D Tiles Validator

```shell
npm install 3d-tiles-validator
```

- Valideer de tilesets

Voor de vlakken:


```shell
3d-tiles-validator --tilesetFile ./dtb_vlakken/tileset.json
Validating tileset ./dtb_vlakken/tileset.json
Validation result:
{
  "date": "2024-08-13T13:08:23.895Z",
  "numErrors": 0,
  "numWarnings": 0,
  "numInfos": 10,
...
}
```

Er komen geen errors maar 10 Info meldingen voor vanwege gebruik niet bekende glTF extensies (voor Mesh Feature en Structural Metadata). Deze informatie meldingen kunnen genegeerd worden.

Voor de punten:
  
```shell
3d-tiles-validator --tilesetFile ./dtb_punten/tileset.json
Validating tileset ./dtb_punten/tileset.json
Validation result:
{
  "date": "2024-08-13T13:11:54.633Z",
  "numErrors": 0,
  "numWarnings": 0,
  "numInfos": 1,
```
Ook hier geen errors maar wel Informatie meldingen. Deze meldingen gaan over het gebruikte model (tree.glb) dat volgens glTF niet valide is. We kunnen het model valideren in https://github.khronos.org/glTF-Validator/ , dan verschijnen dezelfde meldingen. 

Het beste is om met valide modellen te werken maar voor nu negeren we de meldingen. 

Conclusie van de validatie: de 3D tilesets zijn valide, maar er zijn meldingen over het gebruikte model 'tree.glb'.

## Facultatieve opdracht

- Maak een 3D Tileset van panden in Andijk. Gebruik hiervoor BAG data (in Geopackage formaat), te downloaden via de 3dbag website (https://3dbag.nl/en/download). Zorg ervoor dat de attribuut 'identificatie' wordt meegenomen in de 3D tileset.














