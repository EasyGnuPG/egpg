# Join two partial keys into a normal key.

cmd_key_join_help() {
    cat <<-_EOF
    join
        Join two partial keys into a normal key and delete them.

_EOF
}

cmd_key_join() {
    # combine the partial keys
    combine_partial_keys_on_workdir

    # import the combined key
    gpg --import "$WORKDIR/$GPG_KEY.key" \
        || fail "Could not import the combined key."
    rm -rf "$WORKDIR"    # clean up

    # remove the partials
    rm -f "$EGPG_DIR"/$GPG_KEY.key.[0-9][0-9][0-9]
    rm -f "$DONGLE"/.egpg_key/$GPG_KEY.key.[0-9][0-9][0-9]
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
