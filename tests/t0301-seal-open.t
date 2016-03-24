#!/usr/bin/env bash

test_description='Seal and open a message'
source "$(dirname "$0")"/setup-03.sh

test_expect_success 'Test seal' '
    echo "Test 1" > test1.txt &&
    egpg seal test1.txt &&
    [[ -f test1.txt.sealed ]] &&
    [[ ! -f test1.txt ]]
'

test_expect_success 'Test open' '
    egpg open test1.txt.sealed 2>&1 | grep "gpg: Good signature from \"Test 1 <test1@example.org>\"" &&
    [[ -f test1.txt.sealed ]] &&
    [[ -f test1.txt ]] &&
    cat test1.txt &&
    [[ $(cat test1.txt) == "Test 1" ]]
'

test_expect_success 'Test seal with recipients' '
    rm -f test1.txt.sealed &&
    echo -e "y\ny" | egpg seal test1.txt $CONTACT_1 $CONTACT_2 &&
    [[ -f test1.txt.sealed ]] &&
    [[ ! -f test1.txt ]]
'

test_done
