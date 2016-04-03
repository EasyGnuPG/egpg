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
    local usage="Usage: $COMMAND <contact> [-p,--publish] [-l,--level <level>] [-t,--time <time>]"
    [[ $err == 0 ]] || fail $usage
    local contact="$1"
    [[ -n $contact ]] || fail $usage

    case ${level,,} in
        unknown) level=0 ;;
        onfaith) level=1 ;;
        casual) level=2 ;;
        extensive) level=3 ;;
        0|1|2|3) ;;
        *) fail "Unknown verification level: $level" ;;
    esac

    local cert_opts="--default-cert-level=$level --default-cert-expire=$time"
    if [[ $publish == 0 ]]; then
        gpg --lsign-key $cert_opts "$contact"
    else
        gpg --sign-key $cert_opts "$contact"
        gpg_send_keys "$contact"
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
