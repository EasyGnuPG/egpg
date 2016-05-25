# Revoke the key.

cmd_key_rev_help() {
    cat <<-_EOF
    rev,revoke [<revocation-certificate>]
        Cancel the key by publishing the given revocation certificate.

_EOF
}

cmd_key_rev() {
    local revcert="$1"
    get_gpg_key
    [[ -n "$revcert" ]] || revcert="$GNUPGHOME/openpgp-revocs.d/$FPR.rev"
    [[ -f "$revcert" ]] || fail "Revocation certificate not found: $revcert"

    is_full_key || fail "
This key is split into partial keys.
Try first:  $(basename $0) key join
     then:  $(basename $0) key revoke
"

    yesno "
Revocation will make your current key useless.
You'll need to generate a new one.
Are you sure about this?" || return 1

    # import the revocation certificate
    sed -i "$revcert" -e "s/^:---/---/"
    gpg --import "$revcert"
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
