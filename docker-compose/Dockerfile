# Dockerfile.agent
FROM jenkins/agent:latest

USER root

# Installer Docker CLI et dépendances
RUN apt-get update && apt-get install -y \
    docker.io \
    git \
    curl \
    unzip \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Installer Trivy
ENV TRIVY_VERSION=0.46.3
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh

# Installer SonarQube Scanner CLI
#ENV SONAR_SCANNER_VERSION=5.14.0.36548
#RUN curl -Lo /tmp/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip \
#    && unzip /tmp/sonar-scanner.zip -d /opt/ \
#    && rm /tmp/sonar-scanner.zip
#ENV PATH="/opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux/bin:${PATH}"

# Docker socket pour builder les images
VOLUME /var/run/docker.sock

WORKDIR /home/jenkins/agent

USER jenkins
