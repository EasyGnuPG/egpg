#!/usr/bin/env bash

test_description='Command: key import'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg key export' '
    egpg_init &&
    egpg_key_fetch &&
    egpg key export | grep "Key exported to: $KEY_ID.key" &&
    [[ -f "$KEY_ID.key" ]]
'

test_expect_success 'egpg key import (key exists)' '
    egpg key import 2>&1 | grep "There is already a valid key."
'

test_expect_success 'egpg key import (no file argument)' '
    egpg key delete &&
    egpg key import 2>&1 | grep "Usage"
'

test_expect_success 'egpg key import (non existing file)' '
    egpg key import no-file.key 2>&1 | grep "Cannot find file: "
'

test_expect_success 'egpg key import' '
    egpg key import "$KEY_ID.key" &&
    [[ $(egpg key | grep "^id: " | cut -d" " -f2) == $KEY_ID ]]
'

test_done
