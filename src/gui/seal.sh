gui_seal() {
    local file output err

    file=$(yad --file --title="EasyGnuPG | Seal a File")
    [[ -n "$file" ]] || return 0
    if [[ -f "$file.sealed" ]]; then
        yesno "File already exists:\n<tt>$file.sealed</tt>\n\nDo you want to overwrite it?" || return 0
        rm -f "$file.sealed"
    fi

    a=$(select_contacts | cut -d"|" -f1)
    output=$(call cmd_seal "$file" $a 2>&1)
    err=$?
    is_true $DEBUG && echo "$output" > /dev/tty

    if [[ -s "$file.sealed" ]] && [[ $err == 0 ]]; then
        yad --file --filename="$file.sealed" &
        sleep 1
        message info "File saved as:\n <tt>$file.sealed</tt>"
    else
        message error "Failed to seal file.\n" "<tt>$(echo "$output" | grep '^gpg:' | pango_raw)</tt>"
    fi
}

#
# This file is part of EasyGnuPG.  EasyGnuPG is a wrapper around GnuPG
# to simplify its operations.  Copyright (C) 2018 Dashamir Hoxha
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
