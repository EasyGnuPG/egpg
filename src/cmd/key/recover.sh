# Recover the key from the backup partial key and from the partial key
# of the home or the dongle. This is useful when either the dongle or
# the home partial key is lost.

cmd_key_recover_help() {
    cat <<-_EOF
    recover <backup-partial.key.xyz>
        Recover the key from the backup partial key and from the
        partial key of the home or the dongle. This is useful when
        either the dongle or the home partial key is lost.

_EOF
}

cmd_key_recover() {
    local partial1="$1"
    [[ -n "$partial1" ]] || fail "Usage:\n$(cmd_key_recover_help)"
    [[ -f "$partial1" ]] || fail "\nFile not found: $partial1\n"

    local name=$(basename "$partial1")
    local key_id=${name%.key.[0-9][0-9][0-9]}
    [[ "$key_id" != "$name" ]] || fail "\nThe name of the backup partial key must be like '*.key.xyz' where xyz are digits.\n"
    is_full_key $key_id && fail "\nThe key $key_id is already available as a full key.\n"

    # get the other partial key
    local partial2
    partial2=$(get_the_other_partial_key $key_id)
    [[ $? -ne 0 ]] && exit 1
    partial2=$(echo $partial2)

    # combine partial keys and import the full key
    workdir_make
    cp "$partial1" "$WORKDIR/"
    cp "$partial2" "$WORKDIR/"
    gfcombine "$WORKDIR"/$key_id.key.*
    call_fn restore_key "$WORKDIR"/$key_id.key 2>/dev/null || fail "Could not recover the key."
    workdir_clear

    # remove the partials
    rm -f "$partial1"
    rm -f "$partial2"

    # display a notice
    cat <<-_EOF

The key was recovered and imported successfully.
You can split it again with:  $(basename $0) key split

_EOF
}

get_the_other_partial_key() {
    local key_id=$1

    # look on $GNUPGHOME
    local partial
    partial=$(ls "$GNUPGHOME"/$key_id.key.[0-9][0-9][0-9] 2>/dev/null)
    [[ -f "$partial" ]] && echo "$partial" && return

    # look on the dongle
    local guess suggest dongle
    guess="$DONGLE"
    [[ -z "$guess" ]] && guess=$(df -h | grep '/dev/sdb1' | sed 's/ \+/:/g' | cut -d: -f6)
    [[ -z "$guess" ]] && guess=$(df -h | grep '/dev/sdc1' | sed 's/ \+/:/g' | cut -d: -f6)
    [[ -n "$guess" ]] && suggest=" [$guess]"
    read -e -p "Enter the dongle directory$suggest: " dongle
    echo
    dongle=${dongle:-$guess}
    dongle=${dongle%/}
    [[ -n "$dongle" ]] || fail "You need a dongle to recover the key."
    [[ -d "$dongle" ]] \
        || fail "The dongle directory not found: $dongle\nMake sure that the dongle is connected and mounted."
    [[ -d "$dongle"/.gnupg ]] \
        || fail "Directory not found: $dongle/.gnupg"
    partial=$(ls "$dongle"/.gnupg/$key_id.key.[0-9][0-9][0-9] 2>/dev/null)
    [[ -f "$partial" ]] && echo "$partial" && return

    fail "Could not find an other partial key for $key_id"
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
