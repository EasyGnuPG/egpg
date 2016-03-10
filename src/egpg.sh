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

get_gpg_key(){
    [[ -z $GPG_KEY ]] || return

    # find the id of the key
    local secret_keys
    secret_keys=$(gpg --list-secret-keys --with-colons | grep '^sec' | cut -d: -f5)
    GPG_KEY=$(gpg --list-keys --with-colons $secret_keys | grep '^pub:u:' | cut -d: -f5)

    local dont_check=$1
    [[ -n $dont_check ]] && return

    [[ -z $GPG_KEY ]] && fail "No valid key found.\nTry first:  $0 key gen"

    # check for key expiration
    local key_details exp
    key_details=$(gpg --list-keys --with-colons $GPG_KEY)
    key_ids=$(echo "$key_details" | grep -E '^pub|^sub' | cut -d: -f5)
    for key_id in $key_ids; do
        exp=$(echo "$key_details" | grep -E ":$key_id:" | cut -d: -f7)
        if [[ $exp -lt $(date +%s) ]]; then
            echo -e "\nThe key $key_id has expired on $(date -d @$exp +%F).\nPlease renew it with:  $0 key renew\n"
            break
        elif [[ $(($exp - $(date +%s))) -lt $((2*24*60*60)) ]]; then
            echo -e "\nThe key $key_id is expiring soon.\nPlease renew it with:  $0 key renew\n"
            break
        fi
    done
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
    echo -e "$@" >&2
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
export -f gpg

getopt() { "$(which getopt)" "$@" ; }
export -f getopt

shred() { "$(which shred)" -f -z -u "$@" ; }
export -f shred

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

cmd_info() {
    cmd_version
    cat <<-_EOF
EGPG_DIR="$EGPG_DIR"
GNUPGHOME="$GNUPGHOME"
GPG_AGENT_INFO="$GPG_AGENT_INFO"
GPG_TTY="$GPG_TTY"
GPG_OPTS="$GPG_OPTS"
KEYSERVER="$KEYSERVER"
DEBUG="$DEBUG"
_EOF

    local platform_file="$LIBDIR/platform/$PLATFORM.sh"
    [[ -f "$platform_file" ]] && echo "platform_file='$platform_file'"
    local customize_file="$EGPG_DIR/customize.sh"
    [[ -f "$customize_file" ]] && echo "customize_file='$customize_file'"

    cmd_key_fp
}

cmd_help() {
    cat <<-_EOF

Usage: $0 <command> [<options>]

EasyGnuPG is a wrapper around GnuPG to simplify its operations.
Commands and their options are listed below.

    init [<dir>]
        Initialize egpg. Optionally give the directory to be used.
        If not given, the default directory will be $HOME/.egpg/

    [info]
        Display info about the current configuration and settings.

    key <command> [<options>]
        Commands for handling the key. For more details see 'key help'.

    seal <file> [<recipient>...]
        Sign and encrypt a file. The resulting file will have the
        extension '.sealed' The original file will be erased.

    open <file.sealed>
        Decrypt and verify the signature of the given file.
        The file has to end with '.sealed' and the output will have
        that extension stripped.

    sign <file>
        Sign a file. The signature will be saved to <file.signature>.

    verify <file>
        Verify the signature of the given file.  The signature file
        <file.signature> must be present as well.

    --,gpg ...
        Run any gpg command (but using the configuration settings of egpg).

    help
        Show this help text.

    version
        Show version information.

More information may be found in the egpg(1) man page.

_EOF
}

cmd_key_help() {
    cat <<-_EOF

Usage: $0 key <command> [<options>]

Commands to manage the key. They are listed below.

    gen,generate [<email> <name>] [-n,--no-passphrase]
        Create a new GPG key. If <email> and <name> are not given as
        arguments, they will be asked interactively.

    [ls,list,show] [-r,--raw | -c,--colons] [-a,--all]
        Show the details of the key (optionally in raw format or with
        colons). A list of all the keys can be displayed as well
        (including the revoked ones).

    fp,fingerprint
        Show the fingerprint of the key.

    rm,del,delete [<key-id>]
        Delete the key.

    exp,export [<key-id>]
        Export key to file.

    imp,import <file>
        Import key from file.

    get,pull [-d,--dir <gnupghome>] [-i,--key-id <key-id>]
        Get a key from another gpg directory (by default from $GNUPGHOME).

    renew [<time-length>] [-c,--cert] [-a,--auth] [-s,--sign] [-e,--encrypt]
        Renew the key, set the expiration time (by default) 1 month from now.
        The renewal time length can be given like this:
        <n> (days), <n>w (weeks), <n>m (months), <n>y (years)
        The rest of the options specify which subkey will be renewed
        (certifying, authenticating, signing or encrypting).
        If no options are given, then the certifying (main) key will be renewed.

    rev-cert ["description"]
        Generate a revocation certificate for the key.

    rev,revoke [<revocation-certificate>]
        Cancel the key by publishing the given revocation certificate.

_EOF
}

cmd_init() {
    # make sure that dependencies are installed
    test $(which haveged) || fail "You should install haveged:\n    sudo apt-get install haveged"
    test $(which parcimonie) || fail "You should install parcimonie:\n    sudo apt-get install parcimonie"

    # check for an existing directory
    if [[ -d $EGPG_DIR ]]; then
        if yesno "There is an old directory '$EGPG_DIR'. Do you want to erase it?"; then
            # stop the gpg-agent if it is running
            if [[ -f "$EGPG_DIR/.gpg-agent-info" ]]; then
                kill -9 $(cut -d: -f 2 "$EGPG_DIR/.gpg-agent-info") 2>/dev/null
                rm -rf $(dirname $(cut -d: -f 1 "$EGPG_DIR/.gpg-agent-info")) 2>/dev/null
                rm "$EGPG_DIR/.gpg-agent-info"
            fi
            # erase the old directory
            [[ -d "$EGPG_DIR" ]] && rm -rfv "$EGPG_DIR"
        fi
    fi

    # create the new $EGPG_DIR
    export EGPG_DIR="$HOME/.egpg"
    [[ -n "$2" ]] && export EGPG_DIR="$2"
    mkdir -pv "$EGPG_DIR"

    # setup $GNUPGHOME
    GNUPGHOME="$EGPG_DIR/.gnupg"
    mkdir -pv "$GNUPGHOME"
    [[ -f "$GNUPGHOME/gpg-agent.conf" ]] || cat <<_EOF > "$GNUPGHOME/gpg-agent.conf"
pinentry-program /usr/bin/pinentry
default-cache-ttl 300
max-cache-ttl 999999
_EOF

    # setup environment variables
    env_setup ~/.bashrc
}

env_setup() {
    local env_file=$1
    sed -i $env_file -e '/^### start egpg config/,/^### end egpg config/d'
    cat <<_EOF >> $env_file
### start egpg config
export EGPG_DIR="$EGPG_DIR"
_EOF
    cat <<'_EOF' >> $env_file
# Does ".gpg-agent-info" exist and points to gpg-agent process accepting signals?
if ! test -f "$EGPG_DIR/.gpg-agent-info" \
|| ! kill -0 $(cut -d: -f 2 "$EGPG_DIR/.gpg-agent-info") 2>/dev/null
then
    gpg-agent --daemon --no-grab \
        --options "$EGPG_DIR/.gnupg/gpg-agent.conf" \
        --pinentry-program /usr/bin/pinentry \
        --write-env-file "$EGPG_DIR/.gpg-agent-info" > /dev/null
fi
### end egpg config
_EOF
    echo -e "\nAppended the following lines to '$env_file':\n---------------8<---------------"
    sed $env_file -n -e '/^### start egpg config/,/^### end egpg config/p'
    echo "--------------->8---------------
Please realod it to enable the new config:
    source $env_file
"
}

cmd_key() {
    COMMAND+=" $1"
    local keycmd="$1" ; shift
    case "$keycmd" in
        gen|generate)     cmd_key_gen "$@" ;;
        ''|ls|list|show)  cmd_key_list "$@" ;;
        fp|fingerprint)   cmd_key_fp "$@" ;;
        rm|del|delete)    cmd_key_delete "$@" ;;
        exp|export)       cmd_key_export "$@" ;;
        imp|import)       cmd_key_import "$@" ;;
        get|pull)         cmd_key_get "$@" ;;
        renew)            cmd_key_renew "$@" ;;
        rev-cert)         cmd_key_rev_cert "$@" ;;
        rev|revoke)       cmd_key_rev "$@" ;;
        help|*)           cmd_key_help "$@" ;;
    esac
}

