# Command: key test

cmd_key_test_help() {
    cat <<-_EOF
    key test
        Test command cmd_key_test.

_EOF
}

cmd_key_test() {
    echo "cmd_key_test $@"
}
