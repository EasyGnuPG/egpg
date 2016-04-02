#!/usr/bin/env bash

test_description='Command: contact export'
source "$(dirname "$0")"/setup.sh

test_expect_success 'init' '
    egpg_init &&
    egpg_migrate
'

test_expect_success 'egpg contact export <contact-id>' '
    egpg contact export $CONTACT_1 > test1.gpg.asc &&
    [[ -f test1.gpg.asc ]]
'

test_expect_success 'egpg contact export <contact-id> -o' '
    egpg contact export $CONTACT_2 -o test2.gpg.asc &&
    [[ -f test2.gpg.asc ]]
'

test_expect_success 'egpg contact export <contact-id> --output' '
    egpg contact export $CONTACT_3 --output test3.gpg.asc &&
    [[ -f test3.gpg.asc ]]
'

test_expect_success 'egpg contact exp' '
    egpg contact exp $CONTACT_1 > test4.gpg.asc &&
    [[ -f test4.gpg.asc ]]
'

test_done
