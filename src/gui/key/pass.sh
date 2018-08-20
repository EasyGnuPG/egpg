gui_key_pass(){
    # TODO: maybe we should give option for removing passphrase
    # though it would require change in cmd_key_pass

    # This is same as cli part. TODO: just change the pinentry to gui pinentry
    output=$(call cmd_key_pass 2>&1)
    err=$?
    is_true $DEBUG && echo "$output"

    # TODO improve messages
    if [[ $err == 0 ]]; then
        message info "Passphrase changed"
    else
        fail_details=$(echo "$output" | grep '^gpg:' | uniq | pango_raw)
        message error "Failed to change passphrase for <tt>$GPG_KEY</tt>.\n <tt>$fail_details</tt>" 
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