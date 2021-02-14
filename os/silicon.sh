#!/usr/bin/env bash
# vim:ft=sh ts=4 sw=4 et

set -euo pipefail
println() { local IFS=" "; printf '%s\n' "$*"; }
require() { hash "$@" || exit 127; }
die()     { local ret=$?; printf "%s\n" "$@" >&2; exit "$ret"; }

readonly _D="$(dirname "$(readlink -f "$0")")"
cd $_D

require brew
require xcode-select

export HOMEBREW_NO_INSTALL_CLEANUP

install_brew() {
    cd /tmp
    mkdir homebrew
    curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
    sudo mv homebrew /opt/homebrew
}

## tested bottles
bottles=(
    autoconf automake   cmake lua         sqlite
    bash     readline   git   gnu-sed     gnu-tar
    node     python@3.9 ruby  openssl@1.1 xz zsh
)
#brew install ${bottles[*]}

universal=(
    hammerspoon
    fzf
)
brew install ${universal[*]}

brew install font-meslo-lg-nerd-font

libs=(
    libev   libevent libffi       libidn   libmpc
    libomp  libpng   libsodium    libtasn1 libtiff
    libtool libyaml  libunistring
)
brew install ${libs[*]}

fromsource=(
   luajit
   neovim
   silicon
)
brew install --build-from-source ${fromsource[*]}

gnu=(
    binutils coreutils diffutils findutils
    gawk     gnu-tar   gnu-which gnutls
    grep     gzip      less      make watch wdiff wget
)

core=(
    git  neovim openssh ripgrep rsync
    tmux tree   unzip   vim     zsh
)

# rust programs
extras=(
    bat         dust      fd  glow  hammerspoon hexyl
    htop        hyperfine lsd procs scrubcsv
    shellharden tokei     xsv
)


cargo install silicon

casks=(
    rectangle
    karabiner-elements
    docker
    alacritty
    miniconda
)

#brew install ${gnu[*]}
#brew install ${core[*]}
#brew cask install ${casks[*]}
#HOMEBREW_NO_AUTO_UPDATE=1 brew install ${extras[*]}