#!/usr/bin/env bash

test_description='Command: key restore'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg key backup' '
    egpg_init &&
    egpg_key_fetch &&
    egpg key backup | grep "Key saved to" &&
    [[ -f "$KEY_ID.tgz" ]]
'

test_expect_success 'egpg key restore (key exists)' '
    egpg key restore 2>&1 | grep "There is already a valid key."
'

test_expect_success 'egpg key restore (no file argument)' '
    egpg key delete &&
    egpg key restore 2>&1 | grep "Usage"
'

test_expect_success 'egpg key restore (non existing file)' '
    egpg key restore no-file.key 2>&1 | grep "Cannot find file: "
'

test_expect_success 'egpg key restore' '
    egpg key restore "$KEY_ID.tgz" &&
    [[ $(egpg key | grep "^id: " | cut -d" " -f2) == $KEY_ID ]]
'

test_done
