#!/usr/bin/env bash

test_description='Command: key export'
source "$(dirname "$0")"/setup.sh

test_expect_success 'key export (no valid key)' '
    egpg_init &&
    egpg key export 2>&1 | grep "No valid key."
'

test_expect_success 'key export' '
    egpg_key_fetch &&
    egpg key export | grep "Key exported to: $KEY_ID.key" &&
    [[ -f "$KEY_ID.key" ]]
'

test_expect_success 'key export <key-id>' '
    rm -f "$KEY_ID.key" &&
    egpg key export $KEY_ID | grep "Key exported to: $KEY_ID.key" &&
    [[ -f "$KEY_ID.key" ]]
'

test_done
