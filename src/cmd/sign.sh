# Sign a file.

cmd_sign_help() {
    cat <<-_EOF
    sign <file>
        Sign a file. The signature will be saved to <file.signature>.

_EOF
}

cmd_sign() {
    local file="$1" ; shift
    [[ -z "$file" ]] && fail "Usage:\n$(cmd_sign_help)"
    [[ -f "$file" ]] || fail "Cannot find file '$file'"

    # sign
    gnupghome_setup
    gpg --local-user $GPG_KEY \
        --detach-sign --armor --output "$file.signature" "$file"
    gnupghome_reset
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
