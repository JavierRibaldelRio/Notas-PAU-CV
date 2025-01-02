import pdfplumber

convo = "global"
for i in range(2022, 2025):

    with pdfplumber.open(f"data/convocatorias/{convo}/{i}-{convo}.pdf") as pdf:
        for page in pdf.pages:
            extracted_text = page.extract_text()
            if (
                "SUV" in extracted_text
                and "Resultats globals per assignatura" in extracted_text
                and "i universitat" in extracted_text
                and not "UPV" in extracted_text
            ):
                print(page.extract_table(), i)
