import tabula
import pandas as pd

# Especifica la ruta al PDF
pdf_path = "data/convocatorias/global/2024-global.pdf"

# Extrae las tablas del PDF (devuelve una lista de DataFrames)
tablas = tabula.read_pdf(pdf_path, pages="67,68", multiple_tables=True)

# Guarda cada tabla como CSV
for i, tabla in enumerate(tablas):
    tabla.to_csv(f"tabla_{i}.csv", index=False)

# Imprime las tablas extraídas
for tabla in tablas:
    print(tabla)
