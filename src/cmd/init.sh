# Initialize egpg.

cmd_init_help() {
    cat <<-_EOF
    init [<dir>]
        Initialize egpg. Optionally give the directory to be used.
        If not given, the default directory will be $HOME/.egpg/

_EOF
}

cmd_init() {
    # erase any existing directory
    [[ -d "$EGPG_DIR" ]] \
        && yesno "There is an old directory '$EGPG_DIR'. Do you want to erase it?" \
        && rm -rfv "$EGPG_DIR"

    # create the new $EGPG_DIR
    export EGPG_DIR="$HOME"/.egpg
    [[ -n "$1" ]] && export EGPG_DIR="$1"
    mkdir -pv "$EGPG_DIR"
    mkdir -p "$EGPG_DIR"/.gnupg
    [[ -f "$EGPG_DIR"/.gnupg/gpg-agent.conf ]] || cat <<-_EOF > "$EGPG_DIR"/.gnupg/gpg-agent.conf
quiet
pinentry-program /usr/bin/pinentry-tty
allow-loopback-pinentry
default-cache-ttl 300
max-cache-ttl 999999
_EOF
    [[ -f "$EGPG_DIR"/.gnupg/gpg.conf ]] || cat <<-_EOF > "$EGPG_DIR"/.gnupg/gpg.conf
keyid-format long
default-cert-expire 1y
_EOF

    # create the config file
    local config_file="$EGPG_DIR"/config.sh
    [[ -f "$config_file" ]] || cat <<-_EOF > "$config_file"
# If true, push local changes to the keyserver network.
# Leave it empty (or comment out) to disable.
SHARE=
#KEYSERVER=hkp://keys.gnupg.net

# GPG homedir. If "default", then the default one will be used,
# (whatever is in the environment \$GNUPGHOME, usually ~/.gnupg).
GNUPGHOME="$(realpath "$EGPG_DIR")/.gnupg"

# Path of the dongle.
DONGLE=

# If true, print debug output.
DEBUG=
_EOF
    # setup environment variables
    _env_setup ~/.bashrc
}

_env_setup() {
    local env_file="$1"
    [[ -f "$env_file" ]] && sed -i "$env_file" -e '/^### start egpg config/,/^### end egpg config/d'
    cat <<-_EOF >> "$env_file"
### start egpg config
export GPG_TTY=\$(tty)
export EGPG_DIR="$(realpath "$EGPG_DIR")"
#export GNUPGHOME="$(realpath "$EGPG_DIR")/.gnupg"
### end egpg config
_EOF
    echo -e "\nAppended the following lines to '$env_file':\n---------------8<---------------"
    sed "$env_file" -n -e '/^### start egpg config/,/^### end egpg config/p'
    echo "--------------->8---------------
Please reload it to enable the new config:
    source \"$env_file\"
"
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
