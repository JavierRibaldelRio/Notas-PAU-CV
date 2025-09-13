# Center Registration Module (XACEN Data Integration)

This module handles the automated registration of high schools into a SQLite database using external data sources, including CSV records and the public XACEN portal. It is designed as a standalone component of a broader educational data processing project.

## Overview

- `add_center.py`: Fetches and inserts a single center into the database using Playwright to intercept HTTP requests to the XACEN backend.
- `get_center.py`: Contains the `get_center_id()` function, which returns the internal database ID of a given center code. If the center is not yet registered, it triggers `add_center.py` as a subprocess to add it.

## Dependencies

### Python packages

Make sure to install the required libraries in a virtual environment:

```bash
pip install playwright requests
playwright install firefox
```

### Arch Linux system dependencies

To ensure Playwright works properly on Arch-based systems, install the following system libraries:

```bash
sudo pacman -Syu libwebp icu libffi
```

If `playwright install` complains about missing `.so` versions (e.g., `libicui18n.so.66`), you may need to create symbolic links pointing to the current version:

```bash
sudo ln -s /usr/lib/libicui18n.so /usr/lib/libicui18n.so.66
```

Repeat this for any missing `.so` files.

## File Descriptions

### `add_center.py`

- Loads center metadata from a CSV file.
- Fetches additional information (email, owner, CIF, website) via a Playwright-based scraper that intercepts the `GET` request made by the frontend.
- Downloads an official image of the center (if available) from the Generalitat Valenciana website.
- Inserts the full record into the `high_schools` table in `data/notas-pau.db`.

**Scraping logic**:
- Opens the center URL on `xacen.gva.es`.
- Waits for the JavaScript frontend to launch its API request.
- Intercepts the HTTP response to extract relevant fields using `page.wait_for_response(...)`.

### `get_center.py`

- Defines the function `get_center_id(code)`, which checks whether a center with the given code already exists in the database.
- If the center is missing, it calls `add_center.py` using `subprocess.run(...)`, capturing the output (`stdout`) to retrieve the new database ID.
- Intended to be used programmatically by other components of the system.

## How to Run

To add a single center manually:

```bash
python add_center.py 03018684
```

To query or ensure the presence of a center by code using the `get_center_id()` function:

```python
from get_center import get_center_id
center_id = get_center_id("03018684")
```

This will return the internal ID from the `high_schools` table, adding the center first if needed.

## Required External Resources

Ensure the following files and structures are present and correctly linked:

- SQLite database:
  ```
  data/notas-pau.db
  ```
  This database must include the following tables:
  - `high_schools`
  - `municipalities`

- CSV file with base metadata:
  ```
  data/centros/centros_educativos_cv-only-municipality.csv
  ```
  This file should contain at least the fields: `Codigo`, `Denominacion`, `Tipo_Via`, `Direccion`, `Num`, `Codigo_postal`, `Telefono`, `Fax`, `Titularidad`, `CIF`, `lat`, `long`, `Localidad`, and `Regimen`.

- Network access to:
  - `https://xacen.gva.es` (frontend interface)
  - `https://xacen-backend.gva.es` (API endpoint)
  - `https://ceice.gva.es/abc/i_guiadecentros/Fotos/{code}.jpg` (optional center image)

## Notes

- `add_center.py` commits and closes the database connection per call.
- Any errors during scraping (timeout, parsing) are printed to `stderr`.
- Image downloads are optional; if unavailable, the field is stored as `NULL`.
- The module is designed to run safely under subprocess management.

## Limitations

- The script assumes consistent field names and structure in the CSV input.
- Network issues or backend errors may result in incomplete records or timeouts (default timeout: 60 seconds).
- The image endpoint does not always provide valid results for all center codes.

