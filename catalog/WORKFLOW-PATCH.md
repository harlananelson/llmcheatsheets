# CI workflow patch (apply with `workflow` token scope)

GitHub rejects Contents API updates under `.github/workflows/` unless the token
includes the `workflow` OAuth scope. The Quarto kit PR therefore ships this
intended change for maintainers to apply (or re-auth `gh` with `-s workflow`).

## Option A — new workflow file

Add `.github/workflows/catalog-check.yml`:

```yaml
name: Quarto kit catalog check

on:
  push:
  pull_request:
  workflow_dispatch:

jobs:
  catalog-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - name: Quarto kit catalog check
        run: |
          set -euo pipefail
          python3 scripts/qk check
```

## Option B — extend `.github/workflows/render.yml`

Add a `pull_request` trigger and a `catalog-check` job that runs
`python3 scripts/qk check` (see branch build artifact
`/workspace/qk-build/.github/workflows/render.yml` in the authoring workspace).

After applying, delete this note file in a follow-up commit.
