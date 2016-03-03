source "$(dirname "$0")"/setup-01.sh

PASSPHRASE='123'

pegpg() {
    egpg "$@" <<<"$PASSPHRASE"
}

test_expect_success 'Make sure that `haveged` is started' '
    [[ -n "$(ps ax | grep -v grep | grep haveged)" ]]
'
