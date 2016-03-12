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

#
# BEGIN key commands
#

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

    fetch [-d,--dir <gnupghome>] [-k,--key-id <key-id>]
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

    share
        Publish the key to the keyserver network.

_EOF
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
        fetch)            cmd_key_fetch "$@" ;;
        renew)            cmd_key_renew "$@" ;;
        share)            cmd_key_share "$@" ;;
        rev-cert)         cmd_key_rev_cert "$@" ;;
        rev|revoke)       cmd_key_rev "$@" ;;
        help)             cmd_key_help "$@" ;;
        *)                try_ext_cmd "key_$keycmd" "$@" ;;
    esac
}

cmd_key_gen() {
    assert_no_valid_key

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
    gpg_send_keys $GPG_KEY
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
    assert_no_valid_key

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

cmd_key_fetch() {
    assert_no_valid_key

    local opts homedir key_id
    opts="$(getopt -o d:k: -l homedir:,key-id: -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -d|--homedir) homedir="$2"; shift 2 ;;
            -k|--key-id) key_id="$2"; shift 2 ;;
            --) shift; break ;;
        esac
    done
    [[ $err -eq 0 ]] || fail "Usage: $COMMAND [-d,--dir <gnupghome>] [-k,--key-id <key-id>]"

    # get the gnupg dir
    [[ -n "$homedir" ]] || homedir="$ENV_GNUPGHOME"
    [[ -n "$homedir" ]] || fail "No gnupg directory to import from."
    [[ -d "$homedir" ]] || fail "Cannot find gnupg directory: $homedir"
    echo "Importing key from: $homedir"

    # get id of the key to be imported
    [[ -n "$key_id" ]] || key_id=$(get_valid_keys $homedir | cut -d' ' -f1)
    [[ -n "$key_id" ]] || fail "No valid key found."

    # export to tmp file
    make_workdir
    local file="$WORKDIR/$key_id.key"
    gpg --homedir="$homedir" --armor --export $key_id > "$file"
    gpg --homedir="$homedir" --armor --export-secret-keys $key_id >> "$file"

    # import from the tmp file
    gpg --import "$file"
    rm -rf $WORKDIR

    # set trust to ultimate
    local commands=$(echo "trust|5|y|quit" | tr '|' "\n")
    script -c "gpg --command-fd=0 --key-edit $key_id <<< \"$commands\" " /dev/null > /dev/null
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
    gpg_send_keys $GPG_KEY
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
    echo -e "id: $gpg_key\nuid: $uid\nfpr: $fpr"

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
    gpg_send_keys $GPG_KEY

    cmd_key_list
}

cmd_key_share() {
    get_gpg_key
    is_true $SHARE || fail "You must enable sharing first with:\n  $0 set share yes"
    gpg_send_keys $GPG_KEY
}

#
# END key commands
#
