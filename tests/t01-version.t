#!/usr/bin/env bash

test_description='Command: version'
source "$(dirname "$0")"/setup.sh


test_expect_success 'egpg version' '
    egpg version | grep "egpg:  EasyGnuPG"
'

test_expect_success 'egpg v' '
    egpg v | grep "egpg:  EasyGnuPG"
'

test_expect_success 'egpg -v' '
    egpg -v | grep "egpg:  EasyGnuPG"
'

test_expect_success 'egpg --version' '
    egpg --version | grep "egpg:  EasyGnuPG"
'

test_done
