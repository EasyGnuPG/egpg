#!/usr/bin/env bash

test_description='Command: key fetch'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg key fetch' '
    egpg_init &&
    egpg key fetch | grep -e "Importing key from: $GNUPGHOME" &&
    [[ $(egpg key | grep "^id: " | cut -d" " -f2) == $KEY_ID ]]
'

test_expect_success 'egpg key fetch -d' '
    egpg_init "$HOME/.egpg1" &&
    egpg_init "$HOME/.egpg2" &&
    local gnupghome="$HOME/.egpg1/.gnupg" &&
    egpg key fetch -d "$gnupghome" 2>&1 | grep -e "Importing key from: $gnupghome" -e "No valid key found." &&
    egpg 2>&1 | grep "No valid key found."
'

test_expect_success 'egpg key fetch --homedir' '
    local gnupghome="$HOME/.egpg/.gnupg" &&
    egpg key fetch --homedir "$gnupghome" &&
    [[ $(egpg key | grep "^id: " | cut -d" " -f2) == $KEY_ID ]]
'

test_expect_success 'egpg key fetch -k' '
    egpg_init "$HOME/.egpg1" &&
    egpg key fetch -k $KEY_ID | grep -e "Importing key from: $GNUPGHOME" &&
    [[ $(egpg key | grep "^id: " | cut -d" " -f2) == $KEY_ID ]]
'

test_expect_success 'egpg key fetch -d --key-id' '
    egpg_init "$HOME/.egpg3" &&
    local gnupghome="$HOME/.egpg2/.gnupg" &&
    egpg key fetch -d "$gnupghome" --key-id $KEY_ID &&
    [[ $(egpg key | grep "^id: " | cut -d" " -f2) == $KEY_ID ]]
'

test_done
