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

# Show the effective git identity (from ~/.gitconfig.local via ~/.config/git)
# and GitHub CLI auth, so a fresh setup can confirm commits are attributed
# correctly. Run from $HOME so we report the user-level identity, not any
# repo-local override.
verify_git() {
    println ""
    println "==> Git / GitHub configuration"

    local name email origin
    name="$(git -C "$HOME" config user.name  2>/dev/null || true)"
    email="$(git -C "$HOME" config user.email 2>/dev/null || true)"

    if [[ -z "$name" || -z "$email" ]]; then
        println "  ! git identity incomplete  (name: ${name:-<unset>}, email: ${email:-<unset>})"
        println "    Set it in ~/.gitconfig.local:"
        println "      git config --file ~/.gitconfig.local user.name  \"Your Name\""
        println "      git config --file ~/.gitconfig.local user.email \"you@example.com\""
    elif [[ "$email" == "someone@example.com" || "$name" == "Git Config dot Local" ]]; then
        println "  ! git identity is still the template placeholder ($name <$email>)"
        println "    Edit ~/.gitconfig.local with your real name and email."
    else
        origin="$(git -C "$HOME" config --show-origin user.email 2>/dev/null \
                  | awk '{print $1}' | sed 's|^file:||')"
        println "  git identity : $name <$email>"
        println "  from         : ${origin:-?}"
    fi

    if command -v gh >/dev/null 2>&1; then
        if gh auth status >/dev/null 2>&1; then
            local acct
            acct="$(gh auth status 2>&1 | sed -n 's/.*Logged in to [^ ]* account \([^ ]*\).*/\1/p' | head -1)"
            println "  GitHub CLI   : logged in as ${acct:-?}"
        else
            println "  GitHub CLI   : installed but NOT logged in  (run: gh auth login)"
        fi
    else
        println "  GitHub CLI   : gh not installed (optional)"
    fi
}

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
## 2b. Confirm git / GitHub identity is set up correctly.
##
verify_git

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
