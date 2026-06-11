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
    "powerlevel10k|https://github.com/scottstanfield/powerlevel10k.git"
    "fast-syntax-highlighting|https://github.com/scottstanfield/fast-syntax-highlighting.git"
)

# Post-install hooks, run from inside the plugin's checkout directory after
# clone or SHA change. Plugins not listed here have no post-install step.
typeset -A post_install=(
    powerlevel10k              "make pkg"
    fast-syntax-highlighting   "zcompile-many fast-syntax-highlighting.plugin.zsh **/*.zsh"
)

for entry in $plugins; do
    name=${entry%%|*}
    rest=${entry#*|}
    repo=${rest%|*}
    dest=$PLUGIN_DIR/$name
    hook=${post_install[$name]:-}

	if [[ ! -d $dest/.git ]]; then
	    echo "Cloning $name..."
	    git clone --depth=1 --quiet $repo $dest
        if [[ -n $hook ]]; then
            echo "  running post-install for $name..."
            ( cd $dest && setopt EXTENDED_GLOB GLOB_STAR_SHORT && eval $hook )
        fi
	fi
	echo "✓ $name"
done

