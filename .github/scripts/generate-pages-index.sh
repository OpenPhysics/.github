#!/usr/bin/env bash
# Generate docs/index.html for the OpenPhysics GitHub Pages landing page.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPOS_JSON="$REPO_ROOT/structure/repos.json"
OUTPUT="$REPO_ROOT/docs/index.html"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

new_sims="$(jq -r '
  .repos[]
  | select(.isSimulation == true and .status == "active")
  | select(.name | test("cd48"; "i") | not)
  | select(.isPhETPort == false)
  | "\(.name)|\(.deployedUrl // ("https://openphysics.github.io/" + .name))|@\(.description)"
' "$REPOS_JSON" | sort)"

phet_sims="$(jq -r '
  .repos[]
  | select(.isSimulation == true and .status == "active")
  | select(.name | test("cd48"; "i") | not)
  | select(.isPhETPort == true)
  | "\(.name)|\(.deployedUrl // ("https://openphysics.github.io/" + .name))|@\(.description)"
' "$REPOS_JSON" | sort)"

card_html() {
  local line="$1"
  local name url desc
  name="${line%%|*}"
  url="${line#*|}"
  url="${url%%@*}"
  desc="${line#*@}"
  url="$(printf '%s' "$url" | sed 's|OpenPhysics|openphysics|g' | sed 's|/$||')"

  local title
  title="$(printf '%s' "$name" | sed 's/\([A-Z]\)/ \1/g' | sed 's/^ //')"

  cat <<CARD
        <a class="card" href="${url}/">
          <h3>${title}</h3>
          <p>${desc}</p>
          <span class="card-link">Open simulation →</span>
        </a>
CARD
}

{
  cat <<'HEADER'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="OpenPhysics — open-source interactive physics simulations for the web.">
  <title>OpenPhysics Simulations</title>
  <style>
    :root {
      color-scheme: dark;
      --bg: #0b1020;
      --surface: #141b2f;
      --surface-hover: #1a2340;
      --text: #e8edf7;
      --muted: #9aa8c7;
      --accent: #5b8def;
      --accent-soft: rgba(91, 141, 239, 0.15);
      --border: rgba(255, 255, 255, 0.08);
    }

    * { box-sizing: border-box; }

    body {
      margin: 0;
      font-family: "Segoe UI", system-ui, -apple-system, sans-serif;
      background:
        radial-gradient(ellipse 80% 50% at 50% -10%, rgba(91, 141, 239, 0.18), transparent),
        var(--bg);
      color: var(--text);
      line-height: 1.5;
      min-height: 100vh;
    }

    .wrap {
      max-width: 1100px;
      margin: 0 auto;
      padding: 3rem 1.5rem 4rem;
    }

    header {
      text-align: center;
      margin-bottom: 3rem;
    }

    header h1 {
      margin: 0 0 0.75rem;
      font-size: clamp(2rem, 5vw, 2.75rem);
      font-weight: 700;
      letter-spacing: -0.02em;
    }

    header p {
      margin: 0 auto;
      max-width: 42rem;
      color: var(--muted);
      font-size: 1.1rem;
    }

    .links {
      display: flex;
      flex-wrap: wrap;
      gap: 0.75rem;
      justify-content: center;
      margin-top: 1.5rem;
    }

    .links a {
      color: var(--accent);
      text-decoration: none;
      padding: 0.4rem 0.9rem;
      border: 1px solid var(--border);
      border-radius: 999px;
      background: var(--accent-soft);
      font-size: 0.9rem;
    }

    .links a:hover { background: rgba(91, 141, 239, 0.25); }

    section { margin-bottom: 2.5rem; }

    section h2 {
      margin: 0 0 1rem;
      font-size: 1.15rem;
      font-weight: 600;
      color: var(--muted);
      text-transform: uppercase;
      letter-spacing: 0.06em;
    }

    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 1rem;
    }

    .card {
      display: flex;
      flex-direction: column;
      padding: 1.25rem;
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 12px;
      text-decoration: none;
      color: inherit;
      transition: background 0.15s, border-color 0.15s, transform 0.15s;
    }

    .card:hover {
      background: var(--surface-hover);
      border-color: rgba(91, 141, 239, 0.35);
      transform: translateY(-2px);
    }

    .card h3 {
      margin: 0 0 0.5rem;
      font-size: 1.05rem;
      color: var(--text);
    }

    .card p {
      margin: 0;
      flex: 1;
      font-size: 0.92rem;
      color: var(--muted);
    }

    .card-link {
      margin-top: 1rem;
      font-size: 0.85rem;
      font-weight: 600;
      color: var(--accent);
    }

    footer {
      margin-top: 3rem;
      text-align: center;
      color: var(--muted);
      font-size: 0.85rem;
    }

    footer a { color: var(--accent); text-decoration: none; }
    footer a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <div class="wrap">
    <header>
      <h1>OpenPhysics</h1>
      <p>Interactive physics simulations built for the web — explore waves, mechanics, optics, quantum circuits, and more.</p>
      <div class="links">
        <a href="https://github.com/OpenPhysics">GitHub Organization</a>
        <a href="https://github.com/OpenPhysics/.github/blob/main/CONTRIBUTING.md">Contributing</a>
      </div>
    </header>

    <section>
      <h2>Core Simulations</h2>
      <div class="grid">
HEADER

  while IFS= read -r line; do
    [[ -n "$line" ]] && card_html "$line"
  done <<<"$new_sims"

  cat <<'MIDDLE'
      </div>
    </section>

    <section>
      <h2>Classic &amp; PhET Ports</h2>
      <div class="grid">
MIDDLE

  while IFS= read -r line; do
    [[ -n "$line" ]] && card_html "$line"
  done <<<"$phet_sims"

  cat <<'FOOTER'
      </div>
    </section>

    <footer>
      <p>Built with <a href="https://scenerystack.org/">SceneryStack</a> · MIT License ·
      <a href="https://github.com/OpenPhysics/.github">OpenPhysics/.github</a></p>
    </footer>
  </div>
</body>
</html>
FOOTER
} >"$OUTPUT"

echo "Wrote $OUTPUT"