cmd_key_gen() {
    get_gpg_key 'dont-check'
    [[ -z $GPG_KEY ]] \
        || fail "There is already a valid key.\nRevoke it first, or wait until it expires."

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
        Expire-Date: 1m
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
    get_gpg_key
    local COMMANDS=$(echo "addkey|4|4096|1m|addkey|6|4096|1m|save" | tr '|' "\n")
    script -c "echo -e \"$PASSPHRASE\n$COMMANDS\" | gpg --batch --passphrase-fd=0 --command-fd=0 --edit-key $GPG_KEY" /dev/null >/dev/null
    haveged_stop

    echo -e "\nExcellent! You created a fresh GPG key. Here's what it looks like:"
    cmd_key_list

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

    local commands="y|1|$description||y"
    commands=$(echo "$commands" | tr '|' "\n")
    script -c "gpg --yes --command-fd=0 --output \"$revoke_cert\" --gen-revoke $GPG_KEY <<< \"$commands\" " /dev/null > /dev/null
    [[ -f "$revoke_cert" ]] &&  echo -e "Revocation certificate saved at: \n    \"$revoke_cert\""
}

cmd_key_fp() {
    get_gpg_key
    gpg --with-colons --fingerprint $GPG_KEY | grep '^fpr' | cut -d: -f 10 | sed 's/..../\0 /g'
}

