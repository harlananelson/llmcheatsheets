#!/usr/bin/env bash
set -euo pipefail
BR="$(git branch --show-current)"
git rev-parse --is-inside-work-tree >/dev/null || { echo "Not a git repo"; exit 1; }
git commit --allow-empty -m "ci: trigger render" >/dev/null
git push -u origin "$BR"
echo "Pushed. Actions:"
echo "https://github.com/$(git config --get remote.origin.url | sed 's#.*github.com/##;s/.git$//')/actions"
