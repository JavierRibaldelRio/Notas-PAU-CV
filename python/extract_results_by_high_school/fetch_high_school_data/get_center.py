import sqlite3
import subprocess


# Given a center code, checks if it exists in the database.
# If not, adds it. Always returns the id of the corresponding database row.
def get_center_id(code):

    # Connect to the data base
    conn = sqlite3.connect("data/notas-pau.db")
    cur = conn.cursor()

    # Checks if the center is already added
    re = cur.execute("SELECT id FROM high_schools WHERE code = ? ", (code,)).fetchone()

    if re is not None:
        return re[0]

    # If it not exists adds it to the database using subprocess to call the add_center script
    if re == None:

        result = subprocess.run(
            [
                "python3",
                "utils/data_extraction_pdf/database_utils/high_schools/add_center.py",
                code,
            ],
            capture_output=True,
            text=True,
        )

        if result.returncode == 0:
            print(f"Center {code} added successfully.")
            return int(result.stdout.strip())
        else:
            print(f"Error adding center {code}:", result.stderr)
            return None
