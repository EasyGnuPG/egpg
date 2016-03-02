#!/usr/bin/env bash

test_description='Command: version'
source "$(dirname "$0")"/setup-01.sh


test_expect_success 'Make sure we can run `egpg version`' '
    egpg version | grep "egpg:  EasyGnuPG"
'

test_expect_success 'Make sure we can run `egpg v`' '
    egpg v | grep "egpg:  EasyGnuPG"
'

test_expect_success 'Make sure we can run `egpg -v`' '
    egpg -v | grep "egpg:  EasyGnuPG"
'

test_expect_success 'Make sure we can run `egpg --version`' '
    egpg --version | grep "egpg:  EasyGnuPG"
'

test_done
