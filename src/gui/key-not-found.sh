gui_key-not-found() {
    yad --title="EasyGnuPG | Key Not Found" \
        --text="No Valid Key Found" \
        --form \
        --columns=4 \
        --field="Generate":FBTN "bash -c 'gui key_gen'" \
        --field="Fetch":FBTN "bash -c 'gui key_fetch'" \
        --field="Restore":FBTN "bash -c 'gui key_restore'" \
        --field="Recover":FBTN "bash -c 'gui key_recover'" \
        --button=gtk-quit \
        --borders=10
    
    # TODO: if key the above succesfully generates keys,
    # go to the gui_main with key details
      
    GPG_KEY=$(get_valid_keys | cut -d' ' -f1)
    [[ -z $GPG_KEY ]] && return 1
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
