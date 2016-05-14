#!/usr/bin/env bash

test_description='Command: key delete'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg key del (no key)' '
    egpg_init &&
    egpg key del 2>&1 | grep -e "No valid key found."
'

test_expect_success 'egpg key del' '
    egpg_key_fetch &&
    egpg key del &&
    egpg key 2>&1 | grep -e "No valid key found."
'

test_expect_success 'egpg key del <wrong-key>' '
    egpg_key_fetch &&
    egpg key del XYZ 2>&1 | grep -e "Key XYZ not found".
'

test_expect_success 'egpg key del <key-id>' '
    egpg key del $KEY_ID &&
    egpg key 2>&1 | grep -e "No valid key found."
'

test_expect_success 'egpg key rm' '
    egpg_key_fetch &&
    egpg key rm &&
    egpg key 2>&1 | grep -e "No valid key found."
'

test_expect_success 'egpg key delete' '
    egpg_key_fetch &&
    egpg key delete &&
    egpg key 2>&1 | grep -e "No valid key found."
'

test_done
