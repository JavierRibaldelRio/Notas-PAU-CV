import sqlite3  # Import the SQLite library for database operations
import csv      # Import the CSV library for reading CSV files

"""
This script reads subject equivalence codes from a CSV file and inserts them into the 'subjects' table in a SQLite database.
"""

# Connect to the SQLite database
conn = sqlite3.connect("../../../data/notas-pau.db")

# Open the CSV file containing subject code equivalences
with open("../../../data/asignaturas/equivalencias_codigo_asignaturas.csv", mode="r") as file:
    reader = csv.reader(file)  # Create a CSV reader object

    # Iterate over each row in the CSV file
    for row in reader:
        # Determine the main code: use row[1] if present, otherwise row[0]
        codigo = row[0].strip() if row[1] == "" else row[1].strip()

        # Combine both codes into a comma-separated string for 'other_names'
        otros_codigos = " ".join([row[0], row[1]]).strip().replace(" ", ", ")

        # Get the subject name from the third column
        subject = row[2].strip()

        # Insert the subject data into the 'subjects' table
        conn.execute(
            "INSERT INTO subjects(code, name, other_names) VALUES(?,?, ?) ",
            (codigo, subject, otros_codigos),
        )

# Commit the transaction and close the database connection
conn.commit()
conn.close()