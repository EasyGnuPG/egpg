#!/usr/bin/env bash

test_description='Command: key pass'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg key pass' '
    egpg_init &&
    egpg_key_fetch &&

    setup_autopin "0123456789" &&
    egpg key pass &&

    echo "Test 1" > test1.txt &&
    egpg sign test1.txt &&
    egpg verify test1.txt.signature 2>&1 | grep "gpg: Good signature"
'

test_done
