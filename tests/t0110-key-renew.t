#!/usr/bin/env bash

test_description='Command: key renew'
source "$(dirname "$0")"/setup-01.sh

test_expect_success 'Init' '
    egpg init &&
    source "$HOME/.bashrc" &&
    egpg key fetch | grep "Importing key from: $GNUPGHOME"
'

test_expect_success 'Test key renew' '
    egpg key renew &&
    sleep 1 &&
    local expdate=$(egpg key | grep "^cert: " | cut -d" " -f4) &&
    [[ $expdate == $(date -d "1 month" +%F) ]]
'

test_expect_success 'Test key expiration' '
    egpg key expiration &&
    sleep 1 &&
    local expdate=$(egpg key | grep "^cert: " | cut -d" " -f4) &&
    [[ $expdate == $(date -d "1 month" +%F) ]]
'

test_expect_success 'Test key renew 2025-10-15' '
    egpg key renew 2025-10-15 &&
    sleep 1 &&
    local expdate=$(egpg key | grep "^cert: " | cut -d" " -f4) &&
    [[ $expdate == $(date -d 2025-10-15 +%F) ]]
'

test_expect_success 'Test key renew 2 years' '
    egpg key renew 2 years &&
    sleep 1 &&
    local expdate=$(egpg key | grep "^cert: " | cut -d" " -f4) &&
    [[ $expdate == $(date -d "2 years" +%F) ]]
'

test_expect_success 'Test key renew Nov 5 2025' '
    egpg key renew Nov 5 2025 &&
    sleep 1 &&
    local expdate=$(egpg key | grep "^cert: " | cut -d" " -f4) &&
    [[ $expdate == $(date -d "Nov 5 2025" +%F) ]]
'

test_expect_success 'Test key renew Dec 10' '
    egpg key renew Dec 10 &&
    sleep 1 &&
    local expdate=$(egpg key | grep "^cert: " | cut -d" " -f4) &&
    [[ $expdate == $(date -d "Dec 10" +%F) ]]
'

test_done
