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

convert "$TMP/points.png" sparse-color: \
        | sed "s/ /\n/g" \
        | grep -E "gray\(255\)" \
        | sed "s/,gray(255)//g" \
        | awk -v ln=1 '{printf $0 " #%03X ", ln++}' > "$TMP/sparse-points.txt"

convert "$1" -sparse-color Voronoi "@$TMP/sparse-points.txt" "$2"
