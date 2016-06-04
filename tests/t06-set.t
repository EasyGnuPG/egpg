#!/usr/bin/env bash

test_description='Command: set'
source "$(dirname "$0")"/setup.sh

test_expect_success 'init' '
    egpg_init &&
    sed -i "$EGPG_DIR"/config.sh -e "/DEBUG/ c DEBUG=no" &&
    egpg_key_fetch
'

test_expect_success 'egpg set debug yes' '
    egpg info | grep "DEBUG=no" &&
    egpg set debug yes &&
    egpg info | grep "DEBUG=yes"
'

test_expect_success 'egpg set share yes' '
    egpg info | grep "SHARE=no" &&
    egpg set share yes &&
    egpg info | grep "SHARE=yes"
'

test_expect_success 'egpg set dongle' '
    egpg set dongle "$DONGLE" &&
    egpg info | grep "DONGLE=\"$DONGLE\""
'

test_done
