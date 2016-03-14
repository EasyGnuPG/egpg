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
    local usage="Usage: $COMMAND [<contact>] [-r,--raw | -c,--colons]"
    [[ $err -ne 0 ]] && echo $usage && return
    [[ $raw == 1 ]] && [[ $colons == 1 ]] && echo $usage && return

    [[ $raw == 1 ]] && \
        gpg --list-keys "$@" && \
        return

    [[ $colons == 1 ]] && \
        gpg --list-keys --fingerprint --with-colons "$@" && \
        return

    # display the details of each key
    local ids
    ids=$(gpg --list-keys --with-colons "$@" | grep '^pub' | cut -d: -f5)
    for id in $ids; do
        echo
        _display_contact_details $id
        echo
    done
}

_display_contact_details() {
    local id=$1
    local info
    info=$(gpg --list-keys --fingerprint --with-colons $id)

    # get fingerprint and user identity
    local fpr uid
    fpr=$(echo "$info" | grep '^fpr:' | cut -d: -f 10 | sed 's/..../\0 /g')
    uid=$(echo "$info" | grep '^uid:' | cut -d: -f 10)
    echo -e "id: $id\nuid: $uid\nfpr: $fpr"

    local line time1 time2 id start end exp rev
    declare -A keys
    # get the details of the main (cert) key
    line=$(echo "$info" | grep '^pub:')
    if [[ -n "$line" ]]; then
        id=$(echo $line | cut -d: -f5)
        time1=$(echo $line | cut -d: -f6)
        time2=$(echo $line | cut -d: -f7)
        [[ -n $time1 ]] && start=$(date -d @$time1 +%F)
        [[ -n $time2 ]] && end=$(date -d @$time2 +%F)
        exp=''; [[ -n $time2 ]] && [ $(date +%s) -gt $time2 ] && exp='expired'
        rev=''; [[ $(echo $line | grep '^pub:r:') ]] && rev='revoked'
        echo "cert: $id $start $end $exp $rev"
    fi

    # get the details of the auth key
    line=$(echo "$info" | grep '^sub:' | grep ':a:')
    if [[ -n "$line" ]]; then
        id=$(echo $line | cut -d: -f5)
        time1=$(echo $line | cut -d: -f6)
        time2=$(echo $line | cut -d: -f7)
        start=$(date -d @$time1 +%F)
        end=$(date -d @$time2 +%F)
        exp=''; [ $(date +%s) -gt $time2 ] && exp='expired'
        rev=''; [[ $(echo $line | grep '^sub:r:') ]] && rev='revoked'
        echo "auth: $id $start $end $exp $rev"
    fi

    # get the details of the sign key
    line=$(echo "$info" | grep '^sub:' | grep ':s:')
    if [[ -n "$line" ]]; then
        id=$(echo $line | cut -d: -f5)
        time1=$(echo $line | cut -d: -f6)
        time2=$(echo $line | cut -d: -f7)
        start=$(date -d @$time1 +%F)
        end=$(date -d @$time2 +%F)
        exp=''; [ $(date +%s) -gt $time2 ] && exp='expired'
        rev=''; [[ $(echo $line | grep '^sub:r:') ]] && rev='revoked'
        echo "sign: $id $start $end $exp $rev"
    fi

    # get the details of the encrypt key
    line=$(echo "$info" | grep '^sub:' | grep ':e:')
    if [[ -n "$line" ]]; then
        id=$(echo $line | cut -d: -f5)
        time1=$(echo $line | cut -d: -f6)
        time2=$(echo $line | cut -d: -f7)
        start=$(date -d @$time1 +%F)
        end=$(date -d @$time2 +%F)
        exp=''; [ $(date +%s) -gt $time2 ] && exp='expired'
        rev=''; [[ $(echo $line | grep '^sub:r:') ]] && rev='revoked'
        echo "encr: $id $start $end $exp $rev"
    fi
}
