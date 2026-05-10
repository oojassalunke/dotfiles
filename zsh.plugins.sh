#!/usr/bin/env bash
# Vendored zsh plugins. Update pins manually after reviewing upstream changes.
set -euo pipefail

PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
mkdir -p "$PLUGIN_DIR"
echo $PLUGIN_DIR

# Format: <name>|<repo>|<commit-sha>
PLUGINS=(
    "powerlevel10k|https://github.com/romkatv/powerlevel10k.git|604f19a"
    "fast-syntax-highlighting|https://github.com/zdharma-continuum/fast-syntax-highlighting.git|3d574cc"
    "history-search-multi-word|https://github.com/zdharma-continuum/history-search-multi-word.git|c4dcddc"
)

for entry in "${PLUGINS[@]}"; do
    IFS='|' read -r name repo sha <<< "$entry"
    dest="${PLUGIN_DIR}/${name}"
    if [[ ! -d "$dest/.git" ]]; then
        echo "Cloning $name..."
        git clone --depth=10 --quiet "$repo" "$dest"
    fi
    (
        cd "$dest"
        git fetch --quiet origin
        git checkout --quiet "$sha"
    )
    echo "✓ $name @ ${sha:0:8}"
done
