gui_contacts_search(){
    details=$(yad --title="EasyGnuPG | Search Contact" \
        --text="Enter the contact uri" \
        --form \
        --coloumns=2 \
        --field="Name" "" \
        --field="Keyserver" "$KEYSERVER" \
        --button=gtk-yes \
        --button=gtk-quit \
        --borders=10) || return 1

    name=$(echo $details | cut  -d'|' -f1)
    keyserver=$(echo $details | cut  -d'|' -f2)

    # TODO show a processing dialog or something on its line
    # TODO make this work in gui, Currently launcing it in terminal
    # we may need to use the python scripts
    GUI='false'
    gnome-terminal -x egpg contact search $name --keyserver=$keyserver
    GUI='true'
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