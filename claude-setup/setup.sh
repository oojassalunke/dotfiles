#!/usr/bin/env bash
# claude-setup: install Claude Code (if missing) and link personal Claude
# config into ~/.claude. Part of the base personal setup (see os/setup-mac.sh).
#
# Tracks ONLY portable, non-secret config:
#   - settings.json   seeded no-clobber; Claude Code owns the live file
#   - commands/*.md   symlinked; your custom slash commands
#
# NEVER touches secrets / runtime data:
#   ~/.claude.json (auth), history.jsonl, projects/, sessions/, caches,
#   settings.local.json, or the plugins/ tree.
#
# GSD note: settings.json wires hooks + statusline to the get-shit-done
# plugin. This script does NOT install plugins -- run /plugin in Claude Code
# yourself if you use GSD, otherwise those hook paths won't exist.

set -Eeuo pipefail

println() { printf '%s\n' "$*"; }
die()     { printf '%s\n' "$*" >&2; exit 1; }

readonly _D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # claude-setup/
readonly SRC="$_D/claude"                                     # tracked config
readonly DST="$HOME/.claude"

println "==> Claude Code setup"

##
## 1. Install Claude Code if missing.
##
if command -v claude >/dev/null 2>&1; then
    println "  Claude Code: present ($(claude --version 2>/dev/null | head -1))"
elif command -v npm >/dev/null 2>&1; then
    println "  Installing Claude Code via npm..."
    npm install -g @anthropic-ai/claude-code
else
    println "  Installing Claude Code via official installer..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

mkdir -p "$DST" "$DST/commands"

##
## 2. Seed settings.json (no-clobber). Claude Code mutates this file
##    (/config, plugin toggles), so we do NOT symlink it into the repo --
##    same rule the rest of these dotfiles use for tool-owned config.
##    Edit claude-setup/claude/settings.json to change the baseline for
##    future fresh machines.
##
if [[ -e "$DST/settings.json" ]]; then
    println "  settings.json: exists, leaving Claude's live copy as-is"
else
    cp "$SRC/settings.json" "$DST/settings.json"
    println "  settings.json: seeded from repo"
fi

##
## 3. Symlink custom commands (static prompt files; safe to symlink so
##    edits propagate back to the repo). Existing real files are backed up;
##    the plugin-managed commands/gsd/ tree is left untouched.
##
for f in "$SRC"/commands/*.md; do
    [[ -e "$f" ]] || continue
    dst="$DST/commands/$(basename "$f")"
    if [[ -L "$dst" ]]; then
        rm "$dst"
    elif [[ -e "$dst" ]]; then
        mv "$dst" "$dst.bak"
        println "  backed up $(basename "$dst") -> $(basename "$dst").bak"
    fi
    ln -s "$f" "$dst"
    println "  linked command: $(basename "$f")"
done

println ""
println "Claude Code config ready (secrets + runtime data untouched)."
println "Using GSD? Install it in Claude Code with /plugin."
