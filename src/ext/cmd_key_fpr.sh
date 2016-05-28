# Show the fingerprint of the key.

cmd_key_fpr_help() {
    cat <<-_EOF
    key fpr [-q,--qrencode]
        Show the fingerprint of the key.  With the option --qrencode
        it will be converted to a 2D barcode image.

_EOF
}

cmd_key_fpr() {
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
    [[ $err == 0 ]] || fail "Usage:\n$(cmd_key_fpr_help)"

    local fpr=$(call cmd_key_list | grep '^fpr:' | cut -d: -f2)
    [[ $qr == 0 ]] && echo $fpr && exit 0

    fpr=${fpr// /}
    local key_id=${fpr:24}
    echo $fpr | qrencode -o $key_id.png
    echo -e "\nFingerprint barcode saved to: $key_id.png\n"
    [[ -t 1 ]] && display $key_id.png
    return 0
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
