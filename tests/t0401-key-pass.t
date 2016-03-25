#!/usr/bin/env bash

test_description='Change the key passphrase'
source "$(dirname "$0")"/setup-04.sh

test_expect_success 'Make sure that `haveged` is started' '
    [[ -n "$(ps ax | grep -v grep | grep haveged)" ]]
'

test_expect_success 'Generate a key without a passphrase' '
    egpg_init &&
    egpg key gen test1@example.org "Test 1" -n 2>&1 | grep "Excellent! You created a fresh GPG key." &&
    [[ $(egpg key | grep uid:) == "uid: Test 1 <test1@example.org>" ]]
'

test_expect_success 'Change the passphrase of the key' '
    setup_autopin "0123456789" &&
    egpg key pass &&

    echo "Test 1" > test1.txt &&
    egpg sign test1.txt &&
    egpg verify test1.txt 2>&1 | grep "gpg: Good signature"
'

test_done
