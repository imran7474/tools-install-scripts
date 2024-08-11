# This tools installaton available for linxu ubuntu.


# 1 Installing AWS CLI

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

sudo apt install unzip -y

unzip awscliv2.zip

sudo ./aws/install


# 2 kubectl installation

sudo apt update

sudo apt install curl -y

sudo curl -LO "https://dl.k8s.io/release/v1.28.4/bin/linux/amd64/kubectl"

sudo chmod +x kubectl

sudo mv kubectl /usr/local/bin/

kubectl version --client



# 3 Installing eksctl

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

eksctl version


# 4 Intsalling Java

sudo apt update -y

sudo apt install openjdk-17-jre -y

sudo apt install openjdk-17-jdk -y

java --version


# 5 Installing Jenkins

curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
  
sudo apt-get update -y

sudo apt-get install jenkins -y


# 6 Installing Docker 

sudo apt update 

sudo apt install docker.io -y

sudo usermod -aG docker jenkins

sudo usermod -aG docker ubuntu

sudo systemctl restart docker

sudo chmod 777 /var/run/docker.sock



# 7 sonarqube docker container creation

# If you don't want to install Jenkins, you can create a container of Jenkins
# docker run -d -p 8080:8080 -p 50000:50000 --name jenkins-container jenkins/jenkins:lts

# Run Docker Container of Sonarqube

docker run -d  --name sonar -p 9000:9000 sonarqube:lts-community


# 8 Trivy installation 


sudo apt-get install wget apt-transport-https gnupg lsb-release -y

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -

echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list

sudo apt update

sudo apt install trivy -y


#  helm

# 9 Helm installation via snap package

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh

# alternative you can install via snap pkg

#sudo snap install helm --classic


# 10 Installing Terraform


wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update

sudo apt install terraform -y


# 11 argocd 

kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 12 argocd-cli

# argocd cli 

# Linux

curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

chmod +x /usr/local/bin/argocd

#port farwarding to acess argocd 

kubectl port-forward svc/argocd-server -n argocd 8080:443


# get argocd password username admin and get password using below command acess via https://localhost:8080

kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

# login to argocd cli 

argocd login localhost:8080


# 13 to create cluster using kubeadm kubeclt kubelete docker to run this script on master and worker nodes 

# copy command from below  and run script file name is kubeadm0k8s-cluster.sh and give executive persmissiob chmod +x kubeadm0k8s-cluster.sh and and then run .. bash kubeadm0k8s-cluster.sh

#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Updating the package index and installing prerequisites..."

sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl gpg lsb-release

echo "Disabling swap..."

sudo swapoff -a

sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "Loading necessary kernel modules..."

sudo modprobe overlay

sudo modprobe br_netfilter

echo "Setting up required sysctl params..."

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

echo "Applying sysctl params without reboot..."

sudo sysctl --system

echo "Installing Docker..."

# Adding Docker GPG key and repository

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installing Docker

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Adding the current user to the docker group

echo "Adding user to the docker group..."

sudo usermod -aG docker $USER

# Configuring the docker.socket file

echo "Configuring Docker socket file permissions..."

sudo chmod 666 /var/run/docker.sock

# Enabling and starting Docker

echo "Enabling and starting Docker service..."

sudo systemctl enable docker

sudo systemctl start docker

echo "Docker installation completed."

echo "Adding Kubernetes apt repository..."

KUBERNETES_VERSION="v1.30"

REPO_URL="https://pkgs.k8s.io/core:/stable:/${KUBERNETES_VERSION}/deb/"

sudo mkdir -p /etc/apt/keyrings

curl -fsSL ${REPO_URL}Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] ${REPO_URL} /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "Updating the package index and installing Kubernetes components..."

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl

echo "Enabling and starting kubelet service..."

sudo systemctl enable --now kubelet

echo "Kubernetes components installed and system configured successfully."

# note

after this run succesfully the run below command and open port 6443 and run below command on master and the will be give join command to run on worker node .. do not run join command on  master node 

 sudo kubeadm init --pod-network-cidr=10.244.0.0/16

after that you will get a long join command that you run on worker node the joind command will be look like thhis but do not use becuase this is unique for everyone 

 kubeadm join 172.31.39.26:6443 --token 1e904d.1dcfk9hbkjy6w2bc --discovery-token-ca-cert-hash sha256:0ab851180e2764e7c4ab47e3d802ec84ae1cc4c10e75c3bad8f84b26950d2057

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# all master and worker nodes is ready then run network plugin to install network plugn calico 

# Again on the Master Node 

 # Install Calico for our Networking part.

 kubectl apply -f https://docs.projectcalico.org/v3.20/manifests/calico.yaml 
 
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# nginx ingress controller onmaster 

# Next run this for the Ingress Controller

 kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.49.0/deploy/static/provider/baremetal/deploy.yaml
 
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
