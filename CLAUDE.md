# CLAUDE.md — OpenPhysics SceneryStack Simulations

General guidance for AI assistants working on **any** OpenPhysics SceneryStack simulation repository.

Each sim repo has its own `CLAUDE.md` with **sim-specific** context only (architecture, key files, physics, quirks). Read that file first, then use this document for shared conventions.

Community files (contributing, license, issue templates) live in [OpenPhysics/.github](https://github.com/OpenPhysics/.github). Orchestration — reusable CI/CD workflows, the repo catalog, and the compliance audit — lives in [OpenPhysics/Baton](https://github.com/OpenPhysics/Baton). Simulation READMEs follow a fixed six-section outline enforced by Baton's compliance check.

This document is the broad shared guide. For a single subsystem (colors, layout, drag listeners, preferences, i18n, accessibility, …) there is a deeper per-topic reference in [`Baton/skills/`](https://github.com/OpenPhysics/Baton/tree/main/skills) — each file says when it applies; see its [index](https://github.com/OpenPhysics/Baton/blob/main/skills/README.md). The structural and accessibility conventions live in [Baton/CONVENTIONS.md](https://github.com/OpenPhysics/Baton/blob/main/CONVENTIONS.md) and [Baton/ACCESSIBILITY.md](https://github.com/OpenPhysics/Baton/blob/main/ACCESSIBILITY.md).

## Tech stack

| Tool | Version | Notes |
|---|---|---|
| SceneryStack | ^3.0.0 | Simulation framework (PhET-derived) |
| Vite | ^8 | Build tool and dev server |
| TypeScript | ^6 | `erasableSyntaxOnly` — no `enum` or `namespace` |
| Biome | ^2.5 | Linting + formatting (not ESLint, not Prettier) |
| vite-plugin-pwa | ^1 | PWA / offline / installable |

Some sims add Vitest, Playwright, or OpenCV.js — see the sim's `CLAUDE.md` and `package.json`.

## Bootstrap import chain

`src/main.ts` must have `import "./brand.js"` as its **very first import**. This triggers the import chain:

```
main.ts → brand.ts → splash.ts → assert.ts → init.ts
```

`init.ts` executes first, then `assert.ts`, `splash.ts`, and `brand.ts`. **Never reorder these imports.** SceneryStack fails silently or throws cryptic errors if the chain breaks.

Standard bootstrap files in every sim:

| File | Purpose |
|---|---|
| `src/init.ts` | Sim name, version, locales — start of chain |
| `src/assert.ts` | Enables runtime assertions |
| `src/splash.ts` | Splash screen while loading |
| `src/brand.ts` | Brand registration (logo, copyright, links) |
| `src/main.ts` | Entry point — imports `brand.js` first |

`src/init.ts` also owns shared framework switches such as `availableLocales`, `allowLocaleSwitching`, and `colorProfiles` (including `"projector"` when Projector Mode is enabled).

## Standard layout

Most single-screen sims follow:

```
src/
  init.ts assert.ts splash.ts brand.ts main.ts
  *Colors.ts *Constants.ts *Namespace.ts   ← *Namespace.ts at src/ root, never in common/
  i18n/StringManager.ts strings_*.json
  preferences/
    *PreferencesModel.ts *PreferencesNode.ts *QueryParameters.ts  ← *QueryParameters.ts is lowercase-first camelCase
  <sim-screen>/
    *Screen.ts
    model/   ← state, physics, step(dt), reset()
    view/    ← Scenery nodes, layout, input
scripts/generate-icons.ts
.github/workflows/ci.yml   ← calls OpenPhysics/Baton reusable CI
```

Multi-screen sims add one folder per screen (e.g. `composer-screen/`, `single-oscillator/`). Shared code often lives in `src/common/`. There is no top-level `src/model/` or `src/view/` — those live inside a screen folder.

The full structural convention and per-sim checklist live in [Baton/CONVENTIONS.md](https://github.com/OpenPhysics/Baton/blob/main/CONVENTIONS.md) (the structural companion to [Baton/ACCESSIBILITY.md](https://github.com/OpenPhysics/Baton/blob/main/ACCESSIBILITY.md)), enforced by Baton's compliance check.

## Coding conventions

- **No `enum`** — use `const SomeEnum = { ... } as const` (TS6 `erasableSyntaxOnly`)
- **No `namespace`** — use modules or classes with static members
- **`import type`** required for type-only imports (`verbatimModuleSyntax`)
- **Formatter**: 2-space indent, 120-char line width, double quotes, always semicolons
- **Colors** → `*Colors.ts` as `ProfileColorProperty` — never hardcode hex/rgb in views
- **Strings** → `strings_*.json` + `StringManager` — never hardcode display text in views
- **Layout** → `this.layoutBounds` and shared layout constants — avoid magic pixel values
- **Model/view split** — model classes must not import from view

## SceneryStack patterns

### Properties (reactive state)

```typescript
import { NumberProperty, DerivedProperty } from "scenerystack/axon";

const massProperty = new NumberProperty(0.25);
massProperty.link((value) => { /* react */ });

const frequencyProperty = new DerivedProperty(
  [massProperty, springConstantProperty],
  (m, k) => Math.sqrt(k / m) / (2 * Math.PI),
);
```

Use `TReadOnlyProperty<T>` for read-only constructor parameters.

### Color profiles

```typescript
import { ProfileColorProperty, Color } from "scenerystack/scenery";

const springProperty = new ProfileColorProperty(namespace, "spring", {
  default: new Color(255, 100, 100),
  projector: new Color(204, 0, 0),
});
```

### Model–view–screen

```typescript
class MyScreen extends Screen<MyModel, MyScreenView> {
  constructor(options: ScreenOptions) {
    super(() => new MyModel(), (model) => new MyScreenView(model), options);
  }
}
```

Models implement `step(dt)` and `reset()`. Views update from model properties via `.link()` or `step(dt)`.

### Internationalization

Add keys to `strings_en.json` and **every** locale file. Expose via `StringManager` getters. TypeScript errors if locales diverge — intentional.

### Keyboard-help dialog

Every sim wires the navigation-bar keyboard-help (`?`) dialog through each **Screen** — never in `main.ts`/`init.ts`. Add a `<SimName>KeyboardHelpContent` class in the sim's `view/` (or `common/view/` for multi-screen sims) that extends `TwoColumnKeyboardHelpContent`, and pass it via the `createKeyboardHelpNode` screen option:

```typescript
import {
  BasicActionsKeyboardHelpSection,
  ComboBoxKeyboardHelpSection,
  SliderControlsKeyboardHelpSection,
  TwoColumnKeyboardHelpContent,
} from "scenerystack/scenery-phet";

export class MyKeyboardHelpContent extends TwoColumnKeyboardHelpContent {
  public constructor() {
    super(
      // Left column: the interaction-specific sections this sim actually uses.
      [new SliderControlsKeyboardHelpSection(), new ComboBoxKeyboardHelpSection()],
      // Right column: Tab/button navigation (+ checkbox toggling when present).
      [new BasicActionsKeyboardHelpSection({ withCheckboxContent: true })],
    );
  }
}

// in the Screen — keep the default after `...options`:
super(() => new MyModel(), (model) => new MyScreenView(model), {
  ...options,
  createKeyboardHelpNode: () => new MyKeyboardHelpContent(),
});
```

Compose only the standard sections the sim actually has (slider / combo box / checkbox). For a sim with no sliders or combo boxes, use a single column: `super([new BasicActionsKeyboardHelpSection()], [])`. Standard sections carry their own i18n, so no new strings are needed unless you hand-author custom `KeyboardHelpSection` rows.

## SceneryStack module paths

```
scenerystack/sim          Sim, Screen, ScreenView, PreferencesModel, onReadyToLaunch
scenerystack/axon         Property, BooleanProperty, NumberProperty, DerivedProperty, PatternStringProperty, TReadOnlyProperty
scenerystack/scenery      Node, Rectangle, Circle, Text, ProfileColorProperty, VBox, HBox
scenerystack/scenery-phet ResetAllButton, ArrowNode, NumberControl, NumberDisplay
scenerystack/dot          Vector2, Vector2Property, Dimension2, Range, Bounds2, Complex
scenerystack/phetcommon   ModelViewTransform2
scenerystack/sun          Panel, Checkbox, ComboBox, dialog controls
scenerystack/tandem       Tandem
scenerystack/phet-core    Namespace, optionize
scenerystack/chipper      LocalizedString
scenerystack/joist        TModel
scenerystack/query-string-machine  QueryStringMachine
scenerystack/utterance-queue        Utterance, UtteranceQueue, AriaLiveAnnouncer
scenerystack/init         init, madeWithSceneryStackSplashDataURI
scenerystack/brand        brand, TBrand
scenerystack/assert       enableAssert
scenerystack/splash       (side-effect import)
```

Import `.ts` sources with `.js` extensions in import paths.

## Adding simulation content

1. **Model** — add `Property<T>` fields; reset each in `reset()`
2. **View** — create `Node` subclasses; link to model properties
3. **Colors** — add `ProfileColorProperty` entries to `*Colors.ts`
4. **Strings** — add keys to all locale JSON files; expose in `StringManager`
5. **Preferences** — extend `PreferencesModel` options in `src/main.ts` when needed
6. **Accessibility** — give interactive nodes an `accessibleName`; keep the `ScreenView`'s `screenSummaryContent` and `pdomOrder` current (see below)

## Accessibility

All sims follow one shared accessibility pattern so they behave the same internally. The
canonical reference is `SceneryStackTemplate`; the full convention and per-sim checklist live in
[Baton/ACCESSIBILITY.md](https://github.com/OpenPhysics/Baton/blob/main/ACCESSIBILITY.md).
Three required layers:

1. **PDOM names** — every interactive node has an `accessibleName` (and `accessibleHelpText` where useful), sourced from `StringManager`'s `a11y` string group.
2. **Screen summary** — each `ScreenView` registers a `*ScreenSummaryContent` via the `screenSummaryContent` option, with a live `currentDetailsContent`.
3. **Keyboard** — deterministic traversal order via a wrapper `Node`'s `pdomOrder` (`ScreenView` throws if you set `pdomOrder` on itself), `KeyboardDragListener`/`KeyboardListener` on draggable objects, and a `*KeyboardHelpContent`.

Add a11y strings under an `a11y` key in every locale JSON and expose them via
`StringManager.getA11yStrings()`. Voicing/sonification is a later phase.

## Common commands

Run before opening a PR (add `npm test` when the sim defines it):

```bash
npm run lint && npm run check && npm run build
```

| Command | Description |
|---|---|
| `npm start` / `npm run dev` | Vite dev server → http://localhost:5173 |
| `npm run build` | Type-check + production build → `dist/` |
| `npm run preview` | Preview production build |
| `npm run check` | TypeScript (`tsc --noEmit`) |
| `npm run lint` | Biome check |
| `npm run format` | Biome format |
| `npm run fix` | Biome check --write |
| `npm run icons` | Regenerate PWA icons from `public/icons/icon.svg` |
| `npm run clean` | Remove `dist/` |

## TypeScript 6 notes

- `erasableSyntaxOnly` rejects `enum` and `namespace`
- `verbatimModuleSyntax` requires explicit `import type` for type-only symbols
- `noUncheckedSideEffectImports` — side-effect imports must be in package exports

## CI

Each sim's `.github/workflows/ci.yml` calls the reusable workflow:

```yaml
uses: OpenPhysics/Baton/.github/workflows/ci.yml@main
```

On push/PR to `main`: `npm run check`, `npm run lint`, `npm run icons && npm run build`.

## Unit tests (when present)

Tests are optional, but when a sim has them they live in a **root `tests/` folder** (mirroring
the source tree), with `tests/setup.ts` and a root `vitest.config.ts` — never co-located next to
source and never in `__tests__/` directories. This matches `SceneryStackTemplate`.

```typescript
import { describe, it, expect, beforeEach } from "vitest";
```

```
tests/
  setup.ts
  **/*.test.ts     ← unit tests
  **/*.spec.ts     ← Playwright specs, if any
vitest.config.ts   ← include: ["tests/**/*.test.ts"]; setupFiles: ["./tests/setup.ts"]
```

The vitest `environment` (`happy-dom` default, or `jsdom`/`node`) may vary per sim — document the
choice in the sim's `CLAUDE.md`. See [Baton/CONVENTIONS.md §5](https://github.com/OpenPhysics/Baton/blob/main/CONVENTIONS.md).

## Git hooks

All SceneryStack sims ship `.githooks/pre-commit` and `.githooks/pre-push`:

| Hook | Action |
|---|---|
| **pre-commit** | `npm run fix` on staged `.ts`/`.js`/`.json`/`.html` files, then re-stage |
| **pre-push** | `npm run lint` and `npm run check` |

Hooks activate automatically on `npm install` via the `prepare` script (no-op outside a git repo):

```json
"prepare": "git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git config core.hooksPath .githooks || true"
```

To bypass hooks in an emergency: `git commit --no-verify` / `git push --no-verify`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Do not add per-repo `CONTRIBUTING.md` or `LICENSE` — org defaults apply.
