# OpenPhysics org scripts

Utilities for reading [`structure/repos.json`](../../structure/repos.json) and operating on
OpenPhysics repositories. These scripts are intended for local use and for AI agents working in
the monorepo checkout.

## Prerequisites

- [`jq`](https://jqlang.org/)
- [`gh`](https://cli.github.com/) for GitHub sync commands

## Quick reference

| Script | Purpose |
|---|---|
| [`parse-repos.sh`](parse-repos.sh) | Core parser/CLI for `repos.json` |
| [`list-repos.sh`](list-repos.sh) | Human-friendly listing wrapper |
| [`sync-github-metadata.sh`](sync-github-metadata.sh) | Push description + website to GitHub |
| [`lib/repos.sh`](lib/repos.sh) | Bash helper functions for other scripts |
| [`check-repo-compliance.sh`](check-repo-compliance.sh) | README/CI compliance checks |
| [`sync-dependabot.sh`](sync-dependabot.sh) | Copy Dependabot configs to sim repos |

## parse-repos.sh

Primary entry point for agents. Reads `structure/repos.json` and adds computed fields:

- `githubHomepage` — normalized Pages URL (`https://openphysics.github.io/{name}`)
- `localPath` — sibling directory in the workspace checkout
- `localExists` — whether that directory is present locally

```bash
# All repository names
.github/scripts/parse-repos.sh names

# Simulation repos only
.github/scripts/parse-repos.sh names --simulation

# Full JSON with computed fields
.github/scripts/parse-repos.sh list --format json --simulation

# One repo
.github/scripts/parse-repos.sh get DopplerEffect

# Local checkout paths for sims that exist on disk
.github/scripts/parse-repos.sh paths --simulation --require-local

# Run a command per repo (env: REPO_NAME, REPO_HOMEPAGE, REPO_PATH, ...)
.github/scripts/parse-repos.sh for-each --simulation -- \
  echo "$REPO_NAME -> $REPO_HOMEPAGE"

# Catalog summary
.github/scripts/parse-repos.sh summary
```

Filters:

- `--type simulation|template|config|hardware-interface|tool`
- `--status active|template`
- `--simulation` / `--no-simulation`

## sync-github-metadata.sh

Updates GitHub **Description** and **Website** from `repos.json`:

```bash
.github/scripts/sync-github-metadata.sh --dry-run
.github/scripts/sync-github-metadata.sh
.github/scripts/sync-github-metadata.sh --repo TemplateSingleSim
```

Note: GitHub does not expose API toggles for **Deployments** / **Packages** in the About sidebar.

## Bash helpers

Source from other scripts:

```bash
source "$(dirname "$0")/lib/repos.sh"
repos_simulation_names | while read -r sim; do
  echo "$sim"
done
```

Or call the CLI directly:

```bash
.github/scripts/parse-repos.sh names --simulation
```

## Workspace layout

Scripts assume the org `.github` repo lives beside member repos:

```
OpenPhysics/
  .github/          ← this repo
  DopplerEffect/
  TemplateSingleSim/
  ...
```

If your checkout differs, set `OPENPHYSICS_WORKSPACE` or pass `--catalog /path/to/repos.json`.
