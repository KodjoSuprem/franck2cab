#!/bin/bash



DIR="."
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Fonction pour reformater upload_date (YYYYMMDD → YYYY)
format_date() {
    echo "$1" | cut -c1-4
}

# Boucle sur les fichiers au nom générique
find "$DIR" -maxdepth 1 -type f -name "youtube video #*.mp3" | while read -r FILE; do
    BASENAME=$(basename "$FILE")

    if [[ "$BASENAME" =~ youtube\ video\ \#([a-zA-Z0-9_-]{11})\.mp3 ]]; then
        ID="${BASH_REMATCH[1]}"
        echo "▶️ Traitement de $ID..."

        # Bloc de traitement avec gestion d'erreur
        {
            # Extraction JSON via yt-dlp
            METADATA=$(yt-dlp --no-warnings --skip-download --print-json "https://www.youtube.com/watch?v=$ID")

            TITLE=$(echo "$METADATA" | jq -r '.title')
            CHANNEL=$(echo "$METADATA" | jq -r '.channel')
            DATE=$(echo "$METADATA" | jq -r '.upload_date')
            YEAR=$(format_date "$DATE")
            DESCRIPTION=$(echo "$METADATA" | jq -r '.description')
            URL=$(echo "$METADATA" | jq -r '.webpage_url')

            # Nettoyer le titre pour un nom de fichier valide
            SAFE_TITLE=$(echo "$TITLE" | sed 's#[/:*?"<>|]#-#g')
            NEW_FILENAME="${SAFE_TITLE}.mp3"

            SRC="$FILE"
            DST="$DIR/$NEW_FILENAME"
            TMP_MP3="$TMPDIR/$(basename "$NEW_FILENAME")"

            # Ne pas écraser un fichier s'il existe déjà
            if [[ -f "$DST" ]]; then
                echo "⚠️ Fichier déjà présent, on saute : $DST"
                continue
            fi

            # Traitement ffmpeg : copier l'audio + injecter les métadonnées
            ffmpeg -y -i "$SRC" \
                -metadata title="$TITLE" \
                -metadata artist="$CHANNEL" \
                -metadata date="$YEAR" \
                -metadata description="$DESCRIPTION" \
                -metadata synopsis="$DESCRIPTION" \
                -metadata purl="$URL" \
                -metadata comment="$URL" \
                -codec copy "$TMP_MP3" < /dev/null

            mv -v -- "$TMP_MP3" "$DST"
            rm -f -- "$SRC"

            echo "✅ Corrigé : $BASENAME → $NEW_FILENAME"
            echo
        } || {
            echo "❌ Erreur lors du traitement de $BASENAME, on passe au suivant."
            continue
        }
    else
        echo "⛔️ Ignoré : nom de fichier non générique : $BASENAME"
    fi
done

