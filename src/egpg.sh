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

VERSION="2.2-1.0"

LIBDIR="$(dirname "$0")"

# make sure that these global variables
# do not inherit values from the environment
unset WORKDIR GPG_KEY FPR

source "$LIBDIR/auxiliary.sh"
source "$LIBDIR/platform.sh"

cmd_version() {
    echo
    echo "EasyGnuPG $VERSION    ( https://github.com/easygnupg/egpg )"
    echo
}

cmd() {
    PROGRAM="${0##*/}"
    local cmd="$1" ; shift
    case "$cmd" in
        migrate)          call cmd_migrate "$@" ;;
        ''|info)          call cmd_info "$@" ;;
        seal)             call cmd_seal "$@" ;;
        open)             call cmd_open "$@" ;;
        sign)             call cmd_sign "$@" ;;
        verify)           call cmd_verify "$@" ;;
        set)              call cmd_set "$@" ;;
        default)          call cmd_default "$@" ;;

        --|gpg)           cmd_gpg "$@" ;;
        key)              cmd_key "$@" ;;
        c|contact)        cmd_contact "$@" ;;

        ext)              cmd_ext_help "$@" ;;
        *)                call_ext cmd_$cmd "$@" ;;
    esac
}

cmd_gpg() { gpg "$@"; }

cmd_key() {
    local cmd="$1" ; shift
    case "$cmd" in
        help)             call cmd_key_help "$@" ;;
        gen|generate)     call cmd_key_gen "$@" ;;
        ''|ls|list|show)  call cmd_key_list "$@" ;;
        rm|del|delete)    call cmd_key_delete "$@" ;;
        backup)           call cmd_key_backup "$@" ;;
        restore)          call cmd_key_restore "$@" ;;
        fetch)            call cmd_key_fetch "$@" ;;
        renew|expiration) call cmd_key_renew "$@" ;;
        share)            call cmd_key_share "$@" ;;
        revcert)          call cmd_key_revcert "$@" ;;
        rev|revoke)       call cmd_key_rev "$@" ;;
        pass)             call cmd_key_pass "$@" ;;
        split)            call cmd_key_split "$@" ;;
        join)             call cmd_key_join "$@" ;;
        recover)          call cmd_key_recover "$@" ;;
        help)             call cmd_key_help "$@" ;;
        *)                call_ext cmd_key_$cmd "$@" ;;
    esac
}

cmd_contact() {
    local cmd="$1" ; shift
    case "$cmd" in
        ''|help)          call cmd_contact_help "$@" ;;
        exp|export)       call cmd_contact_export "$@" ;;
        imp|import|add)   call cmd_contact_import "$@" ;;
        fetch)            call cmd_contact_fetch "$@" ;;
        fetch-uri)        call cmd_contact_fetchuri "$@" ;;
        search)           call cmd_contact_search "$@" ;;
        receive|pull)     call cmd_contact_receive "$@" ;;
        ls|list|show|find)call cmd_contact_list "$@" ;;
        rm|del|delete)    call cmd_contact_delete "$@" ;;
        certify)          call cmd_contact_certify "$@" ;;
        uncertify)        call cmd_contact_uncertify "$@" ;;
        trust)            call cmd_contact_trust "$@" ;;
        *)                call_ext cmd_contact_$cmd "$@" ;;
    esac
}

call() {
    local cmd=$1; shift
    local file="$LIBDIR/$(echo $cmd | tr _ /).sh"
    [[ -f "$file" ]] || fail "Cannot find command file: $file"
    source "$file"
    if [[ $1 == "help" ]]
    then ${cmd}_help
    else $cmd "$@"
    fi
}

call_fn() {
    local fn=$1; shift
    local file="$LIBDIR/fn/$fn.sh"
    [[ -f "$file" ]] || fail "Cannot find function file: $file"
    source "$file"
    $fn "$@"
}

