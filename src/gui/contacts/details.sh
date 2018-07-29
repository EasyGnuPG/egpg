gui_contacts_details(){
    [[ -z "$@" ]] \
    && message error "<tt>Please select a contact first.<tt>" \
    || cert_status="Uncertify"; yad --text="<big><tt> \
                                            $(call cmd_contact_list "$1" \
                                            | pango_raw \
                                            | sed 's/[^ ]*/\<b\>&\<\/b\>/') \
                                            </tt></big>" \
           --selectable-labels \
           --borders=10 \
           --form \
           --columns=4 \
           --field="Delete":FBTN "bash -c 'gui contacts_delete'" \
           --field="$cert_status":FBTN "bash -c 'gui contacts_certify'" \
           --field="Trust":FBTN "bash -c 'gui contacts_trust'" \
           --field="Export":FBTN "bash -c 'gui contacts_export'" \
           --button=gtk-quit
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
