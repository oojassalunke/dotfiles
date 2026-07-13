#!/usr/bin/env bash
# One-command macOS setup: chains the two-step bootstrap and, optionally,
# the opinionated system defaults.
#
#   1. os/macos-cli.sh    Xcode Command Line Tools + XDG dirs (idempotent)
#   2. ./install.sh       symlink configs, bootstrap mise, install plugins
#   3. os/macos-defaults.sh   (opt-in) `defaults write` system preferences
#
# Steps 1-2 are safe to re-run any time. Step 3 mutates system state
# (kills apps, wants a logout/restart), so it is prompted, not automatic.
# It stays a separate script on purpose — see os/macos-defaults.sh.

set -Eeuo pipefail

println() { printf '%s\n' "$*"; }
die()     { printf '%s\n' "$*" >&2; exit 1; }

readonly _D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # os/
readonly _REPO="$(cd "$_D/.." && pwd)"                        # repo root

[[ "$(uname)" == "Darwin" ]] || die "This script is for macOS. Use os/debian.sh on Linux."

##
## 1. Platform prep (Xcode CLT + XDG dirs). No Homebrew.
##
println "==> os/macos-cli.sh"
"$_D/macos-cli.sh"

##
## 2. Symlinks, mise, plugins.
##
println ""
println "==> install.sh"
"$_REPO/install.sh" "$@"

##
## 3. Opinionated system defaults (opt-in). Mutating; needs logout/restart.
##
println ""
read -rp "Apply opinionated macOS system defaults now (os/macos-defaults.sh)? [y/N] " reply
if [[ "$reply" == [yY] ]]; then
    println "==> os/macos-defaults.sh"
    "$_D/macos-defaults.sh"   # prints its own "Changes applied" summary
else
    println "Skipped system defaults. Run os/macos-defaults.sh yourself when ready."
fi

println ""
println "Done. Open a new shell (or 'exec zsh') to pick up the environment."
