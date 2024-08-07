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

 Voor het laden van de data in PostGIS gebruiken we commandline tool ogr2ogr. Als QGIS is geinstalleerd staat het in de bin directory van QGIS (bijvoorbeeld D:\Program Files\QGIS 3.36.1\bin).

 Voeg de bin directory toe aan de PATH om ogr2ogr te kunnen gebruiken. Dit kan via Windows - Settings of via de commandline:

 ```
  set PATH=%PATH%;D:\Program Files\QGIS 3.36.1\bin
```

- Open een command prompt en navigeer naar de directory waar de shapefiles zijn uitgepakt

Laden van de DTB vlakken:

```
 ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5439 user=postgres dbname=postgres password=postgres" d15cz_reg.shp -t_srs epsg:4979 -nln public.dtb_vlak_andijk -nlt MULTIPOLYGONZ
 ```

Laden van de DTB punten:

```
ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5439 user=postgres dbname=postgres password=postgres" d15cz_sym.shp -t_srs epsg:4979 -nln public.dtb_punt_andijk -nlt POINTZ
```

### Data voorbereiden


