# Package is tabula-py, not just tabula
import tabula
import pdfplumber
import pandas as pd

from find_mistake_rows import find_mistaken_rows

# Returns the first and the last page uses pdf plummers
def get_pages_high_schools( convo, year):

    # Stores the first and the last page
    firstPage = 0
    lastPage = 0
    # Open PDF
    with pdfplumber.open(f"data/convocatorias/{convo}/{year}-{convo}.pdf") as pdf:

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
                return firstPage, lastPage

def get_data_from_pdf(firstPage, lastPage, convo, year):
    table =  []
    
    # Stores the path
    path = f"data/convocatorias/{convo}/{year}-{convo}.pdf"

    # Extracts the table from the pages selected
    for extraction in range(firstPage, lastPage + 1):
        table_page = tabula.read_pdf(path, pages = extraction, stream = True, silent=True)
        
        # Adds the data
        table.extend([row for row in table_page[0].values.tolist() if not pd.isna(row[4])])
    
    return table
    
def format_table_first(table, convo, year):
    for i in table:
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
        if type(i[1]) == str:
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

    return table

# Prueva de metodo alternativo para corregir los errores de recolecta a partir de 2015
def format_table_second(table, convo, year):
    for i in table:
        if type(i[0]) == str:
            correction = i[0][:8]
            try:
                try_int = int(correction)
                i[1] = correction
            except ValueError:
                i.pop(0)

        # Correction of cell types
        if type(i[0]) == float and not pd.isna(i[0]):
            aux = str(int(i[0]))
            if len(aux) < 8:
                dif = 8 - len(aux)
                aux = '0' * dif + aux
            i[0] = aux
        elif type(i[0]) == str and not pd.isna(i[0]):
            aux_one = i[0][:8]
            aux_two = i[0][8:]
            try:
                aux = int(aux_one)
                i[0] = aux_one
            except ValueError:
                try:
                    aux = int(aux_two)
                    i[0] = aux_two
                except ValueError:
                    pass
            

        # We don't need the city of the school
        i.pop(1)

        # The colummn of the enrolled and the candidates is fusioned so we put the candidates at the end of the row
        if type(i[1]) == str:
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

    return table


def format_center_code(row):
    if type(row[0]) == str:
        correction = str(row[0][-8:])
        try:
            try_int = int(correction)
            row[0] = str(correction)
        except ValueError:
            row.pop(0)
    
    if type(row[0]) == float and not pd.isna(row[0]):
        aux = str(int(row[0]))
        if len(aux) < 8:
            dif = 8 - len(aux)
            aux = '0' * dif + aux
        row[0] = aux
    elif type(row[0]) == str and not pd.isna(row[0]):
        aux = row[0][:8]
        row[1] = row[0][8:]
        row[0] = aux
    # We don't need the city of the school
    row.pop(1)

def type_check(row):
    if isinstance(row[1], str):
        nums = row[1].split()
        if len(nums) != 2:
            if len(row) > 2:
                row[1] = row[2]
                row.pop(2)
            else:
                return  # Handle the case where there's no row[2]

        try:
            nums = row[1].split()
            num0, num1 = int(nums[0]), int(nums[1])
            row[1] = num0
            row.insert(2, num1)
        except (ValueError, IndexError):
            if len(row) > 2:
                row[1] = row[2]
                row.pop(2)
                try:
                    nums = row[1].split()
                    num0, num1 = int(nums[0]), int(nums[1])
                    row[1] = num0
                    row.insert(2, num1)
                except (ValueError, IndexError):
                    pass  # Handle the case where the conversion fails
            else:
                pass

    elif pd.isna(row[1]) and isinstance(row[2], str):
        row.pop(1)
        try:
            nums = row[1].split()
            num0, num1 = int(nums[0]), int(nums[1])
            row[1] = num0
            row.insert(2, num1)
        except (ValueError, IndexError):
            pass  # Handle the case where the conversion fails

def string_to_float(row):
    for i in range(4, 10):
        if row[i] == '***':
            row[i] = float('nan')
            continue
        
        row[i] = row[i].replace(' ', '')
        row[i] = row[i].replace(',', '.')
        row[i] = float(row[i])
        

def test_format_table_second(table, convo, year):
    # Use filter to remove rows with NaN in the first column
    table = [row for row in table if not pd.isna(row[0])]
    for row in table:
        # Sets the center code to string and corrects the length
        format_center_code(row)
    
        # Separates convined numbers extracted from the pdf
        type_check(row)

        # The column of the pass is a float, we want a integer
        row[3] = int(row[3])

        # The nexts columns are all floats
        string_to_float(row)


    return table




def marks_from_high_schools(convo, year):
    table = []  

    first, last = get_pages_high_schools(convo, year)

    # Extracts the data form the pages
    pdf_data = get_data_from_pdf(first, last, convo, year)
    
    # Formats the data into the right format to be put inside sqlite
    if year < 2015:
        table = format_table_first(pdf_data, convo, year)
    else:
        # table = format_table_second(pdf_data, convo, year)
        table = test_format_table_second(pdf_data, convo, year)
        #table = pdf_data

    #table = find_mistaken_rows(table)

    return table

years = range(2017, 2025)

calls = {"ordinaria": 0, "extraordinaria": 1, "global": 2}

# print("|-------- 0 -- 1 -- 2 --|")
# for year in years:
#     print("|" + str(year) + ":", end="", flush=True)
#     for call in calls.keys():
#         marks_from_high_schools(call, year)
#         print("    X", end="", flush=True)
#     print("   |")

for year in years:
    for call in calls.keys():
        print(year, call,"\n" + ("-")* 20)

        x = marks_from_high_schools(call, year)
        count = 0
        for i in x:
            count += 1
            print(i)
        print(count)

# TODO repasar rango 2015, fin (no va bé) revisar format_table()
# TODO repasar rango 2015, fin (no va bé) revisar format_table()