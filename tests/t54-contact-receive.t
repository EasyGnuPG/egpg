#!/usr/bin/env bash

test_description='Command: contact receive'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg contact receive <contact-id>' '
    egpg_init &&
    egpg contact receive $CONTACT_1 &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 1 ]]
'

test_expect_success 'egpg contact receive <contact-id> -s <server>' '
    egpg_init &&
    egpg contact receive $CONTACT_2 -s hkp://keys.gnupg.net &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 2 ]]
'

test_expect_success 'egpg contact receive <contact-id> --keyserver <server>' '
    egpg_init &&
    egpg contact receive $CONTACT_3 --keyserver hkp://keys.gnupg.net &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 3 ]]
'

test_done
