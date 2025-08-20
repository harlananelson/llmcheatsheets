# save as: ci_replace_minimal.sh
# run:
#   chmod +x ci_replace_minimal.sh
#   ./ci_replace_minimal.sh
#
# env overrides:
#   QMD=quarto_llm_cheatsheet.qmd BRANCHES='"**"' ./ci_replace_minimal.sh

#!/usr/bin/env bash
set -euo pipefail

QMD="${QMD:-quarto_llm_cheatsheet.qmd}"   # Quarto file to render
WF_DIR=".github/workflows"
NEW_WF="$WF_DIR/render.yml"
BRANCHES=${BRANCHES:-'"main"'}            # set to '"**"' to run on all branches

say(){ printf "\033[36m%s\033[0m\n" "$*"; }
err(){ printf "\033[31mERROR:\033[0m %s\n" "$*" >&2; exit 1; }

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || err "Run inside a git repo."
test -f "$QMD" || err "Missing $QMD"
mkdir -p "$WF_DIR"

# 1) Disable any existing workflows that might be invalid
shopt -s nullglob
disabled=0
for f in "$WF_DIR"/*.yml "$WF_DIR"/*.yaml; do
  [ "$(basename "$f")" = "$(basename "$NEW_WF")" ] && continue
  mv "$f" "$f.disabled"
  git add "$f.disabled"
  disabled=1
done
shopt -u nullglob

# 2) Write a minimal, valid workflow that just renders HTML and uploads it
cat > "$NEW_WF" <<YML
name: Render Quarto (HTML + artifacts)

on:
  push:
    branches: [ $BRANCHES ]
  workflow_dispatch:

jobs:
  render:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: quarto-dev/quarto-actions/setup@v3
      - name: Render HTML (no code execution)
        run: |
          set -euo pipefail
          quarto --version
          quarto render "$QMD" --to html --no-execute
          test -f "${QMD%.qmd}.html"
      - name: Upload HTML artifact
        uses: actions/upload-artifact@v4
        with:
          name: html
          if-no-files-found: error
          path: ${QMD%.qmd}.html
YML

git add "$NEW_WF"
if [ "$disabled" -eq 1 ]; then
  git commit -m "ci: replace with minimal Quarto render; disable old workflows"
else
  git commit -m "ci: add minimal Quarto render workflow"
fi
git push

# 3) Trigger CI (empty commit) and print link
git commit --allow-empty -m "ci: trigger minimal render" >/dev/null
git push
say "Pushed. Open Actions:"
echo "https://github.com/$(git config --get remote.origin.url | sed 's#.*github.com/##;s/.git$//')/actions"