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

#
# BEGIN helper functions
#

colon_field(){
  echo $2 | cut -d: -f${1}
}

get_gpg_key(){
  GPG_KEY=$(colon_field 3 $(gpg --gpgconf-list | grep ^default-key))
  [[ -z $GPG_KEY ]] && GPG_KEY=$(colon_field 5 $(gpg --list-secret-keys --with-colons | grep ^sec | head -n 1))
}

get_new_passphrase() {
    local passphrase passphrase_again
    while true; do
        read -r -p "Enter passphrase for the new key: " -s passphrase || return
        echo
        read -r -p "Retype the passphrase of the key: " -s passphrase_again || return
        echo
        if [[ "$passphrase" == "$passphrase_again" ]]; then
            PASSPHRASE="$passphrase"
            break
        else
            echo "Error: the entered passphrases do not match."
        fi
    done
}

get_passphrase() {
    [[ -v PASSPHRASE ]] && return
    read -r -p "Passphrase: " -s PASSPHRASE || return
    [[ -t 0 ]] && echo
}

yesno() {
    local response
    read -r -p "$1 [y/N] " response
    [[ $response == [yY] ]] || return 1
}

fail() {
    echo "$@" >&2
    exit 1
}

debug() {
    [[ -z $DEBUG ]] && return
    echo "$@"
}

#
# END helper functions
#

#
# BEGIN platform definable
#

gpg() { "$(which gpg2)" $GPG_OPTS "$@" ; }

getopt() { "$(which getopt)" "$@" ; }

shred() { "$(which shred)" -f -z -u "$@" ; }

haveged_start() {
    [[ -z "$(ps ax | grep -v grep | grep haveged)" ]] || return
    echo "
Starting haveged which will greatly improve the speed of creating
a new key, by improving the entropy generation of the system."
    sudo haveged -w 1024
    echo
    HAVEGED_STARTED="true"
}

haveged_stop() {
    [[ -z $HAVEGED_STARTED ]] && return
    sudo killall haveged
}

make_workdir() {
    local warn=1
    [[ $1 == "nowarn" ]] && warn=0
    local template="$PROGRAM.XXXXXXXXXXXXX"
    if [[ -d /dev/shm && -w /dev/shm && -x /dev/shm ]]; then
        WORKDIR="$(mktemp -d "/dev/shm/$template")"
        remove_tmpfile() {
            rm -rf "$WORKDIR"
        }
        trap remove_tmpfile INT TERM EXIT
    else
        if [[ $warn -eq 1 ]]; then
            yesno "$(cat <<- _EOF
Your system does not have /dev/shm, which means that it may
be difficult to entirely erase the temporary non-encrypted
password file after editing.

Are you sure you would like to continue?
_EOF
                    )" || return
        fi
        WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/$template")"
        shred_tmpfile() {
            find "$WORKDIR" -type f -exec shred {} +
            rm -rf "$WORKDIR"
        }
        trap shred_tmpfile INT TERM EXIT
    fi
}

#
# END platform definable
#


#
# BEGIN subcommand functions
#

cmd_version() {
    echo "egpg:  EasyGnuPG  $VERSION    (hosted at: https://github.com/dashohoxha/egpg) "
}

cmd_help() {
    cat <<-_EOF

Usage: $0 <command> [<options>]

EasyGnuPG is a wrapper around GnuPG to simplify its operations.
Commands and their options are listed below.

    key-gen [<email> <name>] [-n,--no-passphrase]
        Create a new GPG key. If <email> and <name> are not given as
        arguments, they will be asked interactively.

    key-id,fingerprint,fp
        Show the id (fingerprint) of the key.

    key-rev-cert ["description"]
        Generate a revocation certificate for the key.

    seal <file> [<recipient>+]
        Sign and encrypt a file to at least one recipient.
        The resulting file will have the extension '.sealed'
        The original file will be erased.

    open <file.sealed>
        Decrypt and verify the signature of the given file.
        The file has to end with '.sealed' and the output will have
        that extension stripped.

    sign <file>
        Sign a file. The signature will be saved to <file.signature>.

    verify <file>
        Verify the signature of the given file.  The signature file
        <file.signature> must be present as well.

    revoke [<revocation-certificate>]
        Cancel the key by publishing the given revocation certificate.

    help
        Show this help text.

    version
        Show version information.

More information may be found in the egpg(1) man page.

_EOF
}

cmd_init() {
    mkdir -p $GNUPGHOME
}

