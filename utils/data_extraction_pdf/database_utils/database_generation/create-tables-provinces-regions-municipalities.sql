# The tables of "regions", "provinces" y "municipalities"tienen referencias entre sí, por lo que hay que crearlas con el siguiente script

CREATE TABLE IF NOT EXISTS municipalities(
    id INTEGER PRIMARY KEY,
    ine_code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL UNIQUE,
    other_names TEXT,
    region INTEGER,
    province INTEGER,

    FOREIGN KEY(region) REFERENCES regions(id),
    FOREIGN KEY(province) REFERENCES provinces(id)
);

CREATE TABLE IF NOT EXISTS regions(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    province INTEGER,

    FOREIGN KEY (province) REFERENCES provinces(id)

);

CREATE TABLE IF NOT EXISTS provinces(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    provincial_capital INTEGER,

    FOREIGN KEY (provincial_capital) REFERENCES municipalities(id)
);

# Mofify municipalities to add the missing FOREIGN KEY

