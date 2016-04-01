#!/usr/bin/env bash

test_description='Command: contact fetch'
source "$(dirname "$0")"/setup-01.sh

egpg_init() {
    local egpg_dir=${1:-$EGPG_DIR}
    rm -rf "$egpg_dir" &&
    egpg init "$egpg_dir" &&
    source "$HOME/.bashrc"
}

test_expect_success 'contact fetch' '
    egpg_init &&
    egpg contact fetch | grep -e "Importing contacts from: $GNUPGHOME" &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 4 ]]
'

test_expect_success 'contact fetch -d' '
    egpg_init "$HOME/.egpg1" &&
    egpg contact fetch -d "$HOME/.egpg/.gnupg" | grep -e "Importing contacts from: $HOME/.egpg/.gnupg" &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 4 ]]
'

test_expect_success 'contact fetch --homedir' '
    egpg_init "$HOME/.egpg2" &&
    egpg contact fetch --homedir "$HOME/.egpg1/.gnupg" | grep -e "Importing contacts from: $HOME/.egpg1/.gnupg" &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 4 ]]
'

test_expect_success 'contact fetch <id>' '
    egpg_init &&
    egpg contact fetch $CONTACT_1 $CONTACT_2 | grep -e "Importing contacts from: $GNUPGHOME" &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 2 ]]
'

test_expect_success 'contact fetch <name>' '
    egpg_init &&
    egpg contact fetch test2 test3@example.org | grep -e "Importing contacts from: $GNUPGHOME" &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 2 ]]
'

test_done
