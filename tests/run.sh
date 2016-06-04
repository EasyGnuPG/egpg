#!/usr/bin/env bash

opts=''
if [[ $1 == '-d' || $1 == '--debug' ]]; then
    opts='--verbose'
    shift
fi

pattern=${@:-*.t}
set -e
cd "$(dirname "$0")"
BLUE='\033[0;34m'
NOCOLOR='\033[0m'
for t in $(ls $pattern); do
    [[ ${t: -2} == ".t" ]] || continue
    [[ -x $t ]] || continue
    echo -e "\n${BLUE}=> ./$t${NOCOLOR}"
    ./$t $opts
done
#prove $pattern

# Example:
#     tests/run.sh
#     tests/run.sh t09-sign.t t10-verify.t
#     tests/run.sh t2*
#     tests/run.sh *-key-*
