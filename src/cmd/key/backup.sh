# Backup key to file.

cmd_key_backup_help() {
    cat <<-_EOF
    backup [<key-id>]
        Backup key to file.

_EOF
}

cmd_key_backup() {
    local key_id="$1"
    [[ -z $key_id ]] && get_gpg_key && key_id=$GPG_KEY

    gnupghome_setup
    gpg --armor --export $key_id > $key_id.key
    gpg --armor --export-secret-keys $key_id >> $key_id.key
    gnupghome_reset
    echo "Key saved to: $key_id.key"
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
