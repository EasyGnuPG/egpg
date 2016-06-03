#!/usr/bin/env bash

test_description='Command: default'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg default' '
    egpg_init &&
    egpg_migrate &&
    egpg default &&
    [[ -d "$HOME/.gnupg-old" ]] &&
    [[ ! -d "$HOME/.egpg/.gnupg" ]] &&
    local gnupghome=$(egpg info | grep "GNUPGHOME" | cut -d= -f2) &&
    gnupghome=${gnupghome:1:-1} &&
    [[ "$gnupghome" == "$GNUPGHOME" ]]
'

test_expect_success 'egpg default (already done)' '
    egpg default 2>&1 | grep "It is already using the default GNUPGHOME."
'

test_done
