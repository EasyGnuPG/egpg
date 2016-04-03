#!/usr/bin/env bash

test_description='Command: contact trust'
source "$(dirname "$0")"/setup.sh

test_expect_success 'init' '
    egpg_init &&
    egpg_migrate
'

test_expect_success 'egpg contact trust' '
    egpg contact trust $CONTACT_1 &&
    egpg contact ls $CONTACT_1 | grep "trust: marginal"
'

test_expect_success 'egpg contact trust -l full' '
    egpg contact trust $CONTACT_1 -l full &&
    egpg contact ls $CONTACT_1 | grep "trust: full"
'

test_expect_success 'egpg contact trust --level none' '
    egpg contact trust $CONTACT_1 --level none &&
    egpg contact ls $CONTACT_1 | grep "trust: none"
'

test_expect_success 'egpg contact trust -l unknown' '
    egpg contact trust $CONTACT_1 -l unknown &&
    [[ -z "$(egpg contact ls $CONTACT_1 | grep "trust: ")" ]]
'

test_expect_success 'egpg contact trust --level xyz' '
    egpg contact trust $CONTACT_1 --level xyz 2>&1 | grep "Unknown trust level: xyz"
'

test_expect_success 'egpg contact trust -l 0' '
    egpg contact trust $CONTACT_1 -l 0 2>&1 | grep "Unknown trust level: 0"
'

test_expect_success 'egpg contact trust --level 1 (remove)' '
    egpg contact trust $CONTACT_1 --level 1 &&
    [[ -z "$(egpg contact ls $CONTACT_1 | grep "trust: ")" ]]
'

test_expect_success 'egpg contact trust -l 2 (none)' '
    egpg contact trust $CONTACT_1 -l 2 &&
    egpg contact ls $CONTACT_1 | grep "trust: none"
'

test_expect_success 'egpg contact trust --level 3 (marginal)' '
    egpg contact trust $CONTACT_1 --level 3 &&
    egpg contact ls $CONTACT_1 | grep "trust: marginal"
'

test_expect_success 'egpg contact trust -l 4 (full)' '
    egpg contact trust $CONTACT_1 -l 4 &&
    egpg contact ls $CONTACT_1 | grep "trust: full"
'

test_done
