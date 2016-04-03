#!/usr/bin/env bash

test_description='Command: contact certify'
source "$(dirname "$0")"/setup.sh

test_expect_success 'init' '
    egpg_init &&
    egpg_migrate &&
    send_gpg_commands_from_stdin
'

test_expect_success 'egpg contact certify' '
    echo "y" | egpg contact certify $CONTACT_1 &&
    egpg contact ls $CONTACT_1 | grep "certified by: Test 1 <test1@example.org>"
'

test_done
