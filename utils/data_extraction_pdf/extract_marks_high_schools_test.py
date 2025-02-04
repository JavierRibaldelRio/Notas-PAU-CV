import pdfplumber

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
            page = pdf.pages[extraction - 1]
            extracted_table = page.extract_table(
                {
                    #"snap_tolerance": 3,
                    "horizontal_strategy": "lines",
                    "vertical_strategy": "text"
                }
            )
            extracted_table.pop(0)

            # This tables are strange
            for row in extracted_table:
                row.pop(0)
                new_row = []
                new_row.append(row[1])
                #new_row = new_row.split(" ")
                row = new_row
            
            table.extend(extracted_table)
    
    # final order of the rows: 
    return table

for i in marks_from_high_schools("global", 2011):
    print(i)