#!/usr/bin/env bash

test_description='Command: init'
source "$(dirname "$0")"/setup.sh
extend_test_key_expiration     # make sure that the test key has not expired

test_expect_success 'egpg' '
    [[ ! -d "$HOME/.egpg" ]] &&
    egpg 2>&1 | grep "Try first: egpg.sh init"
'

test_expect_success 'egpg init' '
    [[ ! -d "$HOME/.egpg" ]] &&
    egpg_init &&
    [[ -d "$HOME/.egpg" ]] &&
    [[ -f "$HOME/.egpg/config.sh" ]] &&
    egpg 2>&1 | grep "Try first:  egpg.sh key gen"
'

test_expect_success 'egpg key fetch' '
    egpg key fetch &&
    local key_id=$(egpg key show | grep "^id: " | cut -d" " -f2) &&
    [[ $key_id == $KEY_ID ]]
'

test_expect_success 'egpg init dir1 (keep old dir)' '
    [[ ! -d "$HOME/.egpg1" ]] &&
    egpg_init "$HOME/.egpg1" &&
    [[ -d "$HOME/.egpg1" ]] &&
    [[ -d "$HOME/.egpg" ]] &&
    egpg | grep "^EGPG_DIR=\"$HOME/.egpg1\""
'

test_expect_success 'egpg init dir2 (keep old dir)' '
    [[ ! -d "$HOME/.egpg2" ]] &&
    egpg_init "$HOME/.egpg2" <<< "n" &&
    [[ -d "$HOME/.egpg2" ]] &&
    [[ -d "$HOME/.egpg1" ]] &&
    egpg | grep "^EGPG_DIR=\"$HOME/.egpg2\""
'

test_expect_success 'egpg init dir1 (remove old dir)' '
    [[ -d "$HOME/.egpg1" ]] &&
    [[ -d "$HOME/.egpg2" ]] &&
    egpg_init "$HOME/.egpg1" <<< "y" &&
    [[ -d "$HOME/.egpg1" ]] &&
    [[ ! -d "$HOME/.egpg2" ]] &&
    egpg | grep "^EGPG_DIR=\"$HOME/.egpg1\""
'

test_expect_success 'egpg init (remove old dir)' '
    [[ -d "$HOME/.egpg" ]] &&
    [[ -d "$HOME/.egpg1" ]] &&
    egpg_init <<< "y" &&
    [[ -d "$HOME/.egpg" ]] &&
    [[ ! -d "$HOME/.egpg1" ]] &&
    egpg | grep "^EGPG_DIR=\"$HOME/.egpg\"" &&
    local key_id=$(egpg key show | grep "^id: " | cut -d" " -f2) &&
    [[ $key_id == $KEY_ID ]]
'

test_done
