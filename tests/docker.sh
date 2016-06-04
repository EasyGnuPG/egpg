#!/bin/bash

# go to the directory of the script
cd $(dirname $0)

IMAGE=egpg-image
CONTAINER=egpg

docker() {
    sudo docker "$@"
}

cmd_help() {
    cat <<-_EOF
Usage: $0 ( build | create | test | start | stop | shell | erase )

First build the image and create the containter:
    $0 build [dockerfile/ubuntu-16.04]
    $0 create

Then run tests like this:
    $0 test -d t01-version.t
    $0 test t0*
    $0 test

You can also enter the shell of the container to run the tests:
    $0 shell
    su testuser
    ./run.sh t1* t2*

When testing is done, clean up the container and the image:
    $0 erase

_EOF
}

cmd_build() {
    local dockerfile=${1:-"dockerfile/ubuntu-16.04"}
    docker build --tag=$IMAGE --file="$dockerfile" .
}

cmd_create() {
    cmd_stop
    docker rm $CONTAINER 2>/dev/null
    docker create --name=$CONTAINER \
        --privileged=true \
        -v "$(dirname $(pwd))":/egpg \
        -w /egpg/tests/ \
        $IMAGE /sbin/init
}

cmd_exec() {
    docker exec -it $CONTAINER env TERM=xterm \
        script /dev/null -c "$@" -q
}

cmd_shell() {
    cmd_start
    cmd_exec bash
}

cmd_start() {
    docker start $CONTAINER
    cmd_exec "/etc/init.d/haveged start"
}

cmd_stop() {
    docker stop $CONTAINER 2>/dev/null
}

cmd_erase() {
    cmd_stop
    docker rm $CONTAINER 2>/dev/null
    docker rmi $IMAGE 2>/dev/null
}

cmd_test() {
    cmd_start

    local opts=''
    if [[ $1 == '-d' || $1 == '--debug' ]]; then
        opts='--debug'
        shift
    fi

    pattern=${@:-*.t}
    for test in $(ls $pattern); do
        cmd_exec "su testuser -c './run.sh $opts $test'"
    done
}

# run the given command
cmd=${1:-help} ; shift
case $cmd in
    help|build|create|test|start|stop|shell|clear) cmd_$cmd "$@" ;;
    *) docker "$@" ;;
esac
