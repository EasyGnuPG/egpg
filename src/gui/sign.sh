gui_sign() {
    local file output err

    file=$(yad --file --title="EasyGnuPG | Sign a File")
    [[ -n "$file" ]] || return 0
    if [[ -f "$file.signature" ]]; then
        yesno "File already exists:\n<tt>$file.signature</tt>\n\nDo you want to overwrite it?" || return 0
        rm -f "$file.signature"
    fi

    output=$(call cmd_sign $file 2>&1)
    err=$?
    is_true $DEBUG && echo "$output"
    [[ $err == 0 ]] || message error "$output"

    if [[ -s "$file.signature" ]]; then
        yad --file --filename="$file.signature" &
        sleep 1
        message info "Signature saved as:\n <tt>$file.signature</tt>"
    else
        message error "Failed to sign file."
    fi
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
