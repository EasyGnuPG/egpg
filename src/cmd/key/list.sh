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
    [[ $err -ne 0 ]] && echo "Usage: $COMMAND [-r,--raw | -c,--colons] [-a,--all]" && return
    [[ $raw == 1 ]] && [[ $colons == 1 ]] && echo "Usage: $COMMAND [-r,--raw | -c,--colons]" && return

    local secret_keys
    if [[ $all == 0 ]]; then
        get_gpg_key
        secret_keys=$GPG_KEY
    else
        secret_keys=$(gpg --list-secret-keys --with-colons | grep '^sec' | cut -d: -f5)
    fi

    [[ $raw == 1 ]] && \
        gpg --list-keys $secret_keys && \
        return

    [[ $colons == 1 ]] && \
        gpg --list-keys --fingerprint --with-colons $secret_keys && \
        return

    # display the details of each key
    for gpg_key in $secret_keys; do
        echo
        _display_key_details $gpg_key
        echo
    done
}

_display_key_details() {
    local gpg_key=$1
    local keyinfo
    keyinfo=$(gpg --list-keys --fingerprint --with-colons $gpg_key)

    # get fingerprint and user identity
    local fpr uid
    fpr=$(echo "$keyinfo" | grep '^fpr:' | cut -d: -f 10 | sed 's/..../\0 /g')
    uid=$(echo "$keyinfo" | grep '^uid:' | cut -d: -f 10)
    echo -e "id: $gpg_key\nuid: $uid\nfpr: $fpr"

    local line time1 time2 id start end exp rev
    declare -A keys
    # get the details of the main (cert) key
    line=$(echo "$keyinfo" | grep '^pub:')
    if [[ -n "$line" ]]; then
        id=$(echo $line | cut -d: -f5)
        time1=$(echo $line | cut -d: -f6)
        time2=$(echo $line | cut -d: -f7)
        start=$(date -d @$time1 +%F)
        end=$(date -d @$time2 +%F)
        exp=''; [ $(date +%s) -gt $time2 ] && exp='expired'
        rev=''; [[ $(echo $line | grep '^pub:r:') ]] && rev='revoked'
        echo "cert: $id $start $end $exp $rev"
    fi

    # get the details of the auth key
    line=$(echo "$keyinfo" | grep '^sub:' | grep ':a:')
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
    line=$(echo "$keyinfo" | grep '^sub:' | grep ':s:')
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
    line=$(echo "$keyinfo" | grep '^sub:' | grep ':e:')
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
