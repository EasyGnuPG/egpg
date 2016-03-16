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

gpg() { "$(which gpg2)" $GPG_OPTS "$@" 2>/dev/null ; }
export -f gpg

getopt() { "$(which getopt)" "$@" ; }
export -f getopt

shred() { "$(which shred)" -f -z -u "$@" ; }
export -f shred

haveged_start() {
    [[ -z "$(ps ax | grep -v grep | grep haveged)" ]] || return
    echo "
Starting haveged which will greatly improve the speed of creating
a new key, by improving the entropy generation of the system."
    sudo haveged -w 1024
    echo
    HAVEGED_STARTED="true"
}

haveged_stop() {
    [[ -z $HAVEGED_STARTED ]] && return
    sudo killall haveged
}

make_workdir() {
    local warn=1
    [[ $1 == "nowarn" ]] && warn=0
    local template="$PROGRAM.XXXXXXXXXXXXX"
    if [[ -d /dev/shm && -w /dev/shm && -x /dev/shm ]]; then
        WORKDIR="$(mktemp -d "/dev/shm/$template")"
        remove_tmpfile() {
            rm -rf "$WORKDIR"
        }
        trap remove_tmpfile INT TERM EXIT
    else
        if [[ $warn -eq 1 ]]; then
            yesno "$(cat <<- _EOF
Your system does not have /dev/shm, which means that it may
be difficult to entirely erase the temporary non-encrypted
password file after editing.

Are you sure you would like to continue?
_EOF
                    )" || return
        fi
        WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/$template")"
        shred_tmpfile() {
            find "$WORKDIR" -type f -exec shred {} +
            rm -rf "$WORKDIR"
        }
        trap shred_tmpfile INT TERM EXIT
    fi
}
