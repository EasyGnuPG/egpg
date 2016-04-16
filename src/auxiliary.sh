# Auxiliary functions.

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
    is_true $DEBUG || return
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

# Return the ids of the keys that are not revoked and not expired.
get_valid_keys(){
    local homedir="${1:-$GNUPGHOME}"
    local valid_keys=''
    local secret_keys partial_keys key_id keyinfo expiration
    secret_keys=$(gpg --homedir="$homedir" --list-secret-keys --with-colons | grep '^sec' | cut -d: -f5)
    partial_keys=$(ls $EGPG_DIR/*.key.* 2>/dev/null | sed -e "s#\.key\..*\$##" -e "s#^.*/##" | uniq)
    for key_id in $secret_keys $partial_keys; do
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
    [[ -z $GPG_KEY ]] && \
        fail "
No valid key found.

Try first:  $(basename $0) key gen
       or:  $(basename $0) key fetch
       or:  $(basename $0) key restore
"

    # check for key expiration
    # an expired key can be renewed at any time, so only a warning is issued
    local key_details exp
    key_details=$(gpg --list-keys --with-colons $GPG_KEY)
    key_ids=$(echo "$key_details" | grep -E '^pub|^sub' | cut -d: -f5)
    for key_id in $key_ids; do
        exp=$(echo "$key_details" | grep -E ":$key_id:" | cut -d: -f7)
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

# Return true if the key is not split.
is_unsplit_key() {
    local key_id=${1:-$GPG_KEY}
    [[ -n $(gpg --list-secret-keys --with-colons $key_id 2>/dev/null) ]]
}

# Copy $GNUPGHOME to a temporary $WORKDIR
# and import there the combined key (if it is split).
gnupghome_setup() {
    workdir_make
    cp -a "$GNUPGHOME"/* "$WORKDIR"/
    GNUPGHOME_BAK="$GNUPGHOME"
    export GNUPGHOME="$WORKDIR"

    get_gpg_key    # get $GPG_KEY
    is_unsplit_key && return

    combine_partial_keys
    gpg --import "$WORKDIR/$GPG_KEY.key" 2>/dev/null || fail "Could not import the combined key."
}
gnupghome_reset() {
    export GNUPGHOME="$GNUPGHOME_BAK"
    unset GNUPGHOME_BAK
    workdir_clear
}

combine_partial_keys() {
    get_gpg_key    # get $GPG_KEY

    # get the partial keys from PC and dongle
    local partial1 partial2
    partial1=$(cd "$EGPG_DIR"; ls $GPG_KEY.key.[0-9][0-9][0-9] 2>/dev/null)
    [[ -f "$EGPG_DIR/$partial1" ]] \
        || fail "Could not find partial key for $GPG_KEY on $EGPG_DIR"
    [[ -d "$DONGLE" ]] \
        || fail "The dongle directory not found: $DONGLE\nMake sure that the dongle is connected and mounted."
    [[ -d "$DONGLE/.egpg_key/" ]] \
        || fail "Directory not found: $DONGLE"
    partial2=$(cd "$DONGLE/.egpg_key"; ls $GPG_KEY.key.[0-9][0-9][0-9] 2>/dev/null)
    [[ -f "$DONGLE/.egpg_key/$partial2" ]] \
        || fail "Could not find partial key for $GPG_KEY on $DONGLE/.egpg_key/"

    # copy the partials to workdir and combine them
    cp "$EGPG_DIR/$partial1" "$WORKDIR/"
    cp "$DONGLE/.egpg_key/$partial2" "$WORKDIR/"
    gfcombine "$WORKDIR/$partial1" "$WORKDIR/$partial2"
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
