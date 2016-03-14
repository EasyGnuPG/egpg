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

source "$LIBDIR/auxiliary.sh"
source "$LIBDIR/platform.sh"

cmd_version() {
    echo "egpg:  EasyGnuPG  $VERSION    (hosted at: https://github.com/dashohoxha/egpg) "
}

cmd() {
    PROGRAM="${0##*/}"
    COMMAND="$PROGRAM $1"

    local cmd="$1" ; shift
    case "$cmd" in
        ''|info)          call cmd_info "$@" ;;
        seal)             call cmd_seal "$@" ;;
        open)             call cmd_open "$@" ;;
        sign)             call cmd_sign "$@" ;;
        verify)           call cmd_verify "$@" ;;
        set)              call cmd_set "$@" ;;

        --|gpg)           cmd_gpg "$@" ;;
        key)              cmd_key "$@" ;;
        c|contact)        cmd_contact "$@" ;;

        *)                call_ext cmd_$cmd "$@" ;;
    esac
}

cmd_gpg() { gpg "$@"; }

cmd_key() {
    COMMAND+=" $1"
    local cmd="$1" ; shift
    case "$cmd" in
        help)             call cmd_key_help "$@" ;;
        gen|generate)     call cmd_key_gen "$@" ;;
        ''|ls|list|show)  call cmd_key_list "$@" ;;
        fp|fingerprint)   call cmd_key_fp "$@" ;;
        rm|del|delete)    call cmd_key_delete "$@" ;;
        exp|export)       call cmd_key_export "$@" ;;
        imp|import)       call cmd_key_import "$@" ;;
        fetch)            call cmd_key_fetch "$@" ;;
        renew)            call cmd_key_renew "$@" ;;
        share)            call cmd_key_share "$@" ;;
        revcert)          call cmd_key_revcert "$@" ;;
        rev|revoke)       call cmd_key_rev "$@" ;;
        pass)             call cmd_key_pass "$@" ;;
        help)             call cmd_key_help "$@" ;;
        *)                call_ext cmd_key_$cmd "$@" ;;
    esac
}

cmd_contact() {
    COMMAND+=" $1"
    local cmd="$1" ; shift
    case "$cmd" in
        ''|help)          call cmd_contact_help "$@" ;;
        exp|export)       call cmd_contact_export "$@" ;;
        imp|import|add)   call cmd_contact_import "$@" ;;
        fetch)            call cmd_contact_fetch "$@" ;;
        ls|list|show|find)call cmd_contact_list "$@" ;;
        rm|del|delete)    call cmd_contact_delete "$@" ;;
        sync)             call cmd_contact_sync "$@" ;;
        confirm)          call cmd_contact_confirm "$@" ;;
        vouch)            call cmd_contact_vouch "$@" ;;
        trust)            call cmd_contact_trust "$@" ;;
        *)                call_ext cmd_contact_$cmd "$@" ;;
    esac
}

call() {
    local cmd=$1; shift
    local file="$LIBDIR/${cmd//_/\/}.sh"
    [[ -f "$file" ]] || fail "Cannot find command file: $file"
    source "$file"
    $cmd "$@"
}

call_ext() {
    local cmd=$1; shift

    # try '~/.egpg/cmd.sh'
    if [[ -f "$EGPG_DIR/$cmd.sh" ]]; then
        debug loading: "$EGPG_DIR/$cmd.sh"
        source "$EGPG_DIR/$cmd.sh"
        debug running: $cmd "$@"
        $cmd "$@"
        return
    fi

    # try 'src/ext/platform/cmd.sh'
    if [[ -f "$LIBDIR/ext/$PLATFORM/$cmd.sh" ]]; then
        debug loading: "$LIBDIR/ext/$PLATFORM/$cmd.sh"
        source "$LIBDIR/ext/$PLATFORM/$cmd.sh"
        debug running: $cmd "$@"
        $cmd "$@"
        return
    fi

    # try 'src/ext/xyz.sh'
    if [[ -f "$LIBDIR/ext/$cmd.sh" ]]; then
        debug loading: "$LIBDIR/ext/$cmd.sh"
        source "$LIBDIR/ext/$cmd.sh"
        debug running: $cmd "$@"
        $cmd "$@"
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
        help|-h|--help)          call cmd_help "$@" ; exit 0 ;;
        init)                    call cmd_init "$@" ; exit 0 ;;
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
