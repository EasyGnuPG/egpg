#!/usr/bin/env bash

test_description='Command: open'
source "$(dirname "$0")"/setup.sh

test_expect_success 'init' '
    egpg_init &&
    egpg_migrate &&
    echo "Test 1" > test1.txt
'

test_expect_success 'egpg seal' '
    egpg seal test1.txt &&
    [[ -f test1.txt.sealed ]] &&
    [[ ! -f test1.txt ]]
'

test_expect_success 'egpg open' '
    egpg open test1.txt.sealed 2>&1 | grep "gpg: Good signature from \"Test 1 <test1@example.org>\"" &&
    [[ -f test1.txt.sealed ]] &&
    [[ -f test1.txt ]] &&
    [[ $(cat test1.txt) == "Test 1" ]]
'

test_done
