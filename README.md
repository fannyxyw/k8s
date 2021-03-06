# k8s安装脚本使用 k8s v1.21.2版本
1. 准备一台centos系统，可以使用vmware虚拟机来搭建
2. IP地址使用静态地址
3. 同时设置host名，去掉vmwam默认生成的xxx.localhost，改成比如k8s-master这样的域名  
   hostnamectl set-name k8s-master  
  修改域名解析文件  
      vim /etch/hosts  
   192.168.126.128 k8s-master  
   192.168.126.129 k8s-node1  
4. 使用ssh终端连接到centos
5. 使用git下载本文档 git clone https://github.com/fannyxyw/k8s.git
6. cd k8s/install
7. sh k8s-install.sh

# 应用部署
1. 允许在master上部署应用：  
  kubectl taint nodes --all node-role.kubernetes.io/master-  
2. 禁止master部署pod命令：  
  kubectl taint nodes k8s node-role.kubernetes.io/master=true:NoSchedule
3. 应用部署例子：  
   https://blog.csdn.net/qq_34525938/article/details/109415401  

# 出错原因查看  
查看 k8s 服务启动或者init 操作失败原因  
journalctl -xefu kubelet

# 参考安装视频  
1. 链接：https://www.bilibili.com/video/BV1oJ411d7Tv  
2. 视频中文档地址：http://blog.hungtcs.top/2019/11/27/23-K8S%E5%AE%89%E8%A3%85%E8%BF%87%E7%A8%8B%E7%AC%94%E8%AE%B0

# 离线安装参考  
https://gitee.com/h0wp0710/myDoc/blob/master/doc/k8s  

# 测试kubernetes集群:
'''shell
$ kubectl create deployment nginx --image=nginx  
$ kubectl expose deployment nginx --port=80  --type=NodePort  
$ kubectl get pod,svc

kubectl get pod --all-namespaces -o wide  
'''

# 发布应用测试
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get pod,svc

# 安装后网络不通重新安装
'''shell  
kubeadm reset -f  
modprobe -r ipip  
lsmod  
rm -rf ~/.kube/  
rm -rf /etc/kubernetes/  
rm -rf /etc/systemd/system/kubelet.service.d  
rm -rf /etc/systemd/system/kubelet.service  
rm -rf /usr/bin/kube*  
rm -rf /etc/cni  
rm -rf /opt/cni  
rm -rf /var/lib/etcd  
rm -rf /var/etcd  
yum clean all  
yum remove kubelet  
yum remove kubeadm  
'''