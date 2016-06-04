# Delete contact(s).

cmd_contact_delete_help() {
    cat <<-_EOF
    rm,del,delete <contact>... [-f,--force]
        Delete the given contact(s).

_EOF
}

cmd_contact_delete() {
    local opts force=0
    opts="$(getopt -o f -l force -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -f|--force) force=1; shift ;;
            --) shift; break ;;
        esac
    done
    [[ $err != 0 ]] && fail "Usage:\n$(cmd_contact_delete_help)"
    [[ -z $1 ]] && fail "Usage:\n$(cmd_contact_delete_help)"

    if [[ $force == 0 ]]; then
        gpg --delete-keys "$@"
    else
        gpg --batch --no-tty --yes --delete-keys "$@"
    fi
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
