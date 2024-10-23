# Optional Assignment: Buildings in Andijk

- Download buildings in Andijk

Url: https://3dbag.nl/en/download?tid=8-512-888

Result: `8-512-888.gpkg`

- Import the buildings into the database

    ```shell
    ogr2ogr -f PostgreSQL pg:"host=localhost user=postgres password=postgres port=5439" -t_srs epsg:4979 8-512-888.gpkg lod22_3d -nln andijk_panden
    ```

- Create a spatial index on the buildings

    ```sql
    psql -U postgres -h localhost -p 5439 -d postgres -c "CREATE INDEX andijk_panden_geom_idx ON public.andijk_panden USING GIST (geom);"
    ```

- Create 3D Tiles of the andijk_panden

```shell
docker run -v $(pwd)/output_andijk_panden:/app/output -it --network="host" geodan/pg2b3dm -h localhost -p 5439 -U postgres -d postgres -t public.andijk_panden -a identificatie --use_implicit_tiling false -o /app/output -c geom --create_gltf false
```