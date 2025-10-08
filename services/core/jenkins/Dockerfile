FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
    apt-get install -y jq curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER jenkins
