#!/usr/bin/env bash

test_description='Command: contact ls'
source "$(dirname "$0")"/setup-01.sh

test_expect_success 'Init' '
    egpg init &&
    source "$HOME/.bashrc" &&
    egpg key fetch | grep -e "Importing key from: $GNUPGHOME"
'

test_expect_success 'egpg contact ls' '
    [[ $(egpg contact ls | grep "^id:" | wc -l) == 1 ]] &&
    [[ $(egpg contact ls | grep "^id:" | cut -d" " -f2) == $KEY_ID ]]
'

test_expect_success 'egpg contact list' '
    [[ $(egpg contact list | grep "^id:" | wc -l) == 1 ]]
'

test_expect_success 'egpg contact show <key-id>' '
    [[ $(egpg contact show $KEY_ID | grep "^id:" | wc -l) == 1 ]] &&
    [[ $(egpg contact show XYZ | grep "^id:" | wc -l) == 0 ]]
'

test_expect_success 'egpg contact show <email>' '
    [[ $(egpg contact show test1@example.org | grep "^id:" | wc -l) == 1 ]] &&
    [[ $(egpg contact show xyz@example.org | grep "^id:" | wc -l) == 0 ]]
'

test_expect_success 'egpg contact find <match>' '
    [[ $(egpg contact find test1 | grep "^id:" | wc -l) == 1 ]] &&
    [[ $(egpg contact find "Test 1" | grep "^id:" | wc -l) == 1 ]] &&
    [[ $(egpg contact find xyz | grep "^id:" | wc -l) == 0 ]]
'

test_expect_success 'egpg contact ls -r' '
    [[ $(egpg contact ls -r | grep "^uid " | sed -e "s/uid \+//") == "Test 1 <test1@example.org>" ]] &&
    [[ $(egpg contact ls --raw | grep "^uid " | sed -e "s/uid \+//") == "Test 1 <test1@example.org>" ]]
'

test_expect_success 'egpg contact ls -c' '
    [[ $(egpg contact ls -c | grep fpr) == "fpr:::::::::669BDE5EB80FE5F18ABA7584D44186C07EA858BD:" ]] &&
    [[ $(egpg contact ls --colons | grep fpr) == "fpr:::::::::669BDE5EB80FE5F18ABA7584D44186C07EA858BD:" ]]
'

test_done
