#!/usr/bin/env bash

test_description='Command: key split'
source "$(dirname "$0")"/setup.sh

init() {
    rm -rf "$EGPG_DIR" &&
    egpg_init &&
    egpg_key_fetch
}

check() {
    local dongle=${1:-$DONGLE} &&
    local backup=${2:-$(pwd)} &&

    ls "$EGPG_DIR"/.gnupg/$KEY_ID.key.* &&
    ls "$dongle"/.gnupg/$KEY_ID.key.* &&
    ls "$backup"/$KEY_ID.key.* &&

    egpg info | grep "DONGLE=\"$dongle\""
}

test_expect_success 'egpg key split' '
    init &&
    echo "$DONGLE" | egpg key split | grep "The key was split successfully." &&
    check
'

test_expect_success 'egpg key split (set dongle)' '
    init &&
    egpg set dongle "$DONGLE" &&
    egpg key split | grep "The key was split successfully." &&
    check
'

test_expect_success 'egpg key split --dongle' '
    init &&
    mkdir -p "$DONGLE"/test &&
    egpg key split --dongle "$DONGLE/test" | grep "The key was split successfully." &&
    check "$DONGLE"/test
'

test_expect_success 'egpg key split --backup' '
    init &&
    mkdir -p "$HOME/backup" &&
    echo "$DONGLE" | egpg key split --backup "$HOME/backup" | grep "The key was split successfully." &&
    check "$DONGLE" "$HOME/backup"
'

test_expect_success 'egpg key split -d -b' '
    init &&
    mkdir -p "$DONGLE/test" &&
    mkdir -p "$HOME/backup" &&
    egpg set dongle "$DONGLE/test" &&
    egpg key split -d "$DONGLE/test" -b "$HOME/backup" | grep "The key was split successfully." &&
    check "$DONGLE/test" "$HOME/backup"
'

test_expect_success 'egpg key split (already split)' '
    init &&
    egpg set dongle "$DONGLE" &&
    egpg key split | grep "The key was split successfully." &&
    egpg key split 2>&1 | grep "The key is already split."
'

test_expect_success 'egpg key split (option checks)' '
    init &&

    egpg key split 2>&1 | grep "You need a dongle to save the partial key." &&

    echo "$DONGLE/test1" | egpg key split 2>&1 | grep "Dongle directory does not exist" &&

    mkdir -p "$DONGLE/test1" &&
    chmod -w "$DONGLE/test1" &&
    echo "$DONGLE/test1" | egpg key split 2>&1 | grep "Dongle directory is not writable" &&

    egpg set dongle "$DONGLE" &&

    egpg key split -b "$HOME/test1" 2>&1 | grep "Backup directory does not exist" &&

    mkdir -p "$HOME/test1" &&
    chmod -w "$HOME/test1" &&
    egpg key split -b "$HOME/test1" 2>&1 | grep "Backup directory is not writable"
'

test_done
