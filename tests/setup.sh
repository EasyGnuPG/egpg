# This file should be sourced by all test-scripts

cd "$(dirname "$0")"
source ./sharness.sh

EGPG="$(dirname $SHARNESS_TEST_DIRECTORY)"/src/egpg.sh
[[ ! -x $EGPG ]] && echo "Could not find egpg.sh" &&  exit 1

egpg() { "$EGPG" "$@" ; }

unset  EGPG_DIR

export HOME="$SHARNESS_TRASH_DIRECTORY"
cp -a "$SHARNESS_TEST_DIRECTORY"/gnupg/ "$HOME"/.gnupg
export GNUPGHOME="$HOME"/.gnupg
export DONGLE="$HOME"/dongle
mkdir -p "$DONGLE"

export KEY_ID="18D1DA4D9E7A4FD0"
export KEY_FPR="A9446F790F9BE7C9D108FC6718D1DA4D9E7A4FD0"

export CONTACT_1="290F15FEDA94668A"
export CONTACT_2="C95634F06073B549"
export CONTACT_3="262A29CB12F046E8"

egpg_init() {
    egpg init "$@" &&
    source "$HOME"/.bashrc
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
    echo "command-fd 0" >> "$HOME"/.egpg/.gnupg/gpg.conf
}

setup_autopin() {
    local pin="${1:-123456}" &&

    killall gpg-agent &&

    local autopin="$(dirname $SHARNESS_TEST_DIRECTORY)"/utils/autopin.sh &&
    cp -f "$autopin" "$EGPG_DIR/" &&
    autopin="$EGPG_DIR"/autopin.sh &&
    sed -i "$autopin" -e "/^PIN=/ c PIN='$pin'" &&
    sed -i "$GNUPGHOME"/gpg-agent.conf -e "/^pinentry-program/ c pinentry-program \"$autopin\"" &&

    source "$HOME"/.bashrc
}
