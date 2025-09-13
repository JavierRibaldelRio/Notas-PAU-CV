import sqlite3


def insert_into_database(rows):

    # Connection
    conn = sqlite3.connect("../../data/notas-pau.db")

    for row in rows:

        conn.execute(
            "INSERT INTO marks(subject_id,enrolled_total,candidates, pass, pass_percentatge,average, standard_dev, candidates_compulsory, candidates_optional, pass_optional,pass_compulsory, year, call) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
            row,
        )

        # final order of the rows: subject, ... (like in the pdf), pass_obligatory_phase, year, convo.

    conn.commit()
    conn.close()
