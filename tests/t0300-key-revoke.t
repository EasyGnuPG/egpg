#!/usr/bin/env bash

test_description='Revoke the key'
source "$(dirname "$0")"/setup-03.sh

sleep 5 # wait for the revocation certificate to be created

test_expect_success 'Revoke a key' '
    echo y | egpg revoke 2>&1 | grep "revocation certificate imported"
'

test_done
