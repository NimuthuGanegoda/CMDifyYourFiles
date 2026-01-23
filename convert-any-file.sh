#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if files were provided
if [ -z "$1" ]; then
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    FILE CONVERTER - DRAG & DROP${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    echo -e "${RED}ERROR: No files detected!${NC}"
    echo
    echo "How to use:"
    echo "  1. Drag and drop ONE OR MORE files onto this script"
    echo "  2. Enter the desired output format (pdf, jpg, png, docx, etc.)"
    echo "  3. Files will be converted and saved in the same folder"
    echo
    echo "Supported conversions:"
    echo "  - PowerPoint/Word (ppt, pptx, doc, docx) → PDF"
    echo "  - PDF → Images (jpg, png, bmp, gif, tiff, webp)"
    echo "  - Images (jpg, png, bmp, gif, tiff, webp) → other formats"
    echo
    read -p "Press Enter to exit..."
    exit 1
fi

clear
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    FILE CONVERTER - DRAG & DROP${NC}"
echo -e "${BLUE}========================================${NC}"
echo

# Prompt for output extension with validation
while true; do
    read -p "Enter output format (pdf, jpg, png, docx, etc.): " OUTEXT
    
    if [ -z "$OUTEXT" ]; then
        echo -e "${RED}ERROR: Extension cannot be empty. Try again.${NC}"
        continue
    fi
    
    # Remove leading dot if present
    OUTEXT="${OUTEXT#.}"
    
    # Validate: only alphanumeric
    if ! [[ "$OUTEXT" =~ ^[a-zA-Z0-9]+$ ]]; then
        echo -e "${RED}ERROR: Invalid format. Use only letters and numbers.${NC}"
        continue
    fi
    
    break
done

echo
echo "Processing files..."
echo

TOTAL_FILES=0
SUCCESS_COUNT=0
FAILED_COUNT=0

# Function to convert a single file
convert_file() {
    local INFILE="$1"
    local ext="${INFILE##*.}"
    ext="${ext,,}"  # Convert to lowercase
    
    # Validate file exists and is a regular file
    if [ ! -f "$INFILE" ]; then
        echo -e "${YELLOW}[SKIP]${NC} File not found or is a directory: $INFILE"
        ((FAILED_COUNT++))
        return
    fi
    
    local OUTFILE="${INFILE%.*}.$OUTEXT"
    ((TOTAL_FILES++))
    
    echo "[$TOTAL_FILES] Converting: $(basename "$INFILE")"
    
    # PDF to Image
    if [[ "$ext" == "pdf" ]]; then
        if [[ "${OUTEXT,,}" =~ ^(jpg|jpeg|png|bmp|gif|tiff|tif|webp)$ ]]; then
            if ! command -v convert &> /dev/null; then
                echo -e "${RED}[ERROR]${NC} ImageMagick not installed. Install with: sudo apt install imagemagick ghostscript"
                ((FAILED_COUNT++))
                return
            fi
            echo "Converting PDF to image..."
            if convert "$INFILE" "$OUTFILE" > /dev/null 2>&1; then
                # Handle ImageMagick's multi-page PDF output naming (basename-0.ext, basename-1.ext, ...)
                base="${INFILE%.*}"
                shopt -s nullglob
                pdf_images=( "$base"-*."$OUTEXT" )
                shopt -u nullglob

                if [ ${#pdf_images[@]} -gt 1 ]; then
                    echo -e "${GREEN}[OK]${NC} Created ${#pdf_images[@]} images (e.g. $(basename "${pdf_images[0]}"), $(basename "${pdf_images[1]}")...) for $(basename "$INFILE")"
                elif [ ${#pdf_images[@]} -eq 1 ]; then
                    echo -e "${GREEN}[OK]${NC} $(basename "${pdf_images[0]}")"
                elif [ -e "$OUTFILE" ]; then
                    # Fallback for single-output cases where OUTFILE exists
                    echo -e "${GREEN}[OK]${NC} $(basename "$OUTFILE")"
                else
                    # Generic success message if we can't determine the exact output filenames
                    echo -e "${GREEN}[OK]${NC} PDF converted to image(s) with base name '$(basename "$base")'"
                fi
                ((SUCCESS_COUNT++))
            else
                echo -e "${RED}[ERROR]${NC} Conversion failed. Ensure ghostscript is installed."
                ((FAILED_COUNT++))
            fi
            return
        fi
    fi

    # PowerPoint to PDF (PPTX/PPT)
    if [[ "${OUTEXT,,}" == "pdf" ]]; then
        if [[ "$ext" == "pptx" || "$ext" == "ppt" ]]; then
            if ! command -v libreoffice &> /dev/null; then
                echo -e "${RED}[ERROR]${NC} LibreOffice not installed. Install with: sudo apt install libreoffice"
                ((FAILED_COUNT++))
                return
            fi
            echo "Converting PowerPoint to PDF..."
            if libreoffice --headless --convert-to pdf --outdir "$(dirname "$INFILE")" "$INFILE" > /dev/null 2>&1; then
                echo -e "${GREEN}[OK]${NC} $(basename "$OUTFILE")"
                ((SUCCESS_COUNT++))
            else
                echo -e "${RED}[ERROR]${NC} Conversion failed"
                ((FAILED_COUNT++))
            fi
            return
        fi
        
        # Word to PDF (DOCX/DOC)
        if [[ "$ext" == "docx" || "$ext" == "doc" ]]; then
            if ! command -v libreoffice &> /dev/null; then
                echo -e "${RED}[ERROR]${NC} LibreOffice not installed. Install with: sudo apt install libreoffice"
                ((FAILED_COUNT++))
                return
            fi
            echo "Converting Word to PDF..."
            if libreoffice --headless --convert-to pdf --outdir "$(dirname "$INFILE")" "$INFILE" > /dev/null 2>&1; then
                echo -e "${GREEN}[OK]${NC} $(basename "$OUTFILE")"
                ((SUCCESS_COUNT++))
            else
                echo -e "${RED}[ERROR]${NC} Conversion failed"
                ((FAILED_COUNT++))
            fi
            return
        fi
    fi
    
    # Image conversions (JPG, PNG, BMP, GIF, TIFF, WEBP)
    if [[ "$ext" =~ ^(jpg|jpeg|png|bmp|gif|tiff|tif|webp)$ ]]; then
        if ! command -v convert &> /dev/null; then
            echo -e "${RED}[ERROR]${NC} ImageMagick not installed. Install with: sudo apt install imagemagick"
            ((FAILED_COUNT++))
            return
        fi
        echo "Converting image format..."
        if convert "$INFILE" "$OUTFILE" > /dev/null 2>&1; then
            echo -e "${GREEN}[OK]${NC} $(basename "$OUTFILE")"
            ((SUCCESS_COUNT++))
        else
            echo -e "${RED}[ERROR]${NC} Image format not supported or conversion failed"
            ((FAILED_COUNT++))
        fi
        return
    fi
    
    # No conversion found
    echo -e "${RED}[ERROR]${NC} .${ext} → .${OUTEXT} conversion not supported"
    ((FAILED_COUNT++))
}

# Process all files
for file in "$@"; do
    convert_file "$file"
done

# Summary
clear
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}       CONVERSION COMPLETE${NC}"
echo -e "${BLUE}========================================${NC}"
echo
echo "Total files processed:   $TOTAL_FILES"
echo -e "Successful conversions:  ${GREEN}$SUCCESS_COUNT${NC}"
echo -e "Failed conversions:      ${RED}$FAILED_COUNT${NC}"
echo

if [ $FAILED_COUNT -gt 0 ]; then
    echo -e "${YELLOW}Check the errors above and try again.${NC}"
fi

echo
read -p "Press Enter to exit..."
exit 0
