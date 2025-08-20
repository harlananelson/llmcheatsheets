#!/usr/bin/env bash
set -euo pipefail
QMD="quarto_llm_cheatsheet.qmd"
IMG_DIR="images"
IMG="$IMG_DIR/placeholder.svg"

# State check
command -v quarto >/dev/null || { echo "Quarto CLI not found."; exit 1; }
test -f "$QMD" || { echo "Missing $QMD"; exit 1; }

# Create a small SVG placeholder
mkdir -p "$IMG_DIR"
cat > "$IMG" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="320" height="200">
  <rect width="100%" height="100%" fill="#ffffff"/>
  <text x="12" y="24" font-size="14" fill="#333">Placeholder figure</text>
  <circle cx="60" cy="150" r="4" fill="#333"/>
  <circle cx="150" cy="110" r="4" fill="#333"/>
  <circle cx="260" cy="70" r="4" fill="#333"/>
  <line x1="40" y1="160" x2="280" y2="60" stroke="#999"/>
</svg>
SVG

# Insert a Markdown figure with the needed label if not already present
if ! grep -q '{#fig-scatter' "$QMD"; then
  awk '
    BEGIN{ins=0}
    /^## 6\) Figures/ && !ins {
      print;
      print "";
      print "![Scatter of X vs Y](images/placeholder.svg){#fig-scatter fig-cap=\"Scatter of X vs Y\"}";
      print "";
      ins=1; next
    }
    {print}
  ' "$QMD" > "$QMD.tmp" && mv "$QMD.tmp" "$QMD"
  echo "Inserted placeholder figure under '## 6) Figures'."
else
  if ! grep -q 'images/placeholder.svg' "$QMD"; then
    printf '\n![Scatter of X vs Y](images/placeholder.svg){#fig-scatter fig-cap="Scatter of X vs Y"}\n' >> "$QMD"
    echo "Appended placeholder figure at end."
  else
    echo "Placeholder figure already present."
  fi
fi

# Render without executing code cells
quarto render "$QMD" --to html --no-execute
HTML_OUT="${QMD%.qmd}.html"
test -f "$HTML_OUT" && { echo "✅ Rendered $HTML_OUT"; ls -lh "$HTML_OUT"; } || { echo "❌ HTML not produced"; exit 1; }