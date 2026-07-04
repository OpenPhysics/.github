# OpenPhysics `.github`

Organization-level GitHub configuration for the [OpenPhysics](https://github.com/OpenPhysics) GitHub
organization. Simulation repositories inherit default community health files from this repo when they do
not define their own.

> **Orchestration lives in [OpenPhysics/Baton](https://github.com/OpenPhysics/Baton).**  This repo 
> holds the community-health defaults that GitHub requires in the special `.github` repo.

## Contents

| Path | Purpose |
|---|---|
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Contribution guidelines (GitHub Flow, PR checklist, quality commands) |
| [`CLAUDE.md`](CLAUDE.md) | General AI-assistant guide for all SceneryStack sim repos |
| [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) | Contributor Covenant v2.1 |
| [`SECURITY.md`](SECURITY.md) | Security reporting via GitHub Security Advisories |
| [`LICENSE`](LICENSE) | GNU Affero GPL v3 — org default for simulation repos |
| [`LICENSE-MIT`](LICENSE-MIT) | MIT license — used by CD48 hardware libraries (`jscd48`, `tscd48`) |
| [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/) | Bug report and feature request templates |
| [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md) | Pull request template |
| [`profile/README.md`](profile/README.md) | Organization profile page |

## Default community files

GitHub automatically serves these files from this repository as organization-wide defaults for member
repos that do not have their own copies:

- `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `LICENSE`
- Issue and pull request templates under `.github/`

SceneryStack simulation repos should **not** duplicate `CONTRIBUTING.md` or `LICENSE` at the repo root;
link to the org defaults instead (see any sim `README.md` **Contributing** section).

CD48 hardware libraries (`jscd48`, `tscd48`) keep their own MIT `LICENSE` at the repo root and do not
inherit the org default.

Each sim repo keeps a **sim-specific** [`CLAUDE.md`](CLAUDE.md) at its root; shared SceneryStack conventions, bootstrap chain, module paths, and CI live in **this** org [`CLAUDE.md`](CLAUDE.md). Fleet structure and accessibility conventions live in [Baton/CONVENTIONS.md](https://github.com/OpenPhysics/Baton/blob/main/CONVENTIONS.md) and [Baton/ACCESSIBILITY.md](https://github.com/OpenPhysics/Baton/blob/main/ACCESSIBILITY.md). Do not add per-repo `AGENTS.md` — use `CLAUDE.md` instead.

## Shared CI, automation, and catalog

These now live in [OpenPhysics/Baton](https://github.com/OpenPhysics/Baton):

- Reusable CI/CD workflows — each sim's `.github/workflows/ci.yml` calls
  `uses: OpenPhysics/Baton/.github/workflows/ci.yml@main`
- Compliance audit (`shared-compliance-check.yml`) enforcing the six-section README outline
- Repository catalog (`structure/repos.json`) and the `scripts/` tooling that reads it
- Dependabot templates (`config/`) and the GitHub Pages landing page (`pages.yml` + `docs/`)
- Fleet conventions (`CONVENTIONS.md`, `ACCESSIBILITY.md`) and SceneryStack AI reference docs (`skills/`)

See the [Baton README](https://github.com/OpenPhysics/Baton#readme) for usage.
