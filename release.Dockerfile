# Unified Dockerfile for building SonarQube with the Community Branch Plugin
# This Dockerfile downloads pre-built release artifacts from GitHub

ARG SQ_VERSION=26.1.0.118079-community
ARG SQ_IMAGE_NAME=sonarqube
ARG REGISTRY_PREFIX=

FROM ${REGISTRY_PREFIX}${SQ_IMAGE_NAME}:${SQ_VERSION}

ARG PLUGIN_VERSION=26.1.2
ARG GITHUB_REPO=fabiogermann/sonarqube-community-branch-plugin
ARG DOWNLOAD_BASE_URL=https://github.com/${GITHUB_REPO}/releases/download/${PLUGIN_VERSION}

# hadolint ignore=DL3002
USER root

# hadolint ignore=DL3018,DL3008,DL3009
RUN set -e && \
    apt-get update && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y wget unzip && \
    wget "${DOWNLOAD_BASE_URL}/sonarqube-community-branch-plugin-${PLUGIN_VERSION}.jar" \
         -O /opt/sonarqube/extensions/plugins/sonarqube-community-branch-plugin.jar && \
    wget "${DOWNLOAD_BASE_URL}/sonarqube-webapp.zip" -O /tmp/sonarqube-webapp.zip && \
    rm -rf /opt/sonarqube/web && mkdir -p /opt/sonarqube/web && \
    unzip /tmp/sonarqube-webapp.zip -d /opt/sonarqube/web && rm /tmp/sonarqube-webapp.zip && \
    sed -i "s|#sonar.web.javaAdditionalOpts=|sonar.web.javaAdditionalOpts=-javaagent:./extensions/plugins/sonarqube-community-branch-plugin.jar=web|g" /opt/sonarqube/conf/sonar.properties && \
    sed -i "s|#sonar.ce.javaAdditionalOpts=|sonar.ce.javaAdditionalOpts=-javaagent:./extensions/plugins/sonarqube-community-branch-plugin.jar=ce|g" /opt/sonarqube/conf/sonar.properties && \
    apt-get purge -y unzip && apt-get autoremove -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
# Note: wget retained for liveness probes

# hadolint ignore=DL3002
USER sonarqube
