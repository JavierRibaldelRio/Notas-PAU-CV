# This script extracts high school exam results from PDF files, processes them, and stores them in a SQLite database.
# It uses helper functions to read and clean the data, and then inserts the results into the database.

from extract_marks_high_schools import marks_from_high_schools  # Function to extract marks from PDF files
from fetch_high_school_data.get_center import get_center_id     # Function to get high school ID from its code
import pandas as pd

import sqlite3  # Library for interacting with SQLite databases



calls = {"ordinaria": 0, "extraordinaria": 1, "global": 2}


# Main function that manages the flow of extraction and storage of grades.
def main():
    # Define the range of years and types of exam calls to process
    years = range(2010, 2025)

    # Connect to the SQLite database
    conn = sqlite3.connect("../data/notas-pau.db")
    cur = conn.cursor()

    # Iterate over each year and call type
    for year in years:
        for call in calls.keys():

            print("===================================")
            print("Extracting results for", call, year)

            try:
                # Read PDF and return a table with the results of each high school
                high_school_results = marks_from_high_schools(call, year)
                print(f"1st. Extracted {len(high_school_results)} records for {call} {year}")
                # Append IDs and clean data
                high_school_results = append_id_and_clean_data(high_school_results, year, call)
                # Print the cleaned results for verification
                print(f"2nd. Processed {len(high_school_results)} records for {call} {year}")

                # Store the processed results in the database
                store_results(high_school_results, conn, cur)

                print(f"3rd. Stored results for {call} {year}, total records: {len(high_school_results)}")
            except Exception as e:
                print(f"Error processing {call} {year}: {e}")

    # Close the database connection
    conn.close()

# For each high school, appends the id of the high school. If the code's length is less than 8, removes the row.
def append_id_and_clean_data(table, year, call):
    """
    Cleans and enriches the table of high school results by:
    - Filtering out rows where the high school code length is not 8.
    - Fetching the high school id using the code.
    - Creating a new tuple with the id, relevant data, year, and call.
    Returns a new list of processed rows ready for database insertion.
    """
    new_table = []
    for row in table:
        if pd.isna(row[0]):
            print(f"Row with NaN code found and removed in {year} {call}: ", row)

        elif len(row[0]) == 8:
            id = get_center_id(row[0])
            if id is not None:
                new_row = (id,) + tuple(row[1:-2]) + (year, calls[call])
                new_table.append(new_row)
    return new_table

# The expected columns in the database are:
# id, code, enrolled, candidates, pass, pass_percentage, average_bach, standard_dev_bach, average_compulsory_pau, standard_dev_pau, difference_average_bach_pau, year, call.

# Adds to the database the results of a high school
def store_results(high_school_results, conn, cur):
    # Insert the processed results into the high_school_marks table
    cur.executemany(
        "INSERT INTO high_school_marks(high_school_id, enrolled_total, candidates, pass, pass_percentatge, average_bach, standard_dev_bach, average_compulsory_pau, standard_dev_pau, diference_average_bach_pau, year, call) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        high_school_results
    )
    conn.commit()

# Entry point of the script
if __name__ == "__main__":
    main()