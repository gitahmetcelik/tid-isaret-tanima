#!/bin/sh
# Iki sunumu derler: ekip-sunumu.tex (ekibin tamami) ve sunum.tex (yalnizca model kismi).
# Sayfa numaralari icin her biri iki kez calisiyor.
set -e
cd "$(dirname "$0")"

# Mac'te TinyTeX kurulu ama PATH'e eklenmemis olabiliyor.
if ! command -v pdflatex >/dev/null 2>&1; then
    for d in "$HOME"/Library/TinyTeX/bin/*; do PATH="$d:$PATH"; done
fi

for f in ekip-sunumu sunum; do
    pdflatex -interaction=nonstopmode "$f.tex"
    pdflatex -interaction=nonstopmode "$f.tex"
done

echo "bitti: ekip-sunumu.pdf, sunum.pdf"
