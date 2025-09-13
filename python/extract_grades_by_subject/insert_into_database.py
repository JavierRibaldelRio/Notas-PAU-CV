import sqlite3

# Inserts a list of rows into the 'marks' table of the database.
def insert_into_database(rows):

    # Establish connection to the database
    conn = sqlite3.connect("../data/notas-pau.db")

    for row in rows:
        # Insert each row into the 'marks' table
        conn.execute(
            "INSERT INTO marks(subject_id,enrolled_total,candidates, pass, pass_percentatge,average, standard_dev, candidates_compulsory, candidates_optional, pass_optional,pass_compulsory, year, call) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
            row,
        )
        # The final order of the row fields: subject, ... (as in the PDF), pass_obligatory_phase, year, call.

    # Commit changes and close the connection
    conn.commit()
    conn.close()
