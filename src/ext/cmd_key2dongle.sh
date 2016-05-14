# Move the sign/cert/main key to dongle.

cmd_key2dongle_help() {
    cat <<-_EOF
    key2dongle [<dongle-dir>] [-r,--reverse]
        Move the sign/cert/main key to dongle.
        With option --reverse move it back to GNUPGHOME.

_EOF
}

cmd_key2dongle() {
    # get the key
    get_gpg_key
    is_full_key || fail "
This key is split into partial keys.
Try first:  $(basename $0) key join
"

    # get options
    local opts reverse=0
    backup=$(pwd)
    opts="$(getopt -o r -l reverse -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -r|--reverse) reverse=1; shift ;;
            --) shift; break ;;
        esac
    done
    [[ $err == 0 ]] || fail "Usage:\n$(cmd_key2dongle_help)"

    # get the key file
    local key_grips=$(get_keygrips)
    local grip=$(echo $key_grips | cut -d" " -f1)
    local keyfile="$GNUPGHOME"/private-keys-v1.d/$grip.key
    [[ $reverse == 0 ]] && [[ -L "$keyfile" ]] && fail "The key is already in dongle."
    [[ $reverse == 1 ]] && [[ ! -L "$keyfile" ]] && fail "The key is already in GNUPGHOME."

    # get the dongle
    local dongle="$1"
    if [[ -z "$dongle" ]]; then
        local guess suggest
        guess="$DONGLE"
        [[ -z "$guess" ]] && guess=$(df -h | grep '/dev/sdb1' | sed 's/ \+/:/g' | cut -d: -f6)
        [[ -z "$guess" ]] && guess=$(df -h | grep '/dev/sdc1' | sed 's/ \+/:/g' | cut -d: -f6)
        [[ -n "$guess" ]] && suggest=" [$guess]"
        read -e -p "Enter the dongle directory$suggest: " dongle
        echo
        dongle=${dongle:-$guess}
    fi
    [[ -n "$dongle" ]] || fail "You need a dongle to move the key."
    [[ -d "$dongle" ]] || fail "Dongle directory does not exist: $dongle"
    [[ -w "$dongle" ]] || fail "Dongle directory is not writable: $dongle"

    # set DONGLE on the config file
    export DONGLE=$(realpath "${dongle%/}")
    sed -i "$EGPG_DIR/config.sh" -e "/DONGLE=/c DONGLE=\"$DONGLE\""

    if [[ $reverse == 0 ]]; then
        # move the keyfile to the dongle
        mkdir -p "$DONGLE"/.gnupg/ \
            || fail "Could not create directory: $DONGLE/.gnupg/"
        rm -f "$DONGLE"/.gnupg/$grip.key
        mv -v "$keyfile" "$DONGLE"/.gnupg/ \
            || fail "Could not copy key to: $DONGLE/.gnupg/"
        ln -s "$DONGLE"/.gnupg/$grip.key "$keyfile"
        echo -e "\nKey moved to $DONGLE/.gnupg/$grip.key \n"
    else
        # move the keyfile to GNUPGHOME
        rm -f "$keyfile"
        mv -v "$DONGLE"/.gnupg/$grip.key "$keyfile"
        echo -e "\nKey moved to $keyfile \n"
    fi
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
