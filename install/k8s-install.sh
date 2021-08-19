#!/bin/bash

echo 'please input master ip(ex:192.168.126.128) :'
read masterIp

#### 关闭防火墙
systemctl stop firewalld.service
systemctl status firewalld.service
systemctl disable firewalld

#### 关闭Swap
swapoff -a
sed -ri 's/.*swap.*/#&/' /etc/fstab
echo "vm.swappiness = 0" >> /etc/sysctl.conf 
sysctl -p

#### 关闭selinux
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config

#### 设置启动参数
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# k8s软件源
wget ftp://ftp.rhce.cc/k8s/* -P /etc/yum.repos.d/

sysctl --system

yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io -y

systemctl start docker
cat <<EOF >  /etc/docker/daemon.json
{
    "registry-mirrors": ["https://registry.docker-cn.com", "https://docker.mirrors.ustc.edu.cn"]
}
EOF

systemctl daemon-reload
systemctl restart docker

systemctl enable docker

docker pull coredns/coredns:1.8.0
docker tag 296a6d5035e2 registry.aliyuncs.com/google_containers/coredns:v1.8.0

yum install -y kubelet-1.21.2-0 kubeadm-1.21.2-0 kubectl-1.21.2-0
systemctl restart kubelet
systemctl enable kubelet

# wget https://docs.projectcalico.org/manifests/calico.yaml

# 初始化master，添加--image-repository参数，默认镜像下载会失败
kubeadm init \
  --apiserver-advertise-address=$masterIp \
  --image-repository registry.aliyuncs.com/google_containers \
  --kubernetes-version v1.21.2 \
  --service-cidr=10.96.0.0/12 \
  --pod-network-cidr=10.244.0.0/16 \
  --ignore-preflight-errors=all

#如果init成功执行如下命令
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 安装网络
kubectl apply -f calico.yaml

#查看集群
kubectl get pods -n kube-system

#安装dashboard
kubectl create -f recommended.yaml

kubectl get pods -n kubernetes-dashboard

#命令获取token
kubectl -n kube-system describe $(kubectl -n kube-system get secret -n kube-system -o name | grep namespace) | grep token


# kubeadm token create --print-join-command
# kubeadm join 192.168.126.137:6443 --token 5ooc2q.up5f3xm8y7foe5cj         --discovery-token-ca-cert-hash sha256:b0750f673fa9c8dfe6338427b881ae3abf4fc9c04267bfc9b8a0e96d2b3d5bbd


# 允许master节点部署pod即可解决问题，命令如下:
# kubectl taint nodes --all node-role.kubernetes.io/master-

#补充点(禁止master部署pod命令)：
# kubectl taint nodes k8s node-role.kubernetes.io/master=true:NoSchedule

#  kubectl describe pod -n kube-system calico-node-d7xjp