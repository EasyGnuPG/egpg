# This file should be sourced by all test-scripts

cd "$(dirname "$0")"
source ./sharness.sh

EGPG="$(dirname $SHARNESS_TEST_DIRECTORY)/src/egpg.sh"
[[ ! -x $EGPG ]] && echo "Could not find egpg.sh" &&  exit 1

egpg() { "$EGPG" "$@" ; }

export EGPG_DIR="$SHARNESS_TRASH_DIRECTORY/.egpg"
rm -rf "$EGPG_DIR" ; mkdir -p "$EGPG_DIR"
[[ ! -d "$EGPG_DIR" ]] && echo "Could not create '$EGPG_DIR'" && exit 1

# Set the homedir for GnuPG.
export GNUPGHOME="$SHARNESS_TEST_DIRECTORY/gnupg/"
mkdir -p "$GNUPGHOME"
chmod 700 "$GNUPGHOME"
