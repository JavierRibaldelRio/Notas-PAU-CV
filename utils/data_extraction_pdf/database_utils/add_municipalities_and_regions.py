import sqlite3
import csv


# Equivalances

provinces = {"valencia": 1, "castellón": 2, "alicante": 3}


# If there is Spanish name of the places choses it over valencian name If noraml = False, str includes "/"
def choose_spanish(str, normal=True):
    if "/" in str:
        return str.split("/")[normal].strip().lower()
    return str.lower()


conn = sqlite3.connect("data/notas-pau.db")

with open("data/comarca-municipios/comarca-municipios.csv", mode="r") as file:

    reader = csv.reader(file)

    # Storages all the data in the right format

    data = list(
        map(
            lambda x: [
                choose_spanish(x[0], False),  # Provincia
                choose_spanish(x[1]),  # Comarca
                x[2],  # Código INE
                choose_spanish(x[3]),  # Nombre del municipio
                x[3].lower(),  # Nombre original
            ],
            reader,
        )
    )

    for row in data:

        # Buscar la comarca con determinada ID
        region = conn.execute(
            "SELECT id,province FROM regions WHERE name=?", (row[1],)
        ).fetchone()

        # Sí no existe la comarca la añade
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

        conn.execute(
            "INSERT INTO municipalities(ine_code, name, other_names, region, province) VALUES (?,?,?,?,?)",
            (row[2], row[3], row[4], region[0], region[1]),
        )


conn.commit()
conn.close()
