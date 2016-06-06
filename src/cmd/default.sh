# Use the default GNUPGHOME
cmd_default_help() {
    cat <<-_EOF
    default
        Use the default GNUPGHOME.

_EOF

}

cmd_default() {
    [[ "$GNUPGHOME" == "$ENV_GNUPGHOME" ]] && fail "It is already using the default GNUPGHOME."

    sed -i "$EGPG_DIR/config.sh" -e "/GNUPGHOME=/c GNUPGHOME=default"
    mv -v "$ENV_GNUPGHOME" "$ENV_GNUPGHOME-old"
    mv -v "$GNUPGHOME" "$ENV_GNUPGHOME"
    export GNUPGHOME="$ENV_GNUPGHOME"
    gpg-connect-agent reloadagent /bye
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
