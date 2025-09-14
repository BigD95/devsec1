#!/bin/bash

# --------------------------
# Mise à jour du système
# --------------------------
apt-get update -y
apt-get upgrade -y

# --------------------------
# Installation des outils essentiels
# --------------------------
apt-get install -y docker.io docker-compose git curl

# Activer Docker
systemctl enable docker
systemctl start docker

apt-get install -y docker-compose
apt-get install docker-compose-plugin

# --------------------------
# Création des dossiers pour Jenkins et Docker Compose
# --------------------------
JENKINS_HOME="/opt/jenkins/jenkins_home"
mkdir -p $JENKINS_HOME
chown -R ubuntu:ubuntu $JENKINS_HOME

# --------------------------
# Copier les fichiers dans le dossier Jenkins
# --------------------------
cp /home/ubuntu/docker-compose.yml $JENKINS_HOME/docker-compose.yml
cp /home/ubuntu/Dockerfile $JENKINS_HOME/Dockerfile

# --------------------------
# Lancer les conteneurs avec Docker Compose
# --------------------------
cd $JENKINS_HOME
docker-compose up -d --build

# --------------------------
# Confirmation
# --------------------------
echo "Installation terminée, conteneurs lancés" > /home/ubuntu/setup_done.txt
