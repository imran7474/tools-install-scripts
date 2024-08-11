#!/bin/bash

# Update the package list
sudo apt update

# Install curl and apt-transport-https
sudo apt -y install curl apt-transport-https

# Add Kubernetes GPG key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Add Kubernetes repository to sources list
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update the package list again after adding Kubernetes repository
sudo apt update

# Install required packages: vim, git, curl, wget, kubelet, kubeadm, kubectl
sudo apt -y install vim git curl wget kubelet kubeadm kubectl

# Mark the installed packages to hold them from being updated automatically
sudo apt-mark hold kubelet kubeadm kubectl

# Confirm the installation by checking the version of kubectl and kubeadm
kubectl version --client && kubeadm version

# Disable Swap: Edit fstab to disable swap on reboot
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Turn off swap immediately
sudo swapoff -a

# Enable necessary kernel modules for Kubernetes
sudo modprobe overlay
sudo modprobe br_netfilter

# Add sysctl settings for Kubernetes
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl settings to apply the changes
sudo sysctl --system

# Install Docker runtime as the container runtime for Kubernetes

# Update the package list
sudo apt update

# Install required packages for Docker
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker repository to sources list
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the package list again after adding Docker repository
sudo apt update

# Install Docker packages
sudo apt install -y containerd.io docker-ce docker-ce-cli

# Create necessary directory for Docker systemd service
sudo mkdir -p /etc/systemd/system/docker.service.d

# Create Docker daemon configuration file with specific settings
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Reload systemd to recognize Docker's new configuration and restart Docker service
sudo systemctl daemon-reload
sudo systemctl restart docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Ensure the necessary kernel modules are loaded
sudo modprobe overlay
sudo modprobe br_netfilter

# Set up sysctl parameters for Kubernetes networking
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl settings to apply the changes
sudo sysctl --system

# Initialize the master node

# Ensure that the br_netfilter module is loaded
lsmod | grep br_netfilter

# Enable kubelet service to start on boot
sudo systemctl enable kubelet

# Initialize the Kubernetes master node
sudo kubeadm init

# Set up kubectl for the regular user to manage the cluster
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Additional nodes can be added using the join command provided by kubeadm init
# Example join command (Replace the token and hash with the actual output from kubeadm init)
# kubeadm join k8s-cluster.computingforgeeks.com:6443 --token <token> \
# --discovery-token-ca-cert-hash sha256:<hash> --control-plane

# Install Calico network plugin on the master node
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml -O
kubectl apply -f calico.yaml
