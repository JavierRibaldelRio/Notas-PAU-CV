#  Calls get_center_id with a subprocess

import csv
import sqlite3
import json
import requests
import time
import random
import sys
from playwright.sync_api import sync_playwright


# Connect to the data base
conn = sqlite3.connect("data/notas-pau.db")
cur = conn.cursor()

POSTAL_CODE_LENGTH = 5


def add_center(code):

    try:
        center_data_raw = get_center_data_from_csv(code)

    except ValueError as e:
        print("Error while reading csv: ", e)

        # Adds the center to the database
    center = {}

    center["id"] = get_id_municipalities(center_data_raw["Localidad"])

    center["code"] = code

    center["name"] = center_data_raw.get("Denominacion", "").lower().strip()

    match center_data_raw.get("Regimen", "").strip():
        case "Púb.":
            center["type_id"] = 0
        case "Priv. Conc.":
            center["type_id"] = 1
        case "Priv.":
            center["type_id"] = 2
        case _:
            center["type_id"] = None

    center["address"] = (
        center_data_raw.get("Tipo_Via", "").lower().strip()
        + " "
        + center_data_raw.get("Direccion", "").lower().strip()
        + " "
        + center_data_raw.get("Num", "").lower().strip()
    )

    # if postal code is less than 6 length pads a cero to the left
    center["postal_code"] = (
        center_data_raw.get("Codigo_postal", "")
        .lower()
        .strip()
        .zfill(POSTAL_CODE_LENGTH)
    )
    center["phone"] = center_data_raw.get("Telefono", "").lower().strip()
    center["fax"] = center_data_raw.get("Fax", "").lower().strip()

    # Latitude Longitude
    center["latitude"] = float(center_data_raw.get("lat", "").replace(",", ".").strip())
    center["longitude"] = float(
        center_data_raw.get("long", "").replace(",", ".").strip()
    )

    # From web scraping if not defined on CSV
    data = get_xacen_data(code)
    center["email"] = data.get("email", "").strip()
    center["owner"] = center_data_raw.get(
        "Titularidad", ""
    ).lower().strip() or data.get("owner", "")
    center["cif"] = center_data_raw.get("CIF", "").strip() or data.get("cif", "")
    center["website"] = data.get("web", "").strip()
    center["image"] = add_image(code)

    # print(
    #     "Adding center:",
    #     center["name"].capitalize()
    #     + " to the database. (Code: "
    #     + center["code"]
    #     + ")",
    # )

    cur.execute(
        "INSERT INTO high_schools (municipality_id, code, name, type_id, cif, address, postal_code, email, phone_number, fax, owner, latitude, longitude,website,image) VALUES (?, ?, ?,  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?) ",
        (
            center["id"],
            center["code"],
            center["name"],
            center["type_id"],
            center["cif"],
            center["address"],
            center["postal_code"],
            center["email"],
            center["phone"],
            center["fax"],
            center["owner"],
            center["latitude"],
            center["longitude"],
            center["website"],
            center["image"],
        ),
    )

    # Save and close connection
    conn.commit()
    conn.close()
    return cur.lastrowid


# Auxiliar functions
def get_center_data_from_csv(code):
    with open(
        "data/centros/centros_educativos_cv-only-municipality.csv",
        newline="",
        encoding="utf-8",
    ) as f:
        reader = csv.DictReader(f)
        for fila in reader:
            if fila["Codigo"] == code:
                return fila
    raise ValueError("Code: " + code + "not found in csv file")


def get_id_municipalities(municipality):

    municipality = municipality.lower().strip()

    match municipality:
        case "náquera":
            municipality = "nàquera"
        case "xilxes":
            municipality = "chilches"
        case "montcada":
            municipality = "monacada"

    separator = ", "

    # Looks for an article introducing the name of a vilagge
    two_ch_substring = municipality[:2]

    match two_ch_substring:

        case "l'":
            municipality = municipality[2:] + separator + two_ch_substring

        case "la" | "el":

            if municipality[2] == " ":
                municipality = municipality[3:] + separator + two_ch_substring

    ans = cur.execute(
        "SELECT id FROM  municipalities WHERE other_names LIKE  ? OR  other_names = ?",
        (municipality + "/%", municipality),
    ).fetchone()

    if ans == None:
        raise LookupError("Municipality: " + municipality + " was not found.")

    return ans[0]


def get_xacen_data(codigo):

    time.sleep(random.uniform(0, 2))

    with sync_playwright() as p:
        browser = p.firefox.launch(headless=True)
        context = browser.new_context()
        page = context.new_page()

        data = {}

        # Interceptar la respuesta específica
        def handle_response(response):

            if (
                response.request.method == "GET"
                and "https://xacen-backend.gva.es/xacen-backend/api/v1/centro/datosGenerales"
                in response.url
            ):
                try:
                    all_data = json.loads(response.text())

                    data["cif"] = all_data.get("cif", "").strip()
                    data["email"] = all_data.get("email", "").strip().lower()
                    data["web"] = all_data.get("web", "").strip().lower()
                    data["owner"] = all_data.get("titular", "").strip().lower()

                except Exception as e:
                    print("Error leyendo JSON:", e)

        page.on("response", handle_response)

        url = f"https://xacen.gva.es/xacen-frontend/centro?codigoCentro={codigo}"
        page.goto(url, timeout=60000)

        page.wait_for_timeout(3000)  # tiempo para que cargue y dispare la petición

        browser.close()
        return data


def add_image(center_id):
    try:
        res = requests.get(
            f"https://ceice.gva.es/abc/i_guiadecentros/Fotos/{center_id}.jpg"
        )
        res.raise_for_status()
        return res.content
    except requests.RequestException as e:
        return None


if __name__ == "__main__":
    code = sys.argv[1]
    print(add_center(code))
