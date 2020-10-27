#!/bin/bash
COMMAND=$1

docker build . \
                --build-arg MYUSER=$(id -n -u) \
                --build-arg MYUSERID=$(id -u) \
                --build-arg MYGROUP=$(id -n -g) \
                --build-arg MYGROUPID=$(id -g) \
                -t infrabuilder


function docker_run {
        # First argument = working directory
        # Second argument = command to execute in the container
        docker run --rm -v $(pwd):/files \
                        --user $(id -u):$(id -g) \
                        -v ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK} \
                        -e SSH_AUTH_SOCK="${SSH_AUTH_SOCK}" \
                        --env-file .env \
                        --workdir $1 \
                        infrabuilder $2
}


case "$COMMAND" in
        create ) docker_run /files create
                ;;

        destroy ) docker_run /files destroy
                ;;
                
        * ) cat <<EOT
Usage:
        infra.sh create
        infra.sh destroy
EOT
        exit 0;;
esac
