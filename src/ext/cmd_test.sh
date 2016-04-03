# Command: test

cmd_test_help() {
    cat <<-_EOF
    test
        Test command cmd_test.

_EOF
}

cmd_test() {
    echo "cmd_test $@"
}
