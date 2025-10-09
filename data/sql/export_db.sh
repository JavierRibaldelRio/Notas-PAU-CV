#!/bin/bash
set -euo pipefail

# Path to the database (relative to this script)
DB_PATH="$(dirname "$0")/../notas-pau.db"

# Directory where output files will be stored
OUT_DIR="$(dirname "$0")"

# Output file names
DUMP_FILE="$OUT_DIR/dump.sql"
SCHEMA_FILE="$OUT_DIR/schema.sql"

echo "Exporting database from $DB_PATH"

# Generate full dump (schema + data)
sqlite3 "$DB_PATH" ".dump" > "$DUMP_FILE"
echo "Full dump created at $DUMP_FILE"

# Generate schema only (no data)
sqlite3 "$DB_PATH" ".schema" > "$SCHEMA_FILE"
echo "Schema created at $SCHEMA_FILE"

echo "Export completed successfully"

# Overwrite the database file in golem_app/ with the current database
GOLEM_DB_PATH="$(dirname "$0")/../../golem_app/notas-pau.db"
cp "$DB_PATH" "$GOLEM_DB_PATH"
echo "Database copied to $GOLEM_DB_PATH"
