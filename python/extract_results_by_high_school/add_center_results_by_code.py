# Script to extract and store results for a specific high school center by code and year range
from extract_marks_high_schools import marks_from_high_schools 
from fetch_high_school_data.get_center import get_center_id    
from run import append_id_and_clean_data, store_results
import sqlite3

# Dictionary mapping call types to integer codes
calls = {"ordinaria": 0, "extraordinaria": 1, "global": 2}

# Main function to process and store results for a center code over a range of years
def add_center_results_by_code(code, years_range):
    # Connect to the SQLite database
    conn = sqlite3.connect("../data/notas-pau.db")
    cur = conn.cursor()

    # Get the internal center ID from the code
    center_id = get_center_id(code)

    print(f"Processing results for center code {code} with ID {center_id}")

    # Iterate over each year and call type
    for year in years_range:
        for call in calls.keys():

            print("===================================")
            print("Extracting results for", call, year)

            try:
                # Extract results for the given call and year
                high_school_results = marks_from_high_schools(call, year) 
                print(f"1.Extracting results for center code {code}, year {year}, call {call}")
        
                # Filter results for the specific center code
                high_school_results = filter(lambda x: x[0] == code, high_school_results)
                print(f"2.Filtered results for center code {code}, year {year}, call {call}")

                # Append center_id, year, and call to each row
                high_school_results = append_id(high_school_results, center_id, year, call)
                print(f"3.Processed results for center code {code}, year {year}, call {call}")

                # Store the processed results in the database
                store_results(high_school_results, conn, cur)
                print(f"4.Stored results for center code {code}, year {year}, call {call}") 
            
            except Exception as e:
                # Print error if any step fails
                print(f"Error processing {call} {year}: {e}")
    # Close the database connection
    conn.close()
    print(f"Finished processing results for center code {code}")
        

# Helper function to append center_id, year, and call to each row
def append_id(table, center_id, year, call):
    """
    Appends the given center_id to each row in the table along with year and call.
    Returns a new list of processed rows ready for database insertion.
    """
    new_table = []
    for row in table:
        # Create new row with center_id, selected columns, year, and call code
        new_row = (center_id,) +  tuple(row[1:-2]) + (year, calls[call])
        new_table.append(new_row)
    return new_table

# Example usage: process results for center code "03014897" from 2020 to 2024
# add_center_results_by_code("03014897", range(2020, 2025))