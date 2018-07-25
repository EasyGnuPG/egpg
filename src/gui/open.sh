gui_open() {
    local file output err msg_type target_file

    file=$(yad \
               --file \
               --title="EasyGnuPG | Open file"\
               --file-filter="Sealed files | *.sealed" \
        ) || return 0

    target_file="${file%.*}"

    if [[ -f  "$target_file" ]]; then
        yesno "File already exists:\n<tt>$target_file</tt>\n"\
              "\nDo you want to overwrite it?" || return 0
        rm -f "$target_file"
    fi
    
    output=$(call cmd_open "$file" 2>&1)
    err=$?
    is_true $DEBUG && echo "$output"
    
    if [[ -s "$target_file" ]] && [[ $err == 0 ]]; then
        xdg-open $(yad --file --filename="$target_file" \
                   --button=gtk-cancel:1 --button="View!gtk-open:0") &
        sleep 1
        message info "File saved as:\n <tt>$target_file</tt>"
    else
        message error "Failed to open file.\n" \
                      "<tt>$(echo "$output" | grep '^gpg:' | uniq | pango_raw)</tt>"
    fi

    return $err
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
