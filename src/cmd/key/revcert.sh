# Generate a revocation certificate for the key.

cmd_key_revcert_help() {
    cat <<-_EOF
    revcert ["description"]
        Generate a revocation certificate for the key.

_EOF
}

cmd_key_revcert() {
    echo -e "\nCreating a revocation certificate.\n"
    local description=${1:-"Key is being revoked"}

    get_gpg_key
    local revcert="$GNUPGHOME/openpgp-revocs.d/$FPR.rev"
    rm -f "$revcert"
    mkdir -p "$(dirname "$revcert")"

    gnupghome_setup
    local commands="y|1|$description||y"
    commands=$(echo "$commands" | tr '|' "\n")
    echo -e "$commands" | gpg --yes --no-tty --command-fd=0 --output "$revcert" --gen-revoke $GPG_KEY
    while [[ -n $(ps -x | grep -e '--gen-revoke' | grep -v grep) ]]; do sleep 0.5; done
    if [[ -f "$revcert" ]]; then
        echo -e "\nRevocation certificate saved at: \n    \"$revcert\""
        call_fn qrencode "$revcert"
        [[ -f "$revcert.pdf" ]] &&  echo -e "    \"$revcert.pdf\"\n"
        cat <<-_EOF
Please move it to a medium which you can hide away; if Mallory gets
access to this certificate he can use it to make your key unusable.
It is smart to print this certificate and store it away, just in case
your media become unreadable.  But have some caution:  The print system of
your machine might store the data and make it available to others!

_EOF
    fi
    gnupghome_reset
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
