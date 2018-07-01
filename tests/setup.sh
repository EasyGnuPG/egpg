# This file should be sourced by all test-scripts

export KEY_ID="18D1DA4D9E7A4FD0"
export KEY_FPR="A9446F790F9BE7C9D108FC6718D1DA4D9E7A4FD0"
export KEY_GRIP_1="3914E664597E9C5998B8BC994C420602895881AB"

export CONTACT_1="290F15FEDA94668A"
export CONTACT_2="C95634F06073B549"
export CONTACT_3="262A29CB12F046E8"

cd "$(dirname "$0")"
source ./sharness.sh

CODE="$(dirname "$SHARNESS_TEST_DIRECTORY")"
EGPG="$CODE"/src/egpg.sh
[[ ! -x $EGPG ]] && echo "Could not find egpg.sh" &&  exit 1

egpg() { "$EGPG" "$@" ; }

unset  EGPG_DIR

export HOME="$SHARNESS_TRASH_DIRECTORY"
export GNUPGHOME="$HOME"/.gnupg

# copy keyring to $GNUPGHOME of the test
cp -a "$CODE"/tests/gnupg/ "$GNUPGHOME"
chmod 700 -R "$GNUPGHOME"
# extend key expiration
commands=$(echo ";expire;1m;y;key 1;expire;1m;y;key 1;save" | tr ';' "\n")
echo -e "$commands" | gpg --no-tty --command-fd=0 --key-edit $KEY_ID 2>/dev/null

export DONGLE="$HOME"/dongle
mkdir -p "$DONGLE"
chmod 700 "$DONGLE"

egpg_init() {
    egpg init "$@" &&
    source "$HOME"/.bashrc &&
    sed -i "$EGPG_DIR"/config.sh -e "/DEBUG/ c DEBUG=yes"
}

egpg_key_fetch() {
    egpg key fetch | grep -e "Importing key from: $GNUPGHOME"
}

egpg_contact_fetch() {
    egpg contact fetch | grep -e "Importing contacts from: $GNUPGHOME"
}

egpg_migrate() {
    egpg migrate 2>&1 | grep -e "Importing key from: $GNUPGHOME" -e "Importing contacts from: $GNUPGHOME"
}

send_gpg_commands_from_stdin() {
    # override function gpg to accept commands from stdin
    cat <<-'_EOF' > "$EGPG_DIR"/customize.sh
gpg() {
    local opts='--quiet --command-fd=0'
    [[ -t 0 ]] || opts+=' --no-tty'
    is_true $DEBUG && echo "debug: $(which gpg2) $opts $@" 1>&2
    "$(which gpg2)" $opts "$@"
}
export -f gpg
_EOF
    chmod +x "$EGPG_DIR"/customize.sh
}

setup_autopin() {
    local pin="${1:-123456}" &&
    cp -f "$CODE"/utils/autopin.sh "$EGPG_DIR"/ &&
    local autopin="$EGPG_DIR"/autopin.sh &&
    sed -i "$autopin" -e "/^PIN=/ c PIN='$pin'" &&
    local homedir="$EGPG_DIR/.gnupg" &&
    sed -i "$homedir"/gpg-agent.conf -e "/^pinentry-program/ c pinentry-program \"$autopin\"" &&
    gpgconf --homedir="$homedir" --reload gpg-agent
}
