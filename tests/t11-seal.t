#!/usr/bin/env bash

test_description='Command: seal'
source "$(dirname "$0")"/setup.sh

test_expect_success 'init' '
    egpg_init &&
    egpg_migrate &&
    echo "Test 1" > test1.txt &&
    echo "Test 2" > test2.txt &&
    send_gpg_commands_from_stdin
'

test_expect_success 'egpg seal' '
    egpg seal test1.txt &&
    [[ -f test1.txt.sealed ]] &&
    [[ ! -f test1.txt ]]
'

test_expect_success 'egpg seal <recipient>...' '
    echo -e "y\ny" | egpg seal test2.txt $CONTACT_1 $CONTACT_2 &&
    [[ -f test2.txt.sealed ]] &&
    [[ ! -f test2.txt ]]
'

test_done
