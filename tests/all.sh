#!/usr/bin/env bash

cd "$(dirname "$0")"
for t in $(ls *.t); do echo $t; ./$t; done
#prove *.t
