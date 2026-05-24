#!/usr/bin/env zsh
# Vendored zsh plugins, cloned from personal forks (shallow + blobless).
set -eu
setopt pipefail

PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
mkdir -p $PLUGIN_DIR

# Compile one or more files to wordcode for faster sourcing.
zcompile-many() {
    local f
    for f; do
        [[ -f $f ]] && zcompile -R -- $f.zwc $f
    done
}

# Format: <name>|<repo>
plugins=(
    "powerlevel10k|https://github.com/scottstanfield/powerlevel10k.git"
    "fast-syntax-highlighting|https://github.com/scottstanfield/fast-syntax-highlighting.git"
)

# Post-install hooks, run from inside the plugin's checkout directory after
# clone. Plugins not listed here have no post-install step.
typeset -A post_install=(
    powerlevel10k              "make pkg"
    fast-syntax-highlighting   "zcompile-many fast-syntax-highlighting.plugin.zsh **/*.zsh"
)

for entry in $plugins; do
    name=${entry%%|*}
    repo=${entry#*|}
    dest=$PLUGIN_DIR/$name
    hook=${post_install[$name]:-}

    if [[ ! -d $dest/.git ]]; then
        echo "Cloning $name..."
        if ! err=$(git clone --quiet --depth 1 --filter=blob:none $repo $dest 2>&1); then
            echo "  clone failed for $name:" >&2
            echo "$err" >&2
            exit 1
        fi
        if [[ -n $hook ]]; then
            echo "  running post-install for $name..."
            ( cd $dest && setopt EXTENDED_GLOB GLOB_STAR_SHORT && eval $hook )
        fi
    fi

    echo "✓ $name"
done

