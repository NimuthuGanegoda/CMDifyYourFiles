#!/bin/bash
# discord-encode.sh - Cross-platform audio size reducer for Discord
# Works on Linux, Mac, Windows (with WSL or Git Bash)

# === CONFIG ===================================================
FFMPEG=ffmpeg
AUDIO_EXT=ogg        # "ogg" (Opus) or "m4a" (AAC)
# ==============================================================

read -p "Enter the amount (in MB) to reduce each file by: " REDUCE_MB
if [[ -z "$REDUCE_MB" ]]; then
    echo "No reduction amount entered. Exiting."
    exit 1
fi

SOURCE="${1:-$(pwd)}"

process_file() {
    IN="$1"
    OUT_DIR="$(dirname "$IN")/DiscordReady"
    OUT="$OUT_DIR/$(basename "${IN%.*}")_discord.$AUDIO_EXT"
    mkdir -p "$OUT_DIR"

    # Get original file size in MB
    ORIG_MB=$(du -m "$IN" | awk '{print $1}')
    MAX_MB=$((ORIG_MB - REDUCE_MB))
    [[ $MAX_MB -lt 1 ]] && MAX_MB=1

    # Get duration in seconds
    SECS=$($FFMPEG -i "$IN" 2>&1 | grep Duration | awk '{print $2}' | tr -d , | awk -F: '{print ($1*3600)+($2*60)+$3}')
    if [[ -z "$SECS" || "$SECS" == "0" ]]; then
        echo "Could not get duration for $IN"
        return
    fi

    # Calculate target bitrate (kbit/s) for MAX_MB
    MAX_KBITS=$(( (MAX_MB * 8192) / SECS ))
    [[ $MAX_KBITS -lt 48 ]] && MAX_KBITS=48

    echo
    echo "Processing $(basename "$IN")  (${SECS}s  ->  ${MAX_MB}MB @ ${MAX_KBITS}kbit/s)"

    if [[ "$AUDIO_EXT" == "m4a" ]]; then
        $FFMPEG -hide_banner -loglevel error -stats \
            -i "$IN" -c:a aac -b:a ${MAX_KBITS}k -movflags +faststart "$OUT" -y
    else
        $FFMPEG -hide_banner -loglevel error -stats \
            -i "$IN" -c:a libopus -b:a ${MAX_KBITS}k -vbr on -compression_level 10 "$OUT" -y
    fi
}

export -f process_file
export FFMPEG AUDIO_EXT REDUCE_MB

find "$SOURCE" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.m4a" -o -iname "*.aac" -o -iname "*.ogg" -o -iname "*.opus" -o -iname "*.wma" \) \
    -exec bash -c 'process_file "$0"' {} \;
