#!/usr/bin/env bash
# Installs Eric's Claude Code agents and skills into ~/.claude/
# Safe to re-run: if a file already exists and differs, it's backed up to <file>.bak first.
#
# Usage (from the repo root):
#   ./install.sh
# If you get "permission denied", run:  bash install.sh

set -euo pipefail

# Directory this script lives in, so it works no matter where you run it from.
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/claude"
DEST="$HOME/.claude"

echo "Installing Claude config from: $SRC"
echo "                          into: $DEST"
echo

# Copy one file, backing up any existing different version first.
install_file() {
  local src_file="$1"
  local dest_file="$2"
  mkdir -p "$(dirname "$dest_file")"
  if [ -f "$dest_file" ] && ! cmp -s "$src_file" "$dest_file"; then
    cp "$dest_file" "$dest_file.bak"
    echo "  backed up existing -> $dest_file.bak"
  fi
  cp "$src_file" "$dest_file"
  echo "  installed $dest_file"
}

# Walk every file under claude/ and mirror it into ~/.claude/
while IFS= read -r -d '' file; do
  rel="${file#"$SRC/"}"           # path relative to claude/
  install_file "$file" "$DEST/$rel"
done < <(find "$SRC" -type f -print0)

# Seed a personal learner profile the first time so the teacher agent has someone
# to calibrate to. Never overwrite an existing one; it's yours to edit.
PROFILE="$DEST/learner-profile.md"
TEMPLATE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/learner-profile.example.md"
if [ ! -f "$PROFILE" ] && [ -f "$TEMPLATE" ]; then
  cp "$TEMPLATE" "$PROFILE"
  echo "  created $PROFILE, edit it to personalize the teacher agent"
fi

echo
echo "Done. Restart Claude Code (or run /agents) to pick up the changes."
