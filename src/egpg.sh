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

cmd_version() {
    echo "egpg:  EasyGnuPG  $VERSION    (hosted at: https://github.com/dashohoxha/egpg) "
}

cmd() {
    PROGRAM="${0##*/}"
    COMMAND="$PROGRAM $1"

    local cmd="$1" ; shift
    case "$cmd" in
        ''|info)      run_cmd info "$@" ;;
        seal)         run_cmd seal "$@" ;;
        open)         run_cmd open "$@" ;;
        sign)         run_cmd sign "$@" ;;
        verify)       run_cmd verify "$@" ;;
        set)          run_cmd set "$@" ;;

        --|gpg)       cmd_gpg "$@" ;;
        key)          cmd_key "$@" ;;
        c|contact)    cmd_contact "$@" ;;

        *)            run_ext_cmd $cmd "$@" ;;
    esac
}

cmd_gpg() { gpg "$@"; }

cmd_key() {
    COMMAND+=" $1"
    local subcmd="$1" ; shift
    case "$subcmd" in
        help)             run_cmd key_help "$@" ;;
        gen|generate)     run_cmd key_gen "$@" ;;
        ''|ls|list|show)  run_cmd key_list "$@" ;;
        fp|fingerprint)   run_cmd key_fp "$@" ;;
        rm|del|delete)    run_cmd key_delete "$@" ;;
        exp|export)       run_cmd key_export "$@" ;;
        imp|import)       run_cmd key_import "$@" ;;
        fetch)            run_cmd key_fetch "$@" ;;
        renew)            run_cmd key_renew "$@" ;;
        share)            run_cmd key_share "$@" ;;
        rev-cert)         run_cmd key_rev_cert "$@" ;;
        rev|revoke)       run_cmd key_rev "$@" ;;
        pass)             run_cmd key_pass "$@" ;;
        help)             run_cmd key_help "$@" ;;
        *)                run_ext_cmd "key_$subcmd" "$@" ;;
    esac
}

cmd_contact() {
    COMMAND+=" $1"
    local subcmd="$1" ; shift
    case "$subcmd" in
        ''|help)          run_cmd contact_help "$@" ;;
        exp|export)       run_cmd contact_export "$@" ;;
        imp|import)       run_cmd contact_import "$@" ;;
        fetch)            run_cmd contact_fetch "$@" ;;
        ls|list|show)     run_cmd contact_list "$@" ;;
        search|find)      run_cmd contact_search "$@" ;;
        rm|del|delete)    run_cmd contact_delete "$@" ;;
        sync)             run_cmd contact_sync "$@" ;;
        confirm)          run_cmd contact_confirm "$@" ;;
        vouch)            run_cmd contact_vouch "$@" ;;
        trust)            run_cmd contact_trust "$@" ;;
        *)                run_ext_cmd "contact_$subcmd" "$@" ;;
    esac
}

run_cmd() {
    local cmd=$1; shift
    local file="$LIBDIR/include/cmd/$cmd.sh"
    [[ -f "$file" ]] || fail "Cannot find command file: $file"
    source "$file"
    cmd_$cmd "$@"
}

run_ext_cmd() {
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
        help|-h|--help)          run_cmd help "$@" ; exit 0 ;;
        init)                    run_cmd init "$@" ; exit 0 ;;
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
    cmd "$@"
}

main "$@"
