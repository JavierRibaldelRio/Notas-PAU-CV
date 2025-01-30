CREATE TABLE IF NOT EXISTS high_school_types(
    id INTEGER PRIMARY KEY,
    type TEXT NOT NULL UNIQUE
);

INSERT INTO high_school_types (id, type) VALUES
    (0, 'público'),
    (1, 'privado-concertado'),
    (2, 'privado')