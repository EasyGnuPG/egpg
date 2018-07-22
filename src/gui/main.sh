# The main interface of the application.

gui_main() {
    get_gpg_key
    yad --title="EasyGnuPG" \
        --text="$(key_info $GPG_KEY)" \
        --selectable-labels \
        --borders=10 \
        --form \
        --columns=4 \
        --field="Sign File":FBTN "bash -c 'gui sign'" \
        --field="Verify File Signature":FBTN "bash -c 'gui verify'" \
        --field="Seal File(s)":FBTN "bash -c 'gui seal'" \
        --field="Open Sealed File(s)":FBTN "bash -c 'gui open'" \
        --field="Manage Key":FBTN "bash -c ' gui key'" \
        --field="Manage Contacts":FBTN "bash -c 'gui contacts'" \
        --field="Settings":FBTN "bash -c 'gui settings'" \
        --button=gtk-quit
       # &>/dev/null
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
