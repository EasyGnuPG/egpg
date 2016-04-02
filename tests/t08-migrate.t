#!/usr/bin/env bash

test_description='Command: migrate'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg migrate' '
    egpg_init &&
    egpg migrate | grep -e "Importing key from: $GNUPGHOME" -e "Importing contacts from: $GNUPGHOME" &&
    [[ $(egpg key | grep "^id: " | cut -d" " -f2) == $KEY_ID ]]
'

test_expect_success 'egpg migrate -d' '
    egpg_init "$HOME/.egpg1" &&
    egpg_init "$HOME/.egpg2" &&

    local gnupghome="$HOME/.egpg1/.gnupg" &&
    egpg migrate -d "$gnupghome" 2>&1 | grep -e "Importing key from: $gnupghome" -e "No valid key found." &&
    egpg 2>&1 | grep "No valid key found."
'

test_expect_success 'egpg migrate --homedir' '
    local gnupghome="$HOME/.egpg/.gnupg" &&
    egpg migrate --homedir "$gnupghome" &&
    [[ $(egpg key | grep "^id: " | cut -d" " -f2) == $KEY_ID ]]
'

test_done
