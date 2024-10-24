# Introductie 

Digital Twins brengen data uit verschillende bronnen waarheidsgetrouw samen in een digitale kopie van de fysieke werkelijkheid. Het begrip digital twin is zeer breed. In deze workshop richten we ons op digital twins van de fysieke leefomgeving. Hierin wordt een realistisch beeld gegeven van een gebied of regio, waarbij ruimtelijke data overzichtelijk weergegeven wordt en gebruikt kan worden voor vele toepassingen. Een dergelijke digital twin kan niet zonder de 3D component. De meeste data is echter niet direct als 3D beschikbaar. Daarom moet de data vaak eerst verwerkt worden. Deze verwerkingsstappen kunnen flink uiteenlopen afhankelijk van het type brondata. 

## Workshop

In deze workshop wordt aan de hand van een aantal voorbeelden gedemonstreerd hoe deze dataverwerking in elkaar steekt. De focus ligt op de 3D Tiles specificatie. Deze OGC-standaard helpt de weergave van grote 3D-datasets te optimaliseren door op slimme wijze alleen de noodzakelijke data in te laden. 

Zie voor een gedetailleerd overzicht van de 3D Tiles specificatie (https://github.com/CesiumGS/3d-tiles/blob/main/3d-tiles-reference-card.pdf)[https://github.com/CesiumGS/3d-tiles/blob/main/3d-tiles-reference-card.pdf]. 

De hoeveelheid data in een digital twin is vaak enorm, waardoor het tegelijk opvragen van alle beschikbare data niet wenselijk is met het oog op de performance. 

Na de dataverwerking gaan we de 3D Tiles visualiseren. 3D Tiles kunnen door meerdere applicaties gebruikt worden. In deze workshop gebruiken we Cesium, een krachtige open source Javascript library. 

Naast visualisatie in Cesium worden de aangemaakte tilesets ingeladen in QGIS.

<img src = "./images/3dtiles_ecosysteem.png">

In deze workshop gaan we een digital twin inrichten voor de Proefpolderdijk bij Andijk. Bij het beheer van deze dijk komt veel verschillende data kijken. We gaan aan de slag met het Digitaal Topografisch Bestand (DTB) van RWS. Aan de hand van deze data laten we zien welke stappen er nodig zijn om van de beschikbare brondata tot een 3D-webomgeving te komen gebruikmakend van open source tooling en open standaarden.  

De workshop is ingedeeld in twee delen, te weten: 

Deel 1: Dataverwerking tot 3D Tiles 

- Data downloaden en importeren; 

- Data voorbereiden

- 3D Tiles maken 

[1_dataverwerking.md](1_dataverwerking.md)

Deel 2: Datavisualisatie in 3D

- 3D tilesets inladen 

- Tileset stijl aanpassen 

- 3D modellen toevoegen 

- PDOK 3D Basisvoorziening 3D Tiles gebruiken

- 3D Tiles in QGIS inladen

[2_datavisualisatie.md](2_datavisualisatie.md)

## Leerdoelen 

Na het voltooien van deze cursus:

- Is er kennis van de 3D Tiles-standaard;

- Is er inzicht in de software en technieken die nodig zijn voor het maken van 3D-tilesets;

- kan een 3D-tileset worden geladen in een CesiumJS-webomgeving;

- zijn de mogelijkheden voor datavisualisatie met CesiumJS bekend.

## Benodigdheden

- Laptop

- Internetverbinding

- Webbrowser

Benodigde software:

- Docker

Check:

```shell
docker --version
Docker version 27.1.1, build 6312585
```
- QGIS

Zet het path naar QGIS in de environment variables, zodat we GDAL commandline tools kunnen gebruiken.

Voorbeelddirectory: C:\Program Files\QGIS 3.38.3\bin\.

kan via Control panel - System - Edit the system Environment Variables - Environment Variables... - System Variables - Path of via de commandline:

 ```shell
set PATH=%PATH%;C:\Program Files\QGIS 3.38.3\bin
```

Check:

```shell
ogr2ogr --version
GDAL 3.9.2, released 2024/08/13
```

- Database management tool (bijv. pgAdmin of DBeaver)

pgAdmin: https://www.pgadmin.org/

DBeaver: https://dbeaver.io/

Het voordeel van DBeaver is dat een groot aantal typen databases gebruikt kunnen worden.

De command line liefhebbers kunnen ook psql gebruiken. psql.exe staat standaard in de bin directory van de QGIS installatie.

- Node.JS 

Download en installeer Node.js (https://nodejs.org/en/download/)

Check:

```shell
node --version
v20.18.0
```

In de workshop wordt operating systeem Windows gebruikt, met wat kleine aanpassingen kunnen
ook andere operating systemen gebruikt worden. 

## Aanmaken database met Docker 

We gebruiken Docker om de PostGIS database te starten. Open een terminal en voer het volgende commando uit:

```
docker run -d -e POSTGRES_PASSWORD=postgres -d -p 5439:5432 postgis/postgis
3cc40f09c573141a90e1a7abdc4f5d0cdfc2bebfe4ab2ff9e3ecf81f83af4529 
```

Uitleg command: 

Docker run: start een nieuwe container.

Met -e environment settings, zoals een wachtwoord of username. 

Met -d zorgt dat de docker ‘detached’ runt, zodat deze niet de terminal blokkeert, maar op de achtergrond draait. 

Met -p verzorgt de portmapping, we gebruiken poort 5439.

Vervolgens kan in DBeaver of PGAdmin en in QGIS connectie gemaakt worden met de database door een connectie toe te voegen. In de settings gebruik: 

- Host: localhost 

- Port: 5439 

- Username: postgres 

- Password: postgres 

Voorbeeld aanmaken database connectie met DBeaver - via Database - New database connection - PostgreSQL:

<img src = "./images/dbeaver_connection.png">

Via SQL Editor -> OpenSQL Script kunnen queries op de database worden uitgevoerd.

Voorbeeld aanmaken database connectie met QGIS - Browser window - PostgreSQL rechtermuis - new connection

<img src = "./images/qgis_connection.png">

Via optie 'Execute SQL' kunnen queries op de database worden uitgevoerd.

Check: Vraag PostGIS versie op met de volgende SQL query:

```sql
SELECT postgis_version();
``` 

Voorbeeld met psql client:

```shell
psql -h localhost -p 5439 -U postgres -d postgres -c "select PostGIS_Version();"
            postgis_version
---------------------------------------
 3.5 USE_GEOS=1 USE_PROJ=1 USE_STATS=1
(1 row)
```
## Werkdirectory

Maak een werkdirectory aan waarin bestanden van deze workshop worden opgeslagen.

Bijvoorbeeld: 

```shell
cd c:\
mkdir workshop_3dtiles
```

## Databestanden

In de workshop maken we gebruik van de volgende databestanden:

- Digitaal Topografisch Bestand (DTB) van RWS

- Bag 3D 

In de opdrachten wordt uitgelegd hoe deze databestanden opgehaald kunnen worden. De databestanden zijn ook te vinden in de map 'data' in deze repository.

## Resultaten

Zie de resultaten van deze workshop in de map 'resultaten'. 

Deze map bevat de volgende submappen:

- andijk_panden: 3D Tiles van de panden in Andijk

- dtb_punten: 3D Tiles van de DTB punten

- dtb_vlakken: 3D Tiles van de DTB vlakken

Het resultaat van de workshop is een 3D-webomgeving waarin de 3D tilesets in Andijk ingeladen zijn.

<img src = "./images/windturbine.gif">

Ga door naar [1_dataverwerking.md](1_dataverwerking.md)
