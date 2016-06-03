#!/usr/bin/env bash

test_description='Command: key join'
source "$(dirname "$0")"/setup.sh

split() {
    rm -rf "$EGPG_DIR" &&
    egpg_init &&
    egpg_key_fetch &&

    echo "$DONGLE" | egpg key split | grep "The key was split successfully." &&

    ls "$EGPG_DIR"/.gnupg/$KEY_ID.key.* &&
    ls "$DONGLE"/.gnupg/$KEY_ID.key.* &&
    ls $KEY_ID.key.* &&
    egpg info | grep "DONGLE=\"$DONGLE\""
}

test_expect_success 'egpg key join' '
    split &&
    egpg key join | grep "The key was recombined and imported successfully."
'

test_expect_success 'egpg key join (key not split)' '
    split &&
    egpg key join &&
    egpg key join 2>&1 | grep "The key is not split."
'

test_expect_success 'egpg key join (no partial key on dongle)' '
    split &&
    rm "$DONGLE"/.gnupg/$KEY_ID.key.* &&
    egpg key join 2>&1 | grep "Could not find partial key for $KEY_ID on $DONGLE/.gnupg/"
'

test_expect_success 'egpg key join (no dongle directory)' '
    split &&
    rm -rf "$DONGLE"/.gnupg &&
    egpg key join 2>&1 | grep "Directory not found: $DONGLE/.gnupg"
'

test_expect_success 'egpg key join (no dongle directory)' '
    split &&
    rm -rf "$DONGLE" &&
    egpg key join 2>&1 | grep "The dongle directory not found: $DONGLE" &&
    mkdir -p "$DONGLE"
'

test_done
