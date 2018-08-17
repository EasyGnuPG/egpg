gui_contacts_add(){
    yad --title="EasyGnuPG | Contact Add" \
        --text="Add a contact" \
        --form \
        --columns=4 \
        --field="Fetch":FBTN "bash -c 'gui contacts_fetch'" \
        --field="Search":FBTN "bash -c 'gui contacts_search'" \
        --field="Receive":FBTN "bash -c 'gui contacts_receive'" \
        --field="Import":FBTN "bash -c 'gui contacts_import'" \
        --button=gtk-quit \
        --borders=10
    
    # TODO display details of contact if addition was succesful
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
