# This file should be sourced by all test-scripts

cd "$(dirname "$0")"
source ./sharness.sh

EGPG="$(dirname $SHARNESS_TEST_DIRECTORY)/src/egpg.sh"
[[ ! -x $EGPG ]] && echo "Could not find egpg.sh" &&  exit 1

egpg() { "$EGPG" "$@" ; }

export HOME="$SHARNESS_TRASH_DIRECTORY"
export EGPG_DIR="$HOME/.egpg"
export GNUPGHOME="$SHARNESS_TEST_DIRECTORY/gnupg/"
