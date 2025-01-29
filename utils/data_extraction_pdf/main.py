from extract_marks import extract_marks_from_pdf
from database_utils.get_ids_of_subjects import get_ids_of_subjects
from database_utils.transformation_of_data import transform_data
from database_utils.insert_into_database import insert_into_database


def main():
    # Script that gets all the data from the pdf's and inserts them inside the database
    years = range(2010, 2025)

    calls = {"ordinaria": 0, "extraordinaria": 1, "global": 2}

    print("|-------- 0 -- 1 -- 2 --|")
    for year in years:
        print("|" + str(year) + ":", end="", flush=True)
        for call in calls.keys():

            # Gets all the data
            table = extract_marks_from_pdf(call, year)

            # Gets all the equivalences of the codes and ids
            equiv_id = get_ids_of_subjects()

            rows = transform_data(table, equiv_id, calls, year, call)

            insert_into_database(rows)

            print("    X", end="", flush=True)
        print("   |")


if __name__ == "__main__":
    main()
