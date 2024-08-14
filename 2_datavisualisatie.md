# 2. Data visualisatie

In deze module gaan we aan de slag met het visualiseren van de 3D Tiles die we in de vorige module hebben gemaakt. We gaan de 3D Tiles inladen in een CesiumJS-webomgeving en de tileset stijlen aanpassen. Daarnaast voegen we 3D modellen toe aan de visualisatie.

## Server opzetten

We beginnen met het installeren van een webserver om de 3D Tiles te serveren. We gebruiken hiervoor Node.JS tool 'http-server'.

```shell
npm install -g http-server
``` 

Open de command line en navigeer naar werkdirectory. Start de server met het volgende commando:

```shell
http-server
```

Open een webbrowser en ga naar [http://localhost:8080](http://localhost:8080). Je ziet nu de bestanden in de werkdirectory.

## Cesium Viewer

Voor het inladen van de 3D Tiles in een CesiumJS-webomgeving, maken we gebruik van de Cesium Viewer.



