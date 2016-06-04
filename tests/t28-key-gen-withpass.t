#!/usr/bin/env bash

test_description='Command: key gen'
source "$(dirname "$0")"/setup.sh

test_expect_success 'Make sure `haveged` is started' '
    [[ -n "$(ps -ax | grep -v grep | grep -v defunct | grep haveged)" ]]
'

test_expect_success 'init' '
    egpg_init &&
    setup_autopin &&
    send_gpg_commands_from_stdin
'

test_expect_success 'egpg key gen' '
    cat <<-_EOF | egpg key gen test1@example.org "Test 1" &&
123456
123456
_EOF
    [[ $(egpg key | grep uid:) == "uid: Test 1 <test1@example.org>" ]]
'

test_done
