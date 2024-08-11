# if u want to remove all tools to run below script 

#!/bin/bash
# For Ubuntu 22.04

# Remove Java
sudo apt-get remove --purge openjdk-17-jre openjdk-17-jdk -y
sudo apt-get autoremove -y
sudo apt-get clean

# Remove Jenkins
sudo systemctl stop jenkins
sudo apt-get remove --purge jenkins -y
sudo rm -rf /var/lib/jenkins
sudo rm -rf /var/cache/jenkins
sudo rm -rf /etc/apt/sources.list.d/jenkins.list
sudo rm -rf /usr/share/keyrings/jenkins-keyring.asc

# Remove Docker
sudo systemctl stop docker
sudo apt-get remove --purge docker.io -y
sudo rm -rf /var/lib/docker
sudo rm -rf /etc/docker
sudo groupdel docker
sudo usermod -G "" ubuntu
sudo usermod -G "" jenkins

# Remove SonarQube Docker Container
docker stop sonar
docker rm sonar

# Remove AWS CLI
sudo rm -rf /usr/local/bin/aws
sudo rm -rf /usr/local/aws-cli
sudo rm -rf /usr/local/aws

# Remove kubectl
sudo rm -f /usr/local/bin/kubectl

# Remove eksctl
sudo rm -f /usr/local/bin/eksctl

# Remove Terraform
sudo apt-get remove --purge terraform -y
sudo rm -f /usr/share/keyrings/hashicorp-archive-keyring.gpg
sudo rm -f /etc/apt/sources.list.d/hashicorp.list

# Remove Trivy
sudo apt-get remove --purge trivy -y
sudo rm -rf /etc/apt/sources.list.d/trivy.list
sudo rm -rf /var/lib/trivy

# Remove Helm
sudo snap remove helm

# Remove ArgoCD
kubectl delete namespace argocd

# Remove ArgoCD CLI
sudo rm -f /usr/local/bin/argocd

echo "Uninstallation and cleanup completed."
