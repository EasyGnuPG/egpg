#!/usr/bin/env bash

test_description='Command: key renew'
source "$(dirname "$0")"/setup.sh

init() {
    egpg_init &&
    egpg_key_fetch
}

check_date() {
    sleep 1 &&
    local date1=$(egpg key | grep "^sign: " | head -n 1 | cut -d" " -f4) &&
    local date2=$(date +%F --date="$(echo "$@")") &&
    [[ $date1 == $date2 ]]
}

test_expect_success 'egpg key renew' '
    init &&
    egpg key renew &&
    check_date 1 month
'

test_expect_success 'egpg key expiration' '
    egpg key expiration &&
    check_date 1 month
'

test_expect_success 'egpg key renew 2025-10-15' '
    egpg key renew 2025-10-15 &&
    check_date 2025-10-15
'

test_expect_success 'egpg key renew 2 years' '
    egpg key renew 2 years &&
    check_date 2 years
'

test_expect_success 'egpg key renew Nov 5 2025' '
    egpg key renew Nov 5 2025 &&
    check_date Nov 5 2025
'

test_expect_success 'Test key renew Dec 10' '
    egpg key renew Dec 10 &&
    check_date Dec 10
'

test_done
