#!/usr/bin/env bash

TMP="$(mktemp -d)"

if [ -z "$1" ]  || [ -z "$2" ]; then
  echo "Usage: $0 <input> <output>"
  exit 1
fi

convert "$1" -define convolve:scale='!' \
        -define morphology:compose=Lighten \
        -morphology Convolve 'Sobel:>' "$TMP/edges.png"

convert xc:White xc:Black -append "$TMP/blacknwhite.png"

convert "$TMP/edges.png" -auto-level \
        -dither FloydSteinberg \
        +level 0%,10% \
        -remap "$TMP/blacknwhite.png" "$TMP/points.png"

convert "$1" "$TMP/points.png" \
        -compose CopyOpacity \
        -composite "$TMP/points-coloured.png"

convert "$TMP/points-coloured.png" sparse-color: > "$TMP/sparse-points.txt"

convert "$1" -sparse-color Voronoi "$(cat "$TMP/sparse-points.txt")" "$2"
