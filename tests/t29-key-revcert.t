#!/usr/bin/env bash

test_description='Command: key revcert'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg key revcert' '
    egpg_init &&
    egpg_key_fetch &&
    egpg key revcert "test" &&
    local key_id=$(egpg key | grep "^id: " | cut -d" " -f2) &&
    local revoke_file="$EGPG_DIR/.gnupg/$key_id.revoke" &&
    [[ -f "$revoke_file" ]]
'

test_done
