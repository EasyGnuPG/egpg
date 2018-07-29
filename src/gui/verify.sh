gui_verify() {
    local file output err msg_type

    file=$(yad \
               --geometry=$file_geo \
               --file \
               --title="EasyGnuPG | Verify Signature"\
               --file-filter="Signature files | *.signature" \
        ) || return 0

    output=$(call cmd_verify "$file" 2>&1)
    err=$?
    is_true $DEBUG && echo "$output"
    [[ $err == 0 ]] && msg_type="info" || msg_type="error"

    message $msg_type "<tt>$(echo "$output" | grep '^gpg:' | pango_raw)</tt>"
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
