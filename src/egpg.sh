#!/usr/bin/env bash

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

GNUPGHOME="${GNUPGHOME:-$(gpgconf --list-dirs | grep ^homedir | sed 's/^[^:]*://')}"
EGPG_DIR="${EGPG_DIR:-$HOME/.egpg}"

### dev
export GNUPGHOME="$EGPG_DIR/.gnupg"
[[ ! -d $GNUPGHOME ]] && mkdir -p $GNUPGHOME

LIBDIR="$(dirname "$0")"
PLATFORM="$(uname | cut -d _ -f 1 | tr '[:upper:]' '[:lower:]')"

GPG="gpg" ; which gpg2 &>/dev/null && GPG="gpg2"


#
# BEGIN helper functions
#

colon_field(){
  echo $2 | cut -d: -f${1}
}

get_my_key(){
  MY_KEY=$(colon_field 3 $($GPG --gpgconf-list | grep ^default-key))
  [[ -z $MY_KEY ]] && MY_KEY=$(colon_field 5 $($GPG --list-secret-keys --with-colons | grep ^sec | head -n 1))
}

get_passphrase() {
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
            find "$WORKDIR" -type f -exec $SHRED {} +
            rm -rf "$WORKDIR"
        }
        trap shred_tmpfile INT TERM EXIT
    fi
}

haveged_start() {
    [[ -z "$(ps ax | grep -v grep | grep haveged)" ]] || return
    echo "
Starting haveged which will greatly improve the speed of creating
a new key, by improving the entropy generation of the system.
"
    sudo haveged -w 1024
    HAVEGED_STARTED="true"
}
haveged_stop() {
    [[ -z $HAVEGED_STARTED ]] && return
    sudo killall haveged
}

GETOPT="getopt"
SHRED="shred -f -z"

platform_file="$LIBDIR/platform/$PLATFORM.sh"
[[ -f "$platform_file" ]] && source "$platform_file"

#
# END platform definable
#


#
# BEGIN subcommand functions
#

cmd_version() {
    echo "
egpg:  EasyGnuPG  v0.1    ( https://github.com/dashohoxha/egpg )
"
}

cmd_help() {
    cat <<-_EOF

Usage: $0 <command> [<options>]

EasyGnuPG is a wrapper around GnuPG to simplify its operations.
Commands and their options are listed below.

    key-gen [<email> <real-name>]
        Create a new GPG key.

    key-id,fingerprint,fp
        Show the id (fingerprint) of the key.

    help
        Show this help text.

    version
        Show version information.

More information may be found in the egpg(1) man page.

_EOF
}

cmd_key_gen() {
    local email=$1 real_name=$2

    echo -e "\nCreating a new key.\n"

    # get email
    [[ -n "$email" ]] || read -e -p "Email to be associated with the key: " email
    [[ -z "$(echo $email | grep '@.*\.')" ]] \
        && fail "This email address ($email) does not appear to be valid (needs an @ and then a .)"
    [[ -n "$("$GPG" -K "$email" 2>/dev/null | grep '^sec')" ]] \
        && fail "There is already a key for '$email'"

    [[ -n "$real_name" ]] || read -e -p "Real Name to be associated with the key: " real_name

    haveged_start
    get_passphrase

    $GPG --quiet --batch --gen-key <<-_EOF
Key-Type: RSA
Key-Length: 4096
Key-Usage: encrypt,sign,auth
Name-Real: $real_name
Name-Email: $email
Expire-Date: 0
Preferences: SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
Passphrase: $PASSPHRASE
_EOF
    [[ $? -ne 0 ]] && return 1

    # set up some sub keys, in order not to use the base key day-to-day
    local COMMANDS=$(echo "addkey|4|4096|2y|addkey|6|4096|2y|save" | tr '|' "\n")
    script -c "echo -e \"$PASSPHRASE\n$COMMANDS\" | $GPG --batch --passphrase-fd=0 --command-fd=0 --edit-key $email" /dev/null >/dev/null
    haveged_stop

    echo -e "\nExcellent! You created a fresh GPG key. Here's what it looks like:"
    $GPG -K "$email"

    # generate a revokation certificate
    echo "Creating a revocation certificate."
    get_my_key
    revoke_path="${GNUPGHOME}/${MY_KEY}-revoke.gpg.asc"
    COMMANDS=$(echo "y|1|Revocation generated along with key ahead of need.||y" | tr '|' "\n")
    script -c "$GPG --command-fd=0 --output $revoke_path --gen-revoke $email <<< \"$COMMANDS\" " /dev/null >/dev/null
    [[ -f $revoke_path ]] && echo -e "Revocation certificate saved at: \n    $revoke_path"

    #  #For development purposes
    #  send_command= "$GPG --keyserver hkp://keys.gnupg.net --send-keys $email"
    #  if [ $DONT_SEND = "yes" ]; then
    #    echo "Not actually sending key..."
    #    echo "Would do: $send_command"
    #  else
    #    $send_command
    #  fi
}

cmd_fingerprint() {
    get_my_key
    [[ -z $MY_KEY ]] && echo "No key found." && return 1
    echo "The fingerprint of your key is:"
    colon_field 10 $("$GPG" --with-colons --fingerprint $MY_KEY | grep '^fpr') | sed 's/..../\0 /g'
}

#
# END subcommand functions
#

# The file 'customize.sh' can be used to redefine
# and customize some functions, without having to
# touch the code of the main script.
customize_file="$EGPG_DIR/customize.sh"
[[ -f "$customize_file" ]] && source "$customize_file"

run_cmd() {
    local cmd="$1" ; shift
    case "$cmd" in
        key-gen)                cmd_key_gen "$@" ;;
        key-id|fp|fingerprint)  cmd_fingerprint "$@" ;;
        *)                      try_ext_cmd $cmd "$@" ;;
    esac

    # cleanup the temporary workdir, if it is still there
    [[ -n "$WORKDIR" ]] && rm -rf "$WORKDIR"
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
    echo "Unknown command '$cmd'. Try: $PROGRAM help."
}

config() {
    [[ -d "$EGPG_DIR" ]] || mkdir -p "$EGPG_DIR"

    # read the config file
    local config_file="$EGPG_DIR/config.sh"
    [[ -f "$config_file" ]] || cat <<-_EOF > "$config_file"
# GnuPG options
GPG_OPTS=

# Enable debug output
DEBUG=
_EOF
    source "$config_file"

    # set defaults, if some configurations are missing
    GPG_OPTS=${GPG_OPTS:-}
    DEBUG=${DEBUG:-}
}

main() {
    case "$1" in
        ''|v|-v|version|--version)  cmd_version "$@" ; exit 0 ;;
        help|-h|--help)             cmd_help "$@" ; exit 0 ;;
    esac

    config

    PROGRAM="${0##*/}"
    COMMAND="$PROGRAM $1"

    run_cmd "$@"
}

main "$@"
