import sqlite3
import csv

"""
Script to add municipalities and regions to the SQLite database from a CSV file.
- Reads data from 'comarca-municipios.csv'.
- Chooses Spanish names when available.
- Adds new regions if they do not exist.
- Inserts municipalities with their region and province info.
"""


# Province name to ID mapping

provinces = {"valencia": 1, "castellón": 2, "alicante": 3}


# Function to select Spanish name if available
# If normal = False, selects the second name (usually Spanish) when '/' is present
# Otherwise, returns the name in lowercase
def choose_spanish(str, normal=True):
    if "/" in str:
        return str.split("/")[normal].strip().lower()
    return str.lower()


db_path = "data/notas-pau.db"
conn = sqlite3.connect(db_path)

# Open CSV file with municipality and region data
with open("data/comarca-municipios/comarca-municipios.csv", mode="r") as file:

    reader = csv.reader(file)

    # Format each row: province, region, INE code, municipality name, original name

    data = list(
        map(
            lambda x: [
                choose_spanish(x[0], False),  # Province (Spanish name)
                choose_spanish(x[1]),         # Region name
                x[2],                         # INE code
                choose_spanish(x[3]),         # Municipality name (Spanish)
                x[3].lower(),                 # Original name
            ],
            reader,
        )
    )

    for row in data:
        # Check if region exists in DB
        region = conn.execute(
            "SELECT id,province FROM regions WHERE name=?", (row[1],)
        ).fetchone()

        # If region does not exist, insert it
        if region == None:
            conn.execute(
                "INSERT INTO regions(name, province) VALUES(?,?)",
                (row[1], provinces[row[0]]),
            )
            conn.commit()

            region = conn.execute(
                "SELECT id,province FROM regions WHERE name=?", (row[1],)
            ).fetchone()

            print(region)

        # Insert municipality with region and province info
        conn.execute(
            "INSERT INTO municipalities(ine_code, name, other_names, region, province) VALUES (?,?,?,?,?)",
            (row[2], row[3], row[4], region[0], region[1]),
        )


# Commit changes and close connection
conn.commit()
conn.close()
