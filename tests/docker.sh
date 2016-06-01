#!/bin/bash

# go to the directory of the script
cd $(dirname $0)

IMAGE=egpg-image
CONTAINER=egpg

help() {
    cat <<-_EOF
Usage: $0 ( build | create | test | start | stop | shell | erase )

First build the image and create the containter:
    $0 build
    $0 create

Then run tests like this:
    $0 test t01-version.t
    $0 test t0*
    $0 test

You can also enter the shell of the container to run the tests:
    $0 shell
    ./run.sh t1* t2*

When testing is done, clean up the container and the image:
    $0 erase

_EOF
}

docker() {
    sudo docker "$@"
}

build() {
    docker build --tag=$IMAGE --file=Dockerfile .
}

create() {
    stop
    docker rm $CONTAINER 2>/dev/null
    docker create --name=$CONTAINER \
        --privileged=true \
        -v "$(dirname $(pwd))":/egpg \
        -w /egpg/tests/ \
        $IMAGE /sbin/init
}

exec_cmd() {
    docker exec -it $CONTAINER env TERM=xterm \
        script /dev/null -c "$@" -q
}

shell() {
    start
    exec_cmd bash
}

start() {
    docker start $CONTAINER
    exec_cmd "/etc/init.d/haveged start"
}

stop() {
    docker stop $CONTAINER 2>/dev/null
}

erase() {
    stop
    docker rm $CONTAINER 2>/dev/null
    docker rmi $IMAGE 2>/dev/null
}

run_test() {
    start
    pattern=${@:-*.t}
    for test in $(ls $pattern); do
        exec_cmd "su testuser -c './run.sh $test'"
    done
}

# run the given command
cmd=${1:-help}
case $cmd in
    help|build|create|start|stop|shell|clear) $cmd ;;
    test) shift ; run_test "$@" ;;
    *) docker "$@" ;;
esac
