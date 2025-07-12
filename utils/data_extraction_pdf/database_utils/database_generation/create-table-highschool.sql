CREATE TABLE IF NOT EXISTS high_schools(

    id INTEGER PRIMARY KEY,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    type_id INTEGER,
    cif TEXT,
    
    address TEXT,
    postal_code INTEGER,
    municipality_id INTEGER NOT NULL,
    locality TEXT,

    latitude REAL,
    longitude REAL,


    
    email TEXT,
    phone_number TEXT,
    fax TEXT,

    website TEXT,
    
    owner TEXT,

    image BLOB,

    FOREIGN KEY (type_id) REFERENCES high_school_types(id),
    FOREIGN KEY (municipality_id) REFERENCES municipalities(id)

)