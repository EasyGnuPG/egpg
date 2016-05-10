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

    workdir_make
    tar xz -C "$WORKDIR" --file=$file || fail "Could not open archive: $file"
    # restore private keys
    cp "$WORKDIR"/*/*.key "$GNUPGHOME"/private-keys-v1.d/
    # restore public keys
    local pub_key=$(ls "$WORKDIR"/*/*.pub)
    gpg --import "$pub_key" || fail "Failed to import public key."

    # set trust to 'ultimate'
    local key_id=$(basename "${pub_key%.pub}")
    local commands=$(echo "trust|5|y|quit" | tr '|' "\n")
    echo -e "$commands" | gpg --no-tty --batch --command-fd=0 --edit-key $key_id
    workdir_clear
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
