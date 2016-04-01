#!/usr/bin/env bash

test_description='Command: migrate'
source "$(dirname "$0")"/setup-01.sh

test_expect_success 'Test `egpg migrate`' '
    egpg init &&
    source "$HOME/.bashrc" &&
    egpg migrate | grep -e "Importing key from: $GNUPGHOME" -e "Importing contacts from: $GNUPGHOME" &&
    local key_id=$(egpg key | grep "^id: " | cut -d" " -f2) &&
    [[ $key_id == $KEY_ID ]]
'

test_expect_success 'Test `egpg migrate -d`' '
    egpg init "$HOME/.egpg1" &&
    source "$HOME/.bashrc" &&

    egpg init "$HOME/.egpg2" &&
    source "$HOME/.bashrc" &&

    local gnupghome="$HOME/.egpg1/.gnupg" &&
    egpg migrate -d "$gnupghome" 2>&1 | grep -e "Importing key from: $gnupghome" -e "No valid key found." &&
    egpg 2>&1 | grep "No valid key found."
'

test_expect_success 'Test `egpg migrate --homedir`' '
    local gnupghome="$HOME/.egpg/.gnupg" &&
    egpg migrate --homedir "$gnupghome" &&
    local key_id=$(egpg key | grep "^id: " | cut -d" " -f2) &&
    [[ $key_id == $KEY_ID ]]
'

test_done
