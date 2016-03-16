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

cmd_contact_trust() {
    local usage="Usage: $COMMAND <contact> [-l,--level <trust-level>]"
    local opts level=3
    opts="$(getopt -o l: -l level: -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -l|--level) level=$2; shift 2 ;;
            --) shift; break ;;
        esac
    done
    [[ $err == 0 ]] || fail $usage
    local contact="$1"
    [[ -n $contact ]] || fail $usage

    case ${level,,} in
        unknown) level=1 ;;
        none) level=2 ;;
        marginal) level=3 ;;
        full) level=4 ;;
        1|2|3|4) ;;
        *) fail "Unknown trust level: $level" ;;
    esac

    local commands=$(echo "trust|$level|quit" | tr '|' "\n")
    script -c "gpg --command-fd=0 --edit-key \"$contact\" <<< \"$commands\" " /dev/null > /dev/null
}
