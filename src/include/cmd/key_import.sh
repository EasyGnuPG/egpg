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

cmd_key_import() {
    assert_no_valid_key

    local file="$1"
    [[ -n "$file" ]] || fail "Usage: $COMMAND  <file>"
    [[ -f "$file" ]] || fail "Cannot find file: $file"

    # import
    echo "Importing key from file: $file"
    gpg --import "$file"

    # set trust to 'ultimate'
    get_gpg_key
    local commands=$(echo "trust|5|y|quit" | tr '|' "\n")
    script -c "gpg --batch --command-fd=0 --key-edit $GPG_KEY <<< \"$commands\" " /dev/null > /dev/null
}
