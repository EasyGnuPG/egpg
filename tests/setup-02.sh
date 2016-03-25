source "$(dirname "$0")"/setup-01.sh

egpg_init() {
    rm -rf "$HOME/.egpg" &&
    egpg init &&
    source "$HOME/.bashrc"
}

test_expect_success 'Initialize egpg' '
    egpg_init &&
    [[ -n "$EGPG_DIR" ]] &&
    [[ -d "$EGPG_DIR" ]]
'
