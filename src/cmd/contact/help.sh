cmd_contact_help() {
    cat <<-_EOF

Usage: $(basename $0) contact <command> [<options>]

Commands to manage the contacts (correspondents, partners).
They are listed below.

_EOF
    call cmd_contact_list help
    call cmd_contact_delete help
    call cmd_contact_export help
    call cmd_contact_import help
    call cmd_contact_fetch help
    call cmd_contact_fetchuri help
    call cmd_contact_search help
    call cmd_contact_receive help
    call cmd_contact_certify help
    call cmd_contact_uncertify help
    call cmd_contact_trust help
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
