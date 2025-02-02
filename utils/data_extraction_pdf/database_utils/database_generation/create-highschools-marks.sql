CREATE TABLE IF NOT EXISTS high_school_marks(
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


)