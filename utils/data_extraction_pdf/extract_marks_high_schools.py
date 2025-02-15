# Package is tabula-py, not just tabula
import tabula
import pdfplumber
import pandas as pd

def marks_from_high_schools(convo, year):

    firstPage = 0
    lastPage = 0
    table = []  

    # Open PDF
    with pdfplumber.open(f"../../data/convocatorias/{convo}/{year}-{convo}.pdf") as pdf:

        # For every page in the pdf
        for page in pdf.pages:

            # Extract the text of the page of the pdf
            extracted_text = page.extract_text()

            # The page we are searching is the only one with the text specified below
            if (
                "i per universitat" in extracted_text
                and "UA" in extracted_text
            ):
                firstPage = page.page_number
                # The last page of the pdf
                lastPage = pdf.pages[len(pdf.pages)-1].page_number
                break

    # Extracts the table from the pages selected
    for extraction in range(firstPage, lastPage + 1):
            table_page = tabula.read_pdf(f"../../data/convocatorias/{convo}/{year}-{convo}.pdf", pages = extraction, stream = True, silent=True)

            # Transforms de DataFrame extracted by tabula to a bidimensional list
            table_to_list = [row for row in table_page[0].values.tolist() if not pd.isna(row[4])]

            # The first column always contains the name of the center, which we don't need
            for i in table_to_list:
                i.pop(0)

                # Correction of cell types
                if type(i[0]) == float and not pd.isna(i[0]):
                    aux = str(int(i[0]))
                    if len(aux) < 8:
                        dif = 8 - len(aux)
                        aux = '0' * dif + aux
                    i[0] = aux
                elif type(i[0]) == str and not pd.isna(i[0]):
                    aux = i[0][:8]
                    i[1] = i[0][8:]
                    i[0] = aux

                # We don't need the city of the school
                i.pop(1)

                # The colummn of the enrolled and the candidates is fusioned so we put the candidates at the end of the row
                aux = i[1].split(' ')
                i[1] = int(aux[0])
                i.append(int(aux[1]))

                # The column of the pass is a float, we want a integrer
                i[2] = int(i[2])

                # The next columns have a comma and are string, we want floats
                for j in range(3, 9):
                    if i[j] == '***':
                        i[j] = float('nan')
                        continue
                    i[j] = i[j].replace(' ', '')
                    i[j] = float(i[j].replace(',', '.'))

                i.append(convo)
                i.append(year)

                # The final order of the row is:
                # center_code, enrolled, pass, pass_percentage, average, standard_dev, average_general_phase, stardard_dev_average, dif_average_average_gen, candidates
                table.append(i)      

    return table
