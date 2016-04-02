#!/usr/bin/env bash

test_description='Command: info'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg info' '
    egpg_init &&
    egpg info | grep "^EGPG_DIR=\"$HOME/.egpg\"" &&
    egpg | grep "^EGPG_DIR=\"$HOME/.egpg\""
'

test_done
