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

    # check that haveged is installed
    test -x /usr/sbin/haveged || fail "You should install haveged:\n    sudo apt install haveged"

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
    [[ $err == 0 ]] || fail "Usage:\n$(cmd_key_gen_help)"

    local email=$1 real_name=$2

    echo -e "\nCreating a new key.\n"

    # get email
    [[ -n "$email" ]] || read -e -p "Email to be associated with the key: " email
    [[ -z "$(echo $email | grep '@.*\.')" ]] \
        && fail "This email address ($email) does not appear to be valid (needs an @ and then a .)"

    [[ -n "$real_name" ]] || read -e -p "Real Name to be associated with the key: " real_name
    real_name=${real_name:-anonymous}

    local PARAMETERS="
        Key-Type: RSA
        Key-Length: 4096
        Key-Usage: sign
        Name-Real: $real_name
        Name-Email: $email
        Subkey-Type: RSA
        Subkey-Length: 4096
        Subkey-Usage: encrypt
        Expire-Date: 1m
        "
    if [[ $pass == 1 ]]; then
        get_new_passphrase
        PARAMETERS+="Passphrase: $PASSPHRASE"
    else
        PARAMETERS+="%no-protection"
    fi

    # generate the key
    haveged_start
    echo -e "$PARAMETERS" | gpg --batch --gen-key 2>/dev/null
    haveged_stop

    # restrict expiration time to 1 month from now
    call cmd_key_renew

    # revokation certificate
    revcert="$GNUPGHOME/openpgp-revocs.d/$FPR.rev"
    if [[ -f "$revcert" ]]; then
        call_fn qrencode "$revcert"
        echo -e "Revocation certificate is at: \n    \"$revcert\""
        [[ -f "$revcert.pdf" ]] &&  echo -e "    \"$revcert.pdf\"\n"
    fi
}

get_new_passphrase() {
    local passphrase passphrase_again
    while true; do
        read -r -p "Enter passphrase for the new key: " -s passphrase || return 1
        echo
        read -r -p "Retype the passphrase of the key: " -s passphrase_again || return 1
        echo
        if [[ "$passphrase" == "$passphrase_again" ]]; then
            PASSPHRASE="$passphrase"
            break
        else
            echo "Error: the entered passphrases do not match."
        fi
    done
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
