#!/usr/bin/env bash
set -euo pipefail

BR="$(git branch --show-current)"
echo "Branch: $BR"

# prerequisites
command -v gh >/dev/null || { echo "Install GitHub CLI: brew install gh"; exit 1; }
gh auth status >/dev/null || { echo "Run: gh auth login"; exit 1; }

# find the latest run on this branch
RID="$(gh run list --branch "$BR" --limit 1 --json databaseId -q '.[0].databaseId')"
test -n "${RID:-}" || { echo "No runs found on branch $BR"; exit 1; }
echo "Run ID: $RID"

# watch until completion (propagates failure as exit code)
gh run watch "$RID" --exit-status

# download the HTML artifact to ./artifacts
mkdir -p artifacts
# artifact was named 'html' in the minimal workflow
gh run download "$RID" -n html -D artifacts/

echo "Artifacts:"
ls -lh artifacts/ || true
