#!/usr/bin/env bash

test_description='Key revocation'
source "$(dirname "$0")"/setup-02.sh

test_expect_success 'Make sure that `haveged` is started' '
    [[ -n "$(ps ax | grep -v grep | grep haveged)" ]]
'

test_expect_success 'Generate a key' '
    egpg_init &&
    egpg key gen test1@example.org "Test 1" -n 2>&1 | grep "Excellent! You created a fresh GPG key."
'

test_expect_success 'Revoke a key (certificate not found)' '
    local key_id=$(egpg key | grep "^id: " | cut -d: -f2) &&
    key_id=$(echo $key_id) &&
    revoke_file="$EGPG_DIR/.gnupg/$key_id.revoke" &&

    mv "$revoke_file" "$revoke_file.bak"
    egpg key revoke 2>&1 | grep "Revocation certificate not found"
'

test_expect_success 'Revoke a key' '
    mv "$revoke_file.bak" "$revoke_file"
    echo y | egpg key revoke 2>&1 | grep "revocation certificate imported"
'

test_done
