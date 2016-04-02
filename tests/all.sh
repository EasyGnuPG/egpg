#!/usr/bin/env bash

set -e
cd "$(dirname "$0")"
for t in $(ls *.t); do echo $t; ./$t; done
#prove *.t
