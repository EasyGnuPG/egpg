# Backup the given key id to the given file.

backup_key() {
    local key_id=$1
    local backup_file="$2"

    workdir_make
    mkdir -p "$WORKDIR"/$key_id/
    gpg --armor --export $key_id > "$WORKDIR"/$key_id/$key_id.pub
    for grip in $(get_keygrips $key_id); do
        cp "$GNUPGHOME"/private-keys-v1.d/$grip.key "$WORKDIR"/$key_id/
    done
    cat <<-_EOF > "$WORKDIR"/$key_id/README.txt
Restore private keys by copying *.key to \$GNUPGHOME/private-keys-v1.d/
Restore public keys with: gpg2 --import *.pub
Then set the trust of the key to ultimate with: gpg2 --edit-key <key-id>
_EOF
    tar cz -C "$WORKDIR" --file="$backup_file" $key_id/
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