cmd_key_delete() {
    local key_id="$1"
    [[ -z $key_id ]] && get_gpg_key && key_id=$GPG_KEY

    local fingerprint
    fingerprint=$(gpg --with-colons --fingerprint $key_id | grep '^fpr' | cut -d: -f10)
    gpg --batch --delete-secret-and-public-keys "$fingerprint"
}

cmd_key_export() {
    local key_id="$1"
    [[ -z $key_id ]] && get_gpg_key && key_id=$GPG_KEY

    gpg --armor --export $key_id > $key_id.key
    gpg --armor --export-secret-keys $key_id >> $key_id.key
    echo "Key exported to: $key_id.key"
}

cmd_key_import() {
    get_gpg_key 'dont-check'
    [[ -z $GPG_KEY ]] \
        || fail "There is already a valid key.\nRevoke it first, or wait until it expires."

    local file="$1"
    [[ -n "$file" ]] || fail "Usage: $COMMAND  <file>"
    [[ -f "$file" ]] || fail "Cannot find file: $file"

    # import
    echo "Importing key from file: $file"
    gpg --import "$file"

    # set trust to 'ultimate'
    get_gpg_key
    local commands=$(echo "trust|5|y|quit" | tr '|' "\n")
    script -c "gpg --batch --command-fd=0 --key-edit $GPG_KEY <<< \"$commands\" " /dev/null > /dev/null
}

