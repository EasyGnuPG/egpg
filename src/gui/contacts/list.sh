export tmpfile=$(mktemp)

sel() {
    selected=$1
    echo $selected > $tmpfile
}
export -f sel

gui_contact_details(){
    # basic dummy contact details
    # TODO: add delete export etc. buttons
    [[ -z "$@" ]] || message info "<tt>$(call cmd_contact_list "$1" | pango_raw)</tt>"
}
export -f gui_contact_details

gui_contacts_list(){
    get_contacts_list "$@" | yad --title="EasyGnuPG | Contacts" \
        --list \
        --width=600 \
        --height=450 \
        --column="ID" \
        --column="UID(s)" \
        --button="Details":'bash -c "gui_contact_details $(head -n 1 $tmpfile)"' \
        --button="Add Contact":'bash -c "gui contacts_add"' \
        --button=gtk-quit \
        --select-action='bash -c "sel %s"'\
        --dclick-action='bash -c "gui_contact_details $(head -n 1 $tmpfile)"'\
        --no-rules-hint
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
