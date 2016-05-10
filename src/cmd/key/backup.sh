# Backup key to file.

cmd_key_backup_help() {
    cat <<-_EOF
    backup [<key-id>] [-q,--qrencode]
        Backup key to text file. If the option --qrencode is given,
        then a PDF file with 3D barcode will be generated as well.

_EOF
}

cmd_key_backup() {
    local opts qr=0
    opts="$(getopt -o q -l qrencode -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -q|--qrencode) qr=1; shift ;;
            --) shift; break ;;
        esac
    done
    [[ $err == 0 ]] || fail "Usage:\n$(cmd_key_backup_help)"

    local key_id="$1"
    [[ -z $key_id ]] && get_gpg_key && key_id=$GPG_KEY

    gnupghome_setup
    mkdir -p "$WORKDIR"/$key_id/
    gpg --armor --export $key_id > "$WORKDIR"/$key_id/$key_id.pub
    for grip in $(get_keygrips $GPG_KEY); do
        cp "$GNUPGHOME"/private-keys-v1.d/$grip.key "$WORKDIR"/$key_id/
    done
    cat <<-_EOF > "$WORKDIR"/$key_id/README.txt
Restore private keys by copying *.key to \$GNUPGHOME/private-keys-v1.d/
Restore public keys with: gpg2 --import *.pub
Then set the trust of the key to ultimate with: gpg2 --edit-key <key-id>
_EOF
    tar cz -C "$WORKDIR" --file=$key_id.tgz $key_id/
    gnupghome_reset
    echo -e "Key saved to: $key_id.tgz"

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
