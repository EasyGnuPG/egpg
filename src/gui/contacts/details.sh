gui_contacts_details(){
    local contact_id details_text
    contact_id=$1
    details_text="<big><tt> \
                $(call cmd_contact_list "$contact_id" | pango_raw | sed 's/[^ ]*/\<b\>&\<\/b\>/') \
                </tt></big>"

    [[ -z "$contact_id" ]] \
    && message error "<tt>Please select a contact first.</tt>" \
    || yad --text="$details_text" \
           --selectable-labels \
           --borders=10 \
           --form \
           --columns=4 \
           --field="Delete":FBTN "bash -c 'gui contacts_delete $contact_id'" \
           --field="Certify":FBTN "bash -c 'gui contacts_certify $contact_id'" \
           --field="Trust":FBTN "bash -c 'gui contacts_trust $contact_id'" \
           --field="Export":FBTN "bash -c 'gui contacts_export $contact_id'" \
           --button=gtk-quit
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
