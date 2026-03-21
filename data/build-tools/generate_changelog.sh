#!/usr/bin/env bash
set -Eeuo pipefail

#######################################
# Configuration
#######################################
CONFIG_FILE=".mod-build-config.json"
OUTPUT_FILE="CHANGELOG.md"

VERSION="${1:-}"
MOD_NAME="${2:-}"

#######################################
# Error handling
#######################################
trap 'echo "Error: Script failed at line $LINENO" >&2' ERR

#######################################
# Dependency checks
#######################################
command -v git >/dev/null 2>&1 || {
  echo "Error: git is not installed or not in PATH" >&2
  exit 1
}

command -v jq >/dev/null 2>&1 || {
  echo "Error: jq is not installed or not in PATH" >&2
  exit 1
}

#######################################
# Validation
#######################################
if [[ -z "$VERSION" || -z "$MOD_NAME" ]]; then
  echo "Usage: $0 <VERSION> <MOD_NAME>" >&2
  exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Config file not found: $CONFIG_FILE" >&2
  exit 1
fi

jq empty "$CONFIG_FILE" || {
  echo "Error: Invalid JSON in $CONFIG_FILE" >&2
  exit 1
}

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Error: Not inside a git repository" >&2
  exit 1
}

#######################################
# Git range
#######################################
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)

if [[ -n "$LAST_TAG" ]]; then
  RANGE="$LAST_TAG..HEAD"
else
  RANGE="HEAD"
fi

mapfile -t COMMITS < <(git log "$RANGE" --pretty=format:%s)

#######################################
# Output header
#######################################
DATE=$(date +"%Y-%m-%d")

{
  echo "## Changelog of $MOD_NAME v$VERSION"
  echo "*$DATE*"
  echo ""
} > "$OUTPUT_FILE"

#######################################
# Processing
#######################################
jq -c '.changelog_categories[]' "$CONFIG_FILE" | while read -r entry; do
  OUTPUT=$(jq -r '.output' <<< "$entry")
  mapfile -t INPUTS < <(jq -r '.inputs[]' <<< "$entry")

  shopt -s nocasematch

  for commit in "${COMMITS[@]}"; do
    [[ -z "$commit" ]] && continue

    for input in "${INPUTS[@]}"; do
      if [[ "$input" =~ ^[[:alnum:]]+$ ]]; then
        [[ "$commit" =~ ^\[$input\][[:space:]]*(.+)$ ]] || continue
      else
        [[ "$commit" =~ ^$input[[:space:]]*(.+)$ ]] || continue
      fi

      TEXT="${BASH_REMATCH[1]}"

      if [[ "$OUTPUT" =~ ^[[:alnum:]]+$ ]]; then
        echo "- $OUTPUT: $TEXT" >> "$OUTPUT_FILE"
      else
        echo "- $OUTPUT $TEXT" >> "$OUTPUT_FILE"
      fi
      break
    done
  done

  shopt -u nocasematch
done

echo "Changelog successfully created in $OUTPUT_FILE."
