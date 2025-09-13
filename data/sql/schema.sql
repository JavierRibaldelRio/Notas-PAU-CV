CREATE TABLE subjects(
id INTEGER PRIMARY KEY,
code TEXT(6) NOT NULL UNIQUE,
name TEXT NOT NULL,
other_names TEXT);
CREATE TABLE marks(
id INTEGER PRIMARY KEY,
subject_id INTEGER NOT NULL,
year INTEGER NOT NULL,
call INTEGER NOT NULL,
enrolled_total INTEGER NOT NULL,
candidates INTEGER NOT NULL,
pass INTEGER NOT NULL,
pass_percentatge REAL NOT NULL,
average REAL NOT NULL,
standard_dev REAL NOT NULL,
candidates_compulsory INTEGER NOT NULL,
pass_compulsory INTEGER NOT NULL,
candidates_optional INTEGER NOT NULL,
pass_optional INTEGER NOT NULL,
FOREIGN KEY(subject_id) REFERENCES subjects(id)
);
CREATE TABLE high_school_types(
    id INTEGER PRIMARY KEY,
    type TEXT NOT NULL UNIQUE
);
CREATE TABLE provinces(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    provincial_capital INTEGER,

    FOREIGN KEY (provincial_capital) REFERENCES municipalities(id)
);
CREATE TABLE high_school_marks(
    id INTEGER PRIMARY KEY,
    high_school_id INTEGER NOT NULL,
    year INTEGER NOT NULL,
    call INTEGER NOT NULL,

    enrolled_total INTEGER NOT NULL,
    candidates INTEGER NOT NULL,
    pass INTEGER NOT NULL,
    pass_percentatge REAL NOT NULL,

    average_bach REAL NOT NULL,
    standard_dev_bach REAL NOT NULL,


    average_compulsory_pau REAL NOT NULL,
    standard_dev_pau REAL NOT NULL,

    diference_average_bach_pau REAL NOT NULL,

    FOREIGN KEY (high_school_id) REFERENCES high_schools(id)

);
CREATE TABLE municipalities(
    id INTEGER PRIMARY KEY,
    ine_code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL UNIQUE,
    other_names TEXT,
    region INTEGER,
    province INTEGER,

    FOREIGN KEY(region) REFERENCES regions(id),
    FOREIGN KEY(province) REFERENCES provinces(id)
);
CREATE TABLE regions(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    province INTEGER,

    FOREIGN KEY (province) REFERENCES provinces(id)

);
CREATE TABLE high_schools(

    id INTEGER PRIMARY KEY,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    type_id INTEGER,
    cif TEXT,
    
    address TEXT,
    postal_code TEXT,
    municipality_id INTEGER NOT NULL,
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

);
