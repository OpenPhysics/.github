# OpenPhysics `.github`

Organization-level GitHub configuration for the [OpenPhysics](https://github.com/OpenPhysics) GitHub
organization. Simulation repositories inherit default community health files from this repo when they do
not define their own.

## Contents

| Path | Purpose |
|---|---|
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Contribution guidelines (GitHub Flow, PR checklist, quality commands) |
| [`CLAUDE.md`](CLAUDE.md) | General AI-assistant guide for all SceneryStack sim repos |
| [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) | Contributor Covenant v2.1 |
| [`SECURITY.md`](SECURITY.md) | Security reporting via GitHub Security Advisories |
| [`LICENSE`](LICENSE) | MIT license — org default for simulation repos |
| [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/) | Bug report and feature request templates |
| [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md) | Pull request template |
| [`.github/workflows/ci.yml`](.github/workflows/ci.yml) | Reusable CI workflow (lint, type-check, build) |
| [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) | Reusable GitHub Pages deploy workflow |
| [`.github/workflows/shared-compliance-check.yml`](.github/workflows/shared-compliance-check.yml) | README and repo-structure compliance audit |
| [`structure/repos.json`](structure/repos.json) | Machine-readable catalog of org repositories |

## Default community files

GitHub automatically serves these files from this repository as organization-wide defaults for member
repos that do not have their own copies:

- `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `LICENSE`
- Issue and pull request templates under `.github/`

SceneryStack simulation repos should **not** duplicate `CONTRIBUTING.md` or `LICENSE` at the repo root;
link to the org defaults instead (see any sim `README.md` **Contributing** section).

Each sim repo keeps a **sim-specific** [`CLAUDE.md`](CLAUDE.md) at its root; shared SceneryStack conventions, bootstrap chain, module paths, and CI live in **this** org [`CLAUDE.md`](CLAUDE.md). Do not add per-repo `AGENTS.md` — use `CLAUDE.md` instead.

## Shared CI

Each simulation's `.github/workflows/ci.yml` calls the reusable workflow:

```yaml
jobs:
  ci:
    uses: OpenPhysics/.github/.github/workflows/ci.yml@main
```

Optional compliance checking (pilot on TemplateSingleSim):

```yaml
  compliance:
    uses: OpenPhysics/.github/.github/workflows/shared-compliance-check.yml@main
    with:
      repo-name: ${{ github.event.repository.name }}
```

## Compliance workflow

[`shared-compliance-check.yml`](.github/workflows/shared-compliance-check.yml) runs weekly (Mondays 06:00 UTC)
and on manual dispatch. It reads [`structure/repos.json`](structure/repos.json), clones each simulation repo,
and checks:

- **FAIL** if `CONTRIBUTING.md` or `LICENSE` exists at repo root
- **FAIL** if `README.md` is missing `## Features`, `## Quick Start`, `## Scripts`, `## Tech Stack`, `## License`, or `## Contributing`
- **FAIL** if `README.md` sections are out of order or include extra top-level sections (only the six standard sections allowed)
- **FAIL** if `.github/workflows/ci.yml` does not call the shared reusable CI workflow

Simulation READMEs use a fixed six-section outline (in order): **Features → Quick Start → Scripts → Tech Stack → License → Contributing**. Per-sim content lives in **Features** and optional extra rows in **Scripts**; long-form docs belong in `doc/` or `CLAUDE.md`, not the README.

Run locally against a checkout:

```bash
.github/scripts/check-repo-compliance.sh /path/to/sim-repo
```

## Repository catalog

[`structure/repos.json`](structure/repos.json) lists all OpenPhysics repositories with metadata (simulation
type, framework, deployed URL, physics topics, etc.). The compliance workflow and org profile README consume
this file.
