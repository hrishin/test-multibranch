FROM jenkins/jenkins:2.235.1

ENV VAULT_VERSION=1.2.3

#SWITCH USER FOR INSTALLATION
USER root

#INSTALLING REQUIRED TOOLS
RUN apk --no-cache add \
            curl \
            python \
            wget

#Vault
RUN wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip vault_${VAULT_VERSION}_linux_amd64.zip && \
    chmod +x vault && \
    mv vault /usr/bin/vault && \
    rm vault_${VAULT_VERSION}_linux_amd64.zip

#GCloud Sdk
RUN curl https://sdk.cloud.google.com | bash -s -- \
    --disable-prompts \
    --install-dir=/opt

#DROP BACK TO REGULAR JENKINS USER
USER jenkins

ENV PATH=$PATH:/opt/google-cloud-sdk/bin

# copy the plugins.txt file and run the install-plugins script 
# https://github.com/jenkinsci/docker#preinstalling-plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# disables the "Do you want to install plugins?" popup
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state