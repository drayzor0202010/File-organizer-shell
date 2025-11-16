#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

TARGET="."
ACTION="move"
RECURSIVE=false
DRYRUN=false

while getopts ":d:mcrnh" opt; do
  case $opt in
    d) TARGET="$OPTARG" ;;
    m) ACTION="move" ;;
    c) ACTION="copy" ;;
    r) RECURSIVE=true ;;
    n) DRYRUN=true ;;
  esac
done

declare -A MAP=(
  [jpg]="Imagens" [jpeg]="Imagens" [png]="Imagens" [gif]="Imagens"
  [mp4]="Videos" [mkv]="Videos"
  [mp3]="Musica" [wav]="Musica"
  [pdf]="Documentos" [doc]="Documentos" [docx]="Documentos"
  [zip]="Comprimidos" [tar]="Comprimidos" [gz]="Comprimidos"
  [sh]="Scripts" [py]="Scripts" [c]="Codigo" [cpp]="Codigo"
)

move_or_copy() {
  local src="$1" destdir="$2"
  mkdir -p "$destdir"
  local base="$(basename "$src")"
  local destpath="$destdir/$base"

  if [[ -e "$destpath" ]]; then
    i=1
    while [[ -e "$destdir/${base%.*}_$i.${base##*.}" ]]; do ((i++)); done
    destpath="$destdir/${base%.*}_$i.${base##*.}"
  fi

  $DRYRUN && echo "[DRY] $ACTION $src -> $destpath" && return

  [[ "$ACTION" == "move" ]] && mv "$src" "$destpath" || cp -p "$src" "$destpath"
}

FILES=()
if $RECURSIVE; then
  while IFS= read -r -d '' f; do FILES+=("$f"); done < <(find "$TARGET" -type f -print0)
else
  for f in "$TARGET"/*; do [[ -f "$f" ]] && FILES+=("$f"); done
fi

for f in "${FILES[@]}"; do
  fname="$(basename "$f")"
  ext="${fname##*.}"
  [[ "$fname" == "$ext" ]] && dest="Sem_Extensao" || dest="${MAP[${ext,,}]:-Outros}"
  move_or_copy "$f" "$TARGET/$dest"
done
