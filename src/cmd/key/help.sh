cmd_key_help() {
    cat <<-_EOF

Usage: $(basename $0) key <command> [<options>]

Commands to manage the key. They are listed below.

_EOF
    call cmd_key_list help
    call cmd_key_gen help
    call cmd_key_fetch help
    call cmd_key_backup help
    call cmd_key_restore help
    call cmd_key_split help
    call cmd_key_join help
    call cmd_key_recover help
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
