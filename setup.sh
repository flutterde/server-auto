#!/bin/bash
DOCKER_USER="***"
DOCKER_USER_PASS="***"
GITHUB_TOKEN="****"
REPO_NAME="**/**-**"
CLONE_URL="https://${GITHUB_TOKEN}@github.com/${REPO_NAME}.git"
PROJECT_NAME="***"

echo "Updating the server..."

sudo apt-get update 1>/dev/null
sudo apt-get upgrade -y 1>/dev/null

echo "Installing required packages..."
sudo apt-get install -y wget  git  curl make 1>/dev/null

echo "Installing Docker..."
wget -qO- https://get.docker.com/ | sh 1>/dev/null

# create user for docker
sudo useradd -m ${DOCKER_USER}
echo "${DOCKER_USER}:${DOCKER_USER_PASS}" | sudo chpasswd
sudo usermod -aG docker ${DOCKER_USER}
echo "Docker user created: ${DOCKER_USER}"

# setting up ssh access
sudo systemctl enable ssh
sudo sed -i -E \
  -e '/^#?PasswordAuthentication/s/.*/PasswordAuthentication yes/' \
  -e '/^#?PermitRootLogin/s/.*/PermitRootLogin no/' \
  -e '/^#?UsePAM/s/.*/UsePAM yes/' \
  -e '/^#?ChallengeResponseAuthentication/s/.*/ChallengeResponseAuthentication no/' \
  /etc/ssh/sshd_config && \
  sudo grep -q '^PasswordAuthentication yes' /etc/ssh/sshd_config || echo 'PasswordAuthentication yes' | sudo tee -a /etc/ssh/sshd_config && \
  sudo grep -q '^PermitRootLogin no' /etc/ssh/sshd_config || echo 'PermitRootLogin no' | sudo tee -a /etc/ssh/sshd_config && \
  sudo grep -q '^UsePAM yes' /etc/ssh/sshd_config || echo 'UsePAM yes' | sudo tee -a /etc/ssh/sshd_config && \
  sudo grep -q '^ChallengeResponseAuthentication no' /etc/ssh/sshd_config || echo 'ChallengeResponseAuthentication no' | sudo tee -a /etc/ssh/sshd_config

sudo grep -q '^\s*PasswordAuthentication\s\+yes' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf && echo "Already set" || \
sudo sed -i -E '/^\s*#?\s*PasswordAuthentication\s+/s/.*/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf || \
echo 'PasswordAuthentication yes' | sudo tee -a /etc/ssh/sshd_config.d/60-cloudimg-settings.conf

sudo systemctl reload sshd
sudo systemctl restart ssh
sudo systemctl restart sshd



# setting the folder
sudo mkdir -p /home/${DOCKER_USER}/docker
sudo chown -R ${DOCKER_USER}:${DOCKER_USER} /home/${DOCKER_USER}/docker
cd /home/${DOCKER_USER}/docker

echo "Cloning the repository..."
git clone ${CLONE_URL} ${PROJECT_NAME} >>/home/${DOCKER_USER}/docker/logs.log

echo "Building the project..."
cd ${PROJECT_NAME}
make up



