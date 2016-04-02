#!/usr/bin/env bash

test_description='Command: key fpr'
source "$(dirname "$0")"/setup.sh

test_expect_success 'egpg key fpr' '
    egpg_init &&
    egpg_key_fetch &&
    [[ $(egpg key fpr) == "669B DE5E B80F E5F1 8ABA 7584 D441 86C0 7EA8 58BD" ]]
'

test_done
