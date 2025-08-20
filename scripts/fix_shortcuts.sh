#!/usr/bin/env bash
set -euo pipefail
QMD="quarto_llm_cheatsheet.qmd"

# STATE CHECK
command -v quarto >/dev/null || { echo "Quarto CLI not found (install from https://quarto.org)."; exit 1; }
test -f "$QMD" || { echo "Missing $QMD in current directory."; exit 1; }

# Patch: convert {{< ... >}} → {{</* ... */>}} so they render as text
# (idempotent: running again keeps the commented form)
perl -0777 -pe 's/\{\{<\s*(.*?)\s*>\}\}/{{<\/* $1 *\/>}}/g' -i "$QMD"

echo "Patched shortcode examples in $QMD."

# Test render (HTML only, no code execution)
quarto render "$QMD" --to html --no-execute

OUT="${QMD%.qmd}.html"
if [[ -f "$OUT" ]]; then
  echo "✅ Rendered $OUT"
  ls -lh "$OUT"
else
  echo "❌ HTML not produced; check Quarto output above."
  exit 1
fi