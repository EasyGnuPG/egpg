# Publish the key to the keyserver network.

cmd_key_share_help() {
    cat <<-_EOF
    share
        Publish the key to the keyserver network.

_EOF
}

cmd_key_share() {
    get_gpg_key
    is_true $SHARE || fail "You must enable sharing first with:\n  $(basename $0) set share yes"
    call_fn gpg_send_keys $GPG_KEY
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
