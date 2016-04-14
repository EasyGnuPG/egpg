# Join two partial keys into a normal key.

cmd_key_join_help() {
    cat <<-_EOF
    join
        Join two partial keys into a normal key and delete them.

_EOF
}

cmd_key_join() {
    # get $GPG_KEY
    get_gpg_key

    # get partial keys on PC and dongle
    local partial1 partial2
    partial1=$(cd "$EGPG_DIR"; ls $GPG_KEY.key.* 2>/dev/null)
    [[ -f "$EGPG_DIR/$partial1" ]] \
        || fail "Could not find partial key for $GPG_KEY on $EGPG_DIR"
    partial2=$(cd "$DONGLE/.egpg_key"; ls $GPG_KEY.key.* 2>/dev/null)
    [[ -f "$DONGLE/.egpg_key/$partial2" ]] \
        || fail "Could not find partial key for $GPG_KEY on $DONGLE/.egpg_key/"

    # combine the partials and import the full key
    make_workdir
    cp "$EGPG_DIR/$partial1" "$WORKDIR/"
    cp "$DONGLE/.egpg_key/$partial2" "$WORKDIR/"
    gfcombine "$WORKDIR/$partial1" "$WORKDIR/$partial2"
    local file="$WORKDIR/$GPG_KEY.key"
    gpg --import "$file" || fail "Could not import the combined key."

    # remove the partials
    rm -f "$EGPG_DIR/$partial1"
    rm -f "$DONGLE/.egpg_key/$partial2"
    # clean up
    rm -rf "$WORKDIR"

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
