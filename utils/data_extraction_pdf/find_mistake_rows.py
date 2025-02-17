import pandas as pd


def check_if_row_has_all_data(row):

    return  row.count(float('nan')) != 0
    

def find_mistaken_rows(table):
    
    filtered_rows = []

    with open("../../data/high_school_extraction_errors.txt", "a") as file:
        for row in table:
            count = 0
            for i in row:
                if pd.isna(i):
                    count += 1
                    break

            if count == 0:
                filtered_rows.append(row)
            
            else:
                # Writes all the errors in the file previously set
                row_str = map(str, row)
                file.write(", ".join(row_str) + "\n")

        file.close()

    return filtered_rows