call_ext() {
    local cmd=$1; shift

    load() {
        debug loading: "$1"
        source "$1"
    }

    if   [[ -f "$EGPG_DIR/$cmd.sh" ]];             then load "$EGPG_DIR/$cmd.sh"
    elif [[ -f "$LIBDIR/ext/$PLATFORM/$cmd.sh" ]]; then load "$LIBDIR/ext/$PLATFORM/$cmd.sh"
    elif [[ -f "$LIBDIR/ext/$cmd.sh" ]];           then load "$LIBDIR/ext/$cmd.sh"
    else
        echo -e "Unknown command '$cmd'.\nTry:  $(basename $0) help"
        return 1
    fi

    debug running: $cmd "$@"
    if [[ $1 == 'help' ]]
    then ${cmd}_help
    else $cmd "$@"
    fi
}

cmd_ext_help() {
    cat <<-_EOF
An external 'command' can be loaded from:
    1. $EGPG_DIR/cmd_command.sh
    2. $LIBDIR/ext/$PLATFORM/cmd_command.sh
    3. $LIBDIR/ext/cmd_command.sh
The first file that is found is loaded and used.
For key commands the name of the file must be: cmd_key_command.sh
and for contact commands it must be: cmd_contact_command.sh

_EOF

    for cmd_file in \
        "$LIBDIR/ext"/cmd_*.sh \
        "$LIBDIR/ext/$PLATFORM"/cmd_*.sh \
        "$EGPG_DIR"/cmd_*.sh
    do
        [[ -f "$cmd_file" ]] || continue
        source "$cmd_file"
        cmd=$(basename "${cmd_file%%.sh}")
        [[ $cmd == *"test" ]] && continue
        ${cmd}_help
    done
}

config() {
    # read the config file
    local config_file="$EGPG_DIR/config.sh"
    ENV_GNUPGHOME=${GNUPGHOME:-~/.gnupg}
    unset SHARE KEYSERVER GNUPGHOME DONGLE DEBUG
    [[ -f "$config_file" ]] && source "$config_file"

    # set defaults, if some configurations are missing
    SHARE=${SHARE:-no}
    KEYSERVER=${KEYSERVER:-hkp://keys.gnupg.net}
    GNUPGHOME=${GNUPGHOME:-$EGPG_DIR/.gnupg}
    [[ "$GNUPGHOME" == "default" ]] && GNUPGHOME="$ENV_GNUPGHOME"
    DEBUG=${DEBUG:-no}

    export GNUPGHOME
    export GPG_TTY=$(tty)

    # create the config file, if it does not exist
    local gpghome="$GNUPGHOME"
    [[ "GNUPGHOME" == "ENV_GNUPGHOME" ]] && gpghome='default'
    [[ -f "$config_file" ]] || cat <<-_EOF > "$config_file"
# If yes, push local changes to the keyserver network.
SHARE=$SHARE
KEYSERVER="$KEYSERVER"

# GPG homedir to be used. If "default", then use the default one,
# (whatever is in the environment $GNUPGHOME, usually ~/.gnupg).
GNUPGHOME="$gpghome"

# Path of the dongle.
DONGLE="$DONGLE"

# If true, print debug output.
DEBUG=$DEBUG
_EOF
}

main() {
    local gnupg_version=$(gpg_version)
    [[ ${gnupg_version%.*} == "2.2" ]] || fail "These scripts are supposed to work with GnuPG 2.2"

    # handle some basic commands
    case "$1" in
        v|-v|version|--version)  shift; cmd_version "$@" ; exit 0 ;;
        help|-h|--help)          shift; call cmd_help "$@" ; exit 0 ;;
        init)                    shift; call cmd_init "$@" ; exit 0 ;;
    esac

    # set config variables
    export EGPG_DIR="${EGPG_DIR:-$HOME/.egpg}"
    [[ -d "$EGPG_DIR" ]] || fail "No directory '$EGPG_DIR'\nTry first: $(basename $0) init"
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
