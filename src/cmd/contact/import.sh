# Import (add) contact(s) from file.

cmd_contact_import_help() {
    cat <<-_EOF
    imp,import,add <file>
        Import (add) contact(s) from file.

_EOF
}

cmd_contact_import() {
    local file="$1"
    [[ -n "$file" ]] || fail "Usage:\n$(cmd_contact_import_help)"
    [[ -f "$file" ]] || fail "Cannot find file: $file"

    # import
    echo "Importing contacts from file: $file"
    gpg --import "$file"
}

#
# This file is part of EasyGnuPG.  EasyGnuPG is a wrapper around GnuPG
# to simplify its operations.  Copyright (C) 2016 Dashamir Hoxha
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
