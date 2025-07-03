# mp3yt

Ce projet propose un script Bash pour télécharger toutes les pistes audio d'une chaîne YouTube, convertir en MP3, ajouter la miniature comme pochette et les métadonnées.

## Prérequis
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [ffmpeg](https://ffmpeg.org/)

Installez-les sur macOS avec Homebrew :

```sh
brew install yt-dlp ffmpeg
```

## Utilisation

```sh
./yt_channel_audio.sh <URL_DE_LA_CHAINE_YOUTUBE>
```

Les fichiers MP3 seront créés dans le dossier courant, avec la miniature de chaque vidéo comme pochette.

## Licence
MIT
