#!/bin/sh
# Raporu derler: pdflatex -> bibtex -> pdflatex -> pdflatex
# (Kaynakça ve içindekiler için iki kez daha çalışması gerekiyor.)
set -e
cd "$(dirname "$0")"

pdflatex -interaction=nonstopmode thesis.tex
bibtex thesis
pdflatex -interaction=nonstopmode thesis.tex
pdflatex -interaction=nonstopmode thesis.tex

echo "bitti: thesis.pdf"
