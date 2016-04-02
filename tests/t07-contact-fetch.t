#!/usr/bin/env bash

test_description='Command: contact fetch'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg contact fetch' '
    egpg_init &&
    egpg contact fetch | grep -e "Importing contacts from: $GNUPGHOME" &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 4 ]]
'

test_expect_success 'egpg contact fetch -d' '
    egpg_init "$HOME/.egpg1" &&
    egpg contact fetch -d "$HOME/.egpg/.gnupg" | grep -e "Importing contacts from: $HOME/.egpg/.gnupg" &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 4 ]]
'

test_expect_success 'egpg contact fetch --homedir' '
    egpg_init "$HOME/.egpg2" &&
    egpg contact fetch --homedir "$HOME/.egpg1/.gnupg" | grep -e "Importing contacts from: $HOME/.egpg1/.gnupg" &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 4 ]]
'

test_expect_success 'egpg contact fetch <id>' '
    egpg_init "$HOME/.egpg3" &&
    egpg contact fetch $CONTACT_1 $CONTACT_2 | grep -e "Importing contacts from: $GNUPGHOME" &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 2 ]]
'

test_expect_success 'egpg contact fetch <name>' '
    egpg_init "$HOME/.egpg4" &&
    egpg contact fetch test2 test3@example.org | grep -e "Importing contacts from: $GNUPGHOME" &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 2 ]]
'

test_done
