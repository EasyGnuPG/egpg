# Change the passphrase.

cmd_key_pass_help() {
    cat <<-_EOF
    pass
        Change the passphrase.

_EOF
}

cmd_key_pass() {
    get_gpg_key
    if is_full_key; then
        gpg --passwd $GPG_KEY 2>/dev/null
    else
        cat <<-_EOF

This key is split into partial keys.
Try first:  $(basename $0) key join
     then:  $(basename $0) key pass
      and:  $(basename $0) key split

_EOF
    fi
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
