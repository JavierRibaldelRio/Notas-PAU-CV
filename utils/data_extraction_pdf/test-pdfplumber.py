import pdfplumber

convo = "global"
for year in range(2010, 2025):

    firstPage = 0
    lastPage = 0
    table = []

    # Abrir PDF
    with pdfplumber.open(f"../../data/convocatorias/{convo}/{year}-{convo}.pdf") as pdf:

        # For every page in the pdf
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

            # Modality pages in case there are more
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

            # Extraction of the table of obligatory subjects
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

        # Extracts the table from the pages selected
        for extraction in range(firstPage, lastPage):
            page = pdf.pages[extraction - 1]
            extracted_table = page.extract_table()
            extracted_table.pop(0)
            if firstPage != lastPage - 1 and extraction == lastPage - 1:
                table.extend(extracted_table)
                break

            table.extend(extracted_table)

    # Converts all the numeric elements that where interpreted as strings to float (or int if has no decimals)
    for fila in table:
        # Adds a new column to the table with the number of people that passed the obligatory phase
        fila.append(int(fila[3]) - int(fila[9]))
        
        for i in range(1, len(fila)):
            if isinstance(fila[i], str):
                fila[i] = fila[i].replace(",", ".")
                if not fila[i].find(".") == -1:
                    fila[i] = float(fila[i])
                else:
                    fila[i] = int(fila[i])

        # Adds two more columns to the table, with the year of the convocatory, and which convocatori
        fila.append(year)
        fila.append(convo)

    #final order of the rows: subject, ... (like in the pdf), pass_obligatory_phase, year, convo.    
    
