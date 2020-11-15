#!/bin/bash
COMMAND=$1
CONFIG_FILE=project/vars.yaml
WEBSERVER_PORT=$(cat ${CONFIG_FILE} | grep webserver_port | cut -d':' -f2 | tr -d '"' | tr -d ' ')

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

        docker run --rm -it \
                        -v $(pwd):/files \
                        --user $(id -u):$(id -g) \
                        -v ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK} \
                        -e SSH_AUTH_SOCK="${SSH_AUTH_SOCK}" \
                        --env-file .env \
                        --workdir /files \
                        -p ${WEBSERVER_PORT}:${WEBSERVER_PORT} \
                        ${EXTRA_OPTIONS} \
                        infrabuilder ${COMMAND}
}

function get_webserver_info {
        echo These are the possible IP addresses:
        hostname -I
        POSSIBLE_IP=$(hostname -I | cut -d' ' -f1)
        read -p "Enter IP address of this machine: [${POSSIBLE_IP}]: " SELECTED_IP
        SELECTED_IP=${SELECTED_IP:-${POSSIBLE_IP}}

        echo "webserver_ip: \"${SELECTED_IP}\"" >> ${CONFIG_FILE}

}

function delete_webserver_info {
        sed -i '/^webserver_ip/d' ${CONFIG_FILE}
}

case "$COMMAND" in
        create ) get_webserver_info
                infra_container create
                ;;

        destroy ) infra_container destroy
                delete_webserver_info
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
