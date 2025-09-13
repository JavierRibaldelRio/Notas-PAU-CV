# Main script to extract, transform and insert PAU grades into the database.
# Iterates through years and calls, processing PDFs and storing the results.
from extract_marks_from_pdf import extract_marks_from_pdf
from get_id_of_subject import get_id_of_subject
from transformation_of_data import transform_data
from insert_into_database import insert_into_database

# Main function that manages the flow of extraction and storage of grades.
def main():
    # Defines the range of years to process (2010-2024)
    years = range(2010, 2025)

    # Dictionary of calls and their associated code
    calls = {"ordinaria": 0, "extraordinaria": 1, "global": 2}

    print("|-------- 0 -- 1 -- 2 --|")
    for year in years:
        # Shows the current year in the console
        print("|" + str(year) + ":", end="", flush=True)
        for call in calls.keys():
            # Extracts grades from the PDF for the current call and year
            table = extract_marks_from_pdf(call, year)

            # Gets the equivalences between codes and subject IDs
            equiv_id = get_id_of_subject()

            # Transforms the extracted data into rows ready for the database
            rows = transform_data(table, equiv_id, calls, year, call)

            # Inserts the rows into the database
            insert_into_database(rows)

            # Marks progress in the console
            print("    X", end="", flush=True)
        print("   |")

# Script entry point
if __name__ == "__main__":
    main()
