# Kubernetes 安装部署
	
**k8s_master组件介绍：**

	API Server：
		负责接受、解析、处理请求；
	
	Scheduler
		调度器，调度每一个容器创建的请求
			观测每一个node的总共可用的CPU，RAM存储资源，根据容器的所需资源的最低资源来评估哪一个node节点合适
		
		两级调度：
			预选，评估每一个node有几个符合
			优选，评估出来后选择最佳
	
	controller-manager:
		控制器管理器，确保控制器处于健康状态；
		安装配置	
		
	kubectl:
		它的主要功能就是管理集群

	kubelet 的主要功能就是:
	定时从某个地方获取节点上 pod/container 的期望状态（运行什么容器、运行的副本数量、网络或者存储如何配置等等），并调用对应的容器平台接口达到这个状态
	集群状态下，kubelet 会从 master 上读取信息，但其实 kubelet 还可以从其他地方获取节点的 pod 信息。
	目前 kubelet 支持三种数据源：
		本地文件
		通过 url 从网络上某个地址来获取信息
		API Server：从 kubernetes master 节点获取信息
		
	
		
**Node节点 组件介绍：**

	kubelet：
		集群代理
		Scheduler调度的结果由kubelet执行，启动Pod，本机管理Pod
		接受任务，在本机试图启动容器，因为运行容器需要docker来执行
		
	kube-proxy
		负责随时与API-Server进行通信
		
	docker
		容器引擎
	
**CNI：接入外部的网络服务解决方案**

	flannel：网络配置
	calico：网络配置，网络策略；
	canel：两者结合体
	
