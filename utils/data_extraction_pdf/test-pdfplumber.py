import pdfplumber

convo = "global"
for i in range(2024, 2025):

    firstPage = 0
    lastPage = 0
    table = []

    # Abrir PDF
    with pdfplumber.open(f"../../data/convocatorias/{convo}/{i}-{convo}.pdf") as pdf:

        # Para cada página
        for page in pdf.pages:

            # Extract pages of modality subject
            extracted_text = page.extract_text()
            if (
                "SUV" in extracted_text
                and "Resultats globals per assignatura" in extracted_text
                and "i universitat" in extracted_text
                and not "UPV" in extracted_text
            ):
                firstPage = page.page_number
                continue

            # Página extra en caso de que la haya
            if (
                "UA" in extracted_text
                and "Resultats globals per assignatura" in extracted_text
                and "i universitat" in extracted_text
                and not "UPV" in extracted_text
                and not "UJI" in extracted_text
                and not "UMH" in extracted_text
                and not "UV" in extracted_text
            ):
                lastPage = page.page_number
                continue

            # Obligatorias
            if (
                "Resultats globals per assignatura comuna" in extracted_text
                and "Sistema Universitari Valencià" in extracted_text
            ):
                extracted_table_special = page.extract_table()
                extracted_table_special.pop(0)
                for fila in extracted_table_special:
                    fila.append(fila[2])
                    fila.append(0)
                    fila.append(0)
                table.extend(extracted_table_special)

        # Trauere la taula  de les asignatures de modalitat
        for extraction in range(firstPage, lastPage):
            page = pdf.pages[extraction - 1]
            extracted_table = page.extract_table()
            extracted_table.pop(0)
            if firstPage != lastPage - 1 and extraction == lastPage - 1:
                table.extend(extracted_table)
                break

            table.extend(extracted_table)

    for fila in table:
        fila.append(int(fila[3]) - int(fila[9]))
        for i in range(1, len(fila) - 1):
            fila[i] = int(float(fila[i].replace(",", ".")))
