#!/usr/bin/env bash
#
# transform.sh - extract data lists from run.py logs and convert to CSV
#
# Usage: ./transform.sh input.txt output.csv
#
# Notes:
#   - input.txt must be the log file produced by run.py
#   - the script filters only lines with "Row with NaN code found and removed in"
#   - it extracts the list inside [ ... ], cleans it, and outputs as CSV
#

INPUT_FILE="${1:-output.txt}"   # log from run.py
OUTPUT_FILE="${2:-output.csv}"  # destination CSV file

grep "Row with NaN code found and removed in" "$INPUT_FILE" \
  | awk -F'[][]' '{
      s=$2
      gsub(/\047/, "", s)     # remove single quotes
      gsub(/, /, ",", s)      # tighten commas
      print s
    }' > "$OUTPUT_FILE"

echo "CSV written to $OUTPUT_FILE"
echo "Source log: $INPUT_FILE (from run.py)"
