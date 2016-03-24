# This file should be sourced by all test-scripts

cd "$(dirname "$0")"
source ./sharness.sh

EGPG="$(dirname $SHARNESS_TEST_DIRECTORY)/src/egpg.sh"
[[ ! -x $EGPG ]] && echo "Could not find egpg.sh" &&  exit 1

egpg() { "$EGPG" "$@" ; }

unset  EGPG_DIR

export HOME="$SHARNESS_TRASH_DIRECTORY"
export GNUPGHOME="$SHARNESS_TEST_DIRECTORY/gnupg/"

export KEY_ID="D44186C07EA858BD"

export CONTACT_1="290F15FEDA94668A"
export CONTACT_2="C95634F06073B549"
export CONTACT_3="262A29CB12F046E8"
