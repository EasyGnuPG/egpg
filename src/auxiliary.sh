# Auxiliary functions.

yesno() {
    local response
    read -r -p "$1 [y/N] " response
    [[ $response == [yY] ]] || return 1
}

fail() {
    workdir_clear
    echo -e "$@" >&2
    exit 1
}

debug() {
    is_true $DEBUG || return 0
    echo "debug: $@"
}

is_true() {
    local var="${1,,}"
    [[ $var == 1 ]] && return 0
    [[ $var == 'yes' ]] && return 0
    [[ $var == 'true' ]] && return 0
    [[ $var == 'enabled' ]] && return 0
    return 1
}

is_false() {
    ! is_true "$@"
}

gpg_version() {
    gpg --version | head -n 1 | cut -d" " -f3
}

# Return the ids of the keys that are not revoked and not expired.
get_valid_keys(){
    local gnupghome="${1:-$GNUPGHOME}"
    local valid_keys=''
    local secret_keys partial_keys key_id keyinfo expiration
    secret_keys=$(gpg --homedir="$gnupghome" --list-secret-keys --with-colons | grep '^sec' | cut -d: -f5)
    partial_keys=$(ls "$gnupghome"/*.key.* 2>/dev/null | sed -e "s#\.key\..*\$##" -e "s#^.*/##" | uniq)
    for key_id in $secret_keys $partial_keys; do
        keyinfo=$(gpg --homedir="$gnupghome" --list-keys --with-colons $key_id | grep '^pub:u:')
        [[ -z $keyinfo ]] && continue
        expiration=$(echo "$keyinfo" | cut -d: -f7)
        [[ -n $expiration ]] && [[ $expiration -lt $(date +%s) ]] && continue
        valid_keys+=" $key_id"
    done
    echo $valid_keys
}

get_gpg_key(){
    [[ -z $GPG_KEY ]] || return 0

    GPG_KEY=$(get_valid_keys | cut -d' ' -f1)
    [[ -z $GPG_KEY ]] && \
        fail "
No valid key found.

Try first:  $(basename $0) key gen
       or:  $(basename $0) key fetch
       or:  $(basename $0) key restore
       or:  $(basename $0) key recover
"

    # get the fingerprint
    FPR=$(gpg --list-keys --fingerprint --with-sig-check --with-colons $GPG_KEY | grep '^fpr:' | cut -d: -f10)

    # check for key expiration
    # an expired key can be renewed at any time, so only a warning is issued
    local key_details exp key_id
    key_details=$(gpg --list-keys --with-colons $GPG_KEY)
    key_ids=$(echo "$key_details" | grep -E '^pub|^sub' | cut -d: -f5)
    for key_id in $key_ids; do
        exp=$(echo "$key_details" | grep -E ":$key_id:" | cut -d: -f7)
        [[ -z $exp ]] && continue
        if [[ $exp -lt $(date +%s) ]]; then
            echo -e "\nThe key $key_id has expired on $(date -d @$exp +%F).\nPlease renew it with:  $(basename $0) key renew\n"
            break
        elif [[ $(($exp - $(date +%s))) -lt $((2*24*60*60)) ]]; then
            echo -e "\nThe key $key_id is expiring soon.\nPlease renew it with:  $(basename $0) key renew\n"
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

# Return true if the key is a full key (not partial).
is_full_key() {
    local key_id=${1:-$GPG_KEY}
    [[ -n $key_id ]] || return 1
    [[ -n $(gpg --list-secret-keys --with-colons $key_id 2>/dev/null) ]]
}

is_split_key() {
    ! is_full_key "$@"
}

get_fingerprint() {
    local key_id=${1:-$GPG_KEY}
    [[ -n $key_id ]] || return 1

    local fingerprint
    fingerprint=$(gpg --with-colons --fingerprint $key_id | grep '^fpr' | cut -d: -f10 | head -n 1)
    echo $fingerprint
}

get_keygrips() {
    local key_id=${1:-$GPG_KEY}
    [[ -n $key_id ]] || return 1

    local keygrips
    keygrips=$(gpg --list-keys --with-keygrip --with-colons $key_id | grep '^grp:' | cut -d: -f10)
    echo $keygrips
}

# Copy $GNUPGHOME to a temporary $WORKDIR
# and import there the combined key (if it is split).
gnupghome_setup() {
    local gnupghome=${1:-"$GNUPGHOME"}
    workdir_make
    cp -a "$gnupghome"/* "$WORKDIR"/
    GNUPGHOME_BAK="$GNUPGHOME"
    export GNUPGHOME="$WORKDIR"

    get_gpg_key    # get $GPG_KEY
    is_full_key && return 0

    # get the partial keys from PC and dongle
    local partial1 partial2
    partial1=$(cd "$GNUPGHOME"; ls $GPG_KEY.key.[0-9][0-9][0-9] 2>/dev/null)
    [[ -f "$GNUPGHOME"/$partial1 ]] \
        || fail "Could not find partial key for $GPG_KEY on $gnupghome"
    [[ -d "$DONGLE" ]] \
        || fail "The dongle directory not found: $DONGLE\nMake sure that the dongle is connected and mounted."
    [[ -d "$DONGLE"/.gnupg/ ]] \
        || fail "Directory not found: $DONGLE"
    partial2=$(cd "$DONGLE"/.gnupg; ls $GPG_KEY.key.[0-9][0-9][0-9] 2>/dev/null)
    [[ -f "$DONGLE"/.gnupg/$partial2 ]] \
        || fail "Could not find partial key for $GPG_KEY on $DONGLE/.gnupg/"

    # copy the partial keys to workdir and combine them
    gfcombine "$GNUPGHOME"/$partial1 "$DONGLE"/.gnupg/$partial2
    call_fn restore_key "$GNUPGHOME"/$GPG_KEY.key
}
gnupghome_reset() {
    export GNUPGHOME="$GNUPGHOME_BAK"
    unset GNUPGHOME_BAK
    workdir_clear
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
