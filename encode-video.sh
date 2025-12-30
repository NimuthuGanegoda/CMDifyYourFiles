#!/bin/bash
# encode-video.sh - Video size reducer with folder support

# === CONFIG ===================================================
FFMPEG=ffmpeg
DEFAULT_MAX_MB=10    # default max output size per video
# ==============================================================

read -p "Enter target max size in MB (default ${DEFAULT_MAX_MB}): " MAX_MB
if [[ -z "$MAX_MB" ]]; then
    MAX_MB=$DEFAULT_MAX_MB
fi

SOURCE="${1:-$(pwd)}"

process_file() {
    IN="$1"
    OUT_DIR="$(dirname "$IN")/Ready"
    OUT="$OUT_DIR/$(basename "${IN%.*}")_ready.mp4"
    mkdir -p "$OUT_DIR"

    # Get duration in seconds
    SECS=$($FFMPEG -i "$IN" 2>&1 | grep Duration | awk '{print $2}' | tr -d , | awk -F: '{print ($1*3600)+($2*60)+$3}')
    if [[ -z "$SECS" || "$SECS" == "0" ]]; then
        echo "Could not get duration for $IN"
        return
    fi

    # Calculate target bitrate (kbit/s) for MAX_MB; subtract ~128k for audio
    MAX_KBITS=$(( (MAX_MB * 8192) / SECS - 128 ))
    [[ $MAX_KBITS -lt 200 ]] && MAX_KBITS=200

    echo
    echo "Processing $(basename "$IN")  (${SECS}s  ->  ${MAX_MB}MB @ ${MAX_KBITS}kbit/s)"

    # Two-pass encode for better quality at target bitrate
    $FFMPEG -hide_banner -loglevel error -stats \
        -i "$IN" \
        -c:v libx264 -b:v ${MAX_KBITS}k -pass 1 -an -f mp4 -y /dev/null

    $FFMPEG -hide_banner -loglevel error -stats \
        -i "$IN" \
        -c:v libx264 -b:v ${MAX_KBITS}k -pass 2 \
        -c:a aac -b:a 96k -movflags +faststart \
        "$OUT" -y
}

export -f process_file
export FFMPEG MAX_MB

if [[ -d "$SOURCE" ]]; then
    find "$SOURCE" -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.flv" -o -iname "*.wmv" -o -iname "*.webm" \) \
        -exec bash -c 'process_file "$0"' {} \;
else
    process_file "$SOURCE"
fi
