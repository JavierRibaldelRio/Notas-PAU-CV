# Gets the raw data and transforms it converting the string into ints an decimals, and returns an array of tuples


def transform_data(data, id_equiv, call_equiv, year, call):
    # Converts all the numeric elements that where interpreted as strings to float (or int if has no decimals)
    for fila in data:

        fila[0] = id_equiv[fila[0]]

        # Adds a new column to the table with the number of people that passed the obligatory phase
        fila.append(int(fila[3]) - int(fila[9]))

        for i in range(1, len(fila) - 1):
            if isinstance(fila[i], str):
                fila[i] = fila[i].replace(",", ".")
                if not fila[i].find(".") == -1:
                    fila[i] = float(fila[i])
                else:
                    fila[i] = int(fila[i])

        # Adds two more columns to the table, with the year of the convocatory, and which convocatori
        fila.append(year)
        fila.append(call_equiv[call])

    # Return a tuple of tuples, that can't be changed
    return tuple(tuple(row) for row in data)
