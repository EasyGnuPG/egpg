# Certify a verified contact.

cmd_contact_certify_help() {
    cat <<-_EOF
    certify <contact> [-p,--publish] [-l,--level <level>] [-t,--time <time>]
        You have verified the identity of the contact (the details of
        the contact, name, email, etc. are correct and belong to a
        real person).  With the --publish option you also share your
        certification with the world, so that your friends may rely on
        it if they wish.  The levels of certification are: 0
        (unknown), 1 (onfaith), 2 (casual), 3 (extensive).  The time
        of certification can be: 0 (unlimited), <n>d (<n> days), <n>w
        (<n> weeks), <n>m (<n> months), <n>y (<n> years).

_EOF
}

cmd_contact_certify() {
    local opts publish=0 level=2 time='1y'
    opts="$(getopt -o pl:t: -l publish,level:,time: -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -p|--publish) publish=1; shift ;;
            -l|--level) level=$2; shift 2 ;;
            -t|--time) time=$2; shift 2 ;;
            --) shift; break ;;
        esac
    done
    [[ $err == 0 ]] || fail "Usage:\n$(cmd_contact_certify_help)"
    local contact="$1"
    [[ -n $contact ]] || fail "Usage:\n$(cmd_contact_certify_help)"

    case ${level,,} in
        unknown) level=0 ;;
        onfaith) level=1 ;;
        casual) level=2 ;;
        extensive) level=3 ;;
        0|1|2|3) ;;
        *) fail "Unknown verification level: $level" ;;
    esac

    local fingerprint=$(get_fingerprint "$contact")
    local homedir="$GNUPGHOME"
    gnupghome_setup
    gpg --batch --default-cert-level=$level --default-cert-expire=$time \
        --quick-sign-key $fingerprint
    gpg --armor --export $fingerprint > "$WORKDIR"/contact.asc
    gpg --homedir="$homedir" --import "$WORKDIR"/contact.asc
    gnupghome_reset

    [[ $publish == 0 ]] || call_fn gpg_send_keys "$contact"
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
