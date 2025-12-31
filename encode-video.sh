#!/bin/bash

echo ""
echo "=========================================="
echo "     VIDEO ENCODER - DRAG & DROP"
echo "=========================================="
echo ""

# Check if files were provided
if [ -z "$1" ]; then
    echo "ERROR: No files detected!"
    echo ""
    echo "How to use:"
    echo "  1. Drag and drop one or MORE video files onto this script"
    echo "  2. Enter MB to reduce each file by"
    echo "  3. Compressed videos saved in 'Ready' folder"
    echo ""
    echo "Supported: MP4, MKV, AVI, MOV, FLV, WMV, WebM"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "ERROR: FFmpeg not installed"
    echo "Install with: sudo apt install ffmpeg"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

echo "Detected files ready to encode"
echo ""

# Prompt for reduction amount
while true; do
    read -p "Enter MB to reduce each file by: " REDUCE_MB
    
    if [ -z "$REDUCE_MB" ]; then
        echo "ERROR: Cannot be empty. Try again."
        echo ""
        continue
    fi
    
    if ! [[ "$REDUCE_MB" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Enter a number only."
        echo ""
        continue
    fi
    
    break
done

echo ""
echo "Encoding to MP4 format..."
echo ""

TOTAL=0
SUCCESS=0
FAILED=0

# Process each file
for file in "$@"; do
    ((TOTAL++))
    
    echo "[$TOTAL] $(basename "$file")"
    
    # Check file exists
    if [ ! -f "$file" ]; then
        echo "    ERROR - File not found"
        ((FAILED++))
        continue
    fi
    
    OUTDIR="$(dirname "$file")/Ready"
    OUTFILE="$OUTDIR/$(basename "${file%.*}")_compressed.mp4"
    
    # Create output directory
    mkdir -p "$OUTDIR" 2>/dev/null
    
    # Get original file size in MB
    ORIG_MB=$(du -m "$file" 2>/dev/null | awk '{print $1}')
    if [ -z "$ORIG_MB" ]; then
        echo "    ERROR - Cannot read file size"
        ((FAILED++))
        continue
    fi
    
    TARGET_MB=$((ORIG_MB - REDUCE_MB))
    [[ $TARGET_MB -lt 10 ]] && TARGET_MB=10
    
    # Get duration
    SECS=$(ffmpeg -i "$file" 2>&1 | grep Duration | awk '{print $2}' | tr -d , | awk -F: '{print int(($1*3600)+($2*60)+$3)}')
    if [[ -z "$SECS" || "$SECS" == "0" ]]; then
        echo "    ERROR - Cannot read duration"
        ((FAILED++))
        continue
    fi
    
    # Calculate bitrate
    KBITS=$(( (TARGET_MB * 8192) / SECS ))
    [[ $KBITS -lt 500 ]] && KBITS=500
    
    echo "    ${ORIG_MB}MB -> ${TARGET_MB}MB @ ${KBITS}kbit/s"
    
    ffmpeg -hide_banner -loglevel error -stats -i "$file" -c:v libx264 -b:v ${KBITS}k -c:a aac -b:a 128k "$OUTFILE" -y 2>/dev/null
    
    if [ $? -eq 0 ]; then
        OUT_MB=$(du -m "$OUTFILE" 2>/dev/null | awk '{print $1}')
        echo "    OK - ${OUT_MB}MB saved"
        ((SUCCESS++))
    else
        echo "    ERROR - Encoding failed"
        ((FAILED++))
    fi
done

echo ""
echo "=========================================="
echo "Processed: $TOTAL files"
echo "Success:   $SUCCESS"
echo "Failed:    $FAILED"
echo "=========================================="
echo "Output folder: Ready/"
echo ""
read -p "Press Enter to exit..."
exit 0
