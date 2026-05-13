#!/usr/bin/env zsh
# Vendored zsh plugins. Update pins manually after reviewing upstream changes.
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

# Format: <name>|<repo>|<commit-sha>
plugins=(
    "powerlevel10k|https://github.com/romkatv/powerlevel10k.git|604f19a"
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions.git|85919cd"
    "fast-syntax-highlighting|https://github.com/zdharma-continuum/fast-syntax-highlighting.git|3d574cc"
)

# Post-install hooks, run from inside the plugin's checkout directory after
# clone or SHA change. Plugins not listed here have no post-install step.
typeset -A post_install=(
    powerlevel10k              "make pkg"
    zsh-autosuggestions        "zcompile-many zsh-autosuggestions.zsh src/**/*.zsh"
    fast-syntax-highlighting   "zcompile-many fast-syntax-highlighting.plugin.zsh **/*.zsh"
)

# Add this option to your install script
if [[ ${1:-} == "--check" ]]; then
    for entry in $plugins; do
        name=${entry%%|*}
        rest=${entry#*|}
        sha=${rest##*|}
        dest=$PLUGIN_DIR/$name
        [[ -d $dest/.git ]] || continue
        echo "── $name (pinned: ${sha:0:8})"
        git -C $dest fetch --quiet origin
        git -C $dest log --oneline --no-decorate $sha..origin/HEAD 2>/dev/null | head -20
        echo
    done
    exit 0
fi

for entry in $plugins; do
    name=${entry%%|*}
    rest=${entry#*|}
    repo=${rest%|*}
    sha=${rest##*|}
    dest=$PLUGIN_DIR/$name
    hook=${post_install[$name]:-}

    fresh=0
    if [[ ! -d $dest/.git ]]; then
        echo "Cloning $name..."
        git clone --quiet $repo $dest
        fresh=1
    fi

    current=$(git -C $dest rev-parse HEAD)
    if [[ $fresh -eq 1 || $current != $sha* ]]; then
        git -C $dest fetch --quiet origin
        git -C $dest checkout --quiet $sha
        if [[ -n $hook ]]; then
            echo "  running post-install for $name..."
            ( cd $dest && setopt EXTENDED_GLOB GLOB_STAR_SHORT && eval $hook )
        fi
    fi

    echo "✓ $name @ ${sha:0:8}"
done

