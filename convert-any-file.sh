#!/bin/bash

# Check if a file was provided
if [ -z "$1" ]; then
    echo "Please drag and drop a file onto this script."
    exit 1
fi

INFILE="$1"
ext="${INFILE##*.}"
echo "Detected file type: .$ext"

# Prompt for output extension
read -p "Enter desired output extension (e.g. pdf, docx, jpg): " OUTEXT

# Prepare output filename
OUTFILE="${INFILE%.*}.$OUTEXT"
echo "Input file: $INFILE"
echo "Output file: $OUTFILE"

# Placeholder for conversion command
echo "[Conversion command would go here]"
# Example: use libreoffice, pandoc, ffmpeg, etc. to convert "$INFILE" to "$OUTFILE"
