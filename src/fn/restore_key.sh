# Restore key from the given backup file.

restore_key() {
    local file="$1"

    workdir_make
    tar xz -C "$WORKDIR" --file="$file" || return 1

    # restore private keys
    mkdir -p "$GNUPGHOME"/private-keys-v1.d/
    chmod 700 "$GNUPGHOME"/private-keys-v1.d/
    cp "$WORKDIR"/*/*.key "$GNUPGHOME"/private-keys-v1.d/

    # restore public keys
    local pub_key=$(ls "$WORKDIR"/*/*.pub)
    gpg --import "$pub_key" || fail "Failed to import public key."

    # set trust to 'ultimate'
    local key_id=$(basename "${pub_key%.pub}")
    local commands=$(echo "trust|5|y|quit" | tr '|' "\n")
    echo -e "$commands" | gpg --no-tty --batch --command-fd=0 --edit-key $key_id
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
