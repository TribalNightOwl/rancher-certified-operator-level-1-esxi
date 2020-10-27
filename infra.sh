#!/bin/bash
COMMAND=$1

case "$COMMAND" in
        create ) source .env
                export PUBSSHKEY
                ansible-playbook playbooks/configure-project.yaml
                ;;
                # ./deploy-helpernode.sh ;;

        destroy ) source config.sh
                docker_run /files/terraform "terraform destroy -auto-approve" \
                && rm -f deploy-helpernode.sh \
                && rm -f files/ks.cfg \
                && rm -f files/vars.yaml \
                && rm -f kubeadmin-password \
                && rm -f kubeconfig \
                && rm -f config.sh \
                && rm -rf terraform \
                && rm -f hosts
                ;;    
        * ) cat <<EOT
Usage:
        infra.sh create
        infra.sh destroy
EOT
        exit 0;;
esac
