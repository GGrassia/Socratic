#!/usr/bin/env bash
# Installs Socratic mode globally (user-level, not per project) on macOS and Linux.
#   ./install.sh            both harnesses
#   ./install.sh claude     Claude Code only  -> $CLAUDE_CONFIG_DIR or ~/.claude
#   ./install.sh opencode   OpenCode only     -> $XDG_CONFIG_HOME/opencode or ~/.config/opencode
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
target="${1:-all}"

case "$target" in
  all|claude|opencode) ;;
  *) echo "Usage: $0 [all|claude|opencode]" >&2; exit 1 ;;
esac

copy_tree() {
  [ -d "$1" ] || { echo "Missing source folder: $1" >&2; exit 1; }
  mkdir -p "$2"
  ( cd "$1" && find . -type f ) | while IFS= read -r rel; do
    rel="${rel#./}"
    src="$1/$rel"; dst="$2/$rel"
    mkdir -p "$(dirname "$dst")"
    # Keep whatever the person customised before we overwrite it.
    if [ -f "$dst" ] && ! cmp -s "$src" "$dst"; then
      cp "$dst" "$dst.bak"
      echo "  kept your edited $rel as $rel.bak"
    fi
    cp "$src" "$dst"
  done
}

# The two harness copies of each prompt must stay identical apart from frontmatter
# and the harness-specific tail. Editing one and not the other is the easiest way
# to break this repo, so the installer refuses to run on drift.
prompt_body() {
  awk -v cut="$2" '
    { sub(/\r$/, "") }
    NR == 1 && $0 == "---" { front = 1; next }
    front { if ($0 == "---") front = 0; next }
    cut != "" && $0 == cut { exit }
    { lines[++n] = $0 }
    END {
      while (n > 0 && lines[n] ~ /^[[:space:]]*$/) n--
      for (i = 1; i <= n; i++) print lines[i]
    }
  ' "$1"
}

assert_in_sync() {
  left="$1"; right="$2"; cut="${3:-}"
  tmp="$(mktemp -d)"
  prompt_body "$left" "$cut" > "$tmp/left"
  prompt_body "$right" "$cut" > "$tmp/right"
  if cmp -s "$tmp/left" "$tmp/right"; then
    echo "  prompt in sync: $(basename "$left")"
  else
    echo "" >&2
    echo "Prompt copies have drifted:" >&2
    echo "  $left" >&2
    echo "  $right" >&2
    diff -u -L "left/$left" -L "right/$right" "$tmp/left" "$tmp/right" >&2 || true
    rm -rf "$tmp"
    echo "Prompt copies must stay identical apart from frontmatter and the harness-specific tail." >&2
    echo "Fix both files, then run the installer again." >&2
    exit 1
  fi
  rm -rf "$tmp"
}

echo "Checking that both harnesses carry the same prompts..."
assert_in_sync "$here/claude-code/output-styles/socratic.md" "$here/opencode/agents/socratic.md" "## Tools in this harness"
assert_in_sync "$here/claude-code/agents/socratic-researcher.md" "$here/opencode/agents/socratic-researcher.md"
assert_in_sync "$here/claude-code/skills/reflect/SKILL.md" "$here/opencode/commands/reflect.md"

if [ "$target" = all ] || [ "$target" = claude ]; then
  dest="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  copy_tree "$here/claude-code" "$dest"
  echo "Claude Code: installed in $dest (pick 'Socratic' in /config, or type /socratic)"
fi

if [ "$target" = all ] || [ "$target" = opencode ]; then
  dest="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
  copy_tree "$here/opencode" "$dest"
  echo "OpenCode: installed in $dest (press Tab to switch to 'socratic')"
  if [ -z "${OPENCODE_ENABLE_EXA:-}" ]; then
    echo "  Note: OpenCode's websearch needs OPENCODE_ENABLE_EXA=1 unless you use OpenCode Zen models."
    echo "  To set it permanently, add 'export OPENCODE_ENABLE_EXA=1' to your shell profile."
  fi
fi

mkdir -p "$HOME/socratic-journal"
