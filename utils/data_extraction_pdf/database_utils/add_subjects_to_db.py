import sqlite3
import csv
import random


conn = sqlite3.connect("../../../data/notas-pau.db")

with open(
    "../../../data/asignaturas/equivalencias_codigo_asignaturas.csv", mode="r"
) as file:

    reader = csv.reader(file)

    for row in reader:

        codigo = row[0].strip() if row[1] == "" else row[1].strip()

        otros_codigos = " ".join([row[0], row[1]]).strip().replace(" ", ", ")

        subject = row[2].strip()
        conn.execute(
            "INSERT INTO subjects(code, name, other_names) VALUES(?,?, ?) ",
            (codigo, subject, otros_codigos),
        )


conn.commit()
conn.close()
