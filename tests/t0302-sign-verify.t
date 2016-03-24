#!/usr/bin/env bash

test_description='Sign and verify a message'
source "$(dirname "$0")"/setup-03.sh

test_expect_success 'Test sign' '
    echo "Test 1" > test1.txt &&
    egpg sign test1.txt &&
    [[ -f test1.txt.signature ]] &&
    [[ -f test1.txt ]] &&
    [[ $(cat test1.txt) == "Test 1" ]]
'

test_expect_success 'Test verify' '
    [[ -f test1.txt ]] &&
    [[ -f test1.txt.signature ]] &&
    egpg verify test1.txt 2>&1 | grep "gpg: Good signature from \"Test 1 <test1@example.org>\""
'

test_expect_success 'Test missing signature' '
    rm -f test1.txt.signature &&
    egpg verify test1.txt 2>&1 | grep "Cannot find file"
'

test_done
