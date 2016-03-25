source "$(dirname "$0")"/setup-02.sh

setup_autopin() {
    local pin="${1:-123456}" &&

    killall gpg-agent &&
    rm -rf /tmp/gpg-* &&

    local autopin="$(dirname $SHARNESS_TEST_DIRECTORY)/utils/autopin.sh" &&
    cp -f "$autopin" "$EGPG_DIR/" &&
    autopin="$EGPG_DIR/autopin.sh" &&
    sed -i "$autopin" -e "/^PIN=/ c PIN='$pin'" &&
    sed -i "$HOME/.bashrc" -e "s#--pinentry-program.*#--pinentry-program \"$autopin\" \\\\#" &&

    source "$HOME/.bashrc"
}
