#!/usr/bin/env bash
set -euo pipefail

BR="$(git branch --show-current)"
echo "Branch: $BR"

command -v gh >/dev/null || { echo "Install GitHub CLI: brew install gh"; exit 1; }
gh auth status >/dev/null || { echo "Run: gh auth login"; exit 1; }

RID="$(gh run list --branch "$BR" --limit 1 --json databaseId -q '.[0].databaseId')"
test -n "${RID:-}" || { echo "No runs found on branch $BR"; exit 1; }
echo "Run ID: $RID"

echo "----- SUMMARY -----"
gh run view "$RID" --json name,displayTitle,headBranch,status,conclusion,event,workflowName -q '
  "workflow=\(.workflowName)  title=\(.displayTitle)\nbranch=\(.headBranch)  status=\(.status)  conclusion=\(.conclusion)  event=\(.event)"
'

echo "----- JOBS -----"
gh run view "$RID" --json jobs -q '
  .jobs[] | "job=\(.name)  status=\(.status)  conclusion=\(.conclusion)"'
echo

echo "----- LOG (last 200 lines) -----"
# Don’t fail the script if the run failed; we still want logs
gh run view "$RID" --log | tail -n 200 || true
