#!/bin/bash

# Instalação do Docker
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Instalação do Kubernetes (kubeadm, kubelet e kubectl)
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2 curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Desativar swap (requisito do Kubernetes)
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Inicialização do cluster Kubernetes
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Exibir o token gerado pelo kubeadm
echo "O token gerado pelo kubeadm é:"
sudo kubeadm token list | awk 'FNR == 2 {print $1}'

# Configuração do ambiente Kubernetes
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Instalação do pod network add-on (Calico)
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Verificação do status do cluster Kubernetes
kubectl get nodes

# Adição de nós de trabalho (worker nodes)
# Para adicionar um nó de trabalho, execute o comando gerado pelo kubeadm init

# Exemplo:
# sudo kubeadm join <IP_DO_NODO_MESTRE>:6443 --token <TOKEN_GERADO_PELO_KUBEADM> --discovery-token-ca-cert-hash <HASH_GERADO_PELO_KUBEADM>
