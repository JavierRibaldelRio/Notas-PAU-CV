import pdfplumber

"""
This file extracts the global results from all the calls and years
"""

def find_data(pdf):

    # Pages split with tables
    pages = []

    # For every page in the pdf
    for page in pdf.pages:

        # Get page of global results per university
        extracted_text = page.extract_text()

        # Extraction of the table of global results
        if (
            "Resultats globals per universitats" in extracted_text 
            and not "Codis d'assignatures" in extracted_text
        ):
            # In the page are two tables, so we create two boxes to extract each table
            w, h = page.width, page.height

            top = page.within_bbox((0, 0, w, h/2))
            bottom = page.within_bbox((0, h/2, w, h))

            t1 = top.extract_table()
            t2 = bottom.extract_table()

            both = (t1, t2)
            pages.append(both)

        elif "Resultats per tipus de centre" in extracted_text:
            return pages

    return pages
        
# The order of this table is:
# enrolled, candidates, pass, pass_percentage, candidates_m, candidates_w, pass_percentage_m, pass_percentage_w, average_bach, standard_dev_bach
def extract_up(page):
    
    t1 = page[0]
    
    return t1[len(t1)-1]

# The order of this table is:
# average_pau, standard_dev_pau, average_nau, standard_dev_nau, final_average_pass, exclusive_candidates_general, exclusive_candidates_especific, candidates_both, fp_candidates_especific
def extract_down(page):

    t2 = page[1]

    return t2[len(t2)-1]


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


# Firsthalf means until 2017 (not included)
def global_results_firsthalf(convo, year):
    with pdfplumber.open(f"../data/convocatorias/{convo}/{year}-{convo}.pdf") as pdf:
        pages = find_data(pdf)
        t1 = extract_up(pages[0])
        t2 = extract_down(pages[0])
        t1.pop(0)
        t1.extend([element for element in t2 if element != 'SUV'])
        format_results(t1)

        if len(t1) == 18:
            t1.append(float('nan'))
        elif len(t1) > 19:
            while not len(t1) == 19:
                t1.pop(len(t1) - 1)

        # Insertion of year and call(convo)
        t1.insert(0, year)

        call = 0
        if convo == "extraordinaria":
            call = 1
        elif convo == "global":
            call = 2

        t1.insert(1, call)
        
    return t1

# Secondhalf means from 2017 to lastyear
def global_results_secondhalf(convo, year):
    with pdfplumber.open(f"../data/convocatorias/{convo}/{year}-{convo}.pdf") as pdf:
        pages = find_data(pdf)
        t1 = extract_up(pages[0])
        t2 = extract_down(pages[0])

        # These tables consider exempted people
        t3 = extract_up(pages[2])
        t4 = extract_down(pages[2])

        # Manual positioning of the data to match the other function
        row = []
        row.append(t1[3]) # enrolled
        row.append(t2[3]) # candidates
        row.append(t3[4]) # pass
        row.append(t3[5]) # pass_percentage
        row.append(t3[3]) # candidates_men
        row.append(t3[2]) # candidates_woman
        row.append(t3[9]) # pass_percentage_man
        row.append(t3[7]) # pass_percentage_woman
        row.append(t4[1]) # average_bach
        row.append(t4[2]) # standard_dev_bach
        row.append(t4[3]) # average_pau
        row.append(t4[4]) # standard_dev_pau
        row.append(t4[5]) # average_nau
        row.append(t4[8]) # standard_dev_nau
        row.append(t4[7]) # final_average_pass
        row.append(t2[4]) # exclusive_candidates_general
        row.append(t2[6]) # exclusive_candidates_especific
        row.append(int(t2[3]) - int(t2[4]) - int(t2[6])) # candidates_both
        row.append(t2[7]) # fp_candidates_especific

        # Format table to the right types
        format_results(row)

        # Insert year and call(convo)
        row.insert(0, year)
        call = 0
        if convo == "extraordinaria":
            call = 1
        elif convo == "global":
            call = 2

        row.insert(1, call)

        return row

# Unification of both methods
def global_results(convo, year):
    if year < 2017:
        return global_results_firsthalf(convo, year)
    return global_results_secondhalf(convo, year)