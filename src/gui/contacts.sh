get_contacts_list() {
    local ids output info
    ids=$(gpg --list-keys --with-colons "$@" | grep '^pub' | cut -d: -f5)
    source "$LIBDIR/fn/print_key.sh"
    for id in $ids; do
        info=$(print_key $id)
        uids=$(echo "$info" | grep "^uid:" | cut -d: -f2 | pango_raw)
        output="$output$id\n$uids\n"
    done
    echo -e $output | head -c -1
}

gui_display_list(){
    get_contacts_list "$@" | yad --title="EasyGnuPG | Contacts" \
        --list \
        --width=600 \
        --height=450 \
        --column="ID" \
        --column="UID(s)" \
        --button="Details" \
        --button="Add Contacts"
        --button=gtk-quit
}

gui_contacts_details(){
    message info "<tt>$(call cmd_contact_list "$1" | pango_raw)</tt>"
}

gui_contacts() {
    selection=$(gui_display_list "$@" | cut -d"|" -f1)
    gui_contacts_details "$selection"
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
