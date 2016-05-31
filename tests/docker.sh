#!/bin/bash

cd $(dirname $0)

case $1 in
    build)
        sudo docker build --tag=egpg --file=Dockerfile .
        ;;
    create)
        sudo docker rm egpg-tests 2>/dev/null
        sudo docker create --name=egpg --privileged=true \
            -v $(dirname $(pwd)):/egpg egpg /sbin/init
        ;;
    start)
        sudo docker start egpg
        ;;
    stop)
        sudo docker stop egpg
        ;;
    enter)
        sudo docker exec -it egpg env TERM=xterm script /dev/null -c bash
        ;;
    test)
        shift
        sudo docker exec egpg env TERM=xterm \
            script /dev/null -c "/etc/init.d/haveged start;
                                 su -c '/egpg/tests/run.sh $@' test;
                                 /etc/init.d/haveged stop;"
        ;;
    rm)
        sudo docker rm egpg-tests 2>/dev/null
        sudo docker rmi egpg-tests 2>/dev/null
        ;;
    *)
        echo "Usage: $0 [ build | create | start | stop | enter | rm ]"
        ;;
esac
