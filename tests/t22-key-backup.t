#!/usr/bin/env bash

test_description='Command: key backup'
source "$(dirname "$0")"/setup.sh

test_expect_success 'key backup (no valid key)' '
    egpg_init &&
    egpg key backup 2>&1 | grep "No valid key."
'

test_expect_success 'key backup' '
    egpg_key_fetch &&
    egpg key backup | grep "Key saved to: $KEY_ID.key" &&
    [[ -f "$KEY_ID.key" ]]
'

test_expect_success 'key backup <key-id>' '
    rm -f "$KEY_ID.key" &&
    egpg key backup $KEY_ID | grep "Key saved to: $KEY_ID.key" &&
    [[ -f "$KEY_ID.key" ]]
'

test_done