cmd_key_get() {
    get_gpg_key 'dont-check'
    [[ -z $GPG_KEY ]] \
        || fail "There is already a valid key.\nRevoke it first, or wait until it expires."

    local opts homedir key_id
    opts="$(getopt -o di -l homedir,key-id -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -d|--homedir) homedir="$2"; shift 2 ;;
            -i|--key-id) key_id="$2"; shift 2 ;;
            --) shift; break ;;
        esac
    done
    [[ $err -eq 0 ]] || fail "Usage: $COMMAND [-d,--dir <gnupghome>] [-i,--key-id <key-id>]"

    echo "Importing key from: $homedir"
    [[ -n "$homedir" ]] || homedir="$ENV_GNUPGHOME"
    [[ -n "$key_id" ]] || key_id=$(_find_key_to_import $homedir)

    make_workdir
    local file="$WORKDIR/$key_id.key"
    gpg --homedir="$homedir" --armor --export $key_id > "$file"
    gpg --homedir="$homedir" --armor --export-secret-keys $key_id >> "$file"

    gpg --import "$file"
    rm -rf $WORKDIR

    local commands=$(echo "trust|5|y|quit" | tr '|' "\n")
    script -c "gpg --command-fd=0 --key-edit $key_id <<< \"$commands\" " /dev/null > /dev/null
}

_find_key_to_import() {
    local homedir="$1"
    [[ -n "$homedir" ]] || fail "No gnupg directory to import from."
    [[ -d "$homedir" ]] || fail "Cannot find gnupg directory: $homedir"

    local secret_keys key_id expiration
    secret_keys=$(gpg --homedir="$homedir" --list-secret-keys --with-colons | grep '^sec' | cut -d: -f5)
    [[ -n $secret_keys ]] || fail "No valid key found."
    for key_id in $secret_keys; do
        expiration=$(gpg --homedir="$homedir" --list-keys --with-colons $key_id | grep '^pub:u:' | cut -d: -f7)
        [[ -z $expiration ]] && continue
        [[ $expiration -lt $(date +%s) ]] && continue
        echo $key_id
        return
    done
    fail "No valid key found."
}

cmd_key_rev() {
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

cmd_key_list() {
    local opts raw=0 colons=0 all=0
    opts="$(getopt -o rca -l raw,colons,all -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -r|--raw) raw=1; shift ;;
            -c|--colons) colons=1; shift ;;
            -a|--all) all=1; shift ;;
            --) shift; break ;;
        esac
    done
    [[ $err -ne 0 ]] && echo "Usage: $COMMAND [-r,--raw | -c,--colons] [-a,--all]" && return
    [[ $raw == 1 ]] && [[ $colons == 1 ]] && echo "Usage: $COMMAND [-r,--raw | -c,--colons]" && return

    local secret_keys
    if [[ $all == 0 ]]; then
        get_gpg_key
        secret_keys=$GPG_KEY
    else
        secret_keys=$(gpg --list-secret-keys --with-colons | grep '^sec' | cut -d: -f5)
    fi

    [[ $raw == 1 ]] && \
        gpg --list-keys $secret_keys && \
        return

    [[ $colons == 1 ]] && \
        gpg --list-keys --fingerprint --with-colons $secret_keys && \
        return

    # display the details of each key
    for gpg_key in $secret_keys; do
        echo
        _display_key_details $gpg_key
        echo
    done
}

