# Contributing to OpenPhysics

Thank you for your interest in contributing to OpenPhysics simulations and tools.

## How to contribute

We use [GitHub Flow](https://guides.github.com/introduction/flow/):

1. Fork the repository and create a branch from `main`.
2. Make your changes with clear, focused commits.
3. Run the quality checks locally (see below).
4. Open a pull request with a clear description of the change.

## Development checks

For SceneryStack simulation repositories, run these before opening a PR:

```bash
npm install
npm run lint
npm run check
npm run build
```

If the repository defines `npm test` and CI runs tests, run `npm test` as well.

## Pull requests

Use the repository pull request template when available. Include:

- What changed and why
- How you tested the change
- Links to related issues (`Fixes #123` when applicable)

## Reporting bugs

Open a [bug report issue](https://github.com/OpenPhysics/.github/issues/new/choose) in the affected simulation repository, or use the **Bug report** template if available.

## Feature requests

Open a **Feature request** issue describing the use case and proposed behavior.

## Code of conduct

This project follows the [OpenPhysics Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold it.

## License

By contributing, you agree that your contributions will be licensed under the [GNU Affero General Public License v3.0](LICENSE) used by OpenPhysics simulation repositories. CD48 hardware libraries (`jscd48`, `tscd48`) use the [MIT License](LICENSE-MIT) instead.
