#!/usr/bin/env bash

test_description='Command: help'
source "$(dirname "$0")"/setup-01.sh

egpg_init() {
    egpg init "$@" &&
    source "$HOME/.bashrc"
}

test_expect_success 'Test `egpg`' '
    [[ ! -d "$HOME/.egpg" ]] &&
    egpg 2>&1 | grep "Try first: egpg.sh init"
'

test_expect_success 'Test `egpg init`' '
    [[ ! -d "$HOME/.egpg" ]] &&
    egpg_init &&
    [[ -d "$HOME/.egpg" ]] &&
    egpg 2>&1 | grep "Try first:  egpg.sh key gen"
'

test_expect_success 'Test `egpg key fetch`' '
    egpg key fetch &&
    local key_id=$(egpg key show | grep "^id: " | cut -d" " -f2) &&
    [[ $key_id == $KEY_ID ]]
'

test_expect_success 'Test `egpg init dir1` (keep old dir)' '
    [[ ! -d "$HOME/.egpg1" ]] &&
    egpg_init "$HOME/.egpg1"
    [[ -d "$HOME/.egpg1" ]] &&
    [[ -d "$HOME/.egpg" ]] &&
    egpg | grep "^EGPG_DIR=\"$HOME/.egpg1\""
'

test_expect_success 'Test `egpg init dir2` (keep old dir)' '
    [[ ! -d "$HOME/.egpg2" ]] &&
    egpg_init "$HOME/.egpg2" <<< "n"
    [[ -d "$HOME/.egpg2" ]] &&
    [[ -d "$HOME/.egpg1" ]] &&
    egpg | grep "^EGPG_DIR=\"$HOME/.egpg2\""
'

test_expect_success 'Test `egpg init dir1` (remove old dir)' '
    [[ -d "$HOME/.egpg1" ]] &&
    [[ -d "$HOME/.egpg2" ]] &&
    egpg_init "$HOME/.egpg1" <<< "y"
    [[ -d "$HOME/.egpg1" ]] &&
    [[ ! -d "$HOME/.egpg2" ]] &&
    egpg | grep "^EGPG_DIR=\"$HOME/.egpg1\""
'

test_expect_success 'Test `egpg init` (remove old dir)' '
    [[ -d "$HOME/.egpg" ]] &&
    [[ -d "$HOME/.egpg1" ]] &&
    egpg_init <<< "y"
    [[ -d "$HOME/.egpg" ]] &&
    [[ ! -d "$HOME/.egpg1" ]] &&
    egpg | grep "^EGPG_DIR=\"$HOME/.egpg\"" &&
    local key_id=$(egpg key show | grep "^id: " | cut -d" " -f2) &&
    [[ $key_id == $KEY_ID ]]
'

test_done
