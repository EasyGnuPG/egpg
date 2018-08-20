gui_key_main(){
    # TODO: Think about the description if it is necessary
    # also do we require any more details??
    yad --text="$(key_info $GPG_KEY)" \
        --selectable-labels \
        --borders=10 \
        --form \
        --columns=4 \
        --field="Delete":FBTN "bash -c 'gui key_delete'" \
        --field="Backup":FBTN "bash -c 'gui key_backup '" \
        --field="Pass":FBTN "bash -c 'gui key_pass '" \
        --field="Renew":FBTN "bash -c 'gui key_renew '" \
        --field="Revcert":FBTN "bash -c 'gui key_revcert '" \
        --field="Revoke":FBTN "bash -c 'gui key_revoke '" \
        --field="Share":FBTN "bash -c 'gui key_share '" \
        --field="Split":FBTN "bash -c 'gui key_split '" \
        --button=gtk-quit
}

#
# This file is part of EasyGnuPG.  EasyGnuPG is a wrappe`r around GnuPG
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
