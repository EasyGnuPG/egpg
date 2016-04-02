#!/usr/bin/env bash

test_description='Command: contact import'
source "$(dirname "$0")"/setup.sh

test_expect_success 'init' '
    egpg_init "$HOME/.egpg1" &&
    egpg_contact_fetch &&
    egpg contact export $CONTACT_1 > contact1.txt &&
    egpg contact export $CONTACT_2 > contact2.txt &&
    egpg contact export $CONTACT_2 $CONTACT_3 > contact3.txt &&
    egpg_init
'

test_expect_success 'egpg contact import <file>' '
    egpg contact import contact1.txt &&
    [[ $(egpg contact ls | grep "^id:" | wc -l) == 1 ]]
'

test_expect_success 'egpg contact imp <file>' '
    egpg contact imp contact2.txt &&
    [[ $(egpg contact ls | grep "^id:" | wc -l) == 2 ]]
'

test_expect_success 'egpg contact add <file>' '
    egpg contact add contact3.txt &&
    [[ $(egpg contact ls | grep "^id:" | wc -l) == 3 ]]
'

test_done
