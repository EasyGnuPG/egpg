#!/usr/bin/env bash

test_description='Command: key recover'
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

test_expect_success 'egpg key recover (lost dongle)' '
    split &&
    rm "$DONGLE"/.gnupg/$KEY_ID.key.* &&
    egpg key recover $KEY_ID.key.* | grep "The key was recovered and imported successfully." &&
    test_must_fail ls $KEY_ID.key.* &&
    test_must_fail ls "$EGPG_DIR"/.gnupg/$KEY_ID.key.*
'

test_expect_success 'egpg key recover (lost pc)' '
    split &&
    rm "$EGPG_DIR"/.gnupg/$KEY_ID.key.* &&
    egpg key recover $KEY_ID.key.* | grep "The key was recovered and imported successfully." &&
    test_must_fail ls $KEY_ID.key.* &&
    test_must_fail ls "$DONGLE"/.gnupg/$KEY_ID.key.*
'

test_expect_success 'egpg key recover (backup file not found)' '
    split &&
    egpg key recover $KEY_ID.key.x 2>&1 | grep "File not found"
'

test_expect_success 'egpg key recover (check backup file extension)' '
    split &&
    mv $KEY_ID.key.* $KEY_ID.key.xyz
    egpg key recover $KEY_ID.key.xyz 2>&1 | grep "The name of the backup partial key must be like"
'

test_expect_success 'egpg key recover (corrupted backup)' '
    split &&
    mv $KEY_ID.key.* $KEY_ID.key.123 &&
    egpg key recover $KEY_ID.key.123 2>&1 | grep "Could not recover the key."
'

test_expect_success 'egpg key recover (key not split)' '
    split &&
    cp $KEY_ID.key.* key.bak &&
    egpg key join &&
    mv key.bak $KEY_ID.key.012 &&
    egpg key recover $KEY_ID.key.012 2>&1 | grep "The key $KEY_ID is already available as a full key."
'

test_expect_success 'egpg key recover (missing partial key)' '
    split &&
    rm "$EGPG_DIR"/.gnupg/$KEY_ID.key.* &&
    rm "$DONGLE"/.gnupg/$KEY_ID.key.* &&
    egpg key recover $KEY_ID.key.* 2>&1 | grep "Could not find an other partial key for $KEY_ID"
'

test_expect_success 'egpg key recover (missing partial key)' '
    split &&
    rm "$EGPG_DIR"/.gnupg/$KEY_ID.key.* &&
    rm -rf "$DONGLE"/.gnupg/ &&
    egpg key recover $KEY_ID.key.* 2>&1 | grep "Directory not found: $DONGLE/.gnupg"
'

test_expect_success 'egpg key recover (missing dongle dir)' '
    split &&
    rm "$EGPG_DIR"/.gnupg/$KEY_ID.key.* &&
    rm -rf "$DONGLE" &&
    egpg key recover $KEY_ID.key.* 2>&1 | grep "The dongle directory not found: $DONGLE"
'

test_done
