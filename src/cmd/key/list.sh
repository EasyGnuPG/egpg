# Show the details of the key.

cmd_key_list_help() {
    cat <<-_EOF
    [ls,list,show] [-r,--raw | -c,--colons] [-a,--all]
        Show the details of the key (optionally in raw format or with
        colons). A list of all the keys can be displayed as well
        (including the revoked and expired ones).

_EOF
}

cmd_key_list() {
    local opts raw=0 colons=0 all=0
    opts="$(getopt -o rca -l raw,colons,all -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -r|--raw) raw=1; shift ;;
            -c|--colons) colons=1; shift ;;
            -a|--all) all=1; shift ;;
            --) shift; break ;;
        esac
    done
    [[ $err -ne 0 ]] && fail "Usage:\n$(cmd_key_list_help)"
    [[ $raw == 1 ]] && [[ $colons == 1 ]] && fail "Usage:\n$(cmd_key_list_help)"

    local secret_keys
    if [[ $all == 0 ]]; then
        get_gpg_key
        secret_keys=$GPG_KEY
    else
        secret_keys=$(get_valid_keys)
    fi

    [[ $raw == 1 ]] && \
        gpg --list-keys --with-sig-check $secret_keys && \
        return

    [[ $colons == 1 ]] && \
        gpg --list-keys --fingerprint --with-sig-check --with-colons $secret_keys && \
        return

    # display the details of each key
    source "$LIBDIR/fn/print_key.sh"
    for gpg_key in $secret_keys; do
        echo
        print_key $gpg_key
        echo
    done
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
