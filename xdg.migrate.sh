#!/usr/bin/env bash
set -euo pipefail

: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"

# Create every parent dir we'll touch
mkdir -p \
    "$XDG_STATE_HOME/zsh" \
    "$XDG_STATE_HOME/bash" \
    "$XDG_STATE_HOME/less" \
    "$XDG_STATE_HOME/vim" \
    "$XDG_STATE_HOME/duckdb" \
    "$XDG_STATE_HOME/python" \
    "$XDG_STATE_HOME/node" \
    "$XDG_STATE_HOME/psql" \
    "$XDG_STATE_HOME/r" \
    "$XDG_DATA_HOME" \
    "$XDG_CONFIG_HOME" \
    "$XDG_CACHE_HOME"

# Helper: move only if source exists and dest doesn't
safe_mv() {
    local src=$1 dst=$2
    if [[ -e $src && ! -e $dst ]]; then
        mv "$src" "$dst"
        echo "moved $src → $dst"
    elif [[ -e $src && -e $dst ]]; then
        echo "skipping $src (destination $dst already exists)"
    fi
}

safe_mv ~/.zsh_history       "$XDG_STATE_HOME/zsh/history"
safe_mv ~/.zsh_history_old   "$XDG_STATE_HOME/zsh/history_old"
safe_mv ~/.bash_history      "$XDG_STATE_HOME/bash/history"
safe_mv ~/.lesshst           "$XDG_STATE_HOME/less/history"
safe_mv ~/.viminfo           "$XDG_STATE_HOME/vim/viminfo"
safe_mv ~/.cargo             "$XDG_DATA_HOME/cargo"
safe_mv ~/.rustup            "$XDG_DATA_HOME/rustup"
safe_mv ~/.julia             "$XDG_DATA_HOME/julia"
safe_mv ~/.docker            "$XDG_CONFIG_HOME/docker"
safe_mv ~/.npm               "$XDG_CACHE_HOME/npm"
safe_mv ~/.duckdb_history    "$XDG_STATE_HOME/duckdb/history"

# duckdb is the only one that needs a symlink because it doesn't honor any env var
[[ -e $XDG_STATE_HOME/duckdb/history && ! -L ~/.duckdb_history ]] && \
    ln -s "$XDG_STATE_HOME/duckdb/history" ~/.duckdb_history

# Optional: nuke zsh_sessions if you set SHELL_SESSIONS_DISABLE=1
if [[ "${SHELL_SESSIONS_DISABLE:-0}" == "1" ]]; then
    rm -rf ~/.zsh_sessions
fi

echo "done. open a new shell to pick up the new env vars."
