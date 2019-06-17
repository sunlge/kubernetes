####################
##    		  ##
##   k8s网络      ##
## 		  ##
##                ##
####################



kubernetes网络通信：
	1.容器间通信：同一个Pod内的多个容器间的通信，lo
	2.Pod通信：Pod IP <---> Pod IP
	3.Pod与service通信：PodIP <---> ClusterIP
	4.Service与集群外部客户端的通信；

CNI：
	flannel
	calico
	canel
	kube-router
	...
k8s当中支持网络插件(CNI)模式：
	kubelet启动时直接通过目录加载，/etc/cni/net.d/
	
