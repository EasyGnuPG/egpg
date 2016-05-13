# Revoke the certification of a contact.

cmd_contact_uncertify_help() {
    cat <<-_EOF
    uncertify <contact>
        Revoke the certification of a contact.

_EOF
}

cmd_contact_uncertify() {
    echo "Try the command: $(basename $0) gpg --key-edit $@"
    echo "and then use the commands: revsig and delsig"
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
