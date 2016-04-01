source "$(dirname "$0")"/setup-01.sh

egpg_init() {
    local egpg_dir=${1:-$HOME/.egpg}
    rm -rf "$egpg_dir" &&
    egpg init "$egpg_dir" &&
    source "$HOME/.bashrc"
}

test_expect_success 'Initialize egpg' '
    egpg_init &&
    [[ -n "$EGPG_DIR" ]] &&
    [[ -d "$EGPG_DIR" ]]
'
