#!/usr/bin/env bash

test_description='Command: --,gpg'
source "$(dirname "$0")"/setup-03.sh

test_expect_success 'Test `egpg --`' '
    [[ $(egpg -- -k | grep "^uid" | wc -l) == 4 ]]
'

test_expect_success 'Test `egpg gpg`' '
    local key_id=$(egpg gpg -K --with-colon | grep "^sec:" | cut -d: -f5) &&
    [[  $key_id == $KEY_ID ]]
'

test_done
