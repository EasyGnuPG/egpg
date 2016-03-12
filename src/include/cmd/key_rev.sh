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

cmd_key_rev() {
    local revoke_cert="$1"
    get_gpg_key
    [[ -n "$revoke_cert" ]] || revoke_cert="$GNUPGHOME/$GPG_KEY.revoke"
    [[ -f "$revoke_cert" ]] || fail "Revocation certificate not found: $revoke_cert"

    yesno "
Revocation will make your current key useless. You'll need
to generate a new one. Are you sure about this?" || return 1

    gpg --import "$revoke_cert"
    gpg_send_keys $GPG_KEY
}
