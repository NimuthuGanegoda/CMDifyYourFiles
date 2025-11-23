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

# Conversion logic

# PowerPoint to PDF (PPTX/PPT)
if [[ "${OUTEXT,,}" == "pdf" ]]; then
    if [[ "${ext,,}" == "pptx" || "${ext,,}" == "ppt" ]]; then
        echo "Converting PowerPoint to PDF using LibreOffice..."
        libreoffice --headless --convert-to pdf --outdir "$(dirname "$INFILE")" "$INFILE"
        if [ $? -eq 0 ]; then
            echo "Conversion successful: $OUTFILE"
        else
            echo "Conversion failed. Make sure LibreOffice is installed."
        fi
        exit 0
    fi
    
    # Word to PDF (DOCX/DOC)
    if [[ "${ext,,}" == "docx" || "${ext,,}" == "doc" ]]; then
        echo "Converting Word document to PDF using LibreOffice..."
        libreoffice --headless --convert-to pdf --outdir "$(dirname "$INFILE")" "$INFILE"
        if [ $? -eq 0 ]; then
            echo "Conversion successful: $OUTFILE"
        else
            echo "Conversion failed. Make sure LibreOffice is installed."
        fi
        exit 0
    fi
fi

# Image conversions (JPG, PNG, BMP, GIF, TIFF, WEBP)
if [[ "${ext,,}" =~ ^(jpg|jpeg|png|bmp|gif|tiff|tif|webp)$ ]]; then
    echo "Converting image format using ImageMagick..."
    convert "$INFILE" "$OUTFILE"
    if [ $? -eq 0 ]; then
        echo "Conversion successful: $OUTFILE"
    else
        echo "Conversion failed. Make sure ImageMagick is installed (sudo apt install imagemagick)."
    fi
    exit 0
fi

# No conversion found
echo "No conversion logic implemented for .$ext to $OUTEXT"
echo "Please add conversion command for this file type."
