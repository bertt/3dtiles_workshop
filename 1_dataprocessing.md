
# 1 - Data Processing

## Introduction 

In this part of the workshop, we will create 3D tilesets from geographical data. We will use open source tools to convert data from a PostgreSQL database to 3D Tiles.

As input data, we will use the Digital Topographic File (DTB) from Rijkswaterstaat. The DTB contains topographic data of the Netherlands in the form of lines, polygons, and points.

From the DTB, we will use two files:

- DTB polygons for models in Batched 3D Models (b3dm) format;

- DTB points for models in Instanced 3D Models (i3dm) format.

To achieve the conversion, we will:

- Download the DTB and import it into the PostgreSQL database with the PostGIS extension;

- Create two tables that will serve as input for pg2b3dm and i3dm.export;

- Create 3D tilesets from the DTB polygons and points.

### Download and import data

We will download DTB data from a small area near Andijk and import it into the database.

- Use the RWS DTB Sheet Viewer (https://maps.rijkswaterstaat.nl/geoweb55/index.html?viewer=DTB_Bladindeling.Webviewer) to find the Andijk map sheet (DTB map sheet `d15cz`)

- Click the link 'Klik hier om dit kaartblad als Shapefile (.zip) te downloaden' in the popup to download the data.

- Unzip the file and place the contents in `./data/dtb`

The zip-file contains 3 Shapefiles:

- d15cz_lin.shp (DTB lines)
- d15cz_reg.shp (DTB polygons)
- d15cz_sym.shp (DTB points)

To load the data into PostGIS, we will use the command-line tool ogr2ogr.

- Open a command prompt and navigate to the working directory

Execute the following command to load the DTB **polygons** into the database:

```shell
ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5439 user=postgres dbname=postgres password=postgres" ./data/dtb/d15cz_reg.shp -t_srs epsg:4979 -nln public.dtb_vlak_andijk -nlt MULTIPOLYGONZ
```

Then, execute the following command to load the DTB **points** into the database:

```shell
ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5439 user=postgres dbname=postgres password=postgres" ./data/dtb/d15cz_sym.shp -t_srs epsg:4979 -nln public.dtb_punt_andijk -nlt POINTZ
```

## Prepare the data

To convert the data to 3D Tiles, we need to create tables that will serve as input for pg2b3dm (surfaces) and i3dm.export (points).

**Create spatial indexes**
In your database client, execute the following SQL queries to make spatial indices:

```sql
CREATE INDEX ON public.dtb_vlak_andijk USING gist(st_centroid(st_envelope(wkb_geometry)));
CREATE INDEX ON public.dtb_punt_andijk USING gist(wkb_geometry);
```

For the points, we create an SQL view that contains the point attributes.

```sql
CREATE OR REPLACE VIEW public.v_dtb_punt_andijk AS
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

The database view is based on the DTB points and has the following properties: 

- we only select the trees ('Boom');

- we use a random rotation and scale;

- we add the model to be used (`tree.glb`);

- we add the attributes `dtb_id`, `description`, and `date` to the `tags` column.

## Creating 3D Tiles from DTB polygons

The following steps show how to create Batched 3D Models from the DTB polygons.

- Pull the [pg2b3dm image](https://github.com/Geodan/pg2b3dm) using docker: `docker pull geodan/pg2b3dm`
- Run the following docker command in the working directory: 
  ```shell
  docker run -v $(pwd)/output:/app/output -it --network="host" geodan/pg2b3dm -h localhost -p 5439 -U postgres -d postgres -t public.dtb_vlak_andijk -a dtb_id,omschr,datum --use_implicit_tiling false -o /app/output -c wkb_geometry --create_gltf false
  ```
- After entering the password (`postgres`), the 3D Tiles will be created in the `output` folder.

*Command explanation*

- `-v $(pwd)/output:/app/output`: mounts the output directory to the container
- `-it --network="host"`: starts the container in interactive mode and uses the host network
- `geodan/pg2b3dm`: runs the pg2b3dm image
- `-h localhost -p 5439 -U postgres -d postgres -t public.dtb_vlak_andijk`: connects to the database and selects the source table
- `-a dtb_id,omschr,datum`: selects the attributes of the table
- `--use_implicit_tiling false`: does not use 3D Tiles 1.1 implicit tiling
- `-o /app/output`: specifies the output directory
- `-c wkb_geometry`: selects the geometry column
- `--create_gltf false`: disables GLTF creation

The `output` directory contains:

- a `tileset.json` file. This file contains references to the 3D tiles.

- a `content` directory with the 3D tiles in b3dm format.


## Creating 3D Tiles from DTB points

To create Instanced 3D Models from the DTB points, we will use i3dm.export. This is also a Docker image available in the Geodan repository (`geodan/i3dm.export`).

```shell
docker run -v $(pwd)/output_i3dm:/app/output -it --network="host" geodan/i3dm.export -c "Host=host.docker.internal;Username=postgres;Password=postgres;Database=postgres;Port=5439" -t public.v_dtb_punt_andijk --max_features_per_tile 100 -o /app/output --use_external_model true
```

*Command explanation*

- `-v $(pwd)/output_i3dm:/app/output`: mounts the output directory to the container
- `-it --network="host"`: starts the container in interactive mode and uses the host network
- `geodan/i3dm.export`: runs the i3dm.export image
- `-c "Host=host.docker.internal;Username=postgres;Password=postgres;Database=postgres;Port=5439"`: connects to the database
- `-t public.v_dtb_punt_andijk`: selects the source table
- `--max_features_per_tile 100`: sets the maximum number of features per tile
- `-o /output`: specifies the output directory
- `--use_external_model true`: uses an external model (tree.glb)

After entering the password, the Instanced 3D tileset will be created in the `output_i3dm` directory.

The directory contain:

- a `tileset.json` file;

- a `content` directory with the 3D tiles in i3dm format.

- a subtree folder with a subtree file.

As a last step, in order for the `tree.glb` model to be available, copy it to the content directory of the i3dm tileset.

```shell
cp ./tree.glb ./output_i3dm/content
```


## Validating tilesets (optional)

The 3D tilesets can be validated with the [3D Tiles Validator tool](https://github.com/CesiumGS/3d-tiles-validator).


To install the 3D Tiles Validator, Node.js is required.

- Open a command prompt and install the 3D Tiles Validator

  ```shell
  npm install 3d-tiles-validator
  ```

- Validate the tilesets
  - For the polygons:
      
    ```shell
    3d-tiles-validator --tilesetFile ./dtb_vlakken/tileset.json
    ```
  - For the points:
  
    ```shell
    3d-tiles-validator --tilesetFile ./dtb_punten/tileset.json
    ```

## Compressing tilesets

The 3D tilesets can be compressed with the 3D Tiles Compressor tool.

To compress the DTB polygons, execute the following command:

```shell
docker run -v $(pwd)/output/content:/tiles -it geodan/compressor5000
```


## Comprimeren tilesets

De 3D tilesets kunnen gecomprimeerd worden met de tool 3D Tiles Compressor.

Voor het comprimeren van de DTB vlakken voer het volgende commanda  uit:

```shell
docker run -v c:\workshop_3dtiles\dtb_vlakken\content:/tiles -it geodan/compressor5000
```

## Optional assignment

- Create a 3D Tileset of buildings in Andijk. Use BAG data (in Geopackage format), downloadable from the 3dbag website (https://3dbag.nl/en/download). Make sure the attribute 'identification' is included in the 3D tileset.





## Facultatieve opdracht

- Maak een 3D Tileset van panden in Andijk. Gebruik hiervoor BAG data (in Geopackage formaat), te downloaden via de 3dbag website (https://3dbag.nl/en/download). Zorg ervoor dat de attribuut 'identificatie' wordt meegenomen in de 3D tileset.

Check your results in [1_dataprocessing_results.md](./resultaten/1_dataprocessing_results.md)

Comprimeer de 3D tileset met de 3D Tiles Compressor.

Ga door naar [2 - Data Visualisation](2_datavisualisation.md)











