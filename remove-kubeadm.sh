# if u want to remove the installation of compenents docker kubeadm kubectl kubelet to run below commands 
#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Removing Kubernetes components..."
sudo apt-get remove --purge -y kubelet kubeadm kubectl

echo "Removing Kubernetes apt repository and key..."
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "Removing Kubernetes configuration files..."
sudo rm -f /etc/kubernetes/kubelet.conf
sudo rm -f /var/lib/kubelet/config.yaml

echo "Removing Docker..."
sudo apt-get remove --purge -y docker-ce docker-ce-cli containerd.io
sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg

echo "Re-enabling swap..."
sudo sed -i '/^#.*swap/s/^#//' /etc/fstab
sudo swapon -a

echo "Removing sysctl configuration for Kubernetes..."
sudo rm -f /etc/sysctl.d/k8s.conf

echo "Applying sysctl settings..."
sudo sysctl --system

echo "System cleaned up. Rebooting..."
sudo reboot
