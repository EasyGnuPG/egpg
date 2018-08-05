gui_key_gen(){
    # TODO: Improve the no-passphrase with using checkbox
    key_details="$(yad --title="EasyGnuPG | Generate Key" \
           --text="Enter details for the key\nLeave passphrases fields blank for no passphrase" \
           --borders=10 \
           --form \
           --field="Email" \
           --field="Name" \
           --field="Passphrase":H \
           --field="Confirm passphrase":H \
           --button="Cancel!gtk-no:1" \
           --button="Generate!gtk-yes:0")" || return 1

    email="$(echo "$key_details" | cut -d"|" -f1)"
    name="$(echo "$key_details" | cut -d"|" -f2)"
    passphrase="$(echo "$key_details" | cut -d"|" -f3)"
    confirm="$(echo "$key_details" | cut -d"|" -f4)"

    [[ -z $email ]] \
    && message error "Email cannot be empty"  && return 0

    [[ "$passphrase" != "$confirm" ]] \
    && message error "The entered passphrases do not match."  && return 0

    [[ -z "$passphrase" ]] &&  passphrase="--no-passphrase"

    call cmd_key_gen "$email" "$name" "$passphrase"
}

#
# This file is part of EasyGnuPG.  EasyGnuPG is a wrapper around GnuPG
# to simplify its operations.  Copyright (C) 2018 Dashamir Hoxha,
# Divesh Uttamchandani
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
