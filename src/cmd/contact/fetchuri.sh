# Retrieve contacts located at the specified URIs.

cmd_contact_fetchuri_help() {
    cat <<-_EOF
    fetch-uri <uri>...
        Retrieve contacts located at the specified URIs.

_EOF
}

cmd_contact_fetchuri() {
    [[ -z $1 ]] && fail "Usage:\n$(cmd_contact_fetchuri_help)"
    #gpg --fetch-keys "$@"
    workdir_make
    cd "$WORKDIR"
    wget -q $@
    gpg --import *
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