_display_key_details() {
    local gpg_key=$1
    local keyinfo
    keyinfo=$(gpg --list-keys --fingerprint --with-colons $gpg_key)

    # get fingerprint and user identity
    local fpr uid
    fpr=$(echo "$keyinfo" | grep '^fpr:' | cut -d: -f 10 | sed 's/..../\0 /g')
    uid=$(echo "$keyinfo" | grep '^uid:' | cut -d: -f 10)
    echo -e "uid: $uid\nfpr: $fpr"

    local line time1 time2 id start end exp rev
    declare -A keys
    # get the details of the main (cert) key
    line=$(echo "$keyinfo" | grep '^pub:')
    if [[ -n "$line" ]]; then
        id=$(echo $line | cut -d: -f5)
        time1=$(echo $line | cut -d: -f6)
        time2=$(echo $line | cut -d: -f7)
        start=$(date -d @$time1 +%F)
        end=$(date -d @$time2 +%F)
        exp=''; [ $(date +%s) -gt $time2 ] && exp='expired'
        rev=''; [[ $(echo $line | grep '^pub:r:') ]] && rev='revoked'
        echo "cert: $id $start $end $exp $rev"
    fi

    # get the details of the auth key
    line=$(echo "$keyinfo" | grep '^sub:' | grep ':a:')
    if [[ -n "$line" ]]; then
        id=$(echo $line | cut -d: -f5)
        time1=$(echo $line | cut -d: -f6)
        time2=$(echo $line | cut -d: -f7)
        start=$(date -d @$time1 +%F)
        end=$(date -d @$time2 +%F)
        exp=''; [ $(date +%s) -gt $time2 ] && exp='expired'
        rev=''; [[ $(echo $line | grep '^sub:r:') ]] && rev='revoked'
        echo "auth: $id $start $end $exp $rev"
    fi

    # get the details of the sign key
    line=$(echo "$keyinfo" | grep '^sub:' | grep ':s:')
    if [[ -n "$line" ]]; then
        id=$(echo $line | cut -d: -f5)
        time1=$(echo $line | cut -d: -f6)
        time2=$(echo $line | cut -d: -f7)
        start=$(date -d @$time1 +%F)
        end=$(date -d @$time2 +%F)
        exp=''; [ $(date +%s) -gt $time2 ] && exp='expired'
        rev=''; [[ $(echo $line | grep '^sub:r:') ]] && rev='revoked'
        echo "sign: $id $start $end $exp $rev"
    fi

    # get the details of the encrypt key
    line=$(echo "$keyinfo" | grep '^sub:' | grep ':e:')
    if [[ -n "$line" ]]; then
        id=$(echo $line | cut -d: -f5)
        time1=$(echo $line | cut -d: -f6)
        time2=$(echo $line | cut -d: -f7)
        start=$(date -d @$time1 +%F)
        end=$(date -d @$time2 +%F)
        exp=''; [ $(date +%s) -gt $time2 ] && exp='expired'
        rev=''; [[ $(echo $line | grep '^sub:r:') ]] && rev='revoked'
        echo "encr: $id $start $end $exp $rev"
    fi
}

cmd_key_renew() {
    local opts cert=0 auth=0 sign=0 encrypt=0
    opts="$(getopt -o case -l cert,auth,sign,encrypt -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -c|--cert) cert=1; shift ;;
            -a|--auth) auth=1; shift ;;
            -s|--sign) sign=1; shift ;;
            -e|--encrypt) encrypt=1; shift ;;
            --) shift; break ;;
        esac
    done
    [[ $err -ne 0 ]] && echo "Usage: $COMMAND [<time-length>] [-c,--cert] [-a,--auth] [-s,--sign] [-e,--encrypt]" && return
    [ $cert == 0 ] && [ $auth == 0 ] && [ $sign == 0 ] && [ $encrypt == 0 ] \
        && cert=1

    local time=${1:-1m}
    local commands=''
    [ $cert == 1 ] && commands+=";expire;$time;y"
    [ $auth == 1 ] && commands+=";key 1;expire;$time;y;key 1"
    [ $sign == 1 ] && commands+=";key 2;expire;$time;y;key 2"
    [ $encrypt == 1 ] && commands+=";key 3;expire;$time;y;key 3"
    commands+=";save"
    commands=$(echo "$commands" | tr ';' "\n")

    get_gpg_key
    script -c "gpg --command-fd=0 --key-edit $GPG_KEY <<< \"$commands\" " /dev/null > /dev/null

    cmd_key_list
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
    get_gpg_key
    gpg --local-user $GPG_KEY \
        --detach-sign --armor --output "$file.signature" "$file"
}

cmd_verify() {
    local file="$1" ; shift
    [[ -z "$file" ]] && fail "Usage: $(basename "$0") verify <file>"
    [[ -f "$file" ]] || fail "Cannot find file '$file'"
    [[ -f "$file.signature" ]] || fail "Cannot find file '$file.signature'"

    # verify
    gpg --verify "$file.signature" "$file"
}

cmd_gpg() { gpg "$@"; }

#
# END subcommand functions
#


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
        --|gpg)      cmd_gpg "$@" ;;
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
    LIBDIR="$(dirname "$0")"
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
