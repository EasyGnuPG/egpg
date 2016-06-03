# Print the details of the given key id.

print_key() {
    local id info fpr uid time1 time2 u start end exp

    id=$1
    info=$(gpg --list-keys --fingerprint --with-sig-check --with-colons $id)

    echo "id: $id"

    # uid
    echo "$info" | grep -E '^uid:[^r]:' | cut -d: -f10 | \
        while read uid; do echo "uid: $uid"; done

    # fpr
    fpr=$(echo "$info" | grep '^fpr:' | cut -d: -f10 | sed 's/..../\0 /g')
    echo "fpr: $fpr"

    # trust
    t=$(echo "$info" | grep '^pub:' | cut -d: -f9)
    case "$t" in u) t='ultimate';; f) t='full';; m) t='marginal';; n) t='none';; *) t='unknown';; esac
    [[ $t == 'unknown' ]] || echo "trust: $t"

    # keys
    echo "$info" | grep -E '^(pub|sub):[^r]:' | cut -d: -f5,6,7,12 | while IFS=: read id time1 time2 u; do
        start=$(date -d @$time1 +%F)
        end='never'; [[ -n $time2 ]] && end=$(date -d @$time2 +%F)
        exp=''; [[ -n $time2 ]] && [ $(date +%s) -gt $time2 ] && exp='expired'
        case "$u" in a) u='auth';; s) u='sign';; e) u='decr';; *) u='sign';; esac
        echo "$u: $id $start $end $exp"
    done

    # verifications
    echo "$info" | grep '^sig:!:' | grep -v "$id" | cut -d: -f5,10 | uniq | \
        while IFS=: read id uid; do echo "certified by: $uid ($id)"; done
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
