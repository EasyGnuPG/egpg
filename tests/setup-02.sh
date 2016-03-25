source "$(dirname "$0")"/setup-01.sh

test_expect_success 'Initialize egpg' '
    egpg init &&
    source "$HOME/.bashrc"
'
