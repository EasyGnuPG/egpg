# Show the details of the contacts.

cmd_contact_list_help() {
    cat <<-_EOF
    ls,list,show,find [<contact>...] [-r,--raw | -c,--colons]
        Show the details of the contacts (optionally in raw format or
        with colons). A list of all the contacts will be displayed if
        no one is selected. A contact can be selected by name, email,
        id, etc.

_EOF
}

cmd_contact_list() {
    local opts raw=0 colons=0
    opts="$(getopt -o rc -l raw,colons -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -r|--raw) raw=1; shift ;;
            -c|--colons) colons=1; shift ;;
            --) shift; break ;;
        esac
    done
    [[ $err -ne 0 ]] && fail "Usage:\n$(cmd_contact_list_help)"
    [[ $raw == 1 ]] && [[ $colons == 1 ]] && fail "Usage:\n$(cmd_contact_list_help)"

    [[ $raw == 1 ]] && \
        gpg --list-keys --with-sig-check "$@" && \
        return

    [[ $colons == 1 ]] && \
        gpg --list-keys --fingerprint --with-sig-check --with-colons "$@" && \
        return

    # display the details of each key
    local ids
    ids=$(gpg --list-keys --with-colons "$@" | grep '^pub' | cut -d: -f5)
    source "$LIBDIR/fn/print_key.sh"
    for id in $ids; do
        echo
        print_key $id
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
