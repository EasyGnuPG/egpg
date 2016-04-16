# Restore key from file.

cmd_key_restore_help() {
    cat <<-_EOF
    restore <file>
        Restore key from file.

_EOF
}

cmd_key_restore() {
    assert_no_valid_key

    local opts split=1 dongle backup=$(pwd)
    opts="$(getopt -o fd:b: -l full,dongle:,backup: -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -f|--full) split=0; shift ;;
            -d|--dongle) dongle="$2"; shift 2 ;;
            -b|--backup) backup="$2"; shift 2 ;;
            --) shift; break ;;
        esac
    done
    [[ $err == 0 ]] || fail "Usage:\n$(cmd_key_restore_help)"

    local file="$1"
    [[ -n "$file" ]] || fail "Usage:\n$(cmd_key_restore_help)"
    [[ -f "$file" ]] || fail "Cannot find file: $file"

    if [[ $split == 1 ]]; then
        call_fn set_dongle "$dongle"
        [[ -d "$backup" ]] || fail "Backup directory does not exist: $backup"
        [[ -w "$backup" ]] || fail "Backup directory is not writable: $backup"
    fi

    # restore
    echo "Restoring key from file: $file"
    gpg --import "$file" 2>/dev/null || fail "Failed to import file: $file"

    # set trust to 'ultimate'
    local key_id=$(gpg --with-fingerprint --with-colons "$file" | grep '^sec' | cut -d: -f5)
    local commands=$(echo "trust|5|y|quit" | tr '|' "\n")
    script -c "gpg --batch --command-fd=0 --key-edit $key_id <<< \"$commands\" " /dev/null > /dev/null

    # split the key into partial keys
    if [[ $split == 1 ]]; then
        local options=''
        [[ -n $DONGLE ]] && options+=" -d $DONGLE"
        [[ -n $backup ]] && options+=" -b $backup"
        call cmd_key_split $options
    fi
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
