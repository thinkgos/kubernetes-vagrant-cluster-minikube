#!/bin/bash
#传递的变量
the_user=$1


echo "~~> 使用镜像源"
curl -L "http://mirrors.aliyun.com/repo/Centos-7.repo" -o /etc/yum.repos.d/CentOS-Base.repo
echo "~~> 安装相关工具"
yum install -y yum-utils curl vim 

echo "~~> 使能ntp,并时间同步"
yum install -y ntp ntpdate
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai 
/usr/sbin/ntpdate ntp1.aliyun.com
systemctl start ntpd
systemctl enable ntpd

echo '~~> 设置nameserver'
cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 223.5.5.5
EOF
cat /etc/resolv.conf

echo "~~> 安装docker"
yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
mkdir -p /etc/docker
# docker的cgroup驱动程序默认设置为system,默认情况下Kubernetes cgroup为systemd
cat > /etc/docker/daemon.json <<-EOF 
{
  "registry-mirrors": [
      "https://8s2vzrff.mirror.aliyuncs.com",
      "https://docker.mirrors.ustc.edu.cn",
      "https://registry.docker-cn.com"
  ],
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

echo "~~>> 将用户加入docker组"
groupadd -f docker
gpasswd -a ${the_user} docker # usermod -aG docker vagrant # ${USER}
newgrp docker  

echo "~~>> 启动docker服务"
systemctl enable docker
systemctl start docker
docker version

echo "~~> 安装k8s前置条件"
yum install -y conntrack-tools socat ebtables ethtool ipset ipvsadm
echo "~~>> 关闭 selinux"
getenforce 
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
echo "~~>> 关闭防火墙"
systemctl status firewalld
systemctl disable firewalld
systemctl stop firewalld
echo "~~>> 禁止swap"
swapoff -a
sed -ri 's/.*swap.*/#&/' /etc/fstab
echo "~~>> 允许 iptables 检查桥接流量"
cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
echo '~~>> 使能iptable kernel参数'
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system