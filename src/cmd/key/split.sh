# Split the key into partial keys.

cmd_key_split_help() {
    cat <<-_EOF
    split [-d,--dongle <dir>] [-b,--backup <dir>]
        Split the key into 3 partial keys and store one of them on the
        dongle (removable device, usb), keep the other one locally,
        and use the third one as a backup. Afterwards, whenever the
        key needs to be used, the dongle has to be present.

_EOF
}

cmd_key_split() {
    # get the key and check that it is not already split
    get_gpg_key
    is_full_key || fail "\nThe key is already split.\n"
    echo -e "\nSplitting the key: $GPG_KEY\n"

    # get options
    local opts dongle backup
    backup=$(pwd)
    opts="$(getopt -o d:b: -l dongle:,backup: -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -d|--dongle) dongle="$2"; shift 2 ;;
            -b|--backup) backup="$2"; shift 2 ;;
            --) shift; break ;;
        esac
    done
    [[ $err == 0 ]] || fail "Usage:\n$(cmd_key_split_help)"

    # check options
    check_split_options "$backup" "$dongle"

    # export key to a tmp dir
    workdir_make
    local file="$WORKDIR"/$GPG_KEY.key
    call_fn backup_key $GPG_KEY "$file"
    [[ -f "$file" ]] || fail "Could not make key backup."

    # split and get the partial names
    gfsplit -n2 -m3 "$file"
    rm "$file"
    chmod 600 "$WORKDIR"/*.key.*
    local partials partial1 partial2 partial3
    partials=$(cd "$WORKDIR"; ls *.key.*)
    partial1=$(echo $partials | cut -d' ' -f1)
    partial2=$(echo $partials | cut -d' ' -f2)
    partial3=$(echo $partials | cut -d' ' -f3)

    # copy partials to the corresponding directories
    rm -f "$backup"/$GPG_KEY.key.*
    mv "$WORKDIR"/$partial1 "$backup" \
        || fail "Could not copy partial key to the backup dir: $backup"
    echo " * Backup partial key saved to: $backup/$partial1"

    mkdir -p "$DONGLE"/.gnupg/ \
        || fail "Could not create directory: $DONGLE/.gnupg/"
    rm -f "$DONGLE"/.gnupg/$GPG_KEY.key.*
    mv "$WORKDIR"/$partial2 "$DONGLE"/.gnupg/ \
        || fail "Could not copy partial key to the dongle: $DONGLE/.gnupg/"
    echo " * Dongle partial key saved to: $DONGLE/.gnupg/$partial2"

    rm -f "$GNUPGHOME"/$GPG_KEY.key.*
    mv "$WORKDIR"/$partial3 "$GNUPGHOME" \
        || fail "Could not copy partial key to: $GNUPGHOME"
    echo " * Local  partial key saved to: $GNUPGHOME/$partial3"

    workdir_clear

    # delete the secret keys
    for grip in $(get_keygrips $GPG_KEY); do
        rm -f "$GNUPGHOME"/private-keys-v1.d/$grip.key
    done

    # display a notice
    cat <<-_EOF

The key was split successfully. Whenever you need to use the key
(to sign, seal, open, etc.) connect first the dongle to the PC.

Make sure to move the backup out of the PC (for example on the cloud).
You will need it to recover the key in case that you loose the dongle
or the PC (but it cannot help you if you loose both of them).

_EOF
}

check_split_options() {
    local backup="$1" dongle="$2"
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
    [[ -n "$dongle" ]] || fail "You need a dongle to save the partial key."
    [[ -d "$dongle" ]] || fail "Dongle directory does not exist: $dongle"
    [[ -w "$dongle" ]] || fail "Dongle directory is not writable: $dongle"
    export DONGLE=$(realpath "${dongle%/}")

    # set DONGLE on the config file
    sed -i "$EGPG_DIR"/config.sh -e "/DONGLE=/c DONGLE=\"$DONGLE\""

    # check the $backup option
    [[ -d "$backup" ]] || fail "Backup directory does not exist: $backup"
    [[ -w "$backup" ]] || fail "Backup directory is not writable: $backup"
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
