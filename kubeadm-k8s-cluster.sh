# to create cluster using kubeadm kubeclt kubelete docker to run this script on master and worker nodes 
# copy command from below #!/bin/bash not from above 2 lines 

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
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# note

#after this run succesfully the run below command and open port 6443 and run below command on master and the will be give join command to run on worker node .. do not run join command on  master node 

# sudo kubeadm init --pod-network-cidr=10.244.0.0/16

#after that you will get a long join command that you run on worker node the joind command will be look like thhis but do not use becuase this is unique for everyone 

#kubeadm join 172.31.39.26:6443 --token 1e904d.1dcfk9hbkjy6w2bc --discovery-token-ca-cert-hash sha256:0ab851180e2764e7c4ab47e3d802ec84ae1cc4c10e75c3bad8f84b26950d2057
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# all master and worker nodes is ready then run network plugin to install network plugn calico 

# Again on the Master Node →

# Apply network plugins:

# Install Calico for our Networking part.

# kubectl apply -f https://docs.projectcalico.org/v3.20/manifests/calico.yaml 
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# nginx ingress controller onmaster 
# Next run this for the Ingress Controller

# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.49.0/deploy/static/provider/baremetal/deploy.yaml
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


