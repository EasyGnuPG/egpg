#!/bin/bash

cd $(dirname $0)
export RONN_STYLE="$(pwd)"
ronn --manual="Easy GnuPG" \
     --organization="dashohoxha" \
     --style="toc,80c,dark" \
     egpg.1.ronn
