#!/usr/bin/env bash

test_description='Command: contact ls'
source "$(dirname "$0")"/setup.sh

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
    egpg contact ls -r    | grep "^uid " | grep "Test 1 <test1@example.org>" &&
    egpg contact ls --raw | grep "^uid " | grep "Test 1 <test1@example.org>"
'

test_expect_success 'egpg contact ls -c' '
    [[ $(egpg contact ls -c | grep fpr | head -1) == "fpr:::::::::A9446F790F9BE7C9D108FC6718D1DA4D9E7A4FD0:" ]] &&
    [[ $(egpg contact ls --colons | grep fpr | head -1) == "fpr:::::::::A9446F790F9BE7C9D108FC6718D1DA4D9E7A4FD0:" ]]
'

test_done
