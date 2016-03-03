#!/usr/bin/env bash

test_description='Create a key'
source "$(dirname "$0")"/setup-02.sh

test_expect_success 'Generate a key' '
    rm -rf "$EGPG_DIR/.gnupg/" &&
    cat <<-_EOF | egpg key-gen test1@example.org "Test 1"
$PASSPHRASE
$PASSPHRASE
_EOF
    egpg fingerprint
'

test_expect_success 'Checking the email format' '
    rm -rf "$EGPG_DIR/.gnupg/" &&
    cat <<-_EOF | egpg key-gen test1 "Test 1"
$PASSPHRASE
$PASSPHRASE
_EOF
    test_must_fail egpg fingerprint
'

test_expect_success 'Pass email and name from stdin' '
    rm -rf "$EGPG_DIR/.gnupg/" &&
    cat <<-_EOF | egpg key-gen
test1@example.com
Test 1
$PASSPHRASE
$PASSPHRASE
_EOF
    egpg fingerprint
'

test_done
