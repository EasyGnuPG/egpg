# Command: contact test

cmd_contact_test_help() {
    cat <<-_EOF
    contact test
        Test command cmd_contact_test.

_EOF
}

cmd_contact_test() {
    echo "cmd_contact_test $@"
}
