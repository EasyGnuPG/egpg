gui_key_share(){
    yesno "Are you sure?\nThis will publish your key <tt>$GPG_KEY</tt> to the keyserver: $KEYSERVER and others" || return 1
    output=$(call cmd_key_share 2>&1)
    err=$?
    is_true $DEBUG && echo "$output"

    # TODO improve messages
    if [[ $err == 0 ]]; then
        message info "Key <tt>$GPG_KEY</tt> shared!".
    else
        fail_details=$(echo "$output" | grep '^gpg:' | uniq | pango_raw)
        message error "Failed to share key <tt>$GPG_KEY</tt>.\n <tt>$fail_details</tt>" 
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