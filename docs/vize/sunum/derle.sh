#!/bin/sh
# Sunumu derler: sunum.tex -> sunum.pdf (sayfa numaralari icin iki kez calisiyor)
set -e
cd "$(dirname "$0")"

# Mac'te TinyTeX kurulu ama PATH'e eklenmemis olabiliyor.
if ! command -v pdflatex >/dev/null 2>&1; then
    for d in "$HOME"/Library/TinyTeX/bin/*; do PATH="$d:$PATH"; done
fi

pdflatex -interaction=nonstopmode sunum.tex
pdflatex -interaction=nonstopmode sunum.tex

echo "bitti: sunum.pdf"
