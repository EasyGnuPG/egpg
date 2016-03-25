#!/usr/bin/env bash

test_description='Create a key without a passphrase'
source "$(dirname "$0")"/setup-02.sh

test_expect_success 'Make sure that `haveged` is started' '
    [[ -n "$(ps ax | grep -v grep | grep haveged)" ]]
'

test_expect_success 'Generate a key' '
    egpg_init &&
    egpg key gen test1@example.org "Test 1" -n 2>&1 | grep "Excellent! You created a fresh GPG key." &&
    [[ $(egpg key | grep uid:) == "uid: Test 1 <test1@example.org>" ]]
'

test_expect_success 'Checking the email format' '
    egpg_init &&
    egpg key gen test1 "Test 1" -n 2>&1 | grep "This email address (test1) does not appear to be valid" &&
    egpg key 2>&1 | grep "No valid key found."
'

test_expect_success 'Pass email and name from stdin' '
    egpg_init &&
    cat <<-_EOF | egpg key gen -n 2>&1 | grep "Excellent! You created a fresh GPG key."
test1@example.org
Test 1
_EOF
    [[ $(egpg key | grep uid:) == "uid: Test 1 <test1@example.org>" ]]
'

test_done
