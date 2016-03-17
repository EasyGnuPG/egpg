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

cmd_help() {
    cat <<-_EOF

Usage: $(basename $0) <command> [<options>]

EasyGnuPG is a wrapper around GnuPG to simplify its operations.
Commands and their options are listed below.

    init [<dir>]
        Initialize egpg. Optionally give the directory to be used.
        If not given, the default directory will be $HOME/.egpg/

    migrate [-d,--homedir <gnupghome>]
        Get keys and contacts from another gpg directory (by default
        from $GNUPGHOME).

    [info]
        Display info about the current configuration and settings.

    seal <file> [<recipient>...]
        Sign and encrypt a file. The resulting file will have the
        extension '.sealed' The original file will be erased.

    open <file.sealed>
        Decrypt and verify the signature of the given file.
        The file has to end with '.sealed' and the output will have
        that extension stripped.

    sign <file>
        Sign a file. The signature will be saved to <file.signature>.

    verify <file>
        Verify the signature of the given file.  The signature file
        <file.signature> must be present as well.

    key <command> [<options>]
        Commands for handling the key. For more details see 'key help'.

    contact <command> [<options>]
        Commands for handling the contacts. For more details see
        'contact help'.

    set <option> <value>
        Change the settings.

    --,gpg ...
        Run any gpg command (but using the configuration settings of egpg).

    help
        Show this help text.

    version
        Show version information.

More information may be found in the egpg(1) man page.

_EOF
}