**k8s相关镜像获取地址**

  可以去Docker Hub上的 [mirrorgooglecontainers](https://hub.docker.com/search/?q=mirrorgooglecontainers&type=image) 获取k8s相关镜像。  
也可以在Git Hub写Dockerfile文件，然后在Docker Hub上去构建。[参考链接](https://blog.csdn.net/shida_csdn/article/details/78480241)		
	
**kubeadm 安装步骤**

	1.master，nodes：安装kubelet，kubeadm，docker
	2.master：kubeadm init
	3.nodes：kubeadm join

## 开始部署
**1.配置yum节点，阿里的。(Master，Node节点都要做)**
---
```
[root@k8s1 yum.repos.d]# vim k8s.repo 
[kubernetes]
name=k8s Repo
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
enabled=1
```

**2.解决密钥报错问题。(Master，Node节点都要做)**
---
```
[root@k8s1 ~]# wget https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
[root@k8s1 ~]# wget https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
[root@k8s1 ~]# rpm --import yum-key.gpg rpm-package-key.gpg
```
**3.Master节点使用kubeadm安装k8s相关组件**
---
```
[root@k8s1 ~]# yum -y  install docker-ce-18.09.3 kubelet-1.14.0-0  kubeadm-1.14.0-0 kubectl-1.14.0-0
[root@k8s1 ~]# systemctl start docker
[root@k8s1 ~]# mkdir -p /etc/docker/
[root@k8s1 ~]# cat >> /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://nw1puivx.mirror.aliyuncs.com"]	##可以自己在阿里云申请一个镜像加速器
}
```

**4.Service模型简单介绍：**
---
```
	userspace 	1.1-
		依赖于Iptables。
	iptables 	1.10-
	IP_vs 		1.10+
		需要添加专门的选项，如果没有则自动降级为Iptables。
		编辑Kubelet的配置文件/etc/sysconfig/kubelet
			KUBE_PROXY_MODE=ipvs	
```

**5.加载模块(如果不使用ipvs模式可掠过。)**
---
```
[root@master ~]# modprobe br_netfilter
#使用Ip_vs
	modprobe ip_vs
	modprobe ip_vs_rr
	modprobe ip_vs_wrr
	modprobe ip_vs_sh
	modprobe nf_conntrack_ipv4
	
##不为1代表没有装载好，请自己检查。
[root@k8s1 ~]# cat /proc/sys/net/bridge/bridge-nf-call-ip6tables 
1
[root@k8s1 ~]# cat /proc/sys/net/bridge/bridge-nf-call-iptables 
1
```

**6.设置Docker 代理(自己装镜像，可以省略下面步骤。)此处略过即可**
---
```
[root@k8s1 ~]# vim /usr/lib/systemd/system/docker.service 
Environment="HTTPS_PROXY=http://www.ik8s.io:10080"
Environment="NO_PROXY=127.0.0.0/8,192.168.100.0/24"
```
**7.生成配置文件检查**
---
```
[root@k8s1 ~]# rpm -ql kubelet
##清单目录 /etc/kubernetes/manifests
##配置文件 /etc/sysconfig/kubelet
##untli file /etc/systemd/system/kubelet.service
##主程序   /usr/bin/kubelet
```

**8.启动kubernetes的相关组件**
---
```
[root@k8s1 ~]# systemctl stop firewalld
[root@k8s1 ~]# systemctl disable firewalld
[root@k8s1 ~]# systemctl enable !$
[root@k8s1 ~]# systemctl status kubelet
[root@k8s1 ~]# systemctl start kubelet
[root@k8s1 ~]# systemctl enable docker
[root@k8s1 ~]# systemctl start !$
```
**9.初始化参数介绍**
---
```
[root@k8s1 ~]# kubeadm init --help

--apiserver-advertise-address string  ##自己的监听地址
--apiserver-bind-port int32	      ##监听端口，默认6443
--cert-dir string                     ##加载证书文件目录 
--config string			      ##加载配置文件
```
**10.禁用swap分区(Node,Master节点都要做)**
---
```
[root@k8s1 ~]# swapoff -a
[root@k8s1 ~]# sed -i "/swap/s/^/#/g"  /etc/fstab
[root@k8s1 ~]# sed -n '/swap/p' /etc/fstab
#/dev/mapper/centos-swap swap                    swap    defaults        0 0
[root@k8s1 ~]# vim /etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS="--fail-swap-on=false" ##swap开启时不让其出错
```

**11.提前将镜像下载到本地,下面几个镜像是必须的.**
---
```
##使用命令 kubeadm config images list 查看
	k8s.gcr.io/kube-proxy 
	k8s.gcr.io/kube-apiserver          
	k8s.gcr.io/kube-controller-manager   
	k8s.gcr.io/kube-scheduler           
	k8s.gcr.io/etcd       
	k8s.gcr.io/pause
	quay.io/coreos/flannel
[root@k8s1 ~]# for images in  $(kubeadm config images list |sed -nr "s#^k8s.*/(.*)#registry.cn-hangzhou.aliyuncs.com/google_containers/\1#p"); do docker pull $images; done
[root@k8s1 ~]# docker images | grep ^registry.cn-han | awk '{print "docker tag",$1":"$2,$1":"$2}' | sed -e 's/registry.cn-hangzhou.aliyuncs.com\/google_containers/k8s.gcr.io/2' | sh -x
[root@k8s1 ~]# docker images | grep ^registry.cn-han | awk '{print "docker rmi """$1""":"""$2}' | sh -x
[root@k8s1 ~]# kubeadm init --kubernetes-version=v1.14.0 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --ignore-preflight-errors=Swap 
```

**12.执行生成的以下命令，如果没有生成则表示初始化失败**
---
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

**13.将生成的以下命令保存，Node节点可以用它加入集群**
---
```
kubeadm join 192.168.65.60:6443 --token s0g7pn.qnnbjzhiwk74hidp \
    --discovery-token-ca-cert-hash sha256:298278ac5e27bfa51224a9a34eaf19aa24e89424c99f511fb77d03a118f1897b
过期后创建新的可参考：
	https://blog.csdn.net/mailjoin/article/details/79686934
	
在过期以后，下面的命令会自动重新生成一个token，并且产生一条命令。生成以后直接复制即可。	
kubeadm token create --print-join-command
    
##关于绑定网卡问题可以参考：
	https://k8smeetup.github.io/docs/reference/setup-tools/kubeadm/kubeadm-init
	
当运行 init 时，您必须保证指定一个内部 IP 作为 API server 的绑定地址，例如：(可以忽略)
	kubeadm init --apiserver-advertise-address=<private-master-ip>
	
当工作节点 Node 配置好后，添加一个指定工作 Node节点 私有的 IP 的参数到 /etc/systemd/system/kubelet.service.d/10-kubeadm.conf 中：(可以忽略)
	--node-ip=<private-node-ip>
	
##全部装载完成之后：
	会监听一个6443的端口
```

**14.配置Node节点**
---
```
[root@node1 ~]# yum -y install docker-ce-18.09.3 kubelet-1.14.0-0 kubeadm-1.14.0-0  //kubectl(可选_执行客户端程序)
[root@node1 ~]# systemctl enable kubelet
[root@node1 ~]# systemctl enable docker	
[root@node1 ~]# systemctl start  docker
[root@node1 ~]# cat >> /images <<EOF 
#k8s Node节点所镜像清单
k8s.gcr.io/kube-proxy
k8s.gcr.io/coredns
k8s.gcr.io/pause
EOF
[root@node1 ~]# for i in $(cat images |sed -nr "s#^k8s.*/(.*)#registry.cn-hangzhou.aliyuncs.com/google_containers/\1#p"); do docker pull $images; done
[root@node1 ~]#  docker images | grep registry.cn-hangzhou.aliyuncs.com/google_containers | awk '{print "docker tag",$1":"$2,$1":"$2}' | sed -e 's/registry.cn-hangzhou.aliyuncs.com\/google_containers/k8s.gcr.io/2' | sh -x
[root@node1 ~]#  docker images | grep registry.cn-hangzhou.aliyuncs.com/google_containers | awk '{print "docker rmi """$1""":"""$2}' | sh -x
[root@node1 docker]# kubeadm join 192.168.65.60:6443 --token s0g7pn.qnnbjzhiwk74hidp     --discovery-token-ca-cert-hash sha256:298278ac5e27bfa51224a9a34eaf19aa24e89424c99f511fb77d03a118f1897b	
```

**15.master上执行**
---
```
wget https://raw.githubusercontent.com/sunlge/kubernetes/k8s-1.14.0/program/kubernetes_install/kube-flannel.yml
kubectl apply -f kube-flannel.yml
根据以下说明对kube-flannel.yml文件进行修改：
	最好先将yml文件下载下来，之后在用apply去声明它。
	官网的地址：
		https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
	由于flannel使用默认路由的网卡接口，导致适用了外网网卡，致使pod之间无法访问。
	所以需要指定使用相应网卡。如果内网网卡为eth1，那么在command参数增加--iface=eth1即可，具体配置如下
	command:
        - /opt/bin/flanneld
        args:
        - --ip-masq
        - --kube-subnet-mgr
        - --iface=eth1
```
**16.Master执行命令，下面是Tab补全**
---
```
[root@k8s1 ~]# cat >> /root/.bashrc <<EOF
source <(kubeadm completion bash)
source <(kubectl completion bash)
EOF
##查看相关节点，已经是Ready状态
[root@k8s1 ~]# kubectl get nodes
NAME                STATUS   ROLES    AGE   VERSION
master.sunlge.com   Ready    master   75m   v1.14.0
node01.sunlge.com   Ready    <none>   42m   v1.14.0

```
