# Split the key into partial keys.

cmd_key_split_help() {
    cat <<-_EOF
    split [-d,--dongle <dir>] [-b,--backup <dir>]
        Split the key into 3 partial keys and store one of them on the
        dongle (removable device, usb), keep the other one locally,
        and use the third one as a backup.

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
    call_fn check_split_options "$backup" "$dongle"

    # export key to a tmp dir
    workdir_make
    local file="$WORKDIR/$GPG_KEY.key"
    gpg --armor --export $GPG_KEY > "$file"
    gpg --armor --export-secret-keys $GPG_KEY >> "$file"

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
    mv "$WORKDIR/$partial1" "$backup" \
        || fail "Could not copy partial key to the backup dir: $backup"
    echo " * Backup partial key saved to: $backup/$partial1"

    mkdir -p "$DONGLE/.gnupg/" \
        || fail "Could not create directory: $DONGLE/.gnupg/"
    rm -f "$DONGLE"/.gnupg/$GPG_KEY.key.*
    mv "$WORKDIR/$partial2" "$DONGLE/.gnupg/" \
        || fail "Could not copy partial key to the dongle: $DONGLE/.gnupg/"
    echo " * Dongle partial key saved to: $DONGLE/.gnupg/$partial2"

    rm -f "$GNUPGHOME"/$GPG_KEY.key.*
    mv "$WORKDIR/$partial3" "$GNUPGHOME" \
        || fail "Could not copy partial key to: $GNUPGHOME"
    echo " * Local  partial key saved to: $GNUPGHOME/$partial3"

    workdir_clear

    # delete the secret key
    local fingerprint=$(gpg --list-keys --with-colons --fingerprint $GPG_KEY | grep '^fpr:' | cut -d: -f10)
    gpg --batch --delete-secret-keys $fingerprint

    # display a notice
    cat <<-_EOF

The key was split successfully. Whenever you need to use the key
(to sign, seal, open, etc.) connect first the dongle to the PC.

Make sure to move the backup out of the PC (for example on the cloud).
You will need it to recover the key in case that you loose the dongle
or the PC (but it cannot help you if you loose both of them).

_EOF
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
