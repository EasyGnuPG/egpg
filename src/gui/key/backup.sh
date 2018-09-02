gui_key_backup(){
    local details qrencode output err
    details=$(yad --title="EasyGnuPG | Key Backup" \
            --text="KeyID $GPG_KEY" \
            --form \
            --field="QR ENCODE":CHK\
            --button=gtk-yes \
            --button=gtk-quit \
            --borders=10) || return 1

    qrencode=$(echo $details | cut -d'|' -f1)
    is_true $qrencode && qrencode='--qrencode' || qrencode=''
    output=$(call cmd_key_backup "$GPG_KEY" $qrencode 2>&1)
    err=$?
    is_true $DEBUG && echo "$output"

    # TODO improve messages
    if [[ $err == 0 ]]; then
        # TODO: maybe we can also ask/show the backup file location
        message info "$output"
    else
        fail_details=$(echo "$output" | grep '^gpg:' | uniq | pango_raw)
        message error "Failed to backup key $GPG_KEY.\n <tt>$fail_details</tt>" 
        return 1
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