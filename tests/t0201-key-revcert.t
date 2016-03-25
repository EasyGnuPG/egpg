#!/usr/bin/env bash

test_description='Create a revocation certificate'
source "$(dirname "$0")"/setup-02.sh

test_expect_success 'Make sure that `haveged` is started' '
    [[ -n "$(ps ax | grep -v grep | grep haveged)" ]]
'

test_expect_success 'Generate a key' '
    egpg_init &&
    egpg key gen test1@example.org "Test 1" -n 2>&1 | grep "Excellent! You created a fresh GPG key."
'

test_expect_success 'Test `key revcert`' '
    local key_id=$(egpg key | grep "^id: " | cut -d: -f2) &&
    key_id=$(echo $key_id) &&
    local revoke_file="$EGPG_DIR/.gnupg/$key_id.revoke" &&
    [[ -f "$revoke_file" ]] &&
    rm -f "$revoke_file" &&

    egpg key revcert "test" &&
    [[ -f "$revoke_file" ]]
'

test_done
