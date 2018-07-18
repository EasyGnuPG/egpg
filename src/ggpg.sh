#!/bin/bash

# include all the functions defined by egpg
source $(dirname $0)/egpg.sh

main() {
    yad --text "Would you like to start EasyGnuPG?" \
        --button=gtk-no:1 --button=gtk-yes:0

    local gnupg_version=$(gpg_version)
    [[ ${gnupg_version%.*} == "2.2" ]] || fail "These scripts are supposed to work with GnuPG 2.2"

    # set config variables
    export EGPG_DIR="${EGPG_DIR:-$HOME/.egpg}"
    [[ -d "$EGPG_DIR" ]] || fail "No directory '$EGPG_DIR'\nTry first: $(basename $0) init"
    config

}

# call the main function, unless the script
# is sourced from another one
unset BASH_SOURCE 2>/dev/null
[[ $0 != $BASH_SOURCE ]] || main "$@"
