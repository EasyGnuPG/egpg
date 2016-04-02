#!/usr/bin/env bash

test_description='Command: contact search'
source "$(dirname "$0")"/setup.sh

test_expect_success 'init' '
    egpg_init &&
    send_gpg_commands_from_stdin
'

test_expect_success 'egpg contact search' '
    echo "1" | egpg contact search "egpg test key" &&
    [[ $(egpg contact ls | grep "^id:" | wc -l) == 1 ]]
'

test_expect_success 'egpg contact search -s <keyserver>' '
    echo "2" | egpg contact search "egpg test key" -s  hkp://keys.gnupg.net &&
    [[ $(egpg contact ls | grep "^id:" | wc -l) == 2 ]]
'

test_expect_success 'egpg contact search --keyserver <keyserver>' '
    echo "3" | egpg contact search "egpg test key" --keyserver  hkp://keys.gnupg.net &&
    [[ $(egpg contact ls | grep "^id:" | wc -l) == 3 ]]
'

test_done
