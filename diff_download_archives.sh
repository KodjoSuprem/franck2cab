#!/bin/bash

archive_file="download_archive.txt"
declare -A archive_ids
declare -A disk_urls
declare -A disk_ids

# Charger les IDs de l'archive
if [[ -f "$archive_file" ]]; then
    while read -r line; do
        [[ "$line" =~ youtube\ ([a-zA-Z0-9_-]{11}) ]] && archive_ids[${BASH_REMATCH[1]}]=1
    done < "$archive_file"
else
    echo "❌ Fichier $archive_file introuvable."
    exit 1
fi

# Analyser les fichiers mp3 présents sur disque
shopt -s nullglob
for f in *.mp3; do
    url=$(ffprobe -v error -show_entries format_tags=comment,purl -of default=noprint_wrappers=1:nokey=1 "$f" \
        | grep -Eo 'https://www\.youtube\.com/watch\?v=[a-zA-Z0-9_-]{11}' | head -n1)

    if [[ -n "$url" ]]; then
        id=$(echo "$url" | sed -E 's/.*v=([a-zA-Z0-9_-]{11}).*/\1/')
        disk_urls["$id"]="$url"
        disk_ids["$id"]=1
    else
        echo "⚠️  Aucun ID trouvé dans $f"
    fi
done

echo "🔍 Fichiers présents sur le disque mais absents de $archive_file :"
for id in "${!disk_ids[@]}"; do
    if [[ -z "${archive_ids[$id]}" ]]; then
        echo "➕ ${disk_urls[$id]}"
    fi
done

echo
echo "🔍 IDs présents dans $archive_file mais absents sur le disque :"
for id in "${!archive_ids[@]}"; do
    if [[ -z "${disk_ids[$id]}" ]]; then
        echo "❌ https://www.youtube.com/watch?v=$id"
    fi
done
