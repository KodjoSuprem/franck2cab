#!/bin/bash

# yt_channel_audio.sh
# Télécharge toutes les pistes audio d'une chaîne YouTube en MP3 avec miniature comme pochette.

# Vérifie que yt-dlp et ffmpeg sont installés
if ! command -v yt-dlp &> /dev/null; then
    echo "yt-dlp n'est pas installé. Installez-le avec : brew install yt-dlp"
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg n'est pas installé. Installez-le avec : brew install ffmpeg"
    exit 1
fi

# Vérifie que l'URL de la chaîne est fournie
if [ -z "$1" ]; then
    echo "Usage : $0 <URL_DE_LA_CHAINE_YOUTUBE>"
    exit 1
fi

URL="$1"

yt-dlp --no-overwrites --no-mtime --download-archive download_archive.txt -f bestaudio --embed-metadata --extract-audio --audio-format mp3 --embed-thumbnail --output "%(title)s.%(ext)s" "$URL"
