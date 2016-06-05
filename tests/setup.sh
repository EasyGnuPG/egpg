# This file should be sourced by all test-scripts

cd "$(dirname "$0")"
source ./sharness.sh

CODE="$(dirname "$SHARNESS_TEST_DIRECTORY")"
EGPG="$CODE"/src/egpg.sh
[[ ! -x $EGPG ]] && echo "Could not find egpg.sh" &&  exit 1

egpg() { "$EGPG" "$@" ; }

unset  EGPG_DIR

export HOME="$SHARNESS_TRASH_DIRECTORY"

export GNUPGHOME="$HOME"/.gnupg
cp -a "$CODE"/tests/gnupg/ "$GNUPGHOME"

export DONGLE="$HOME"/dongle
mkdir -p "$DONGLE"
chmod 700 "$DONGLE"

export KEY_ID="D44186C07EA858BD"

export CONTACT_1="290F15FEDA94668A"
export CONTACT_2="C95634F06073B549"
export CONTACT_3="262A29CB12F046E8"

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
    # echo "command-fd 0" >> "$HOME"/.egpg/.gnupg/gpg.conf

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

    killall gpg-agent &&
    rm -rf /tmp/gpg-* &&

    local autopin="$CODE"/utils/autopin.sh &&
    cp -f "$autopin" "$EGPG_DIR/" &&
    autopin="$EGPG_DIR"/autopin.sh &&
    sed -i "$autopin" -e "/^PIN=/ c PIN='$pin'" &&
    sed -i "$HOME"/.bashrc -e "s#--pinentry-program.*#--pinentry-program \"$autopin\" \\\\#" &&

    source "$HOME"/.bashrc
}
