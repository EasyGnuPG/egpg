#!/usr/bin/env bash

test_description='Command: key backup'
source "$(dirname "$0")"/setup.sh

test_expect_success 'key backup (no valid key)' '
    egpg_init &&
    egpg key backup 2>&1 | grep "No valid key."
'

test_expect_success 'key backup' '
    egpg_key_fetch &&
    egpg key backup | grep "Key saved to" &&
    [[ -f "$KEY_ID.tgz" ]]
'

test_expect_success 'key backup <key-id>' '
    rm -f "$KEY_ID.tgz" &&
    egpg key backup $KEY_ID | grep "Key saved to" &&
    [[ -f "$KEY_ID.tgz" ]]
'

test_expect_success 'key backup -q' '
    rm -f "$KEY_ID.tgz" &&
    egpg key backup -q | grep "$KEY_ID.tgz.base64.pdf" &&
    [[ -f "$KEY_ID.tgz" ]] &&
    [[ -f "$KEY_ID.tgz.base64.pdf" ]]
'

test_done
