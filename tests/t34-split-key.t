#!/usr/bin/env bash

test_description='Commands when the key is split'
source "$(dirname "$0")"/setup.sh

init() {
    rm -rf "$EGPG_DIR" &&
    egpg_init &&
    egpg_migrate &&
    send_gpg_commands_from_stdin &&
    echo "$DONGLE" | egpg key split
}

test_expect_success 'init' '
    init
'

test_expect_success 'egpg sign' '
    echo "Test 1" > test1.txt &&
    egpg sign test1.txt &&
    [[ -f test1.txt.signature ]] &&
    [[ -f test1.txt ]] &&
    [[ $(cat test1.txt) == "Test 1" ]]
'

test_expect_success 'egpg verify' '
    egpg verify test1.txt.signature 2>&1 | grep "gpg: Good signature from \"Test 1 <test1@example.org>\""
'

test_expect_success 'egpg seal' '
    echo "y" | egpg seal test1.txt &&
    [[ -f test1.txt.sealed ]] &&
    [[ ! -f test1.txt ]]
'

test_expect_success 'egpg open' '
    egpg open test1.txt.sealed 2>&1 | grep "gpg: Good signature from \"Test 1 <test1@example.org>\"" &&
    [[ -f test1.txt.sealed ]] &&
    [[ -f test1.txt ]] &&
    [[ $(cat test1.txt) == "Test 1" ]]
'

test_expect_success 'egpg gpg' '
    [[ $(egpg -- -k | grep "^uid" | wc -l) == 4 ]]
'

test_expect_success 'egpg set share yes' '
    egpg set share yes &&
    egpg info | grep "SHARE=yes"
'

test_expect_success 'egpg key share' '
    egpg key share 2>&1 | grep "gpg: sending key"
'

test_expect_success 'egpg key del' '
    egpg key del &&
    egpg key 2>&1 | grep -e "No valid key found."
'

test_expect_success 'egpg key backup' '
    init &&
    egpg key backup | grep "Key saved to" &&
    [[ -f "$KEY_ID.tgz" ]]
'

test_expect_success 'egpg key pass' '
    egpg key pass 2>&1 | grep "This key is split into partial keys."
'

test_expect_success 'egpg key renew' '
    egpg key renew 2>&1 | grep "This key is split into partial keys."
'

test_expect_success 'egpg key revcert' '
    egpg key revcert "test" &&
    local revcert="$EGPG_DIR/.gnupg/openpgp-revocs.d/$KEY_FPR.rev" &&
    [[ -f "$revcert" ]]
'

test_expect_success 'egpg key revoke' '
    egpg key revoke 2>&1 | grep "This key is split into partial keys."
'

test_expect_success 'egpg contact certify' '
    echo "y" | egpg contact certify $CONTACT_1 &&
    egpg contact ls $CONTACT_1 | grep "certified by: Test 1 <test1@example.org>"
'

test_done
