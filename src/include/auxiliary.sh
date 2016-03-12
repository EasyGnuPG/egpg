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
# BEGIN helper functions
#

# Return the ids of the keys that are not revoked and not expired.
get_valid_keys(){
    local homedir="${1:-$GNUPGHOME}"
    local valid_keys=''
    local secret_keys key_id keyinfo expiration
    secret_keys=$(gpg --homedir="$homedir" --list-secret-keys --with-colons | grep '^sec' | cut -d: -f5)
    for key_id in $secret_keys; do
        keyinfo=$(gpg --homedir="$homedir" --list-keys --with-colons $key_id | grep '^pub:u:')
        [[ -z $keyinfo ]] && continue
        expiration=$(echo "$keyinfo" | cut -d: -f7)
        [[ -n $expiration ]] && [[ $expiration -lt $(date +%s) ]] && continue
        valid_keys+=" $key_id"
    done
    echo $valid_keys
}

get_gpg_key(){
    [[ -z $GPG_KEY ]] || return
    GPG_KEY=$(get_valid_keys | cut -d' ' -f1)
    [[ -z $GPG_KEY ]] && fail "No valid key found.\nTry first:  $0 key gen"

    # check for key expiration
    # an expired key can be renewed at any time, so only a warning is issued
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

# Fail with a suitable message if there is any valid key.
# This is called before generating or importing a new key,
# to make sure that there is no more than one valid key.
assert_no_valid_key(){
    local gpg_key=$(get_valid_keys | cut -d' ' -f1)
    [[ -z $gpg_key ]] || fail "There is already a valid key.\nRevoke or delete it first."
}

gpg_send_keys() {
    is_true $SHARE || return
    gpg --keyserver "$KEYSERVER" --send-keys "$@"
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

is_true() {
    local var="${1,,}"
    [[ $var == 1 ]] && return
    [[ $var == 'yes' ]] && return
    [[ $var == 'true' ]] && return
    [[ $var == 'enabled' ]] && return
}

is_false() {
    ! is_true "$@"
}

#
# END helper functions
#
