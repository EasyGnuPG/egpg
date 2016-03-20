#!/usr/bin/env bash

test_description='Command: help'
source "$(dirname "$0")"/setup-01.sh

test_expect_success 'Test `egpg`' '
    [[ ! -d $EGPG_DIR ]] &&
    egpg 2>&1 | grep "Try first: egpg.sh init"
'

test_expect_success 'Test `egpg init`' '
    egpg init &&
    [[ -d $EGPG_DIR ]] &&
    egpg 2>&1 | grep "Try first:  egpg.sh key gen"
'

test_expect_success 'Test `egpg key gen`' '
    egpg key gen test1@example.org "Test1" -n | grep "Excellent! You created a fresh GPG key." &&
    [[ -n $(egpg key show | grep "^id: ") ]]
'

test_done
