#!/usr/bin/env bash

test_description='Command: contact pick'
source "$(dirname "$0")"/setup.sh

test_expect_success 'init' '
    egpg_init &&
    egpg_migrate &&
    egpg contact ls $CONTACT_1 | grep "^fpr:" | cut -d: -f2 | qrencode -o $CONTACT_1.png &&
    [[ -f $CONTACT_1.png ]] &&
    egpg contact del -f $CONTACT_1
'

test_expect_success 'egpg contact pick --image' '
    egpg contact pick --image $CONTACT_1.png &&
    [[ $(egpg contact ls $CONTACT_1 | grep "^id:" | cut -d" " -f2) == $CONTACT_1 ]]
'

test_done
