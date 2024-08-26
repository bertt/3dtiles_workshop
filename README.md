# Introductie 

Digital Twins brengen data uit verschillende bronnen waarheidsgetrouw samen in een digitale kopie van de fysieke werkelijkheid. Het begrip digital twin is zeer breed. In deze workshop richten we ons op digital twins van de fysieke leefomgeving. Hierin wordt een realistisch beeld gegeven van een gebied of regio, waarbij ruimtelijke data overzichtelijk weergegeven wordt en gebruikt kan worden voor vele toepassingen. Een dergelijke digital twin kan niet zonder de 3D component. De meeste data is echter niet direct als 3D beschikbaar. Daarom moet de data vaak eerst verwerkt worden. Deze verwerkingsstappen kunnen flink uiteenlopen afhankelijk van het type brondata. 

## Workshop

In deze workshop wordt aan de hand van een aantal voorbeelden gedemonstreerd hoe deze dataverwerking in elkaar steekt. De focus ligt op de 3D Tiles specificatie. Deze OGC-standaard helpt de weergave van grote 3D-datasets te optimaliseren door op slimme wijze alleen de noodzakelijke data in te laden. De hoeveelheid data in een digital twin is vaak enorm, waardoor het tegelijk opvragen van alle beschikbare data niet wenselijk is met het oog op de performance. 

<img src = "3dtiles_ecosysteem.png">

Na de dataverwerking gaan we de 3D Tiles visualiseren. 3D Tiles kunnen door veel verschillende applicaties gebruikt worden (Figuur 1). In dit geval gaan we gebruik maken van CesiumJS, een krachtige open source Javascript library waarmee tilesets ingeladen kunnen worden in de browser. Met CesiumJS kan een digital twin-omgeving vormgegeven worden waarin grote hoeveelheden data als 3D Tiles geserveerd worden. Ook worden de aangemaakte tilesets ingeladen in QGIS.

In deze workshop gaan we een digital twin inrichten voor de Proefpolderdijk bij Andijk. Bij het beheer van deze dijk komt veel verschillende data kijken. We gaan aan de slag met het Digitaal Topografisch Bestand van RWS en puntenwolken. Aan de hand van deze data laten we zien welke stappen er nodig zijn om van de beschikbare brondata tot een 3D-webomgeving te komen gebruikmakend van open source tooling en open standaarden.  

De workshop is ingedeeld in twee modules, te weten: 

Deel 1: Dataverwerking tot 3D Tiles 

- 3D Tiles specificatie 

- Batched 3D Models en Instanced 3D Models 

- PostgreSQL en PostGIS 

[1_dataverwerking.md](1_dataverwerking.md)

Deel 2: Datavisualisatie in 3D met behulp van CesiumJS 

- 3D tilesets inladen 

- Tileset stijl aanpassen 

- 3D modellen toevoegen 

[2_datavisualisatie.md](1_datavisualisatie.md)

## Leerdoelen 

Na afronding van deze cursus: 

- weet je wat de 3D Tiles standaard is; 

- heb je inzicht in de software en technieken die nodig zijn om 3D tilesets te maken; 

- kun je een 3D tileset inladen in een CesiumJS-webomgeving; 

- weet je wat de mogelijkheden zijn voor datavisualisatie met CesiumJS. 

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

Voorbeelddirectory: C:\Program Files\QGIS 3.36.1\bin.

kan via Control panel - System - Edit the system Environment Variables - Environment Variables... - System Variables - Path of via de commandline:

 ```shell
set PATH=%PATH%;D:\Program Files\QGIS 3.36.1\bin
```

Check:

```shell
ogr2ogr --version
GDAL 3.8.4, released 2024/02/08
```

- Database management tool (bijv. pgAdmin of DBeaver)

pgAdmin: https://www.pgadmin.org/

DBeaver: https://dbeaver.io/

De command line liefhebbers kunnen ook psql gebruiken. psql.exe staat standaard in de bin directory van de QGIS installatie.

- Node.JS 

Download en installeer Node.js (https://nodejs.org/en/download/)

Check:

```shell
node --version
v21.7.1
```

In de workshop wordt operating systeem Windows gebruikt, met wat kleine aanpassingen kunnen
ook andere operating systemen gebruikt worden. 

## Lokaal aanmaken database met Docker 

Om eenvoudig lokaal een PostGIS database aan te maken kan je een Docker Image ophalen en starten. Doe dat met de volgende command in de command line: 

```
docker run -d -e POSTGRES_PASSWORD=postgres -d -p 5439:5432 postgis/postgis 
```

Uitleg command: 

Docker run: start een nieuwe container.

Met -e environment settings, zoals een wachtwoord of username. 

Met -d zorgt dat de docker ‘detached’ runt, zodat deze niet de terminal blokkeert, maar op de achtergrond draait. 

Met -p verzorg de portmapping. Als je al een lokale installatie hebt van Postgres, dan zal deze waarschijnlijk al op port 5432 draaien. Daarom maken we een mapping met -p {host}:{container}, in dit geval 5439. Hiermee open je de port 5439 die aansluit op port 5432 van de container. Zo kan je dus via localhost port 5439 connectie maken met de postgres database van je container. 

Vervolgens kan in DBeaver of PGAdmin en in QGIS connectie gemaakt worden met de database door een connectie toe te voegen. In de settings gebruik: 

- Host: localhost 

- Port: 5439 

- Username: postgres 

- Password: postgres 

Check: Vraag PostGIS versie op met de volgende SQL query:

Voorbeeld met psql client:

```shell
psql -h localhost -p 5439 -U postgres -d postgres -c "SELECT postgis_full_version();"
POSTGIS="3.4.0 0874ea3"
```
## Werkdirectory

Maak een werkdirectory aan waarin bestanden van deze workshop worden opegslagen.

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