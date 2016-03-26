#!/usr/bin/env bash

test_description='Command: key fetch'
source "$(dirname "$0")"/setup-01.sh

test_expect_success 'Test `egpg key fetch`' '
    egpg init &&
    source "$HOME/.bashrc" &&

    egpg key fetch | grep -e "Importing key from: $GNUPGHOME" &&

    local key_id=$(egpg key | grep "^id: " | cut -d" " -f2) &&
    [[ $key_id == $KEY_ID ]]
'

test_expect_success 'Test `egpg key fetch -d`' '
    egpg init "$HOME/.egpg1" &&
    source "$HOME/.bashrc" &&

    egpg init "$HOME/.egpg2" &&
    source "$HOME/.bashrc" &&

    local gnupghome="$HOME/.egpg1/.gnupg" &&
    egpg key fetch -d "$gnupghome" 2>&1 | grep -e "Importing key from: $gnupghome" -e "No valid key found." &&

    egpg 2>&1 | grep "No valid key found."
'

test_expect_success 'Test `egpg migrate --homedir`' '
    local gnupghome="$HOME/.egpg/.gnupg" &&
    egpg key fetch --homedir "$gnupghome" &&

    local key_id=$(egpg key | grep "^id: " | cut -d" " -f2) &&
    [[ $key_id == $KEY_ID ]]
'

test_expect_success 'Test `egpg key fetch -k`' '
    egpg init "$HOME/.egpg1" &&
    source "$HOME/.bashrc" &&

    egpg key fetch -k $KEY_ID | grep -e "Importing key from: $GNUPGHOME" &&

    local key_id=$(egpg key | grep "^id: " | cut -d" " -f2) &&
    [[ $key_id == $KEY_ID ]]
'

test_expect_success 'Test `egpg key fetch --key-id`' '
    egpg key del &&

    local gnupghome="$HOME/.egpg2/.gnupg" &&
    egpg key fetch -d "$gnupghome" --key-id $KEY_ID &&

    local key_id=$(egpg key | grep "^id: " | cut -d" " -f2) &&
    [[ $key_id == $KEY_ID ]]
'

test_done
