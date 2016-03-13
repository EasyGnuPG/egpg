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

cmd_key_renew() {
    local opts cert=0 auth=0 sign=0 encrypt=0
    opts="$(getopt -o case -l cert,auth,sign,encrypt -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -c|--cert) cert=1; shift ;;
            -a|--auth) auth=1; shift ;;
            -s|--sign) sign=1; shift ;;
            -e|--encrypt) encrypt=1; shift ;;
            --) shift; break ;;
        esac
    done
    [[ $err -ne 0 ]] && echo "Usage: $COMMAND [<time-length>] [-c,--cert] [-a,--auth] [-s,--sign] [-e,--encrypt]" && return
    [ $cert == 0 ] && [ $auth == 0 ] && [ $sign == 0 ] && [ $encrypt == 0 ] \
        && cert=1

    local time=${1:-1m}
    local commands=''
    [ $cert == 1 ] && commands+=";expire;$time;y"
    [ $auth == 1 ] && commands+=";key 1;expire;$time;y;key 1"
    [ $sign == 1 ] && commands+=";key 2;expire;$time;y;key 2"
    [ $encrypt == 1 ] && commands+=";key 3;expire;$time;y;key 3"
    commands+=";save"
    commands=$(echo "$commands" | tr ';' "\n")

    get_gpg_key
    script -c "gpg --command-fd=0 --key-edit $GPG_KEY <<< \"$commands\" " /dev/null > /dev/null
    gpg_send_keys $GPG_KEY

    call cmd_key_list
}
