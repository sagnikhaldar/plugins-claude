#!/usr/bin/env bash
# Mirror each catalogued plugin's version from its source repo's
# .claude-plugin/plugin.json into this marketplace manifest. Idempotent:
# rewrites marketplace.json in place and leaves it unchanged when already
# in sync. Requires `gh` (authenticated) and `jq`.
set -euo pipefail

MANIFEST="${1:-.claude-plugin/marketplace.json}"
PLUGIN_PATH=".claude-plugin/plugin.json"

if [[ ! -f "$MANIFEST" ]]; then
  echo "error: manifest not found: $MANIFEST" >&2
  exit 1
fi

# name<TAB>repo for every github-sourced plugin.
mapfile -t entries < <(
  jq -r '.plugins[] | select(.source.source == "github") | "\(.name)\t\(.source.repo)"' "$MANIFEST"
)

for entry in "${entries[@]}"; do
  name="${entry%%$'\t'*}"
  repo="${entry##*$'\t'}"

  upstream="$(
    gh api "repos/${repo}/contents/${PLUGIN_PATH}" \
      -H "Accept: application/vnd.github.raw" 2>/dev/null | jq -r '.version' || true
  )"
  if [[ -z "$upstream" || "$upstream" == "null" ]]; then
    echo "warn: could not read ${PLUGIN_PATH} version for ${name} (${repo}); skipping" >&2
    continue
  fi

  current="$(jq -r --arg n "$name" '.plugins[] | select(.name == $n) | .version' "$MANIFEST")"
  if [[ "$current" == "$upstream" ]]; then
    echo "${name}: up to date (${current})"
    continue
  fi

  echo "${name}: ${current} -> ${upstream}"
  tmp="$(mktemp)"
  jq --arg n "$name" --arg v "$upstream" \
    '(.plugins[] | select(.name == $n) | .version) = $v' "$MANIFEST" >"$tmp"
  mv "$tmp" "$MANIFEST"
done
