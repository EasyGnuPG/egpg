#!/usr/bin/env bash

test_description='Command: key fpr'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg key fpr' '
    egpg_init &&
    egpg_key_fetch &&
    egpg key fpr | grep "A944 6F79 0F9B E7C9 D108 FC67 18D1 DA4D 9E7A 4FD0"
'

test_expect_success 'egpg key fpr -q' '
    egpg key fpr -q | grep "Fingerprint barcode saved to: $KEY_ID.png" &&
    [[ -f $KEY_ID.png ]]
'

test_expect_success 'egpg key fpr --qrencode' '
    rm -f $KEY_ID.png &&
    egpg key fpr --qrencode | grep "Fingerprint barcode saved to: $KEY_ID.png" &&
    [[ -f $KEY_ID.png ]]
'

test_done
