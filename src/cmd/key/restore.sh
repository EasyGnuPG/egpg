# Restore key from file.

cmd_key_restore_help() {
    cat <<-_EOF
    restore <file.tgz>
        Restore key from backup file.

_EOF
}

cmd_key_restore() {
    assert_no_valid_key

    local file="$1"
    [[ -n "$file" ]] || fail "Usage:\n$(cmd_key_restore_help)"
    [[ -f "$file" ]] || fail "Cannot find file: $file"

    echo "Restoring key from file: $file"
    call_fn restore_key $file 2>/dev/null || fail "Could not restore the key."
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
