import sqlite3


def insert_into_database(rows):

    # Connection
    conn = sqlite3.connect("../../data/notas-pau.db")

    for row in rows:

        conn.execute(
            "INSERT INTO marks(subject_id,enrolled_total,candidates, pass, pass_percentatge,average, standard_dev, candidates_compulsory, pass_compulsory, candidates_optional, pass_optional, year, call) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
            row,
        )

    conn.commit()
    conn.close()
