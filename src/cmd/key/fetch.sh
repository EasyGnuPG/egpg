# Get a key from another gpg directory.

cmd_key_fetch_help() {
    cat <<-_EOF
    fetch [-d,--homedir <gnupghome>] [-k,--key-id <key-id>]
        Get a key from another gpg directory (by default from \$GNUPGHOME).

_EOF
}

cmd_key_fetch() {
    assert_no_valid_key

    local opts homedir key_id
    opts="$(getopt -o d:k: -l homedir:,key-id: -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -d|--homedir) homedir="$2"; shift 2 ;;
            -k|--key-id) key_id="$2"; shift 2 ;;
            --) shift; break ;;
        esac
    done
    [[ $err -eq 0 ]] || fail "Usage:\n$(cmd_key_fetch_help)"

    # get the gnupg dir
    [[ -n "$homedir" ]] || homedir="$ENV_GNUPGHOME"
    [[ -n "$homedir" ]] || fail "No gnupg directory to import from."
    [[ -d "$homedir" ]] || fail "Cannot find gnupg directory: $homedir"
    echo -e "\nImporting key from: $homedir\n"

    # get id of the key to be imported
    [[ -n "$key_id" ]] || key_id=$(get_valid_keys "$homedir" | cut -d' ' -f1)
    [[ -n "$key_id" ]] || fail "No valid key found."

    workdir_make
    local file="$WORKDIR/$key_id.tgz"
    # backup to tmp file
    local gnupghome="$GNUPGHOME"
    GNUPGHOME="$homedir"
    call_fn backup_key $key_id "$file"
    # restore from tmp file
    GNUPGHOME="$gnupghome"
    call_fn restore_key "$file" 2>/dev/null || fail "Could not fetch the key."
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
