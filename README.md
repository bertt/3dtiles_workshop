# Introductie 

Digital Twins brengen data uit verschillende bronnen waarheidsgetrouw samen in een digitale kopie van de fysieke werkelijkheid. Het begrip digital twin is zeer breed. In deze workshop richten we ons op digital twins van de fysieke leefomgeving. Hierin wordt een realistisch beeld gegeven van een gebied of regio, waarbij ruimtelijke data overzichtelijk weergegeven wordt en gebruikt kan worden voor vele toepassingen. Een dergelijke digital twin kan niet zonder de 3D component. De meeste data is echter niet direct als 3D beschikbaar. Daarom moet de data vaak eerst verwerkt worden. Deze verwerkingsstappen kunnen flink uiteenlopen afhankelijk van het type brondata. 

## Workshop

In deze workshop leer je aan de hand van een aantal voorbeelden hoe deze dataverwerking in elkaar steekt. De focus ligt op de 3D Tiles specificatie. Deze OGC-standaard helpt de weergave van grote 3D-datasets te optimaliseren door op slimme wijze alleen de noodzakelijke data in te laden. De hoeveelheid data in een digital twin is vaak namelijk enorm, waardoor het tegelijk opvragen van alle beschikbare data niet wenselijk is met het oog op de performance. 

<img src = "3dtiles_ecosysteem.png">

Daarnaast geeft deze workshop inzicht in hoe je vanuit de geproduceerde 3D-data naar de daadwerkelijke visualisatie kunt komen. 3D Tiles kunnen door veel verschillende applicaties gebruikt worden (Figuur 1). In dit geval gaan we gebruik maken van CesiumJS, een krachtige open source Javascript library waarmee tilesets ingeladen kunnen worden in de browser. Met CesiumJS kan een digital twin-omgeving vormgegeven worden waarin grote hoeveelheden data als 3D Tiles geserveerd worden. 

In deze workshop gaan we een digital twin inrichten voor de Proefpolderdijk bij Andijk. Bij het beheer van deze dijk komt veel verschillende data kijken. We gaan aan de slag met het Digitaal Topografisch Bestand van RWS en puntenwolken. Aan de hand van deze data laten we zien welke stappen er nodig zijn om van de beschikbare brondata tot een 3D-webomgeving te komen gebruikmakend van open source tooling en open standaarden.  

De workshop is ingedeeld in twee losstaande modules, te weten: 

Deel 1: Dataverwerking tot 3D Tiles 

- 3D Tiles specificatie 

- Batched 3D Models en Instanced 3D Models 

- PostgreSQL en PostGIS 

- Puntenwolken 

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

- QGIS

- Database management tool (bijv. pgAdmin of DBeaver)

In de workshop wordt operating systeem Windows gebruikt, met wat kleine aanpassingen kunnen
ook andere operating systemen gebruikt worden. 

## Data bestanden

In deze workshop wordt de directory c:\workshop als standaard directory gebruikt.

## Lokaal aanmaken database met Docker 

Om eenvoudig lokaal een database aan te maken kan je een Docker Image pullen en deze runnen. Doe dat met de volgende command in de command line of in GIT Bash: 

```
docker run -d --name postgis_container -e POSTGRES_PASSWORD=postgres -d -p 5439:5432 postgis/postgis 
```

Vervolgens kan je in DBeaver of PGAdmin en in QGIS connectie maken met deze database door een connectie toe te voegen. In de settings zet je het volgende: 

- Host: localhost 

- Port: 5439 

- Username: postgres 

- Password: postgres 

Uitleg command: 

Met Docker roep je Docker aan met run bouwt Docker automatisch je image en draait deze meteen als container. 

Met --name geef je een naam aan je image. 

Met -e environment settings, zoals een wachtwoord of username. 

Met -d zorg je dat de docker ‘detached’ runt, zodat deze niet je terminal blokkeert, maar op de achtergrond draait. 

Met -p verzorg je de portmapping. Als je al een lokale installatie hebt van Postgres, dan zal deze waarschijnlijk al op port 5432 draaien. Daarom maken we een mapping met -p {host}:{container}, in dit geval 5439. Hiermee open je de port 5439 die aansluit op port 5432 van de container. Zo kan je dus via localhost port 5439 connectie maken met de postgres database van je container. 

 

