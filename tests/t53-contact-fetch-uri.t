#!/usr/bin/env bash

test_description='Command: contact fetch-uri'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg contact fetch-uri' '
    egpg_init &&

    local contact_1="https://github.com/easygnupg/egpg/raw/gnupg-2.1/tests/gnupg/6073B549.gpg.asc" &&
    local contact_2="https://github.com/easygnupg/egpg/raw/gnupg-2.1/tests/gnupg/DA94668A.gpg.asc" &&

    egpg contact fetch-uri $contact_1 $contact_2 &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 2 ]]
'

test_done
