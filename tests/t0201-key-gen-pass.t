#!/usr/bin/env bash

test_description='Create a key with a passphrase'
source "$(dirname "$0")"/setup-02.sh

test_expect_success 'Make sure that `haveged` is started' '
    [[ -n "$(ps ax | grep -v grep | grep haveged)" ]]
'

change_pinentry_program() {
    local autopin="$(dirname $SHARNESS_TEST_DIRECTORY)/utils/autopin.sh" &&
    cp -f "$autopin" "$EGPG_DIR/" &&
    autopin="$EGPG_DIR/autopin.sh" &&
    sed -i "$HOME/.bashrc" -e "s#--pinentry-program.*#--pinentry-program \"$autopin\" \\\\#" &&
    killall gpg-agent &&
    rm -rf /tmp/gpg-* &&
    source "$HOME/.bashrc"
}

test_expect_success 'Generate a key with a passphrase' '
    egpg_init &&
    change_pinentry_program &&

    echo <<-_EOF | egpg key gen test1@example.org "Test 1" 2>&1 | grep "Excellent! You created a fresh GPG key." &&
123456
123456
_EOF
    [[ $(egpg key | grep uid:) == "uid: Test 1 <test1@example.org>" ]]
'

test_done