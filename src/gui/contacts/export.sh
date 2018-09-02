gui_contacts_export(){
    local contact_id file output err
    contact_id = $1

    # select a destination filename
    file=$(yad --file --save --title="Export As") || return 1

    if [[ -f "$file" ]]; then
        yesno "File already exists:\n<tt>$file</tt>\n\nDo you want to overwrite it?" || return 0
        rm -f "$file"
    fi

    output=$(call cmd_contact_export $contact_id -o $file)
    err=$?
    is_true $DEBUG && echo "$output"

    if [[ -s "$file" ]] && [[ $err == 0 ]]; then
        yad --file --filename="$file" &
        sleep 1
        message info "Contact exported to:\n <tt>$file</tt>"
    else
        message error "Failed to export contact.\n" "<tt>$(echo "$output" | grep '^gpg:' | uniq)</tt>"
    fi
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