# High School Exam Results Extractor (Notas PAU CV)

This project extracts, processes, and stores high school exam results (PAU) from PDF files for the Comunidad Valenciana. The results are parsed, cleaned, and inserted into a SQLite database for further analysis.

## Features
- Extracts tables from PDF files using `tabula-py` and `pdfplumber`.
- Cleans and formats data for different years and exam calls.
- Maps high school codes to database IDs (automatically adds new centers if not found).
- Stores results in a structured SQLite database.


## Requirements
- Python 3.8+
- `tabula-py`
- `pdfplumber`
- `pandas`
- `sqlite3` (standard library)

Install dependencies:
```bash
pip install tabula-py pdfplumber pandas
```

## How It Works
1. **PDF Extraction:**
   - The script locates the relevant pages in each PDF and extracts tables using `tabula-py`.
2. **Data Cleaning:**
   - Data is cleaned and formatted according to the year and call (ordinaria, extraordinaria, global).
   - High school codes are mapped to database IDs. If a code is not found, the function adds the new center to the database automatically.
3. **Database Storage:**
   - Cleaned results are inserted into the `high_school_marks` table in the SQLite database.

## Usage
Run the main script to process all available years and calls:
```bash
python run.py
```

## Database Schema
The `high_school_marks` table expects the following columns:
- `high_school_id`
- `enrolled_total`
- `candidates`
- `pass`
- `pass_percentatge`
- `average_bach`
- `standard_dev_bach`
- `average_compulsory_pau`
- `standard_dev_pau`
- `diference_average_bach_pau`
- `year`
- `call`

## Customization
- To add new years or calls, place the corresponding PDF files in `data/convocatorias/{call}/{year}-{call}.pdf`.
- Update the database schema if you need to store additional fields.

## Troubleshooting
- Ensure all dependencies are installed.
- Check that PDF files are correctly named and placed in the expected folders.
- If you encounter errors, review the console output for details on problematic rows or files.
- If you have issues with Java or tabula (e.g., errors about Java not found), set the following environment variables before running the script:
  ```bash
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
  export PATH=$JAVA_HOME/bin:$PATH
  ```


