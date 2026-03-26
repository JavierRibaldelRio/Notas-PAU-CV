# Maps Folder

This folder contains the geographic data used to render regional maps in the application.

## Files

### `map-cv-comarcas.gpkg`
Original GeoPackage file containing the full-resolution geometries of the Valencian Community comarcas.  
This file preserves the original level of geometric detail and is kept for reference and reproducibility.

### `map-cv-comarcas-simple.gpkg`
Simplified version of the original map, created to improve performance in interactive visualizations (Shiny + Plotly).

The simplification was performed using **QGIS** with the following approach:
- Geometry simplification tool from the Processing Toolbox
- Douglas–Peucker algorithm
- A tolerance value selected to reduce vertex density while preserving the visual integrity of comarca boundaries

All original attributes were preserved during the simplification process.

## Notes

- The simplified map is intended for use in interactive and web-based contexts.
- The original map is retained to allow future reprocessing or comparison if different simplification parameters are required.
