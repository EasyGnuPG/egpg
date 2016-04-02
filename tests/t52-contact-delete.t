#!/usr/bin/env bash

test_description='Command: contact delete'
source "$(dirname "$0")"/setup.sh

test_expect_success 'init' '
    egpg_init &&
    egpg_migrate &&
    send_gpg_commands_from_stdin
'

test_expect_success 'egpg contact delete' '
    egpg contact delete $CONTACT_3 &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 4 ]]
'

test_expect_success 'egpg contact delete (n)' '
    echo "n" | egpg contact delete $CONTACT_3 &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 4 ]]
'

test_expect_success 'egpg contact delete (y)' '
    echo "y" | egpg contact delete $CONTACT_3 &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 3 ]]
'

test_expect_success 'egpg contact delete -f' '
    egpg contact delete $CONTACT_2 -f &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 2 ]]
'

test_expect_success 'egpg contact delete --force' '
    egpg contact fetch &&
    egpg contact delete $CONTACT_2 $CONTACT_3 --force &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 2 ]]
'

test_expect_success 'egpg contact del -f' '
    egpg contact fetch &&
    egpg contact del $CONTACT_2 $CONTACT_3 -f &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 2 ]]
'

test_expect_success 'egpg contact rm -f' '
    egpg contact fetch &&
    egpg contact rm $CONTACT_2 $CONTACT_3 -f &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 2 ]]
'

test_expect_success 'egpg contact del <email> -f' '
    egpg contact fetch &&
    egpg contact del test3 test4@example.org -f &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 2 ]]
'

test_done
