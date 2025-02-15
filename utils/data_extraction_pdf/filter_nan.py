from extract_marks_high_schools import marks_from_high_schools
import pandas as pd

def filter_nan(convo, year):

    # Creates a table
    table = marks_from_high_schools(convo, year)
    filtered_rows = []
    for row in table:
        if not pd.isna(row):
            filtered_rows.append(row)
        else:

            # WARNING!!! Execute the file from the utils/data_extraction folder
            file = open("../../data/high_school_extraction_errors.txt", "a")

            # Writes all the errors in the file previously set
            file.write(", ".join(row) + "\n")

    return filtered_rows