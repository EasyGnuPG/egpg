# Sign and encrypt a file.

cmd_seal_help() {
    cat <<-_EOF
    seal <file> [<recipient>...]
        Sign and encrypt a file. The resulting file will have the
        extension '.sealed'. The original file will be erased.

_EOF
}

cmd_seal() {
    local file="$1" ; shift
    [[ -z "$file" ]] && fail "Usage:\n$(cmd_seal_help)"
    [[ -f "$file" ]] || fail "Cannot find file '$file'"

    if [[ -f "$file.sealed" ]]; then
        yesno "File '$file.sealed' exists. Overwrite?" || return 1
        rm -f "$file.sealed"
    fi

    # get recipients
    get_gpg_key
    local recipients="--recipient $GPG_KEY"
    while [[ -n "$1" ]]; do
        recipients="$recipients --recipient $1"
        shift
    done

    # sign and encrypt
    gnupghome_setup
    gpg --no-tty --auto-key-locate=local,cert,keyserver,pka \
        --keyserver "$KEYSERVER" $recipients \
        --sign --encrypt --armor \
        --output "$file.sealed" "$file"
    gnupghome_reset

    [[ -f "$file.sealed" ]] && shred "$file"
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
