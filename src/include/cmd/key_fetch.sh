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
    [[ $err -eq 0 ]] || fail "Usage: $COMMAND [-d,--dir <gnupghome>] [-k,--key-id <key-id>]"

    # get the gnupg dir
    [[ -n "$homedir" ]] || homedir="$ENV_GNUPGHOME"
    [[ -n "$homedir" ]] || fail "No gnupg directory to import from."
    [[ -d "$homedir" ]] || fail "Cannot find gnupg directory: $homedir"
    echo "Importing key from: $homedir"

    # get id of the key to be imported
    [[ -n "$key_id" ]] || key_id=$(get_valid_keys $homedir | cut -d' ' -f1)
    [[ -n "$key_id" ]] || fail "No valid key found."

    # export to tmp file
    make_workdir
    local file="$WORKDIR/$key_id.key"
    gpg --homedir="$homedir" --armor --export $key_id > "$file"
    gpg --homedir="$homedir" --armor --export-secret-keys $key_id >> "$file"

    # import from the tmp file
    gpg --import "$file"
    rm -rf $WORKDIR

    # set trust to ultimate
    local commands=$(echo "trust|5|y|quit" | tr '|' "\n")
    script -c "gpg --command-fd=0 --key-edit $key_id <<< \"$commands\" " /dev/null > /dev/null
}
