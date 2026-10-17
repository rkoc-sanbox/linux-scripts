#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <output_dir>"
    exit 1
fi

OUTPUT_DIR="$1"
mkdir -p "$OUTPUT_DIR"

for f in *.MP4; do
    if [ ! -f "$f" ]; then
        echo "No MP4 files found in current directory."
        exit 1
    fi

    OUTPUT_FILE="$OUTPUT_DIR/${f%.*}-c.MP4"
    PART_FILE="${OUTPUT_FILE}.part"

    if [ -f "$OUTPUT_FILE" ]; then
        echo "Skipping (already done): $f"
        continue
    fi

    echo "Processing: $f"
    	cpulimit -l 200 -- ffmpeg -i "$f" \
        -c:v libx265 \
        -preset slow \
        -crf 23 \
        -threads 4 \
        -c:a copy \
        -f mp4 \
        "$PART_FILE"

    if [ $? -eq 0 ]; then
        mv "$PART_FILE" "$OUTPUT_FILE"
        echo "Done: $f -> $OUTPUT_FILE"
    else
        echo "Error processing: $f — removing .part file"
        rm -f "$PART_FILE"
        exit 1
    fi
done

echo "All files processed!"

