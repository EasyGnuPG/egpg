# Trust contact to verify and certify correctly others.

cmd_contact_trust_help() {
    cat <<-_EOF
    trust <contact> [-l,--level <trust-level>]
        You have verified the identity of the contact and you also
        trust him to be able to verify correctly and honestly the
        identities of other people. The trust levels are:
        4 (full), 3 (marginal), 2 (none), 1 (unknown)

_EOF
}

cmd_contact_trust() {
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
    [[ $err == 0 ]] || fail "Usage:\n$(cmd_contact_trust_help)"
    local contact="$1"
    [[ -n $contact ]] || fail "Usage:\n$(cmd_contact_trust_help)"

    case ${level,,} in
        unknown) level=1 ;;
        none) level=2 ;;
        marginal) level=3 ;;
        full) level=4 ;;
        1|2|3|4) ;;
        *) fail "Unknown trust level: $level" ;;
    esac

    local commands=$(echo "$level|quit" | tr '|' "\n")
    echo -e "$commands" | gpg --no-tty --command-fd=0 --edit-key "$contact" trust 2>/dev/null
    call cmd_contact_list "$contact" | grep -e "^uid:" -e "^trust:" -e "^\$"
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
