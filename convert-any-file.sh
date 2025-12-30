#!/bin/bash

# Check if a file or folder was provided
if [ -z "$1" ]; then
    echo "Please drag and drop a file or folder onto this script."
    exit 1
fi

INPUT="$1"

is_image_ext() {
    case "${1,,}" in
        jpg|jpeg|png|bmp|gif|tiff|tif|webp) return 0 ;;
        *) return 1 ;;
    esac
}

convert_single() {
    local INFILE="$1"; local OUTEXT="$2"
    local ext="${INFILE##*.}"; ext="${ext,,}"
    local OUTFILE="${INFILE%.*}.$OUTEXT"
    echo "Input file: $INFILE"
    echo "Output file: $OUTFILE"

    # PPT/PPTX/DOC/DOCX -> PDF via LibreOffice
    if [[ "${OUTEXT,,}" == "pdf" ]]; then
        if [[ "$ext" == "pptx" || "$ext" == "ppt" || "$ext" == "docx" || "$ext" == "doc" ]]; then
            echo "Converting to PDF using LibreOffice..."
            libreoffice --headless --convert-to pdf --outdir "$(dirname "$INFILE")" "$INFILE"
            if [ $? -eq 0 ]; then
                echo "Conversion successful: ${INFILE%.*}.pdf"
            else
                echo "Conversion failed. Ensure LibreOffice is installed."
            fi
            return
        fi
    fi

    # Image conversions via ImageMagick
    if is_image_ext "$ext"; then
        echo "Converting image format using ImageMagick..."
        convert "$INFILE" "$OUTFILE"
        if [ $? -eq 0 ]; then
            echo "Conversion successful: $OUTFILE"
        else
            echo "Conversion failed. Make sure ImageMagick is installed (sudo apt install imagemagick)."
        fi
        return
    fi

    echo "No conversion logic implemented for .$ext to $OUTEXT"
}

if [ -d "$INPUT" ]; then
    read -p "Enter desired output extension for all files (e.g. pdf, jpg): " OUTEXT
    if [[ -z "$OUTEXT" ]]; then
        echo "No output extension provided. Exiting."
        exit 1
    fi
    export -f convert_single is_image_ext
    export OUTEXT
    find "$INPUT" -type f -print0 | xargs -0 -I {} bash -c 'convert_single "$0" "$OUTEXT"' {}
else
    ext="${INPUT##*.}"
    echo "Detected file type: .${ext}"
    read -p "Enter desired output extension (e.g. pdf, docx, jpg): " OUTEXT
    if [[ -z "$OUTEXT" ]]; then
        echo "No output extension provided. Exiting."
        exit 1
    fi
    convert_single "$INPUT" "$OUTEXT"
fi
