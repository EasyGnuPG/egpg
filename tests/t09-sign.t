#!/usr/bin/env bash

test_description='Command: sign'
source "$(dirname "$0")"/setup.sh

test_expect_success 'init' '
    egpg_init &&
    egpg_key_fetch &&
    echo "Test 1" > test1.txt
'

test_expect_success 'egpg sign' '
    egpg sign test1.txt &&
    [[ -f test1.txt.signature ]] &&
    [[ -f test1.txt ]] &&
    [[ $(cat test1.txt) == "Test 1" ]]
'

test_done
