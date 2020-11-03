#!/bin/bash
COMMAND=$1

docker build . \
                --build-arg MYUSER=$(id -n -u) \
                --build-arg MYUSERID=$(id -u) \
                --build-arg MYGROUP=$(id -n -g) \
                --build-arg MYGROUPID=$(id -g) \
                -t infrabuilder

function infra_container {
        EXTRA_OPTIONS=""
        COMMAND=$1

        if [ "$1" = "shell" ]; then
                EXTRA_OPTIONS="--entrypoint /bin/bash -it"
                COMMAND=""
        fi

        docker run --rm -v $(pwd):/files \
                        --user $(id -u):$(id -g) \
                        -v ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK} \
                        -e SSH_AUTH_SOCK="${SSH_AUTH_SOCK}" \
                        --env-file .env \
                        --workdir /files \
                        ${EXTRA_OPTIONS} \
                        infrabuilder ${COMMAND}
}

case "$COMMAND" in
        create ) infra_container create
                ;;

        destroy ) infra_container destroy
                ;;

        shell ) infra_container shell
                ;;
                
        * ) cat <<EOT
Usage:
        infra.sh create
        infra.sh destroy
EOT
        exit 0;;
esac
