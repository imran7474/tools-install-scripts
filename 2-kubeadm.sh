#!/bin/bash

# Set Kubernetes version and repository URL
KUBERNETES_VERSION="v1.30"
REPO_URL="https://pkgs.k8s.io/core:/stable:/${KUBERNETES_VERSION}/deb/"

# Create directory for the Kubernetes keyring
sudo mkdir -p /etc/apt/keyrings

# Download and add the Kubernetes GPG key
curl -fsSL ${REPO_URL}Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the Kubernetes repository to the sources list
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] ${REPO_URL} /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package lists and install Kubernetes packages
sudo apt update
sudo apt install -y vim git curl wget kubelet kubeadm kubectl

# Hold Kubernetes packages to prevent them from being updated automatically
sudo apt-mark hold kubelet kubeadm kubectl

# Confirm installation by checking the versions
kubectl version --client && kubeadm version

# Disable Swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Add sysctl settings for Kubernetes
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl settings
sudo sysctl --system

# Install Docker and its dependencies
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io docker-ce docker-ce-cli

# if necessory then uncomment -----------------------------------------------------------------------------------------
# # Create Docker directories
# sudo mkdir -p /etc/systemd/system/docker.service.d

# # Create daemon.json for Docker
# sudo tee /etc/docker/daemon.json <<EOF
# {
#   "exec-opts": ["native.cgroupdriver=systemd"],
#   "log-driver": "json-file",
#   "log-opts": {
#     "max-size": "100m"
#   },
#   "storage-driver": "overlay2"
# }
# EOF
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Start and enable Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker

# Ensure kernel modules are loaded
sudo modprobe overlay
sudo modprobe br_netfilter

# Reload sysctl settings again
sudo sysctl --system

# Initialize Kubernetes master node
lsmod | grep br_netfilter
sudo systemctl enable kubelet
kubeadm init

# Configure kubectl for the current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Additional nodes can be added with kubeadm join command (output from kubeadm init)

# Install Calico network plugin
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml -O
kubectl apply -f calico.yaml

# Confirm that Kubernetes is up and running
kubectl get nodes
