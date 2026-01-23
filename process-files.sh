#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check dependencies
check_deps() {
    local missing=0
    if ! command -v pdfunite &> /dev/null; then
        echo -e "${RED}Error: poppler-utils (pdfunite) not found.${NC}"
        echo "Install with: sudo apt install poppler-utils"
        missing=1
    fi
    if ! command -v pdfseparate &> /dev/null; then
        echo -e "${RED}Error: poppler-utils (pdfseparate) not found.${NC}"
        echo "Install with: sudo apt install poppler-utils"
        missing=1
    fi
    if ! command -v gs &> /dev/null; then
        echo -e "${RED}Error: ghostscript not found.${NC}"
        echo "Install with: sudo apt install ghostscript"
        missing=1
    fi
    if ! command -v montage &> /dev/null; then
        echo -e "${RED}Error: imagemagick (montage) not found.${NC}"
        echo "Install with: sudo apt install imagemagick"
        missing=1
    fi
    if ! command -v qpdf &> /dev/null; then
        echo -e "${RED}Error: qpdf not found.${NC}"
        echo "Install with: sudo apt install qpdf"
        missing=1
    fi

    if [ $missing -eq 1 ]; then
        exit 1
    fi
}

merge_pdfs() {
    if [ "$#" -lt 3 ]; then
        echo -e "${RED}Error: At least 2 input files and 1 output file required.${NC}"
        echo "Usage: merge file1.pdf file2.pdf ... output.pdf"
        return 1
    fi

    # Last argument is output
    local args=("$@")
    local len=${#args[@]}
    local output=${args[$((len-1))]}
    unset args[$((len-1))]

    echo "Merging files into $output..."
    pdfunite "${args[@]}" "$output"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Success!${NC}"
    else
        echo -e "${RED}Failed to merge PDFs.${NC}"
    fi
}

split_pdf() {
    if [ "$#" -ne 2 ]; then
        echo -e "${RED}Error: Input file and output prefix required.${NC}"
        echo "Usage: split input.pdf output-prefix"
        return 1
    fi

    local input=$1
    local prefix=$2

    echo "Splitting $input..."
    pdfseparate "$input" "${prefix}-%d.pdf"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Success! Pages saved as ${prefix}-N.pdf${NC}"
    else
        echo -e "${RED}Failed to split PDF.${NC}"
    fi
}

compress_pdf() {
    if [ "$#" -ne 2 ]; then
        echo -e "${RED}Error: Input file and output file required.${NC}"
        echo "Usage: compress input.pdf output.pdf"
        return 1
    fi

    local input=$1
    local output=$2

    echo "Compressing $input..."
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
       -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$output" "$input"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Success! Saved to $output${NC}"
    else
        echo -e "${RED}Failed to compress PDF.${NC}"
    fi
}

create_collage() {
    if [ "$#" -lt 2 ]; then
        echo -e "${RED}Error: At least 1 input file and 1 output file required.${NC}"
        echo "Usage: collage file1.jpg file2.jpg ... output.jpg"
        return 1
    fi

    # Last argument is output
    local args=("$@")
    local len=${#args[@]}
    local output=${args[$((len-1))]}
    unset args[$((len-1))]

    echo "Creating collage..."
    # Using montage with auto-layout
    montage "${args[@]}" -geometry +0+0 -frame 5 -shadow -background none "$output"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Success! Saved to $output${NC}"
    else
        echo -e "${RED}Failed to create collage.${NC}"
    fi
}

rotate_pdf() {
    if [ "$#" -ne 3 ]; then
        echo -e "${RED}Error: Input file, angle, and output file required.${NC}"
        echo "Usage: rotate input.pdf angle output.pdf"
        echo "Angle examples: +90, +180, -90"
        return 1
    fi

    local input=$1
    local angle=$2
    local output=$3

    echo "Rotating $input by $angle degrees..."
    qpdf --rotate="$angle" "$input" "$output"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Success! Saved to $output${NC}"
    else
        echo -e "${RED}Failed to rotate PDF.${NC}"
    fi
}

watermark_pdf() {
    if [ "$#" -ne 3 ]; then
        echo -e "${RED}Error: Input file, text, and output file required.${NC}"
        echo "Usage: watermark input.pdf 'Watermark Text' output.pdf"
        return 1
    fi

    local input=$1
    local text=$2
    local output=$3
    local temp_watermark="temp_watermark_$(date +%s).pdf"

    echo "Creating watermark with text '$text'..."
    # Create a temporary transparent watermark PDF
    convert -size 1000x1000 xc:none -gravity center -pointsize 60 \
            -fill "rgba(0,0,0,0.2)" -annotate 45 "$text" \
            "$temp_watermark"

    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to create watermark image.${NC}"
        return 1
    fi

    echo "Applying watermark..."
    qpdf "$input" --overlay "$temp_watermark" --repeat=1 -- "$output"

    local ret=$?
    rm -f "$temp_watermark"

    if [ $ret -eq 0 ]; then
        echo -e "${GREEN}Success! Saved to $output${NC}"
    else
        echo -e "${RED}Failed to watermark PDF.${NC}"
    fi
}

interactive_menu() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}       ADVANCED FILE TOOLS${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo "1. Merge PDFs"
    echo "2. Split PDF"
    echo "3. Compress PDF"
    echo "4. Create Image Collage"
    echo "5. Rotate PDF"
    echo "6. Watermark PDF"
    echo "q. Quit"
    echo
    read -p "Select an option: " choice

    case $choice in
        1)
            read -p "Enter PDF files to merge (space separated): " files
            read -p "Enter output filename: " out
            merge_pdfs $files "$out"
            ;;
        2)
            read -p "Enter PDF file to split: " infile
            read -p "Enter output prefix (e.g. page): " prefix
            split_pdf "$infile" "$prefix"
            ;;
        3)
            read -p "Enter PDF file to compress: " infile
            read -p "Enter output filename: " out
            compress_pdf "$infile" "$out"
            ;;
        4)
            read -p "Enter image files for collage (space separated): " files
            read -p "Enter output filename: " out
            create_collage $files "$out"
            ;;
        5)
            read -p "Enter PDF file to rotate: " infile
            read -p "Enter rotation angle (+90, +180, -90): " angle
            read -p "Enter output filename: " out
            rotate_pdf "$infile" "$angle" "$out"
            ;;
        6)
            read -p "Enter PDF file to watermark: " infile
            read -p "Enter watermark text: " text
            read -p "Enter output filename: " out
            watermark_pdf "$infile" "$text" "$out"
            ;;
        q)
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
}

# Main execution
check_deps

if [ -z "$1" ]; then
    interactive_menu
else
    CMD=$1
    shift
    case $CMD in
        merge)
            merge_pdfs "$@"
            ;;
        split)
            split_pdf "$@"
            ;;
        compress)
            compress_pdf "$@"
            ;;
        collage)
            create_collage "$@"
            ;;
        rotate)
            rotate_pdf "$@"
            ;;
        watermark)
            watermark_pdf "$@"
            ;;
        *)
            echo "Unknown command: $CMD"
            echo "Available commands: merge, split, compress, collage, rotate, watermark"
            exit 1
            ;;
    esac
fi
