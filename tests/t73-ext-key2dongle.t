#!/usr/bin/env bash

test_description='Command: key2dongle'
source "$(dirname "$0")"/setup.sh

init() {
    rm -rf "$EGPG_DIR" &&
    egpg_init &&
    egpg_key_fetch
}

test_expect_success 'egpg key2dongle' '
    init &&
    egpg set dongle "$DONGLE" &&
    egpg key2dongle &&
    [[ -f "$DONGLE"/.gnupg/$KEY_GRIP_1.key ]] &&
    [[ -L "$EGPG_DIR"/.gnupg/private-keys-v1.d/$KEY_GRIP_1.key ]]
'

test_expect_success 'egpg sign' '
    echo "Test 1" > test1.txt
    egpg sign test1.txt &&
    [[ -f test1.txt.signature ]]
'

test_expect_success 'egpg key2dongle (key already in dongle)' '
    egpg key2dongle 2>&1 | grep "The key is already in dongle."
'

test_expect_success 'egpg key2dongle --reverse' '
    egpg key2dongle --reverse &&
    [[ ! -f "$DONGLE"/.gnupg/$KEY_GRIP_1.key ]] &&
    [[ -f "$EGPG_DIR"/.gnupg/private-keys-v1.d/$KEY_GRIP_1.key ]]
'

test_expect_success 'egpg key2dongle -r (key already in gnupghome)' '
    egpg key2dongle -r 2>&1 | grep "The key is already in GNUPGHOME."
'

test_expect_success 'egpg key2dongle (dongle check)' '
    init &&

    egpg key2dongle 2>&1 | grep "You need a dongle to move the key." &&

    egpg key2dongle "$DONGLE/test1" 2>&1 | grep "Dongle directory does not exist" &&

    mkdir -p "$DONGLE/test1" &&
    chmod -w "$DONGLE/test1" &&
    echo "$DONGLE/test1" | egpg key2dongle 2>&1 | grep "Dongle directory is not writable"
'

test_done
