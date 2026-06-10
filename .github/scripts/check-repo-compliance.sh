#!/usr/bin/env bash
# Compliance checks for OpenPhysics SceneryStack simulation repositories.
set -euo pipefail

REPO_DIR="${1:?Repository directory required}"
cd "$REPO_DIR"

echo "Checking compliance in: $(pwd)"
FAIL=0
WARN=0

fail() {
  echo "FAIL: $1"
  FAIL=1
}

warn() {
  echo "WARN: $1"
  WARN=1
}

pass() {
  echo "OK: $1"
}

if [ -f CONTRIBUTING.md ]; then
  fail "CONTRIBUTING.md must not exist at repo root (use org default from OpenPhysics/.github)"
else
  pass "no local CONTRIBUTING.md"
fi

if [ -f LICENSE ]; then
  fail "LICENSE must not exist at repo root (use org default from OpenPhysics/.github)"
else
  pass "no local LICENSE"
fi

REQUIRED_SECTIONS=(
  "Features"
  "Quick Start"
  "Scripts"
  "Tech Stack"
  "License"
  "Contributing"
)

if [ ! -f README.md ]; then
  fail "README.md is missing"
else
  mapfile -t HEADINGS < <(grep -E '^## ' README.md | sed 's/^## //')
  for heading in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -q "^## ${heading}" README.md; then
      fail "README.md missing '## ${heading}' section"
    else
      pass "README has ## ${heading}"
    fi
  done

  expected_index=0
  for heading in "${HEADINGS[@]}"; do
    if [ "$expected_index" -ge "${#REQUIRED_SECTIONS[@]}" ]; then
      fail "README.md has unexpected section '## ${heading}' (only standard sections allowed)"
      continue
    fi
    if [ "$heading" != "${REQUIRED_SECTIONS[$expected_index]}" ]; then
      if [ "$expected_index" -eq 0 ] && [ "$heading" = "Screens" ]; then
        fail "README.md must use '## Features' instead of '## Screens'"
      else
        fail "README.md section order wrong: expected '## ${REQUIRED_SECTIONS[$expected_index]}', found '## ${heading}'"
      fi
    else
      ((expected_index++)) || true
    fi
  done

  if [ "$expected_index" -ne "${#REQUIRED_SECTIONS[@]}" ]; then
    fail "README.md is missing one or more required sections after '## Features'"
  else
    pass "README section order matches standard outline"
  fi
fi

if [ ! -f .github/workflows/ci.yml ]; then
  fail ".github/workflows/ci.yml is missing"
elif ! grep -q "OpenPhysics/.github/.github/workflows/ci.yml@main" .github/workflows/ci.yml; then
  fail "ci.yml must call OpenPhysics/.github reusable workflow"
else
  pass "ci.yml uses shared reusable workflow"
fi

if [ "$FAIL" -ne 0 ]; then
  echo "Compliance check failed."
  exit 1
fi

if [ "$WARN" -ne 0 ]; then
  echo "Compliance check passed with warnings."
else
  echo "Compliance check passed."
fi
