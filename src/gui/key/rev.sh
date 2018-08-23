gui_key_rev(){
    get_gpg_key
    revcert=$(yad --title="EasyGnuPG | Revoke Key" \
            --text="Select a revocation certificate" \
            --form \
            --field="select file":FL "$GNUPGHOME/openpgp-revocs.d/$FPR.rev" \
            --button=gtk-yes:0 \
            --button=gtk-quit:1 \
            --borders=10 | cut -d'|' -f1) || return 1
    
    output=$(call cmd_key_rev $revcert 2>&1)
    err=$?
    is_true $DEBUG && echo "$output"

    # TODO improve messages
    # TODO maybe add a confirmation message if required
    if [[ $err == 0 ]]; then
        message info "Key successfully revoked!"
        # TODO open contact list of the fetched contacts(if possible)
        # else open the complete contact list
    else
        fail_details=$(echo "$output" | grep '^gpg:' | uniq | pango_raw)
        message error "Failed to revoke keys.\n <tt>$fail_details</tt>" 
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