import sqlite3

# Inserts a list of rows into the 'high_school_types_results' table of the database.
def insert_into_database(row):

    # Establish connection to the database
    conn = sqlite3.connect("../data/notas-pau.db")


    # Insert each row into the 'high_school_types_results' table
    conn.execute(
        "INSERT INTO high_school_types_results(year, call, type_id, enrolled, candidates, pass, pass_percentage, candidates_m, candidates_w, pass_percentage_m, pass_percentage_w, average_bach, standard_dev_bach, average_pau, standard_dev_pau, average_nau, standard_dev_nau, final_average_pass, exclusive_candidates_general, exclusive_candidates_especific, candidates_both, fp_candidates_especific) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        row,
    )
    # The final order of the row fields: year, call, type_id, enrolled, candidates, pass, pass_percentage, candidates_m, candidates_w, pass_percentage_m, pass_percentage_w, average_bach, standard_dev_bach, average_pau, standard_dev_pau, average_nau, standard_dev_nau, final_average_pass, exclusive_candidates_general, exclusive_candidates_especific, candidates_both, fp_candidates_especific

    # Commit changes and close the connection
    conn.commit()
    conn.close()