cmd_key_gen() {
    local opts pass=1
    opts="$(getopt -o n -l no-passphrase -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -n|--no-passphrase) pass=0; shift ;;
            --) shift; break ;;
        esac
    done
    [[ $err -ne 0 ]] && echo "Usage: $COMMAND <email> <name> [-n,--no-passphrase]" && return

    local email=$1 real_name=$2

    echo -e "\nCreating a new key.\n"

    # get email
    [[ -n "$email" ]] || read -e -p "Email to be associated with the key: " email
    [[ -z "$(echo $email | grep '@.*\.')" ]] \
        && fail "This email address ($email) does not appear to be valid (needs an @ and then a .)"
    [[ -n "$(gpg -K "$email" 2>/dev/null | grep '^sec')" ]] \
        && fail "There is already a key for '$email'"

    [[ -n "$real_name" ]] || read -e -p "Real Name to be associated with the key: " real_name
    real_name=${real_name:-anonymous}

    haveged_start

    local PARAMETERS="
        Key-Type: RSA
        Key-Length: 4096
        Key-Usage: encrypt,sign
        Name-Real: $real_name
        Name-Email: $email
        Subkey-Type: RSA
        Subkey-Length: 4096
        Subkey-Usage: auth
        Expire-Date: 1y
        Preferences: SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
        "
    if [[ $pass -eq 1 ]]; then
        get_new_passphrase
        [[ -n "$PASSPHRASE" ]] && PARAMETERS+="Passphrase: $PASSPHRASE"
    else
        PASSPHRASE=''
    fi
    gpg --quiet --batch --gen-key <<< "$PARAMETERS"

    [[ $? -ne 0 ]] && return 1

    # set up some sub keys, in order not to use the base key day-to-day
    local COMMANDS=$(echo "addkey|4|4096|1y|addkey|6|4096|1y|save" | tr '|' "\n")
    script -c "echo -e \"$PASSPHRASE\n$COMMANDS\" | gpg --batch --passphrase-fd=0 --command-fd=0 --edit-key $email" /dev/null >/dev/null
    haveged_stop

    echo -e "\nExcellent! You created a fresh GPG key. Here's what it looks like:"
    gpg -K "$email"

    # generate a revokation certificate
    cmd_key_rev_cert "This revocation certificate was generated when the key was created."

    # send the key to keyserver
    [[ -n $KEYSERVER ]] && gpg --keyserver $KEYSERVER --send-keys $GPG_KEY
}

cmd_key_rev_cert() {
    echo "Creating a revocation certificate."
    local description=${1:-"Key is being revoked"}

    get_gpg_key
    revoke_cert="$GNUPGHOME/$GPG_KEY.revoke"
    rm -f "$revoke_cert"

    get_passphrase
    local commands="y|1|$description||y"
    [[ -n "$PASSPHRASE" ]] && commands+="|$PASSPHRASE"
    commands=$(echo "$commands" | tr '|' "\n")
    script -c "gpg --yes --command-fd=0 --output \"$revoke_cert\" --gen-revoke $GPG_KEY <<< \"$commands\" " /dev/null > /dev/null
    [[ -f "$revoke_cert" ]] &&  echo -e "Revocation certificate saved at: \n    \"$revoke_cert\""
}

cmd_fingerprint() {
    get_gpg_key
    [[ -z $GPG_KEY ]] && echo "No key found." && return 1
    echo "The fingerprint of your key is:"
    colon_field 10 $(gpg --with-colons --fingerprint $GPG_KEY | grep '^fpr') | sed 's/..../\0 /g'
}

cmd_revoke() {
    local revoke_cert="$1"
    get_gpg_key
    [[ -n "$revoke_cert" ]] || revoke_cert="$GNUPGHOME/$GPG_KEY.revoke"
    [[ -f "$revoke_cert" ]] || fail "Revocation certificate not found: $revoke_cert"

    yesno "
Revocation will make your current key useless. You'll need
to generate a new one. Are you sure about this?" || return 1

    gpg --import "$revoke_cert"
    [[ -n $KEYSERVER ]] && gpg --keyserver $KEYSERVER --send-keys $GPG_KEY
}

