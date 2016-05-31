# Read the barcode of the fingerprint and receive the contact details
# from the keyserver network.

cmd_contact_pick_help() {
    cat <<-_EOF
    contact pick [-i,--image <imagefile>]
        Read fingerprint as a 2D barcode from camera or from image
        and receive the given contact from the keyserver network.

_EOF
}

cmd_contact_pick() {
    local opts image fpr
    opts="$(getopt -o i: -l image: -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -i|--image) image="$2"; shift 2 ;;
            --) shift; break ;;
        esac
    done
    [[ $err == 0 ]] || fail "Usage:\n$(cmd_contact_pick_help)"

    # get fingerprint from image or from camera barcode
    if [[ -n "$image" ]]; then
        [[ -f "$image" ]] || fail "File not found: $image"
        fpr=$(zbarimg --raw --quiet $image)
    else
        tmpfile=$(mktemp)
        zbarcam --raw > $tmpfile &
        local pid=$!
        while true; do
            fpr=$(head -n 1 $tmpfile)
            [[ -n $fpr ]] && break
        done
        kill -9 $pid 2>/dev/null
    fi

    # receive the contact with this fingerprint
    fpr=${fpr// /}
    call cmd_contact_receive $fpr
    call cmd_contact_list $fpr
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
