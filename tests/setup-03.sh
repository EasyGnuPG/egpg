source "$(dirname "$0")"/setup-02.sh

send_gpg_commands_from_stdin() {
    echo "command-fd 0" >> "$HOME/.egpg/.gnupg/gpg.conf"
}

test_expect_success 'Import the test key and contacts' '
    egpg migrate | grep -e "Importing key from: $GNUPGHOME" -e "Importing contacts from: $GNUPGHOME" &&

    local key_id=$(egpg key | grep "^id: " | cut -d" " -f2) &&
    [[ $key_id == $KEY_ID ]] &&

    send_gpg_commands_from_stdin
'
