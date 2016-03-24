source "$(dirname "$0")"/setup-01.sh

test_expect_success 'Init and import the test key and contacts' '
    egpg init &&
    source "$HOME/.bashrc" &&

    egpg migrate | grep -e "Importing key from: $GNUPGHOME" -e "Importing contacts from: $GNUPGHOME" &&
    local key_id=$(egpg key | grep "^id: " | cut -d" " -f2) &&
    [[ $key_id == $KEY_ID ]] &&

    echo "command-fd 0" >> "$HOME/.egpg/.gnupg/gpg.conf"
'
