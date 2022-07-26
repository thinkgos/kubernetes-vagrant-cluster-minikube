#!/bin/bash

echo "~~> 添加kube组件仓库源"
cat > /etc/yum.repos.d/kubernetes.repo<<EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum makecache -y fast

echo "~~>> 安装kubectl"
yum install -y kubectl
kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null
kubectl version --client

# 安装minikube
curl -L https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -o /usr/local/bin/minikube
chmod a+x /usr/local/bin/minikube

## 安装KubeKey
# export KKZONE=cn
# curl -sfL https://get-kk.kubesphere.io | VERSION=v1.2.1 sh -
# chmod +x kk
## 开始安装k8s
#  ./kk create cluster -y --with-kubernetes v1.21.5 --with-kubesphere v3.2.1
## 验证k8s
# kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f

# 开启k8s
# minikube start --driver=none --image-mirror-country='cn' --image-repository='registry.cn-hangzhou.aliyuncs.com/google_containers' --registry-mirror='https://registry.docker-cn.com' --kubernetes-version=v1.23.9 --apiserver-ips="172.16.5.190"
# minikube start --driver=docker --image-mirror-country='cn' --image-repository='registry.cn-hangzhou.aliyuncs.com/google_containers' --registry-mirror='https://registry.docker-cn.com' --base-image="kicbase/stable:v0.0.30" --kubernetes-version=v1.23.9
# 启用 dashboard
# minikube dashboard
# 启用ingress
# minikube addons enable ingress