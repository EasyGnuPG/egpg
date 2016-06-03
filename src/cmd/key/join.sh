# Join two partial keys into a normal key.

cmd_key_join_help() {
    cat <<-_EOF
    join
        Join two partial keys into a full key and delete the partials.

_EOF
}

cmd_key_join() {
    get_gpg_key    # get $GPG_KEY
    is_full_key && fail "\nThe key is not split.\n"

    # get the partial keys
    local partial1 partial2
    partial1=$(cd "$GNUPGHOME"; ls $GPG_KEY.key.[0-9][0-9][0-9] 2>/dev/null)
    [[ -f "$GNUPGHOME"/$partial1 ]] \
        || fail "Could not find partial key for $GPG_KEY on $GNUPGHOME"
    [[ -d "$DONGLE" ]] \
        || fail "The dongle directory not found: $DONGLE\nMake sure that the dongle is connected and mounted."
    [[ -d "$DONGLE"/.gnupg/ ]] \
        || fail "Directory not found: $DONGLE/.gnupg"
    partial2=$(cd "$DONGLE"/.gnupg; ls $GPG_KEY.key.[0-9][0-9][0-9] 2>/dev/null)
    [[ -f "$DONGLE"/.gnupg/$partial2 ]] \
        || fail "Could not find partial key for $GPG_KEY on $DONGLE/.gnupg/"

    # combine partial keys and import the full key
    workdir_make
    cp "$GNUPGHOME"/$partial1 "$WORKDIR/"
    cp "$DONGLE"/.gnupg/$partial2 "$WORKDIR/"
    gfcombine "$WORKDIR"/$partial1 "$WORKDIR"/$partial2
    call_fn restore_key "$WORKDIR"/$GPG_KEY.key 2>/dev/null || fail "Could not import the combined key."
    workdir_clear

    # remove the partials
    rm -f "$GNUPGHOME"/$partial1
    rm -f "$DONGLE"/.gnupg/$partial2
    rm -f $GPG_KEY.key.[0-9][0-9][0-9]

    # display a notice
    cat <<-_EOF

The key was recombined and imported successfully.
Don't forget to delete also the backup partial key.

_EOF
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
