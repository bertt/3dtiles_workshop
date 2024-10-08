# Dataverwerking

## Inleiding

In deze opdracht gaan we 3D tilesets maken van geografische data. We gebruiken open source tools om data uit een PostgreSQL database te converteren naar 3D Tiles.

Als brondata gebruiken we het Digitaal Topografisch Bestand (DTB) van Rijkswaterstaat. Het DTB bevat topografische gegevens van Nederland in de vorm van lijnen, vlakken en punten.

Uit de DTB gebruiken we twee bestanden:

- DTB vlakken voor modellen in Batched 3D Models (b3dm) formaat;

- DTB punten voor modellen in Instanced 3D Models (i3dm) formaat.

Om de conversie voor elkaar te krijgen moeten we: 

- DTB downloaden en importeren naar de PostgreSQL database met de PostGIS extensie; 

- Twee tabellen aanmaken die dienen als input voor pg2b3dm en i3dm.export;  

- 3D tilesets maken van de DTB vlakken en punten;
 
### Data downloaden en importeren 

Van een gebiedje bij Andijk gaan we DTB downloaden en importeren in de database.

- Zoek via de RWS DTB Bladindeling viewer (https://maps.rijkswaterstaat.nl/geoweb55/index.html?viewer=DTB_Bladindeling.Webviewer) het Andijk kaartblad (DTB kaartblad d15cz)

Klik op de link 'Klik hier om dit kaartblad als Shapefile (.zip) te downloaden' in de popup om de data te downloaden.

- Pak het zip-bestand uit naar de werkdirectory

De zip bevat 3 shapefiles:

- d15cz_lin.shp (DTB lijnen)
- d15cz_reg.shp (DTB vlakken)
- d15cz_sym.shp (DTB punten)

 Voor het laden van de data in PostGIS gebruiken we commandline tool ogr2ogr. 

- Open een command prompt en navigeer naar de werkdirectory

Voor het laden van de DTB vlakken in de database voer het volgende commando uit:

```
 ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5439 user=postgres dbname=postgres password=postgres" d15cz_reg.shp -t_srs epsg:4979 -nln public.dtb_vlak_andijk -nlt MULTIPOLYGONZ

 ```

Voor het laden van de DTB punten in de database voer het volgende commando uit:

```shell
ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5439 user=postgres dbname=postgres password=postgres" d15cz_sym.shp -t_srs epsg:4979 -nln public.dtb_punt_andijk -nlt POINTZ
```

### Data voorbereiden

Om de data te kunnen converteren naar 3D Tiles moeten we tabellen aanmaken die dienen als input voor pg2b3dm (vlakken) en i3dm.export (punten).


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

De database view is gebaseerd op DTB punten en bevat de volgende gegevens:

- we selecteren alleen de bomen;

- gebruiken een random rotatie en schaal;

- voegen het te gebruiken model model (tree.glb) toe;

- voegen de attributen 'dtb id', 'omschrijving' en 'datum' toe in de 'tags' kolom.


### 3D Tiles maken van DTB vlakken

De volgende stappen laten zien hoe we Batched 3D Models kunnen maken van de DTB vlakken.

- Download command line tool pg2b3dm (https://github.com/Geodan/pg2b3dm/releases, voor Windows kies pg2b3dm-win-x64.zip
) en pak het zip-bestand uit en kopieer de executable naar de workdirectory.

- Open een command prompt in de werkdirectory

Check de versie van pg2b3dm

```shell
pg2b3dm --version
Tool: pg2b3dm 2.14.0.0
```

- Voer het volgende commando uit

```
pg2b3dm -U postgres -h localhost -p 5439 -d postgres -t public.dtb_vlak_andijk -a dtb_id,omschr,datum --use_implicit_tiling false -o ./dtb_vlakken -c wkb_geometry --create_gltf false
```

Uitleg commando:

-U: gebruikersnaam van de database

-h: hostnaam van de database

-p: poortnummer van de database

-t: naam van de tabel

-a: attributen van de tabel

--use_implicit_tiling: gebruik 3D Tiles 1.1 implicit 

-o: output directory

-c: kolom met geometrie


Na het opgeven van het wachtwoord wordt de 3D tileset gemaakt in de directory 'dtb_vlakken'.

De directory 'dtb_vlakken' bevat:

- een tileset.json bestand. 

In dit bestand staan de referenties naar de 3D tiles.

- een directory 'content' met de 3D tiles in b3dm formaat. 

### 3D Tiles maken van DTB punten

Voor het maken van Instanced 3D Models van de DTB punten gebruiken we i3dm.export.

- Download command line tool i3dm.export (https://github.com/Geodan/i3dm.export/releases)

- Unzip het bestand en kopieer i3dm.export.exe naar de werkdirectory

Check:

```shell
i3dm.export --version
i3dm.export 2.7.2
```

- kopieer het boom model 'tree.glb' naar de werkdirectory

- Voer het volgende commando uit

```shell
 i3dm.export -c "Host=localhost;Username=postgres;Password=postgres;Database=postgres;Port=5439" -t public.v_dtb_punt_andijk -o ./dtb_punten --use_i3dm true
```

Uitleg commando:

-c: connectiestring naar de database

-t: naam van de tabel of view

-o: output directory

--use_i3dm: gebruik i3dm formaat

Na het opgeven van het wachtwoord wordt de Instanced 3D tileset gemaakt in de directory 'dtb_punten'. De directory bevat: 

- een tileset.json bestand;

- een directory 'content' met de 3D tiles in I3dm formaat;

- een subtree folder met subtree file.

## Valideren tilesets

De 3D tilesets kunnen gevalideerd worden met de tool 3D Tiles Validator - https://github.com/CesiumGS/3d-tiles-validator

Voor installatie van deze tool is Node.js vereist.

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
  "date": "2024-08-26T13:00:03.503Z",
  "numErrors": 0,
  "numWarnings": 0,
  "numInfos": 0
}
```

Er zijn geen errors, warnings of informatie meldingen. De 3D tileset is valide.

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

## Comprimeren tilesets

De 3D tilesets kunnen gecomprimeerd worden met de tool 3D Tiles Compressor.

Voor het comprimeren van de DTB vlakken voer het volgende commanda  uit:

```shell
docker run -v c:\workshop_3dtiles\dtb_vlakken\content:/tiles -it geodan/compressor5000
```

## Facultatieve opdracht

- Maak een 3D Tileset van panden in Andijk. Gebruik hiervoor BAG data (in Geopackage formaat), te downloaden via de 3dbag website (https://3dbag.nl/en/download). Zorg ervoor dat de attribuut 'identificatie' wordt meegenomen in de 3D tileset.

Zie eventueel de resultaten directory bestand 1_dataverwerking.txt voor de uitwerking van deze opdracht.

Comprimeer de 3D tileset met de 3D Tiles Compressor.

Ga door naar [2_datavisualisatie.md](2_datavisualisatie.md)











