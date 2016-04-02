#!/usr/bin/env bash

test_description='Command: help'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg help' '
    egpg help | grep "Commands and their options are listed below."
'

test_expect_success 'egpg --help' '
    egpg --help | grep "Commands and their options are listed below."
'

test_expect_success 'egpg -h' '
    egpg -h | grep "Commands and their options are listed below."
'

test_done
