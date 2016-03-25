source "$(dirname "$0")"/setup-02.sh

change_pinentry_program() {
    local autopin="$(dirname $SHARNESS_TEST_DIRECTORY)/utils/autopin.sh" &&
    cp -f "$autopin" "$EGPG_DIR/" &&
    autopin="$EGPG_DIR/autopin.sh" &&
    sed -i "$HOME/.bashrc" -e "s#--pinentry-program.*#--pinentry-program \"$autopin\" \\\\#" &&
    killall gpg-agent &&
    rm -rf /tmp/gpg-* &&
    source "$HOME/.bashrc"
}
