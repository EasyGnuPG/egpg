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
    local file=$(ls "$EGPG_DIR"/$GPG_KEY.key.* 2>/dev/null)
    [[ -n "$file" ]] && fail "There is already a partial key for $GPG_KEY on $EGPG_DIR"

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
    [[ $err -eq 0 ]] || fail "Usage:\n$(cmd_key_split_help)"

    # get the dongle dir
    if [[ -z "$dongledir" ]]; then
        local guess suggest
        guess="$DONGLE"
        [[ -z "$guess" ]] && guess=$(df -h | grep '/dev/sdb1' | sed 's/ \+/:/g' | cut -d: -f6)
        [[ -z "$guess" ]] && guess=$(df -h | grep '/dev/sdc1' | sed 's/ \+/:/g' | cut -d: -f6)
        [[ -n "$guess" ]] && suggest=" [$guess]"
        echo
        read -e -p "Enter the dongle directory$suggest: " dongledir
        echo
        dongledir=${dongledir:-$guess}
    fi
    [[ -n "$dongledir" ]] || fail "You need a dongle to save the partial key."
    [[ -d "$dongledir" ]] || fail "Dongle directory does not exist: $dongledir"
    [[ -w "$dongledir" ]] || fail "Dongle directory is not writable: $dongledir"
    dongledir=${dongledir%/}

    # check the backup dir
    [[ -d "$backupdir" ]] || fail "Backup directory does not exist: $backupdir"
    [[ -w "$backupdir" ]] || fail "Backup directory is not writable: $backupdir"


    # export key to a tmp dir
    make_workdir
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
    echo " - Backup partial key saved to: $backupdir/$partial1"
    mkdir -p "$dongledir/.egpg_key/" \
        || fail "Could not create directory: $dongledir/.egpg_key/"
    mv "$WORKDIR/$partial2" "$dongledir/.egpg_key/" \
        || fail "Could not copy partial key to the dongle: $dongledir/.egpg_key/"
    echo " - Dongle partial key saved to: $dongledir/.egpg_key/$partial2"
    mv "$WORKDIR/$partial3" "$EGPG_DIR" \
        || fail "Could not copy partial key to: $EGPG_DIR"
    echo " - Local partial key saved to:  $EGPG_DIR/$partial3"
    rm -rf "$WORKDIR"    # clean up

    # set DONGLE on the config file
    sed -i "$EGPG_DIR/config.sh" -e "/DONGLE=/c DONGLE=\"$dongledir\""

    # delete the secret key
    local fingerprint=$(gpg --list-keys --with-colons --fingerprint $GPG_KEY | grep '^fpr:' | cut -d: -f10)
    gpg --batch --delete-secret-keys $fingerprint

    # display a notice
    cat <<-_EOF

The key was split successfully. Whenever you need to use the key (to
sign, seal, open, etc.) connect first the dongle to the PC.

Make sure to move the backup out of the PC (for example on the
cloud). You will need it to recover the key in case that you loose the
dongle or the PC (but it cannot help you if you loose both of them).

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
