# Main script to extract and insert the type center results into the database.
# Iterates through years and calls, processing PDFs and storing the results.
from type_center_results import type_center_results
from insert_into_database import insert_into_database

def main():
    # Define the range of years to process (from 2010 to 2024 inclusive)
    years = range(2014, 2025)

    # Define the types of exam calls
    calls = {"ordinaria": 0, "extraordinaria": 1, "global": 0}

    # Print header for progress visualization
    print("|-------- 0 -- 1 -- 2 --|")
    for year in years:
        # Print the current year
        print("|" + str(year) + ":", end="", flush=True)
        for call in calls.keys():
            # Get the global results for the given call and year
            table = type_center_results(call, year)

            # Insert the results into the database
            for row in table:
                insert_into_database(row)

            # Print progress marker
            print("    X", end="", flush=True)
        # End of the year row
        print("   |")


# Script entry point
if __name__ == "__main__":
    main()