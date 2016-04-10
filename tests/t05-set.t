#!/usr/bin/env bash

test_description='Command: set'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg set share yes' '
    egpg_init &&
    [[ "$(egpg info | grep SHARE)" == "SHARE=no" ]] &&
    egpg set share yes &&
    [[ "$(egpg info | grep SHARE)" == "SHARE=yes" ]]
'

test_done
