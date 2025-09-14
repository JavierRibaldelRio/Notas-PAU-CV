import pdfplumber

"""
This file extracts the marks from the compulsory and optional subjects
"""

def extract_marks_from_pdf(convo, year):

    firstPage = 0
    lastPage = 0
    table = []

    # Open PDF
    with pdfplumber.open(f"../data/convocatorias/{convo}/{year}-{convo}.pdf") as pdf:

        # For every page in the pdf
        for page in pdf.pages:

            # Get pages of modality subject
            extracted_text = page.extract_text()

            # Extraction of the table of obligatory subjects
            if (
                "Resultats globals per assignatura comuna" in extracted_text
                and "Sistema Universitari Valencià" in extracted_text
            ):

                extracted_table_special = page.extract_table()
                extracted_table_special.pop(0)
                
                # Since these are compulsory subjects, it is not possible for people to take these subjects as optional, so we put 0 on those columns.
                for fila in extracted_table_special:
                    fila.append(fila[2])  #
                    fila.append(0)  #
                    fila.append(0)  #
                    
                table.extend(extracted_table_special)
                continue

            # Extraction of the first page of the pdf that contains all other subjects, modality subjects.
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

        # Extracts the table from the pages selected
        for extraction in range(firstPage, lastPage):
            page = pdf.pages[extraction - 1]
            extracted_table = page.extract_table()
            extracted_table.pop(0)
            if firstPage != lastPage - 1 and extraction == lastPage - 1:
                table.extend(extracted_table)
                break

            table.extend(extracted_table)

    # final order of the rows: subject, ... (like in the pdf), pass_obligatory_phase, year, convo.
    return table
