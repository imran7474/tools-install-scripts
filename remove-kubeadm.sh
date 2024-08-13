#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting removal of Kubernetes components..."

# Check if Kubernetes components are installed and remove them
if dpkg -l | grep -q kubelet; then
    echo "Removing kubelet, kubeadm, and kubectl..."
    sudo apt-get remove --purge -y --allow-change-held-packages kubelet kubeadm kubectl
fi

# Remove Kubernetes apt repository and key
if [ -f /etc/apt/sources.list.d/kubernetes.list ]; then
    echo "Removing Kubernetes apt repository..."
    sudo rm -f /etc/apt/sources.list.d/kubernetes.list
fi

if [ -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]; then
    echo "Removing Kubernetes apt key..."
    sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg
fi

# Remove Kubernetes configuration files
if [ -f /etc/kubernetes/kubelet.conf ]; then
    echo "Removing Kubernetes configuration files..."
    sudo rm -f /etc/kubernetes/kubelet.conf
fi

if [ -f /var/lib/kubelet/config.yaml ]; then
    sudo rm -f /var/lib/kubelet/config.yaml
fi

echo "Checking for Docker installation..."

# Check if Docker is installed and remove it
if dpkg -l | grep -q docker-ce; then
    echo "Removing Docker..."
    sudo apt-get remove --purge -y --allow-change-held-packages docker-ce docker-ce-cli containerd.io
fi

if [ -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
    echo "Removing Docker apt key..."
    sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg
fi

# Re-enable swap
echo "Re-enabling swap..."
sudo sed -i '/swap/ s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapon -a

# Remove sysctl configuration for Kubernetes if it exists
if [ -f /etc/sysctl.d/k8s.conf ]; then
    echo "Removing sysctl configuration for Kubernetes..."
    sudo rm -f /etc/sysctl.d/k8s.conf
fi

# Apply sysctl settings
echo "Applying sysctl settings..."
sudo sysctl --system

echo "System cleaned up. Rebooting..."
sudo reboot
