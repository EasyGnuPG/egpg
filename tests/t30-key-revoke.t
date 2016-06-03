#!/usr/bin/env bash

test_description='Command: key revoke'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg key revoke (certificate not found)' '
    egpg_init &&
    egpg_key_fetch &&
    egpg key revoke 2>&1 | grep "Revocation certificate not found"
'

test_expect_success 'egpg key revoke' '
    egpg key revcert &&
    echo y | egpg key revoke &&
    egpg key 2>&1 | grep "No valid key found."
'

test_done
