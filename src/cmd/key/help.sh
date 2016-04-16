cmd_key_help() {
    cat <<-_EOF

Usage: $(basename $0) key <command> [<options>]

Commands to manage the key. They are listed below.

By default the key is split into three partial keys (one stored on the
dongle, one locally, and one for backup) and no passphrase is used.
Whenever the key needs to be used, the dongle needs to be present.
However it is possible to switch from partial keys to a full key (with
the command 'join') and vice-versa (with the command 'split').  Also
the passphrase can be changed (with the command 'pass').

The commands for generating, fetching or restoring the key, by default
split it to partials, unless the option [-f,--full] is given. They
also accept the options [-d,--dongle <dir>] [-b,--backup <dir>] which
tell them where to store the partial keys. If --dongle is not given,
it will be asked interactively. The default for the option --backup is
the current working directory ($(pwd)).

_EOF
    call cmd_key_list help
    call cmd_key_gen help
    call cmd_key_fetch help
    call cmd_key_backup help
    call cmd_key_restore help
    call cmd_key_split help
    call cmd_key_join help
    call cmd_key_pass help
    call cmd_key_share help
    call cmd_key_renew help
    call cmd_key_revcert help
    call cmd_key_rev help
    call cmd_key_delete help
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
