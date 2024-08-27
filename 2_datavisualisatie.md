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

Kopieer index.html naar de werkdirectory

Open index.html in een teksteditor. In de code worden 3 tilesets geladen:

-  DTB Vlakken: ./dtb_vlakken/tileset.json

-  DTB puntent: ./dtb_punten/tileset.json

-  Andijk panden: ./andijk_panden/tileset.json

Open een brower en ga naar [http://localhost:8080/index.html](http://localhost:8080/index.html). Je ziet nu de 3D Tiles in de Cesium Viewer.

De Cesium viewer bevat een aantal kaartlagen:

- PDOK BRT achtergrondkaart;

- 3D Basisvoorziening - Digitaal Terreinmodel (DTM)

https://api.pdok.nl/kadaster/3d-basisvoorziening/ogc/v1_0/collections/digitaalterreinmodel

Inspecteer de viewer op de DTB vlakken, bomen en panden. Welke attributen zijn er beschikbaar per laag?

We zien dat de DTB vlakken soms verdwijnen onder het terrein, dit is eventueel op te lossen door de vlakken iets te verhogen
  
  ```javascript
var translation = new Cesium.Cartesian3(0, 0, 5); 
var modelMatrix = Cesium.Matrix4.fromTranslation(translation);
tilesetDtbVlakken.modelMatrix = modelMatrix;
 ```

## Tileset stijlen aanpassen

Styling kan worden toegepast op de tileset op twee manieren:

- tijdens het genereren van de tileset

- via de index.html file

In deze oefening wordt de styling toegepast via de index.html file.

Zie voor een beschrijving van de 3D Tiles Styling language https://github.com/CesiumGS/3d-tiles/tree/main/specification/Styling

Open index.html in een teksteditor. Voeg de volgende code toe aan de tileset van de DTB vlakken:

```javascript
    tilesetDtbVlakken.style = new Cesium.Cesium3DTileStyle({
      color: {
        conditions: [
        ["${feature['osmchr']} === 'Bitumen'", "color('#430719')"],
        ["${feature['omschr']} === 'Steen bekleding'", "color('#740320')"],
        ["${feature['omschr']} === 'Bomen en struiken'", "color('#008000')"],
        ["${feature['omschr']} === 'Industrieterrein'", "color('#FFFF00')"]
        // todo: add more conditions
        ]
      }
    });
```

Bekijk het resultaat in de Cesium Viewer. De vlakken zijn nu gekleurd op basis van de omschrijving van de vlakken. 

Experimenteer met de kleuren en voeg meer condities toe.

## 3D modellen toevoegen

Naast 3D Tiles kunnen we ook losse 3D modellen toevoegen aan de visualisatie.

Kopieer het 3D model 'windturbine.glb' naar de werkdirectory.

Voeg de volgende code toe aan index.html en bekijk het resultaat in de browser:

```javascript
    const windturbine = viewer.entities.add({ 
      position: Cesium.Cartesian3.fromDegrees(5.193486,52.754867), 
      model: { 
        uri: "windturbine.glb"         
     }, 
    });
```

Als het goed is zie je nu een windturbine met animatie in de Cesium Viewer.

<img src = "windturbine.gif">

## 3D Basisvoorziening

In de 3D Basis voorziening van PDOK zijn een aantal 3D Tilesets beschikbaar die we kunnen inladen in de Cesium Viewer.

Zie https://api.pdok.nl/kadaster/3d-basisvoorziening/ogc/v1_0/collections/gebouwen voor een beschrijving van de 3D gebouwen 
tileset. 

Voeg deze tileset toe aan de Cesium Viewer en inspecteer de gebouwen.

```javascript
const tileset3DGebouwen = await Cesium.Cesium3DTileset.fromUrl(
  "https://api.pdok.nl/kadaster/3d-basisvoorziening/ogc/v1_0/collections/gebouwen/3dtiles"
);  
viewer.scene.primitives.add(tileset3DGebouwen);
```


## QGIS

In deze oefening gaan we de gemaakte 3D Tiles inladen in QGIS.

Open QGIS en ga naar de menu optie 'Layer' -> 'Data Source Manager' en selecteer 'Scene'.

Voeg de DTB vlakken toe via 

- Zet 'Source Type' op 'Service'

Maak een nieuwe connectie aan via knop 'New' -> 'New Cesium 3D Tiles Connection'

Name: DTB Vlakken

URL: http://localhost:8080/dtb_vlakken/tileset.json

Klik op Add en als het goed is zie je nu de DTB vlakken in QGIS.

Vraag: Waarom zien we de gedefinieerde stylen niet in QGIS?

Extra opgave: Voeg de Andijk panden toe aan QGIS.

Voor het bekijken in 3D in QGIS, ga naar View -> 3D Map Views ->  new 3D Map View

Als het goed is opent er een nieuw venster met de 3D Tiles.

Wat valt er op aan de 3D View in QGIS?



