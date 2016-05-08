# Display info about the current configuration and settings.

cmd_info_help() {
    cat <<-_EOF
    [info]
        Display info about the current configuration and settings.

_EOF
}

cmd_info() {
    cmd_version
    cat <<-_EOF
EGPG_DIR="$EGPG_DIR"
GNUPGHOME="$GNUPGHOME"
DONGLE="$DONGLE"
KEYSERVER="$KEYSERVER"
GPG_TTY="$GPG_TTY"
SHARE=$SHARE
DEBUG=$DEBUG
_EOF

    local platform_file="$LIBDIR/platform/$PLATFORM.sh"
    [[ -f "$platform_file" ]] && echo "platform_file='$platform_file'"
    local customize_file="$EGPG_DIR/customize.sh"
    [[ -f "$customize_file" ]] && echo "customize_file='$customize_file'"

    call cmd_key_list
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
