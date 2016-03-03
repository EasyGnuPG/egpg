source "$(dirname "$0")"/setup-02.sh

test_expect_success 'Create a key' '
    cat <<-_EOF | egpg key-gen
test1@example.org
Test 1
$PASSPHRASE
$PASSPHRASE
_EOF
    egpg fingerprint
'
