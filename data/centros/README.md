# GVA Educational Localities Dataset

This folder contains data originally downloaded from the Generalitat Valenciana (GVA) website.

## Data Source

The dataset was originally downloaded from the GVA (Generalitat Valenciana) website:  
[https://ceice.gva.es/es/web/educacion](https://ceice.gva.es/es/web/educacion)  
However, for unknown reasons, it is no longer available or has been removed from the official site.

## Files

- `centros_educativos_cv.xls`: the original file as downloaded.
- `centros_educativos_cv-only-municipality.csv`: a cleaned version of the data.

## Description and Context

The dataset lists **localities** associated with educational centers in the Valencian Community.  
In the original version, locality names often included both the **municipality and a smaller administrative unit** (such as a village or *pedanía*), formatted as:  
`València - El Saler`.

These names reflect the geographic classification used for schools, and not necessarily official administrative boundaries.

## Data Transformation

To simplify the dataset and enable consistent grouping at the **municipality level**, the following operations were applied:

1. **Split by hyphen (`-`)**: The original locality column was split using LibreOffice Calc’s **"Text to Columns"** tool with `-` as the delimiter.
2. **Remove pedanía**: Only the first part (the municipality) was retained, and the second part (pedanía or smaller unit) was discarded.
   - For example:  
     - `Valencia - El Saler` → `Valencia`  
     - `Elx - La Marina` → `Elx`
3. **Handle exceptions**: Some municipalities contain a legitimate hyphen in their names, such as:
   - `Vila-real`
   - `Riba-roja del Túria`

   These names were mistakenly split during the initial operation and were **manually corrected** to preserve their proper form.

This cleaned version enables standardized analysis of school data by municipality.
