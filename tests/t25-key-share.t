#!/usr/bin/env bash

test_description='Command: key share'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg key share (before enabling)' '
    egpg_init &&
    egpg_key_fetch &&
    egpg key share 2>&1 | grep "You must enable sharing first"
'

test_expect_success 'egpg key share (after enabling)' '
    egpg set share yes &&
    egpg key share 2>&1 | grep "gpg: sending key"
'

test_done
