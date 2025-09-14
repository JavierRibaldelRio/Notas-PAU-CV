# PAU Grades Data Processing (Valencian Community)

**Note:** This is not the main repository README. This folder acts as a set of utilities solely for parsing and acquiring PAU grades data. It contains scripts and tools for extracting, transforming, and loading PAU grades and related information. Other modules may exist for analysis or visualization.

## Project Structure

- `add_subjects_to_db/`: Scripts for adding subjects to the database.
- `extract_grades_by_subject/`: Extracts grades by subject from PDF files and loads them into the database.
- `extract_results_by_high_school/`: Extracts and processes results by high school, including fetching high school data.
- `regions/`: Adds municipalities and regions data.
- `requirements.txt`: Python dependencies.

## Usage

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
2. Run extraction scripts as needed:
   - For grades by subject:
     ```bash
     python extract_grades_by_subject/run.py
     ```
   - For high school results:
     ```bash
     python extract_results_by_high_school/run.py
     ```
   - For adding subjects or regions, run the respective scripts in their folders.

## Requirements
- Python 3.10+
- See `requirements.txt` for required packages.
