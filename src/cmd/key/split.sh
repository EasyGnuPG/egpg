# Split the key into partial keys.

cmd_key_split_help() {
    cat <<-_EOF
    split [-d,--dongledir <dir>] [-b,--backupdir <dir>]
        Split the key into 3 partial keys; one of them is kept on the
        PC, one of them is stored on a dongle (removable device, usb),
        and the other one is used as a backup. After this, the dongle
        with the partial key has to be connected to the PC whenever we
        need to use the key (to sign or decrypt).

_EOF
}

cmd_key_split() {
    # get the key and check that it is not already split
    get_gpg_key
    is_unsplit_key || fail "\nThe key is already split.\n"

    # get options
    local opts dongledir backupdir
    backupdir=$(pwd)
    opts="$(getopt -o d:b: -l dongledir:,backupdir: -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -d|--dongledir) dongledir="$2"; shift 2 ;;
            -b|--backupdir) backupdir="$2"; shift 2 ;;
            --) shift; break ;;
        esac
    done
    [[ $err == 0 ]] || fail "Usage:\n$(cmd_key_split_help)"

    # check $dongledir and set $DONGLE
    call_fn set_dongle "$dongledir"

    # check the backup dir
    [[ -d "$backupdir" ]] || fail "Backup directory does not exist: $backupdir"
    [[ -w "$backupdir" ]] || fail "Backup directory is not writable: $backupdir"

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
    mv "$WORKDIR/$partial1" "$backupdir" \
        || fail "Could not copy partial key to the backup dir: $backupdir"
    echo " * Backup partial key saved to: $backupdir/$partial1"

    mkdir -p "$DONGLE/.egpg_key/" \
        || fail "Could not create directory: $DONGLE/.egpg_key/"
    mv "$WORKDIR/$partial2" "$DONGLE/.egpg_key/" \
        || fail "Could not copy partial key to the dongle: $DONGLE/.egpg_key/"
    echo " * Dongle partial key saved to: $DONGLE/.egpg_key/$partial2"

    mv "$WORKDIR/$partial3" "$EGPG_DIR" \
        || fail "Could not copy partial key to: $EGPG_DIR"
    echo " * Local  partial key saved to: $EGPG_DIR/$partial3"

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
