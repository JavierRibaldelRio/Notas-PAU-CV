import sqlite3


def get_ids_of_subjects():

    # Output dict with the equivalences
    output = {}

    # Connection
    conn = sqlite3.connect("../data/notas-pau.db")
    cur = conn.cursor()

    # Get all subjects
    for subject in cur.execute("SELECT id, other_names FROM subjects").fetchall():

        for code in subject[1].split(", "):
            output[code] = subject[0]

    conn.close()

    return output
