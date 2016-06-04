#!/usr/bin/env bash

test_description='Command: key gen -n'
source "$(dirname "$0")"/setup.sh

test_expect_success 'Make sure that `haveged` is started' '
    [[ -n "$(ps -ax | grep -v grep | grep -v defunct | grep haveged)" ]]
'

test_expect_success 'egpg key gen <email> <"full name"> -n' '
    egpg_init &&
    egpg key gen -n test1@example.org "Test 1" &&
    [[ $(egpg key | grep uid:) == "uid: Test 1 <test1@example.org>" ]]
'

test_expect_success 'egpg key gen <nonvalid-email> <"full name"> -n' '
    egpg_init <<< "y" &&
    egpg key gen -n test1 "Test 1" 2>&1 | grep "This email address (test1) does not appear to be valid" &&
    egpg key 2>&1 | grep "No valid key found."
'

test_expect_success 'egpg key gen --no-passphrase' '
    egpg_init <<< "y" &&
    cat <<-_EOF | egpg key gen --no-passphrase &&
test1@example.org
Test 1
_EOF
    [[ $(egpg key | grep uid:) == "uid: Test 1 <test1@example.org>" ]]
'

test_done
