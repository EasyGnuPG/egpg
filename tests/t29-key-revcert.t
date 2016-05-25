#!/usr/bin/env bash

test_description='Command: key revcert'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg key revcert' '
    egpg_init &&
    egpg_key_fetch &&
    egpg key revcert "test" &&
    local revcert="$EGPG_DIR/.gnupg/openpgp-revocs.d/$KEY_FPR.rev" &&
    [[ -f "$revcert" ]] &&
    [[ -f "$revcert.pdf" ]]
'

test_done
