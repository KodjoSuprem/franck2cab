#!/bin/bash

output_file="download_archive.txt"
declare -A existing_ids

# Charger les IDs déjà présents
if [[ -f "$output_file" ]]; then
    while read -r line; do
        [[ "$line" =~ youtube\ ([a-zA-Z0-9_-]{11}) ]] && existing_ids[${BASH_REMATCH[1]}]=1
    done < "$output_file"
fi

# Chercher les fichiers MP3 dans le dossier courant
shopt -s nullglob

for f in *.mp3; do
    url=$(ffprobe -v error -show_entries format_tags=comment,purl -of default=noprint_wrappers=1:nokey=1 "$f" \
        | grep -Eo 'https://www\.youtube\.com/watch\?v=[a-zA-Z0-9_-]{11}' | head -n1)

    if [[ -n "$url" ]]; then
        video_id=$(echo "$url" | sed -E 's/.*v=([a-zA-Z0-9_-]{11}).*/\1/')

        if [[ -z "${existing_ids[$video_id]}" ]]; then
            echo "youtube $video_id" >> "$output_file"
            existing_ids[$video_id]=1
            echo "➕ Added $video_id from $f"
        else
            echo "✅ Already present: $video_id"
        fi
    else
        echo "⚠️ No video ID found in $f"
    fi
done

echo "✅ Mise à jour de $output_file terminée."
