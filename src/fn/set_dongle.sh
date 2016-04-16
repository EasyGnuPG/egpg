# Check the given dongle and set it to DONGLE.

set_dongle() {
    local dongle="$1"
    if [[ -z "$dongle" ]]; then
        local guess suggest
        guess="$DONGLE"
        [[ -z "$guess" ]] && guess=$(df -h | grep '/dev/sdb1' | sed 's/ \+/:/g' | cut -d: -f6)
        [[ -z "$guess" ]] && guess=$(df -h | grep '/dev/sdc1' | sed 's/ \+/:/g' | cut -d: -f6)
        [[ -n "$guess" ]] && suggest=" [$guess]"
        read -e -p "Enter the dongle directory$suggest: " dongle
        echo
        dongle=${dongle:-$guess}
    fi
    [[ -n "$dongle" ]] || fail "You need a dongle to save the partial key."
    [[ -d "$dongle" ]] || fail "Dongle directory does not exist: $dongle"
    [[ -w "$dongle" ]] || fail "Dongle directory is not writable: $dongle"
    export DONGLE=${dongle%/}

    # set DONGLE on the config file
    sed -i "$EGPG_DIR/config.sh" -e "/DONGLE=/c DONGLE=\"$DONGLE\""
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
