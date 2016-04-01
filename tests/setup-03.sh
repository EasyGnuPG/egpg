source "$(dirname "$0")"/setup-02.sh

send_gpg_commands_from_stdin() {
    echo "command-fd 0" >> "$HOME/.egpg/.gnupg/gpg.conf"
}

test_expect_success 'Import the test key and contacts' '
    egpg migrate 2>&1 | grep -e "Importing key from: $GNUPGHOME" -e "Importing contacts from: $GNUPGHOME" &&
    [[ $(egpg key | grep "^id: " | cut -d" " -f2) == $KEY_ID ]] &&
    [[ $(egpg contact ls | grep "^id: " | wc -l) == 4 ]] &&
    send_gpg_commands_from_stdin
'
