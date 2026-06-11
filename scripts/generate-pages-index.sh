#!/usr/bin/env bash
# Generate docs/index.html for the OpenPhysics GitHub Pages landing page.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPOS_JSON="$REPO_ROOT/structure/repos.json"
OUTPUT="$REPO_ROOT/docs/index.html"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

# Each line: name|url|hue|topics(comma-separated)@description
jq_program='
  .repos[]
  | select(.isSimulation == true and .status == "active")
  | select(.name | test("cd48"; "i") | not)
  | select(.isPhETPort == $phet)
  | "\(.name)|\(.deployedUrl // ("https://openphysics.github.io/" + .name))|\((.name | explode | add) % 360)|\(.physicsTopics | join(","))@\(.description)"
'

new_sims="$(jq -r --argjson phet false "$jq_program" "$REPOS_JSON" | sort)"
phet_sims="$(jq -r --argjson phet true "$jq_program" "$REPOS_JSON" | sort)"

html_escape() {
  printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

card_html() {
  local line="$1"
  local meta desc name url hue topics
  meta="${line%%@*}"
  desc="${line#*@}"
  IFS='|' read -r name url hue topics <<<"$meta"
  url="$(printf '%s' "$url" | sed 's|OpenPhysics|openphysics|g' | sed 's|/$||')"

  local title monogram
  title="$(printf '%s' "$name" | sed 's/\([A-Z]\)/ \1/g' | sed 's/^ //')"
  monogram="$(printf '%s' "$name" | grep -o '[A-Z]' | head -2 | tr -d '\n')"

  local tags_html=""
  if [[ -n "$topics" ]]; then
    local topic
    local count=0
    IFS=',' read -ra topic_arr <<<"$topics"
    for topic in "${topic_arr[@]}"; do
      [[ $count -ge 3 ]] && break
      tags_html+="<span class=\"tag\">$(html_escape "$topic")</span>"
      count=$((count + 1))
    done
  fi

  cat <<CARD
        <a class="card" href="${url}/" style="--hue: ${hue};">
          <div class="card-head">
            <span class="badge">${monogram}</span>
            <span class="card-arrow" aria-hidden="true">&rarr;</span>
          </div>
          <h3>$(html_escape "$title")</h3>
          <p>$(html_escape "$desc")</p>
          <div class="tags">${tags_html}</div>
        </a>
CARD
}

count_lines() {
  [[ -z "$1" ]] && { echo 0; return; }
  printf '%s\n' "$1" | grep -c .
}

new_count="$(count_lines "$new_sims")"
phet_count="$(count_lines "$phet_sims")"
total_count="$((new_count + phet_count))"

{
  cat <<'HEADER'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="OpenPhysics — open-source interactive physics simulations for the web.">
  <meta property="og:title" content="OpenPhysics Simulations">
  <meta property="og:description" content="Open-source interactive physics simulations for the web.">
  <meta name="theme-color" content="#0b1020">
  <title>OpenPhysics Simulations</title>
  <style>
    :root {
      color-scheme: dark;
      --bg: #080c18;
      --bg-2: #0d1326;
      --surface: rgba(255, 255, 255, 0.035);
      --surface-hover: rgba(255, 255, 255, 0.06);
      --text: #eef2fb;
      --muted: #98a6c8;
      --faint: #6c7896;
      --accent: #6f9bff;
      --border: rgba(255, 255, 255, 0.09);
      --radius: 16px;
      --maxw: 1140px;
    }

    * { box-sizing: border-box; }

    html { scroll-behavior: smooth; }

    body {
      margin: 0;
      font-family: "Inter", "Segoe UI", system-ui, -apple-system, sans-serif;
      color: var(--text);
      line-height: 1.6;
      min-height: 100vh;
      background: var(--bg);
      -webkit-font-smoothing: antialiased;
      overflow-x: hidden;
    }

    /* Animated aurora backdrop */
    .bg {
      position: fixed;
      inset: 0;
      z-index: -1;
      overflow: hidden;
      background:
        radial-gradient(60% 50% at 50% -5%, rgba(111, 155, 255, 0.20), transparent 70%),
        radial-gradient(40% 40% at 100% 0%, rgba(168, 85, 247, 0.12), transparent 70%),
        linear-gradient(180deg, var(--bg-2), var(--bg) 40%);
    }
    .bg::before, .bg::after {
      content: "";
      position: absolute;
      width: 45vw;
      height: 45vw;
      border-radius: 50%;
      filter: blur(90px);
      opacity: 0.5;
      animation: drift 22s ease-in-out infinite alternate;
    }
    .bg::before { background: radial-gradient(circle, rgba(91, 141, 239, 0.6), transparent 60%); top: -10vw; left: -8vw; }
    .bg::after  { background: radial-gradient(circle, rgba(168, 85, 247, 0.45), transparent 60%); bottom: -12vw; right: -8vw; animation-delay: -8s; }

    @keyframes drift {
      from { transform: translate(0, 0) scale(1); }
      to   { transform: translate(6vw, 4vw) scale(1.15); }
    }

    .wrap { max-width: var(--maxw); margin: 0 auto; padding: clamp(3rem, 8vw, 6rem) 1.5rem 4rem; }

    /* Hero */
    header { text-align: center; margin-bottom: 4rem; }
    .eyebrow {
      display: inline-block;
      font-size: 0.78rem;
      letter-spacing: 0.18em;
      text-transform: uppercase;
      color: var(--muted);
      padding: 0.35rem 0.9rem;
      border: 1px solid var(--border);
      border-radius: 999px;
      background: rgba(255, 255, 255, 0.03);
      margin-bottom: 1.5rem;
    }
    header h1 {
      margin: 0 0 1rem;
      font-size: clamp(2.5rem, 7vw, 4.25rem);
      font-weight: 800;
      letter-spacing: -0.03em;
      line-height: 1.05;
      background: linear-gradient(135deg, #ffffff 20%, #8fb2ff 60%, #c4a3ff 100%);
      -webkit-background-clip: text;
      background-clip: text;
      color: transparent;
    }
    header p { margin: 0 auto; max-width: 40rem; color: var(--muted); font-size: clamp(1rem, 2.5vw, 1.2rem); }

    .links { display: flex; flex-wrap: wrap; gap: 0.75rem; justify-content: center; margin-top: 2rem; }
    .links a {
      display: inline-flex;
      align-items: center;
      gap: 0.4rem;
      color: var(--text);
      text-decoration: none;
      padding: 0.6rem 1.2rem;
      border: 1px solid var(--border);
      border-radius: 999px;
      background: rgba(255, 255, 255, 0.04);
      font-size: 0.92rem;
      font-weight: 500;
      transition: background 0.18s, border-color 0.18s, transform 0.18s;
    }
    .links a:hover { background: rgba(111, 155, 255, 0.16); border-color: rgba(111, 155, 255, 0.4); transform: translateY(-1px); }
    .links a.primary { background: linear-gradient(135deg, #5b8def, #7c5bef); border-color: transparent; }
    .links a.primary:hover { filter: brightness(1.08); }

    /* Sections */
    section { margin-bottom: 3.5rem; }
    .section-head { display: flex; align-items: baseline; gap: 0.75rem; margin: 0 0 1.5rem; }
    .section-head h2 {
      margin: 0;
      font-size: 1.05rem;
      font-weight: 600;
      color: var(--text);
      text-transform: uppercase;
      letter-spacing: 0.1em;
    }
    .section-head .count {
      font-size: 0.8rem;
      color: var(--faint);
      padding: 0.1rem 0.55rem;
      border: 1px solid var(--border);
      border-radius: 999px;
    }
    .section-head::after {
      content: "";
      flex: 1;
      height: 1px;
      background: linear-gradient(90deg, var(--border), transparent);
    }

    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(290px, 1fr)); gap: 1.1rem; }

    /* Cards */
    .card {
      position: relative;
      display: flex;
      flex-direction: column;
      padding: 1.4rem;
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      text-decoration: none;
      color: inherit;
      overflow: hidden;
      backdrop-filter: blur(8px);
      transition: transform 0.2s ease, border-color 0.2s ease, background 0.2s ease, box-shadow 0.2s ease;
    }
    .card::before {
      content: "";
      position: absolute;
      inset: 0 0 auto 0;
      height: 3px;
      background: linear-gradient(90deg, hsl(var(--hue) 85% 65%), hsl(calc(var(--hue) + 45) 85% 62%));
      opacity: 0.85;
    }
    .card:hover {
      transform: translateY(-4px);
      background: var(--surface-hover);
      border-color: hsl(var(--hue) 70% 60% / 0.5);
      box-shadow: 0 16px 40px -16px hsl(var(--hue) 80% 55% / 0.55);
    }

    .card-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 1rem; }
    .badge {
      display: grid;
      place-items: center;
      width: 44px;
      height: 44px;
      border-radius: 12px;
      font-weight: 700;
      font-size: 0.95rem;
      letter-spacing: 0.02em;
      color: #fff;
      background: linear-gradient(135deg, hsl(var(--hue) 80% 58%), hsl(calc(var(--hue) + 45) 78% 52%));
      box-shadow: 0 6px 16px -6px hsl(var(--hue) 80% 55% / 0.7);
    }
    .card-arrow {
      font-size: 1.2rem;
      color: var(--faint);
      transition: transform 0.2s ease, color 0.2s ease;
    }
    .card:hover .card-arrow { transform: translate(3px, -3px); color: hsl(var(--hue) 85% 70%); }

    .card h3 { margin: 0 0 0.5rem; font-size: 1.1rem; font-weight: 650; color: var(--text); }
    .card p { margin: 0 0 1.1rem; flex: 1; font-size: 0.9rem; color: var(--muted); }

    .tags { display: flex; flex-wrap: wrap; gap: 0.4rem; margin-top: auto; }
    .tag {
      font-size: 0.72rem;
      color: var(--muted);
      padding: 0.18rem 0.6rem;
      border: 1px solid var(--border);
      border-radius: 999px;
      background: rgba(255, 255, 255, 0.03);
      white-space: nowrap;
    }

    footer {
      margin-top: 4rem;
      padding-top: 2rem;
      border-top: 1px solid var(--border);
      text-align: center;
      color: var(--faint);
      font-size: 0.85rem;
    }
    footer a { color: var(--muted); text-decoration: none; }
    footer a:hover { color: var(--accent); }

    @media (prefers-reduced-motion: reduce) {
      .bg::before, .bg::after { animation: none; }
      html { scroll-behavior: auto; }
    }
  </style>
</head>
<body>
  <div class="bg" aria-hidden="true"></div>
  <div class="wrap">
    <header>
      <span class="eyebrow">Open-source physics for the web</span>
      <h1>OpenPhysics</h1>
      <p>Interactive simulations for waves, mechanics, optics, electromagnetism, and quantum circuits &mdash; free to explore, remix, and teach with.</p>
      <div class="links">
        <a class="primary" href="#simulations">Browse simulations</a>
        <a href="https://github.com/OpenPhysics">GitHub Organization</a>
        <a href="https://github.com/OpenPhysics/.github/blob/main/CONTRIBUTING.md">Contributing</a>
      </div>
    </header>

    <main id="simulations">
HEADER

  cat <<SECTION
    <section>
      <div class="section-head">
        <h2>Core Simulations</h2>
        <span class="count">${new_count}</span>
      </div>
      <div class="grid">
SECTION

  while IFS= read -r line; do
    [[ -n "$line" ]] && card_html "$line"
  done <<<"$new_sims"

  cat <<SECTION
      </div>
    </section>

    <section>
      <div class="section-head">
        <h2>Classic &amp; PhET Ports</h2>
        <span class="count">${phet_count}</span>
      </div>
      <div class="grid">
SECTION

  while IFS= read -r line; do
    [[ -n "$line" ]] && card_html "$line"
  done <<<"$phet_sims"

  cat <<FOOTER
      </div>
    </section>
    </main>

    <footer>
      <p>${total_count} live simulations &middot; Built with <a href="https://scenerystack.org/">SceneryStack</a> &middot; MIT License &middot;
      <a href="https://github.com/OpenPhysics/.github">OpenPhysics/.github</a></p>
    </footer>
  </div>
</body>
</html>
FOOTER
} >"$OUTPUT"

echo "Wrote $OUTPUT"
