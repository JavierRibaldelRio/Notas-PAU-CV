# This data starts to appear in 2014
# 1rs case 2014-2016
# 2nd case 2017-2024
import pdfplumber

def find_data(pdf, year):

    pages = []
    count = 0
    for page in pdf.pages:
        
        extracted_text = page.extract_text()

        if ("Resultats globals per tipus de centre" in extracted_text and year < 2017):
            w, h = page.width, page.height

            top = page.within_bbox((0, 0, w, h/2))
            bottom = page.within_bbox((0, h/2, w, h))

            t1 = top.extract_table()
            t2 = bottom.extract_table()

            both = (t1, t2)
            pages.append(both)
            return pages
        
        elif (
            ("Resultats per tipus de centre" in extracted_text
            and "SUV" in extracted_text) or count != 0):

            # There are three pages and in the second and third there is no page title
            count += 1

            w, h = page.width, page.height

            if year == 2017 or year == 2018:
                # The tables are no longer in the exact center
                # Mesured with ChatGPT xD
                top = page.within_bbox((0, 0, w, h*0.55))
                bottom = page.within_bbox((0, h*0.55, w, h))
            else:
                top = page.within_bbox((0, 0, w, h*0.5))
                bottom = page.within_bbox((0, h*0.5, w, h))

            t1 = top.extract_table()
            t2 = bottom.extract_table()

            both = (t1, t2)
            pages.append(both)

            if count == 2:
                return pages


    return pages

# Formats the results to the correct types
def format_results(row):
    for idx, i in enumerate(row):
        if isinstance(i, str):
            i = i.replace(",", ".")
            if "." in i:
                row[idx] = float(i)
            elif i == "":
                row[idx] = float('nan')
            else:
                row[idx] = int(i)

def table_updown_firsthalf(page, idx):
    table = page[idx]
    
    if idx == 0:
        # The header of the table
        table.pop(0)
    else:
        # Two column don't needed
        for row in table:
            row.pop(len(row)-1)
            row.pop(len(row)-1)

    # Don't want people that don't come from a center
    if len(table) == 5:
        table.pop(len(table)-2)
    return table
            
def type_center_results_firsthalf(call, year):
    with pdfplumber.open(f"../data/convocatorias/{call}/{year}-{call}.pdf") as pdf:
        pages = find_data(pdf, year)
        t1 = table_updown_firsthalf(pages[0], 0)
        t2 = table_updown_firsthalf(pages[0], 1)

        # Manual tidy of data
        publico = t1[0]
        publico.extend([element for element in t2[0] if element != 'Público'])
        # Type in sql table
        publico[0] = 0

        privado = t1[1]
        privado.extend([element for element in t2[1] if element != 'Privado'])
        # Type in sql table
        privado[0] = 2

        concertado = t1[2]
        concertado.extend([element for element in t2[2] if element != 'Concertado'])
        # Type in sql table
        concertado[0] = 1

        total = t1[3]
        total.extend([element for element in t2[3] if element != 'TOTAL'])
        # Type in sql table
        total[0] = 3

        # All together in a "table"
        table = []
        table.append(publico)
        table.append(privado)
        table.append(concertado)
        table.append(total)

        for row in table:
            format_results(row)

            # Insert year and call(convo)
            row.insert(0, year)
            convo = 0
            if call == "extraordinaria":
                convo = 1
            elif call == "global":
                convo = 2

            row.insert(1, convo)

            # This means that were no participants in both phases, it sometimes happends in an extraordinary call
            if row[len(row) - 2] < 0:
                row[len(row) - 2] = 0

        return table
    
def table_updown_secondhalf(page, idx):
    table = page[idx]
    table.pop(0)

    return table

def tidy_data(row, t1, t2, t3, t4, type):
    row.append(t1[type][2])
    row.append(t2[type][2])
    row.append(t3[type][4])
    row.append(t3[type][5])
    row.append(t3[type][3])
    row.append(t3[type][2])
    row.append(t3[type][9])
    row.append(t3[type][7])
    row.append(t4[type][1])
    row.append(t4[type][2])
    row.append(t4[type][3])
    row.append(t4[type][4])
    row.append(t4[type][5])
    row.append(t4[type][8])
    row.append(t4[type][7])
    row.append(t2[type][4])
    row.append(t2[type][6])
    row.append(int(t2[type][2]) - int(t2[type][3]) - int(t2[type][5]))
    row.append(t2[type][6])
    
def type_center_results_secondhalf(call, year):
    with pdfplumber.open(f"../data/convocatorias/{call}/{year}-{call}.pdf") as pdf:
        pages = find_data(pdf, year)

        t1 = table_updown_secondhalf(pages[0], 0)
        t2 = table_updown_secondhalf(pages[0], 1)
        t3 = table_updown_secondhalf(pages[1], 0)
        t4 = table_updown_secondhalf(pages[1], 1)

        publico = [0]
        privado = [2]
        concertado = [1]
        total = [3]

        # Manual positioning of the data to match the other function
        for i in range(0, 4):
            if i == 0:
                tidy_data(publico, t1, t2, t3, t4, i)
            elif i == 1:
                tidy_data(privado, t1, t2, t3, t4, i)
            elif i == 2:
                tidy_data(concertado, t1, t2, t3, t4, i)
            elif i == 3:
                tidy_data(total, t1, t2, t3, t4, i)
    
        table = []
        table.append(publico)
        table.append(privado)
        table.append(concertado)
        table.append(total)

        for row in table:

            # Format the results
            format_results(row)

            # Insert year and call(convo)
            row.insert(0, year)
            convo = 0
            if call == "extraordinaria":
                convo = 1
            elif call == "global":
                convo = 2

            row.insert(1, convo)

            # This means that were no participants in both phases, it sometimes happends in an extraordinary call
            if row[len(row) - 2] < 0:
                row[len(row) - 2] = 0

    
    
    return table

def type_center_results(call, year):
    if year < 2017:
        return type_center_results_firsthalf(call, year)
    return type_center_results_secondhalf(call, year)


