# PAU Grades Extraction and Database Insertion

This set of scripts automates the extraction, transformation, and storage of PAU (Pruebas de Acceso a la Universidad) grades for the Valencian Community from PDF files into a SQLite database.

## Workflow Overview
1. **run.py**: Main entry point. Iterates through years and calls ("ordinaria", "extraordinaria", "global"), orchestrating the extraction, transformation, and insertion of grades.
2. **extract_marks_from_pdf.py**: Extracts raw grade tables from PDF files for each year and call, handling both compulsory and optional subjects.
3. **get_id_of_subject.py**: Maps subject codes found in the PDFs to their corresponding IDs in the database using the `subjects` table.
4. **transformation_of_data.py**: Cleans and transforms the raw data, handling exceptions, converting strings to numbers, and adding calculated columns (such as year and call).
5. **insert_into_database.py**: Inserts the transformed data rows into the `marks` table of the SQLite database.

## How It Works
- The process starts with `run.py`, which loops through all years (2010-2024) and calls.
- For each combination, it extracts the grades from the corresponding PDF using `extract_marks_from_pdf.py`.
- Subject codes are mapped to database IDs via `get_id_of_subject.py`.
- The data is cleaned and transformed in `transformation_of_data.py`.
- Finally, the processed rows are inserted into the database by `insert_into_database.py`.

## Requirements
- Python 3.x
- `pdfplumber` library
- SQLite database with the required schema (`subjects` and `marks` tables)
- PDF files located in `../data/convocatorias/{convo}/{year}-{convo}.pdf`

## Usage
Run the main script:
```bash
python run.py
```
This will process all available PDFs and populate the database with the extracted grades.

## File Descriptions
- **run.py**: Orchestrates the entire process.
- **extract_marks_from_pdf.py**: Handles PDF parsing and table extraction.
- **get_id_of_subject.py**: Provides subject code to ID mapping.
- **transformation_of_data.py**: Cleans and formats the data for database insertion.
- **insert_into_database.py**: Handles database insertion logic.
