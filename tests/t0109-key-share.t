#!/usr/bin/env bash

test_description='Command: key share'
source "$(dirname "$0")"/setup-01.sh

test_expect_success 'Init and migrate' '
    egpg init &&
    source "$HOME/.bashrc" &&
    egpg key fetch | grep -e "Importing key from: $GNUPGHOME"
'

test_expect_success 'Test key share (before enabling)' '
    egpg key share 2>&1 | grep "You must enable sharing first"
'

test_expect_success 'Test key share (after enabling)' '
    egpg set share yes &&
    egpg key share 2>&1 | grep "gpg: sending key"
'

test_done
