#!/usr/bin/env bash

test_description='Command: help'
source "$(dirname "$0")"/setup-01.sh

test_expect_success 'Test `egpg help`' '
    egpg help | grep "Commands and their options are listed below."
'

test_expect_success 'Test `egpg --help`' '
    egpg --help | grep "Commands and their options are listed below."
'

test_expect_success 'Test `egpg -h`' '
    egpg -h | grep "Commands and their options are listed below."
'

test_done
