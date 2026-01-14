# Gets the raw data and transforms it converting the string into ints an decimals, and returns an array of tuples

def transform_data(data, id_equiv, call_equiv, year, call):
    """
    Transforms raw grade data:
    - Handles special cases and missing values.
    - Converts string numbers to int/float.
    - Adds calculated columns (passed obligatory, year, call).
    - Returns immutable tuple of tuples.
    Args:
        data: List of lists with raw data.
        id_equiv: Dict mapping subject codes to IDs.
        call_equiv: Dict mapping call names to IDs.
        year: Year of the data.
        call: Call name.
    """
    # Exception: Remove GERMANY 2020 extraordinary row with no grades
    if data[3][0] == "ALE" and year == 2020 and call_equiv[call] == 1:
        data.pop(3)

    # Exception: Remove ITALIAN 2023 extraordinary row with no grades
    elif data[19][0] == "ITA" and year == 2023 and call_equiv[call] == 1:
        data.pop(19)

    # Iterate over each row and transform values
    for fila in data:
        # Exception: German 2010 extraordinary missing average (UA)
        if fila[5] == "***" and year == 2010:
            fila[5] = 6.601
        # Exception: German 2012 extraordinary missing average (UMH)
        elif fila[5] == "***" and year == 2012:
            fila[5] = 9.002

        # Map subject code to ID
        fila[0] = id_equiv[fila[0]]

        # Add column: number of people who passed obligatory phase
        fila.append(int(fila[3]) - int(fila[9]))

        # Convert string numbers to float or int
        for i in range(1, len(fila) - 1):
            if isinstance(fila[i], str):
                fila[i] = fila[i].replace(",", ".")
                if not fila[i].find(".") == -1:
                    fila[i] = float(fila[i])
                else:
                    fila[i] = int(fila[i])

        # Add year and call columns
        fila.append(year)
        fila.append(call_equiv[call])

        # Not tested yet, but should be fine
        fila.append((fila[5] / fila[4]) * 100)

    # Return immutable tuple of tuples
    return tuple(tuple(row) for row in data)
