#!/usr/bin/env bash

test_description='Command: key export/import'
source "$(dirname "$0")"/setup-01.sh

test_expect_success 'Init' '
    egpg init &&
    source "$HOME/.bashrc" &&
    egpg key fetch | grep "Importing key from: $GNUPGHOME"
'

test_expect_success 'Test key export' '
    egpg key export | grep "Key exported to: $KEY_ID.key" &&
    [[ -f "$KEY_ID.key" ]]
'

test_expect_success 'Test key export <key-id>' '
    rm -f "$KEY_ID.key" &&
    egpg key export $KEY_ID | grep "Key exported to: $KEY_ID.key" &&
    [[ -f "$KEY_ID.key" ]]
'

test_expect_success 'Test key import (key exists)' '
    egpg key import 2>&1 | grep "There is already a valid key."
'

test_expect_success 'Test key import (no import file)' '
    egpg key delete &&
    egpg key import 2>&1 | grep "Usage" &&
    egpg key import no-file.key 2>&1 | grep "Cannot find file: "
'

test_expect_success 'Test key import' '
    egpg key import "$KEY_ID.key" &&
    local key_id=$(egpg key | grep "^id: " | cut -d" " -f2) &&
    [[ $key_id == $KEY_ID ]]
'

test_done
