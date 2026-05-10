#!/usr/bin/env bash
# xdg-audit.sh — show which tools have/haven't migrated

check() {
    local label=$1 old=$2 new=$3
    local old_exists="—" new_exists="—"
    [[ -e $old || -L $old ]] && old_exists="present"
    [[ -e $new || -L $new ]] && new_exists="present"
    printf "%-20s  old=%-8s  new=%s\n" "$label" "$old_exists" "$new_exists"
}

echo "=== histories ==="
check "zsh"     ~/.zsh_history          ~/.local/state/zsh/history
check "bash"    ~/.bash_history         ~/.local/state/bash/history
check "less"    ~/.lesshst              ~/.local/state/less/history
check "vim"     ~/.viminfo              ~/.local/state/vim/viminfo
check "python"  ~/.python_history       ~/.local/state/python/history
check "node"    ~/.node_repl_history    ~/.local/state/node/repl_history
check "psql"    ~/.psql_history         ~/.local/state/psql/history
check "R"       ~/.Rhistory             ~/.local/state/r/history
check "duckdb"  ~/.duckdb_history       ~/.local/state/duckdb/history

echo
echo "=== relocations ==="
check "cargo"   ~/.cargo                ~/.local/share/cargo
check "rustup"  ~/.rustup               ~/.local/share/rustup
check "julia"   ~/.julia                ~/.local/share/julia
check "npm"     ~/.npm                  ~/.cache/npm
check "docker"  ~/.docker               ~/.config/docker
check "claude"  ~/.claude               ~/.config/claude

echo
echo "=== other ==="
[[ -L ~/.duckdb_history ]] && echo "duckdb symlink: $(readlink ~/.duckdb_history)" || echo "duckdb: NOT symlinked"
[[ -d ~/.zsh_sessions ]] && echo "zsh_sessions: still present" || echo "zsh_sessions: gone ✓"
