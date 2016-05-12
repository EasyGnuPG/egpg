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

    local file=$key_id.tgz
    call_fn backup_key $key_id $file
    [[ -f $file ]] && echo -e "Key saved to: $file"

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
