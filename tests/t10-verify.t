#!/usr/bin/env bash

test_description='Command: verify'
source "$(dirname "$0")"/setup.sh

test_expect_success 'init' '
    egpg_init &&
    egpg_key_fetch &&
    echo "Test 1" > test1.txt
'

test_expect_success 'egpg verify (missing signature)' '
    egpg verify test1.txt.signature 2>&1 | grep "Cannot find signature"
'

test_expect_success 'egpg verify (wrong extension)' '
    egpg verify test1.txt 2>&1 | grep "Signature file must have extension"
'

test_expect_success 'egpg verify (missing file)' '
    egpg sign test1.txt &&
    rm test1.txt &&
    egpg verify test1.txt.signature 2>&1 | grep "Cannot find file"
'

test_expect_success 'egpg verify' '
    echo "Test 1" > test1.txt &&
    egpg verify test1.txt.signature 2>&1 | grep "gpg: Good signature from \"Test 1 <test1@example.org>\""
'

test_done
