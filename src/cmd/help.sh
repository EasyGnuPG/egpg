cmd_help() {
    cat <<-_EOF

Usage: $(basename $0) <command> [<options>]

EasyGnuPG is a wrapper around GnuPG to simplify its operations.
Commands and their options are listed below.

_EOF
    call cmd_init help
    call cmd_migrate help
    call cmd_info help
    call cmd_seal help
    call cmd_open help
    call cmd_sign help
    call cmd_verify help
    call cmd_default help
    call cmd_set help

    cat <<-_EOF
    key <command> [<options>]
        Commands for handling the key. For more details see 'key help'.

    contact <command> [<options>]
        Commands for handling the contacts. For more details see
        'contact help'.

    --,gpg ...
        Run any gpg command (but using the configuration settings of egpg).

    help
        Show this help text.

    version
        Show version information.

More information may be found in the egpg(1) man page.
Try also:
    $(basename $0) key help          # for key commands
    $(basename $0) contact help      # for contact commands
    $(basename $0) ext help          # for external commands

_EOF
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
