#!/usr/bin/env bash

test_description='Command: key del'
source "$(dirname "$0")"/setup-01.sh

test_expect_success 'Init' '
    egpg init &&
    source "$HOME/.bashrc"
'

test_expect_success 'Test key del (no key)' '
    egpg key del 2>&1 | grep -e "No valid key found."
'

test_expect_success 'Test key del' '
    egpg key fetch | grep -e "Importing key from: $GNUPGHOME" &&
    egpg key del
'

test_expect_success 'Test key del <wrong-key>' '
    egpg key fetch | grep -e "Importing key from: $GNUPGHOME" &&
    egpg key del XYZ 2>&1 | grep -e "Key XYZ not found".
'

test_expect_success 'Test key del <key-id>' '
    egpg key del $KEY_ID &&
    egpg key 2>&1 | grep -e "No valid key found."
'

test_done
