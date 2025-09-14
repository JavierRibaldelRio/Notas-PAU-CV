# SQL Files Structure and Export Script

This directory contains files for managing and exporting the Notas-PAU-CV project database.

## Main Files

- **schema.sql**: Database table definitions, including fields, types, and relationships.
- **seed.sql**: Structure plus initial data for main tables. The seed file contains only information related to high-school types and location data (provinces, municipalities, regions).
- **dump.sql**: Full database dump (structure and data), auto-generated for backup or restore.
- **export_db.sh**: Bash script to export the SQLite database. This script only generates `dump.sql` (structure + data) and `schema.sql` (structure only) from the main database file.

## Typical Usage

- Use `schema.sql` to create the database structure, then populate with `seed.sql`.
- Use `dump.sql` to restore or clone the full database.
- Run `export_db.sh` to generate backup files.

## Notes
- All files are for SQLite.
- The directory may include other scripts or data management files.


```mermaid
erDiagram
    SUBJECTS {
        INTEGER id PK
        TEXT code UK
        TEXT name
        TEXT other_names
    }

    MARKS {
        INTEGER id PK
        INTEGER subject_id FK
        INTEGER year
        INTEGER call
        INTEGER enrolled_total
        INTEGER candidates
        INTEGER pass
        REAL pass_percentatge
        REAL average
        REAL standard_dev
        INTEGER candidates_compulsory
        INTEGER pass_compulsory
        INTEGER candidates_optional
        INTEGER pass_optional
    }

    HIGH_SCHOOL_TYPES {
        INTEGER id PK
        TEXT type UK
    }

    PROVINCES {
        INTEGER id PK
        TEXT name UK
        INTEGER provincial_capital FK
    }

    HIGH_SCHOOL_MARKS {
        INTEGER id PK
        INTEGER high_school_id FK
        INTEGER year
        INTEGER call
        INTEGER enrolled_total
        INTEGER candidates
        INTEGER pass
        REAL pass_percentatge
        REAL average_bach
        REAL standard_dev_bach
        REAL average_compulsory_pau
        REAL standard_dev_pau
        REAL diference_average_bach_pau
    }

    MUNICIPALITIES {
        INTEGER id PK
        TEXT ine_code UK
        TEXT name UK
        TEXT other_names
        INTEGER region FK
        INTEGER province FK
    }

    REGIONS {
        INTEGER id PK
        TEXT name UK
        INTEGER province FK
    }

    HIGH_SCHOOLS {
        INTEGER id PK
        TEXT code
        TEXT name
        INTEGER type_id FK
        TEXT cif
        TEXT address
        TEXT postal_code
        INTEGER municipality_id FK
        REAL latitude
        REAL longitude
        TEXT email
        TEXT phone_number
        TEXT fax
        TEXT website
        TEXT owner
        BLOB image
    }

    %% Relationships
    MARKS }o--|| SUBJECTS : "subject_id"
    HIGH_SCHOOLS }o--|| HIGH_SCHOOL_TYPES : "type_id"
    HIGH_SCHOOLS }o--|| MUNICIPALITIES : "municipality_id"
    HIGH_SCHOOL_MARKS }o--|| HIGH_SCHOOLS : "high_school_id"
    MUNICIPALITIES }o--|| REGIONS : "region"
    MUNICIPALITIES }o--|| PROVINCES : "province"
    REGIONS }o--|| PROVINCES : "province"
    PROVINCES }o--|| MUNICIPALITIES : "provincial_capital"
```