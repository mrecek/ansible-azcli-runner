##################################################################################
# Container designed for executing Ansible playbooks. Includes the Azure CLI
# and dependancies. Uses Ubuntu as the base image.
##################################################################################

FROM ubuntu:22.04
LABEL org.opencontainers.image.title="ansible-azcli-runner"
LABEL org.opencontainers.image.authors="Mark Recek"

# To prevent interactive prompts from apt commands
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && \
    apt install -y python3 python3-pip python-is-python3 apt-transport-https gnupg2 ca-certificates curl openssh-server lsb-release software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# Install Ansible using pip
RUN pip3 install ansible

# Install Ansible Azure using pip
RUN pip3 install ansible[azure]

# Install the Azure collection using ansible-galaxy
RUN ansible-galaxy collection install azure.azcollection

# Install requirements for the AZ collection
RUN curl -o /tmp/requirements.txt https://raw.githubusercontent.com/ansible-collections/azure/dev/requirements.txt && \
    pip3 install -r /tmp/requirements.txt

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Cleanup cached apt lists
RUN rm -rf /var/lib/apt/lists/*
RUN service ssh start

# Set up the entrypoint
CMD ["/bin/bash"]
