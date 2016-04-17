# Get a key from another gpg directory.

cmd_key_fetch_help() {
    cat <<-_EOF
    fetch [-h,--homedir <gnupghome>] [-k,--key-id <key-id>]
        Get a key from another gpg directory
        (by default from $GNUPGHOME).

_EOF
}

cmd_key_fetch() {
    assert_no_valid_key

    local opts homedir key_id split=1 dongle backup=$(pwd)
    opts="$(getopt -o h:k:fd:b: -l homedir:,key_id:,full,dongle:,backup: -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -h|--homedir) homedir="$2"; shift 2 ;;
            -k|--key-id) key_id="$2"; shift 2 ;;
            -f|--full) split=0; shift ;;
            -d|--dongle) dongle="$2"; shift 2 ;;
            -b|--backup) backup="$2"; shift 2 ;;
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

    # check split options
    [[ $split == 1 ]] && call_fn check_split_options "$backup" "$dongle"

    local egpghome="$GNUPGHOME"
    gnupghome_setup "$homedir"
    # export to tmp file
    local file="$WORKDIR/$key_id.key"
    gpg --armor --export $key_id > "$file"
    gpg --armor --export-secret-keys $key_id >> "$file"
    # import from the tmp file
    gpg --homedir="$egpghome" --import "$file" 2>/dev/null || fail "Failed to import file: $file"
    gnupghome_reset

    # set trust to ultimate
    local commands=$(echo "trust|5|y|quit" | tr '|' "\n")
    script -c "gpg --command-fd=0 --key-edit $key_id <<< \"$commands\" " /dev/null > /dev/null

    # split the key into partial keys
    [[ $split == 1 ]] && call_fn split_key $backup
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
