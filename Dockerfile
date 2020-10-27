FROM ubuntu:20.04

ENV \
 TERRAFORM_VERSION=0.13.2

ARG MYUSER=default
ARG MYUSERID=1000
ARG MYGROUP=default
ARG MYGROUPID=1000

RUN apt-get update && apt-get install -y \
    ansible \
    curl \
    python3-dev \
    python3-pip \
    unzip \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install \
        ansible \
        ansible-runner \
        click \
        python-dotenv \
        docker

RUN curl -O https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
   && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
   && mv terraform /usr/local/bin/ \
   && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN groupadd --gid ${MYGROUPID} ${MYGROUP} \
    && useradd --create-home --uid ${MYUSERID} --gid ${MYGROUPID} ${MYUSER}

COPY infra.py /infra.py

USER ${MYUSER}

RUN mkdir /home/${MYUSER}/.ssh \
    && chmod 700 /home/${MYUSER}/.ssh \
    && echo "Host *" >  /home/${MYUSER}/.ssh/config \
    && echo "    StrictHostKeyChecking no" >>  /home/${MYUSER}/.ssh/config\
    && chmod 400 /home/${MYUSER}/.ssh/config

ENTRYPOINT [ "python3", "/infra.py" ]

