gui_key_split(){
    details=$(yad --title="EasyGnuPG | Split Key" \
        --text="Select folders to split key $GPG_KEY:" \
        --form \
        --field="Dongle directory":DIR ""\
        --field="Backup directory":DIR "$(pwd)"\
        --button=gtk-yes \
        --button=gtk-quit \
        --borders=10) || return 1
    
    backup_dir=$(echo $details | cut -d"|" -f1)
    dongle_dir=$(echo $details | cut -d"|" -f2)
    output=$(call cmd_key_split -d $dongle_dir -b $backup_dir 2>&1)
    err=$?
    is_true $DEBUG && echo "$output"

    # TODO improve messages
    if [[ $err == 0 ]]; then
        message info "Key splited successfully"
    else
        fail_details=$(echo "$output" | grep '^gpg:' | uniq | pango_raw)
        message error "Failed to split key $GPG_KEY.\n <tt>$fail_details</tt>" 
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