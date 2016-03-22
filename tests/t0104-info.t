#!/usr/bin/env bash

test_description='Command: help'
source "$(dirname "$0")"/setup-01.sh

test_expect_success 'Test `egpg info`' '
    egpg init &&
    source "$HOME/.bashrc" &&
    egpg info | grep "^EGPG_DIR=\"$HOME/.egpg\"" &&
    egpg | grep "^EGPG_DIR=\"$HOME/.egpg\""
'

test_done
