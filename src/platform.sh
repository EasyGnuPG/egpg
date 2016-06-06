# Platform dependent functions.

gpg() {
    local opts='--quiet'
    [[ -t 0 ]] || opts+=' --no-tty'
    if is_true $DEBUG; then
        opts+=' --status-fd=2'
        echo "debug: $(which gpg2) $opts $@" 1>&2
    fi
    "$(which gpg2)" $opts "$@"
}
export -f gpg

getopt() { "$(which getopt)" "$@" ; }
export -f getopt

shred() { "$(which shred)" -f -z -u "$@" ; }
export -f shred

haveged_start() {
    [[ -z "$(ps -ax | grep -v grep | grep -v defunct | grep haveged)" ]] || return 0
    echo "
Starting haveged which will greatly improve the speed of creating
a new key, by improving the entropy generation of the system."
    sudo haveged -w 1024
    echo
    HAVEGED_STARTED="true"
}
haveged_stop() {
    [[ -z $HAVEGED_STARTED ]] && return 0
    sudo killall haveged
}

# Create a safe temp directory on $WORKDIR.
workdir_make() {
    [[ -z "$WORKDIR" ]] || return 0

    local tmpdir="${TMPDIR:-/tmp}"
    [[ -d /dev/shm && -w /dev/shm && -x /dev/shm ]] && tmpdir="/dev/shm"
    WORKDIR="$(mktemp -d "$tmpdir/$PROGRAM.XXXXXXXXXXXXX")"

    trap workdir_clear INT TERM EXIT
}
workdir_clear() {
    [[ -n "$WORKDIR" ]] || return 0
    [[ -d "$WORKDIR" ]] && find "$WORKDIR" -type f -exec shred {} +
    [[ -d "$WORKDIR" ]] && rm -rf "$WORKDIR"
    unset WORKDIR
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