cmd_seal() {
    local file="$1" ; shift
    [[ -z "$file" ]] && fail "Usage: $(basename "$0") seal <file> [<recipient>+]"
    [[ -f "$file" ]] || fail "Cannot find file '$file'"

    if [[ -f "$file.sealed" ]]; then
        yesno "File '$file.sealed' exists. Overwrite?" || return
        rm -f "$file.sealed"
    fi

    # get recipients
    get_gpg_key
    local recipients="--recipient $GPG_KEY"
    while [[ -n "$1" ]]; do
        recipients="$recipients --recipient $1"
        shift
    done

    # sign and encrypt
    local keyserver=${KEYSERVER:-hkp://keys.gnupg.net}
    gpg --auto-key-locate=local,cert,keyserver,pka \
        --keyserver $keyserver $recipients \
        --sign --encrypt --armor \
        --output "$file.sealed" "$file"

    [[ -f "$file.sealed" ]] && shred "$file"
}

cmd_open() {
    local file="$1" ; shift
    [[ -z "$file" ]] && fail "Usage: $(basename "$0") open <file.sealed>"
    [[ -f "$file" ]] || fail "Cannot find file '$file'"

    local output=${file%.sealed}
    [[ "$output" != "$file" ]] || fail "The given file does not end in '.sealed'."

    # decrypt and verify
    local keyserver=${KEYSERVER:-hkp://keys.gnupg.net}
    gpg --keyserver $keyserver \
        --keyserver-options auto-key-retrieve,verbose,honor-keyserver-url \
        --decrypt --output "$output" "$file"
}

cmd_sign() {
    local file="$1" ; shift
    [[ -z "$file" ]] && fail "Usage: $(basename "$0") sign <file>"
    [[ -f "$file" ]] || fail "Cannot find file '$file'"

    # sign
    gpg --detach-sign --armor --output "$file.signature" "$file"
}

cmd_verify() {
    local file="$1" ; shift
    [[ -z "$file" ]] && fail "Usage: $(basename "$0") verify <file>"
    [[ -f "$file" ]] || fail "Cannot find file '$file'"
    [[ -f "$file.signature" ]] || fail "Cannot find file '$file.signature'"

    # verify
    gpg --verify "$file.signature" "$file"
}

#
# END subcommand functions
#


run_cmd() {
    PROGRAM="${0##*/}"
    COMMAND="$PROGRAM $1"

    local cmd="$1" ; shift
    case "$cmd" in
        ''|v|-v|version|--version)  cmd_version "$@" ;;
        help|-h|--help)             cmd_help "$@" ;;
        key-gen)                    cmd_key_gen "$@" ;;
        key-id|fp|fingerprint)      cmd_fingerprint "$@" ;;
        revoke)                     cmd_revoke "$@" ;;
        seal)                       cmd_seal "$@" ;;
        open)                       cmd_open "$@" ;;
        sign)                       cmd_sign "$@" ;;
        verify)                     cmd_verify "$@" ;;
        key-rev-cert)               cmd_key_rev_cert "$@" ;;
        *)                          try_ext_cmd $cmd "$@" ;;
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
    # read the config file
    local config_file="$EGPG_DIR/config.sh"
    [[ -f "$config_file" ]] || cat <<-_EOF > "$config_file"
# GnuPG options
GPG_OPTS=

# Push local changes to the keyserver.
# Leave it empty (or comment out) to disable sending.
#KEYSERVER=hkp://keys.gnupg.net

# Enable debug output
DEBUG=
_EOF
    source "$config_file"

    # set defaults, if some configurations are missing
    GPG_OPTS=${GPG_OPTS:-}
    #KEYSERVER=${KEYSERVER:-hkp://keys.gnupg.net}
    DEBUG=${DEBUG:-}
}

main() {
    EGPG_DIR="${EGPG_DIR:-$HOME/.egpg}"
    #GNUPGHOME="${GNUPGHOME:-$(gpgconf --list-dirs | grep ^homedir | sed 's/^[^:]*://')}"
    export GNUPGHOME="$EGPG_DIR/.gnupg"
    [[ ! -d "$EGPG_DIR" ]] && cmd_init
    config

    # customize platform dependent functions
    LIBDIR="$(dirname "$0")"
    PLATFORM="$(uname | cut -d _ -f 1 | tr '[:upper:]' '[:lower:]')"
    platform_file="$LIBDIR/platform/$PLATFORM.sh"
    [[ -f "$platform_file" ]] && source "$platform_file"

    # The file 'customize.sh' can be used to redefine
    # and customize some functions, without having to
    # touch the code of the main script.
    customize_file="$EGPG_DIR/customize.sh"
    [[ -f "$customize_file" ]] && source "$customize_file"

    # run the command
    run_cmd "$@"
}

main "$@"
