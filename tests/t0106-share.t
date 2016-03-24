#!/usr/bin/env bash

test_description='Command: set'
source "$(dirname "$0")"/setup-01.sh

test_expect_success 'Test `egpg set share yes`' '
    egpg init &&
    source "$HOME/.bashrc" &&

    [[ "$(egpg info | grep SHARE)" == "SHARE=" ]] &&
    egpg set share yes &&
    [[ "$(egpg info | grep SHARE)" == "SHARE=yes" ]]
'

test_done
