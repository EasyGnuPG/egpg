# Restore key from file.

cmd_key_restore_help() {
    cat <<-_EOF
    restore <file> [-u,--unsplit] \\
                   [-d,--dongledir <dir>] [-b,--backupdir <dir>]
        Restore key from file. By default it will be split into
        3 partial keys: one saved locally, one on the dongle,
        and one to be used as a backup.

_EOF
}

cmd_key_restore() {
    assert_no_valid_key

    local opts split=1 dongledir backupdir=$(pwd)
    opts="$(getopt -o ud:b: -l unsplit,dongledir:,backupdir: -n "$PROGRAM" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
        case $1 in
            -u|--unsplit) split=0; shift ;;
            -d|--dongledir) dongledir="$2"; shift 2 ;;
            -b|--backupdir) backupdir="$2"; shift 2 ;;
            --) shift; break ;;
        esac
    done
    [[ $err == 0 ]] || fail "Usage:\n$(cmd_key_restore_help)"

    local file="$1"
    [[ -n "$file" ]] || fail "Usage:\n$(cmd_key_restore_help)"
    [[ -f "$file" ]] || fail "Cannot find file: $file"

    if [[ $split == 1 ]]; then
        call_fn set_dongle "$dongledir"
        [[ -d "$backupdir" ]] || fail "Backup directory does not exist: $backupdir"
        [[ -w "$backupdir" ]] || fail "Backup directory is not writable: $backupdir"
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
        [[ -n $backupdir ]] && options+=" -b $backupdir"
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
