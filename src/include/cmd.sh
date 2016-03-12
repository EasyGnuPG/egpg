#!/usr/bin/env bash
#
# EasyGnuPG is a wrapper around GnuPG to simplify its operations.
# Copyright (C) 2016  Dashamir Hoxha
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
# BEGIN command functions
#

cmd_help() {
    cat <<-_EOF

Usage: $0 <command> [<options>]

EasyGnuPG is a wrapper around GnuPG to simplify its operations.
Commands and their options are listed below.

    init [<dir>]
        Initialize egpg. Optionally give the directory to be used.
        If not given, the default directory will be $HOME/.egpg/

    [info]
        Display info about the current configuration and settings.

    key <command> [<options>]
        Commands for handling the key. For more details see 'key help'.

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

cmd_version() {
    echo "egpg:  EasyGnuPG  $VERSION    (hosted at: https://github.com/dashohoxha/egpg) "
}

cmd_info() {
    cmd_version
    cat <<-_EOF
EGPG_DIR="$EGPG_DIR"
GNUPGHOME="$GNUPGHOME"
GPG_AGENT_INFO="$GPG_AGENT_INFO"
GPG_TTY="$GPG_TTY"
GPG_OPTS="$GPG_OPTS"
SHARE=$SHARE
KEYSERVER=$KEYSERVER
DEBUG=$DEBUG
_EOF

    local platform_file="$LIBDIR/platform/$PLATFORM.sh"
    [[ -f "$platform_file" ]] && echo "platform_file='$platform_file'"
    local customize_file="$EGPG_DIR/customize.sh"
    [[ -f "$customize_file" ]] && echo "customize_file='$customize_file'"

    cmd_key_fp
}

cmd_init() {
    # make sure that dependencies are installed
    test $(which haveged) || fail "You should install haveged:\n    sudo apt-get install haveged"
    test $(which parcimonie) || fail "You should install parcimonie:\n    sudo apt-get install parcimonie"

    # check for an existing directory
    if [[ -d $EGPG_DIR ]]; then
        if yesno "There is an old directory '$EGPG_DIR'. Do you want to erase it?"; then
            # stop the gpg-agent if it is running
            if [[ -f "$EGPG_DIR/.gpg-agent-info" ]]; then
                kill -9 $(cut -d: -f 2 "$EGPG_DIR/.gpg-agent-info") 2>/dev/null
                rm -rf $(dirname $(cut -d: -f 1 "$EGPG_DIR/.gpg-agent-info")) 2>/dev/null
                rm "$EGPG_DIR/.gpg-agent-info"
            fi
            # erase the old directory
            [[ -d "$EGPG_DIR" ]] && rm -rfv "$EGPG_DIR"
        fi
    fi

    # create the new $EGPG_DIR
    export EGPG_DIR="$HOME/.egpg"
    [[ -n "$2" ]] && export EGPG_DIR="$2"
    mkdir -pv "$EGPG_DIR"

    # setup $GNUPGHOME
    GNUPGHOME="$EGPG_DIR/.gnupg"
    mkdir -pv "$GNUPGHOME"
    [[ -f "$GNUPGHOME/gpg-agent.conf" ]] || cat <<_EOF > "$GNUPGHOME/gpg-agent.conf"
pinentry-program /usr/bin/pinentry
default-cache-ttl 300
max-cache-ttl 999999
_EOF

    # setup environment variables
    env_setup ~/.bashrc
}

env_setup() {
    local env_file=$1
    sed -i $env_file -e '/^### start egpg config/,/^### end egpg config/d'
    cat <<_EOF >> $env_file
### start egpg config
export EGPG_DIR="$EGPG_DIR"
_EOF
    cat <<'_EOF' >> $env_file
# Does ".gpg-agent-info" exist and points to gpg-agent process accepting signals?
if ! test -f "$EGPG_DIR/.gpg-agent-info" \
|| ! kill -0 $(cut -d: -f 2 "$EGPG_DIR/.gpg-agent-info") 2>/dev/null
then
    gpg-agent --daemon --no-grab \
        --options "$EGPG_DIR/.gnupg/gpg-agent.conf" \
        --pinentry-program /usr/bin/pinentry \
        --write-env-file "$EGPG_DIR/.gpg-agent-info" > /dev/null
fi
### end egpg config
_EOF
    echo -e "\nAppended the following lines to '$env_file':\n---------------8<---------------"
    sed $env_file -n -e '/^### start egpg config/,/^### end egpg config/p'
    echo "--------------->8---------------
Please realod it to enable the new config:
    source $env_file
"
}


cmd_seal() {
    local file="$1" ; shift
    [[ -z "$file" ]] && fail "Usage: $(basename "$0") seal <file> [<recipient>+]"
    [[ -f "$file" ]] || fail "Cannot find file '$file'"

    if [[ -f "$file.sealed" ]]; then
        yesno "File '$file.sealed' exists. Overwrite?" || return
        rm -f "$file.sealed"
    fi

    # get recipients
    get_gpg_key
    local recipients="--recipient $GPG_KEY"
    while [[ -n "$1" ]]; do
        recipients="$recipients --recipient $1"
        shift
    done

    # sign and encrypt
    gpg --auto-key-locate=local,cert,keyserver,pka \
        --keyserver "$KEYSERVER" $recipients \
        --sign --encrypt --armor \
        --output "$file.sealed" "$file"

    [[ -f "$file.sealed" ]] && shred "$file"
}

cmd_open() {
    local file="$1" ; shift
    [[ -z "$file" ]] && fail "Usage: $(basename "$0") open <file.sealed>"
    [[ -f "$file" ]] || fail "Cannot find file '$file'"

    local output=${file%.sealed}
    [[ "$output" != "$file" ]] || fail "The given file does not end in '.sealed'."

    # decrypt and verify
    gpg --keyserver "$KEYSERVER" \
        --keyserver-options auto-key-retrieve,verbose,honor-keyserver-url \
        --decrypt --output "$output" "$file"
}

cmd_sign() {
    local file="$1" ; shift
    [[ -z "$file" ]] && fail "Usage: $(basename "$0") sign <file>"
    [[ -f "$file" ]] || fail "Cannot find file '$file'"

    # sign
    get_gpg_key
    gpg --local-user $GPG_KEY \
        --detach-sign --armor --output "$file.signature" "$file"
}

cmd_verify() {
    local file="$1" ; shift
    [[ -z "$file" ]] && fail "Usage: $(basename "$0") verify <file>"
    [[ -f "$file" ]] || fail "Cannot find file '$file'"
    [[ -f "$file.signature" ]] || fail "Cannot find file '$file.signature'"

    # verify
    gpg --verify "$file.signature" "$file"
}

cmd_set() {
    local option=$1 ; shift
    case ${option,,} in
        share)
            local value=$1
            SHARE=$value
            sed -i "$EGPG_DIR/config.sh" -e "/SHARE=/c SHARE=$value"
            gpg_send_keys
            ;;
        *)
            echo "Unknown option '$option'"
            ;;
    esac
    sed -i $config_file
}

cmd_gpg() { gpg "$@"; }

#
# END command functions
#
