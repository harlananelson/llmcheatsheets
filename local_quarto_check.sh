#!/usr/bin/env bash
set -euo pipefail

QMD="${QMD:-cheatsheets/quarto_llm_cheatsheet.qmd}"   # override with: QMD=foo.qmd ./local_quarto_check.sh

echo "=== STATE CHECK ==="
command -v quarto >/dev/null || { echo "Quarto CLI not found. On macOS: brew install --cask quarto"; exit 1; }
echo "quarto: $(quarto --version)"
echo "pwd:    $(pwd)"
test -f "$QMD" || { echo "Missing $QMD in repo root."; exit 1; }

echo
echo "=== Render HTML (no code execution) ==="
quarto render "$QMD" --to html --no-execute
HTML_OUT="${QMD%.qmd}.html"
test -f "$HTML_OUT" && echo "OK: $HTML_OUT created" || { echo "FAIL: $HTML_OUT not found"; exit 1; }

echo
echo "=== Render PDF (optional) ==="
if quarto render "$QMD" --to pdf --no-execute; then
  PDF_OUT="${QMD%.qmd}.pdf"
  test -f "$PDF_OUT" && echo "OK: $PDF_OUT created" || echo "PDF render ran but file missing"
else
  echo "PDF render failed (likely missing LaTeX). To install TinyTeX locally:"
  echo "  quarto install tinytex   # or brew install --cask mactex-no-gui"
fi

echo
echo "=== DONE ==="
ls -lh "$HTML_OUT" 2>/dev/null || true
ls -lh "${QMD%.qmd}.pdf" 2>/dev/null || true