# Create a new GPG key.

cmd_key_gen_help() {
    cat <<-_EOF
    gen,generate [<email> <name>] [-n,--no-passphrase]
        Create a new GPG key. If <email> and <name> are not given as
        arguments, they will be asked interactively.

_EOF
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
    [[ $err -ne 0 ]] && fail "Usage:\n$(cmd_key_gen_help)"

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
        Key-Usage: sign
        Name-Real: $real_name
        Name-Email: $email
        Subkey-Type: RSA
        Subkey-Length: 4096
        Subkey-Usage: auth
        Expire-Date: 1m
        Preferences: SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
        "
    if [[ $pass == 1 ]]; then
        get_new_passphrase
        [[ -n "$PASSPHRASE" ]] && PARAMETERS+="Passphrase: $PASSPHRASE"
    else
        PASSPHRASE=''
    fi
    gpg --quiet --batch --gen-key <<< "$PARAMETERS"

    [[ $? -ne 0 ]] && return 1

    # set up some sub keys, in order not to use the base key day-to-day
    get_gpg_key
    local commands="addkey|4|4096|1m|addkey|6|4096|1m|save"
    commands=$(echo "$commands" | tr '|' "\n")
    script -c "gpg --batch --command-fd=0 --edit-key $GPG_KEY <<< \"$commands\"" /dev/null >/dev/null
    while [[ -n $(ps ax | grep -e '--edit-key' | grep -v grep) ]]; do sleep 0.5; done
    haveged_stop

    echo -e "\nExcellent! You created a fresh GPG key. Here's what it looks like:"
    call cmd_key_list

    # generate a revokation certificate
    call cmd_key_revcert "This revocation certificate was generated when the key was created."

    # send the key to keyserver
    gpg_send_keys $GPG_KEY
    return 0
}

#
# This file is part of EasyGnuPG.  EasyGnuPG is a wrapper around GnuPG
# to simplify its operations.  Copyright (C) 2016 Dashamir Hoxha
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
