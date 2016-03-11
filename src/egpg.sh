#!/usr/bin/env bash
#
# EasyGnuPG is a wrapper around GnuPG to simplify its operations.
# Copyright (C) 2016  Dashamir Hoxha
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/

umask 077
set -o pipefail

VERSION="v0.6"

LIBDIR="$(dirname "$0")"

source "$LIBDIR/include/auxiliary.sh"
source "$LIBDIR/include/platform.sh"
source "$LIBDIR/include/cmd.sh"
source "$LIBDIR/include/cmd_key.sh"

run_cmd() {
    PROGRAM="${0##*/}"
    COMMAND="$PROGRAM $1"

    local cmd="$1" ; shift
    case "$cmd" in
        ''|info)  cmd_info "$@" ;;
        key)      cmd_key "$@" ;;
        seal)     cmd_seal "$@" ;;
        open)     cmd_open "$@" ;;
        sign)     cmd_sign "$@" ;;
        verify)   cmd_verify "$@" ;;
        set)      cmd_set "$@" ;;
        --|gpg)   cmd_gpg "$@" ;;
        *)        try_ext_cmd $cmd "$@" ;;
    esac
}

try_ext_cmd() {
    local cmd=$1; shift

    # try '~/.egpg/cmd_xyz.sh'
    if [[ -f "$EGPG_DIR/cmd_$cmd.sh" ]]; then
        debug loading: "$EGPG_DIR/cmd_$cmd.sh"
        source "$EGPG_DIR/cmd_$cmd.sh"
        debug running: cmd_$cmd "$@"
        cmd_$cmd "$@"
        return
    fi

    # try 'src/ext/platform/cmd_xyz.sh'
    if [[ -f "$LIBDIR/ext/$PLATFORM/cmd_$cmd.sh" ]]; then
        debug loading: "$LIBDIR/ext/$PLATFORM/cmd_$cmd.sh"
        source "$LIBDIR/ext/$PLATFORM/cmd_$cmd.sh"
        debug running: cmd_$cmd "$@"
        cmd_$cmd "$@"
        return
    fi

    # try 'src/ext/cmd_xyz.sh'
    if [[ -f "$LIBDIR/ext/cmd_$cmd.sh" ]]; then
        debug loading: "$LIBDIR/ext/cmd_$cmd.sh"
        source "$LIBDIR/ext/cmd_$cmd.sh"
        debug running: cmd_$cmd "$@"
        cmd_$cmd "$@"
        return
    fi
    echo -e "Unknown command '$cmd'.\nTry:  $0 help"
}

config() {
    ENV_GNUPGHOME="$GNUPGHOME"
    export GNUPGHOME="$EGPG_DIR/.gnupg"
    export GPG_AGENT_INFO=$(cat "$EGPG_DIR/.gpg-agent-info" | cut -c 16-)
    export GPG_TTY=$(tty)

    # read the config file
    local config_file="$EGPG_DIR/config.sh"
    [[ -f "$config_file" ]] || cat <<-_EOF > "$config_file"
# GnuPG options
GPG_OPTS=

# Push local changes to the keyserver network.
# Leave it empty (or comment out) to disable.
SHARE=
#KEYSERVER=hkp://keys.gnupg.net

# Enable debug output
DEBUG=
_EOF
    source "$config_file"

    # set defaults, if some configurations are missing
    GPG_OPTS=${GPG_OPTS:-}
    KEYSERVER=${KEYSERVER:-hkp://keys.gnupg.net}
    DEBUG=${DEBUG:-}
}

main() {
    # handle some basic commands
    case "$1" in
        v|-v|version|--version)  cmd_version "$@" ; exit 0 ;;
        help|-h|--help)          cmd_help "$@" ; exit 0 ;;
        init)                    cmd_init "$@" ; exit 0 ;;
    esac

    # set config variables
    export EGPG_DIR="${EGPG_DIR:-$HOME/.egpg}"
    [[ -d "$EGPG_DIR" ]] || fail "No directory '$EGPG_DIR'\nTry first: $0 init"
    config

    # customize platform dependent functions
    PLATFORM="$(uname | cut -d _ -f 1 | tr '[:upper:]' '[:lower:]')"
    local platform_file="$LIBDIR/platform/$PLATFORM.sh"
    [[ -f "$platform_file" ]] && source "$platform_file"

    # The file 'customize.sh' can be used to redefine
    # and customize some functions, without having to
    # touch the code of the main script.
    local customize_file="$EGPG_DIR/customize.sh"
    [[ -f "$customize_file" ]] && source "$customize_file"

    # run the command
    run_cmd "$@"
}

main "$@"
